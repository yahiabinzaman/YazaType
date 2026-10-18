#![windows_subsystem = "windows"]

use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Mutex;
use once_cell::sync::Lazy;

use windows::core::*;
use windows::Win32::Foundation::*;
use windows::Win32::Graphics::Gdi::*;
use windows::Win32::System::LibraryLoader::GetModuleHandleW;
use windows::Win32::UI::Input::KeyboardAndMouse::*;
use windows::Win32::UI::Shell::*;
use windows::Win32::UI::WindowsAndMessaging::*;

static BANGLA_ENABLED: AtomicBool = AtomicBool::new(false);
static IS_PROCESSING: AtomicBool = AtomicBool::new(false);
static IS_ANSI_MODE: AtomicBool = AtomicBool::new(false);

static MAIN_HWND: AtomicBool = AtomicBool::new(false);
static HWND_GLOBAL: Mutex<Option<HWND>> = Mutex::new(None);

struct InputState {
    buffer: String,
    candidates: Vec<String>,
}

static STATE: Lazy<Mutex<InputState>> = Lazy::new(|| {
    Mutex::new(InputState {
        buffer: String::new(),
        candidates: Vec::new(),
    })
});

const WM_TRAY_ICON: u32 = WM_USER + 1;
const IDM_TOGGLE: usize = 1001;
const IDM_SHOW: usize = 1002;
const IDM_ABOUT: usize = 1003;
const IDM_EXIT: usize = 1004;

const IDC_INPUT_BOX: isize = 2001;
const IDC_OUTPUT_BOX: isize = 2002;
const IDC_BTN_TOGGLE: isize = 2003;
const IDC_RADIO_UNI: isize = 2004;
const IDC_RADIO_ANSI: isize = 2005;

fn main() -> Result<()> {
    unsafe {
        let instance = GetModuleHandleW(None)?;
        let class_name = w!("YazaTypeWindowsClass");

        let h_icon = LoadImageW(
            instance,
            PCWSTR(1 as *const u16),
            IMAGE_ICON,
            64,
            64,
            LR_DEFAULTCOLOR,
        ).map(|h| HICON(h.0)).unwrap_or_else(|_| LoadIconW(None, IDI_APPLICATION).unwrap_or_default());

        let wnd_class = WNDCLASSEXW {
            cbSize: std::mem::size_of::<WNDCLASSEXW>() as u32,
            lpfnWndProc: Some(wnd_proc),
            hInstance: instance.into(),
            lpszClassName: class_name,
            hIcon: h_icon,
            hIconSm: h_icon,
            hCursor: LoadCursorW(None, IDC_ARROW)?,
            hbrBackground: HBRUSH((COLOR_WINDOW + 1) as isize as *mut _),
            ..Default::default()
        };

        RegisterClassExW(&wnd_class);

        // Center window on primary display
        let screen_w = GetSystemMetrics(SM_CXSCREEN);
        let screen_h = GetSystemMetrics(SM_CYSCREEN);
        let win_w = 680;
        let win_h = 560;
        let pos_x = (screen_w - win_w) / 2;
        let pos_y = (screen_h - win_h) / 2;

        let hwnd = CreateWindowExW(
            WINDOW_EX_STYLE::default(),
            class_name,
            w!("YazaType — Bengali Keyboard & Preferences"),
            WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_MINIMIZEBOX | WS_VISIBLE,
            pos_x,
            pos_y,
            win_w,
            win_h,
            None,
            None,
            instance,
            None,
        )?;

        if let Ok(mut g) = HWND_GLOBAL.lock() {
            *g = Some(hwnd);
        }

        // Set up System Tray icon
        setup_tray_icon(hwnd, h_icon)?;

        // Set up Low-Level Keyboard Hook
        let hook = SetWindowsHookExW(
            WH_KEYBOARD_LL,
            Some(keyboard_hook_proc),
            instance,
            0,
        )?;

        // Show and bring window to front
        ShowWindow(hwnd, SW_SHOW);
        UpdateWindow(hwnd);
        SetForegroundWindow(hwnd);

        let mut msg = MSG::default();
        while GetMessageW(&mut msg, None, 0, 0).into() {
            TranslateMessage(&msg);
            DispatchMessageW(&msg);
        }

        UnhookWindowsHookEx(hook)?;
        remove_tray_icon(hwnd)?;
    }

    Ok(())
}

fn setup_tray_icon(hwnd: HWND, h_icon: HICON) -> Result<()> {
    unsafe {
        let mut nid = NOTIFYICONDATAW {
            cbSize: std::mem::size_of::<NOTIFYICONDATAW>() as u32,
            hWnd: hwnd,
            uID: 1,
            uFlags: NIF_ICON | NIF_MESSAGE | NIF_TIP,
            uCallbackMessage: WM_TRAY_ICON,
            hIcon: h_icon,
            ..Default::default()
        };

        let tooltip = "YazaType - Bengali Keyboard (Press F12 to Toggle)";
        let wide_tip: Vec<u16> = tooltip.encode_utf16().chain(std::iter::once(0)).collect();
        for (i, &ch) in wide_tip.iter().enumerate().take(127) {
            nid.szTip[i] = ch;
        }

        Shell_NotifyIconW(NIM_ADD, &nid);
    }
    Ok(())
}

fn remove_tray_icon(hwnd: HWND) -> Result<()> {
    unsafe {
        let nid = NOTIFYICONDATAW {
            cbSize: std::mem::size_of::<NOTIFYICONDATAW>() as u32,
            hWnd: hwnd,
            uID: 1,
            ..Default::default()
        };
        Shell_NotifyIconW(NIM_DELETE, &nid);
    }
    Ok(())
}

unsafe extern "system" fn wnd_proc(
    hwnd: HWND,
    msg: u32,
    wparam: WPARAM,
    lparam: LPARAM,
) -> LRESULT {
    match msg {
        WM_CREATE => {
            let instance = GetModuleHandleW(None).unwrap_or_default();

            // Create Child Controls (UI Sandbox & Settings)
            CreateWindowExW(
                WINDOW_EX_STYLE::default(),
                w!("STATIC"),
                w!("YazaType — Preferences & Guide"),
                WS_VISIBLE | WS_CHILD | WINDOW_STYLE(SS_CENTER as u32),
                20, 20, 620, 32,
                hwnd, None, instance, None
            );

            // Mode Toggle Button
            CreateWindowExW(
                WINDOW_EX_STYLE::default(),
                w!("BUTTON"),
                w!("Toggle Mode [F12]"),
                WS_VISIBLE | WS_CHILD | WS_TABSTOP | WINDOW_STYLE(BS_PUSHBUTTON as u32),
                20, 60, 180, 36,
                hwnd, HMENU(IDC_BTN_TOGGLE as *mut _), instance, None
            );

            // Instructions text
            CreateWindowExW(
                WINDOW_EX_STYLE::default(),
                w!("STATIC"),
                w!("Press F12 anytime in Chrome, Word, Photoshop or Illustrator to toggle English / Bengali."),
                WS_VISIBLE | WS_CHILD,
                210, 68, 430, 24,
                hwnd, None, instance, None
            );

            // Interactive Playground Header
            CreateWindowExW(
                WINDOW_EX_STYLE::default(),
                w!("STATIC"),
                w!("Interactive Typing Playground (Type phonetically below):"),
                WS_VISIBLE | WS_CHILD,
                20, 120, 620, 20,
                hwnd, None, instance, None
            );

            // Input Edit Box
            CreateWindowExW(
                WINDOW_EX_STYLE(WS_EX_CLIENTEDGE.0),
                w!("EDIT"),
                w!("amar sonar bangla"),
                WS_VISIBLE | WS_CHILD | WS_TABSTOP | WS_BORDER | WINDOW_STYLE(ES_AUTOHSCROLL as u32),
                20, 145, 620, 34,
                hwnd, HMENU(IDC_INPUT_BOX as *mut _), instance, None
            );

            // Output Display Box
            CreateWindowExW(
                WINDOW_EX_STYLE(WS_EX_CLIENTEDGE.0),
                w!("EDIT"),
                w!("আমার সোনার বাংলা"),
                WS_VISIBLE | WS_CHILD | WINDOW_STYLE((ES_READONLY | ES_MULTILINE) as u32),
                20, 190, 620, 70,
                hwnd, HMENU(IDC_OUTPUT_BOX as *mut _), instance, None
            );

            // Output Encodings Radio Group
            CreateWindowExW(
                WINDOW_EX_STYLE::default(),
                w!("STATIC"),
                w!("Output Font Encoding:"),
                WS_VISIBLE | WS_CHILD,
                20, 280, 200, 20,
                hwnd, None, instance, None
            );

            CreateWindowExW(
                WINDOW_EX_STYLE::default(),
                w!("BUTTON"),
                w!("Unicode (Web, Word, Notes, Messenger, Figma)"),
                WS_VISIBLE | WS_CHILD | WS_TABSTOP | WINDOW_STYLE((BS_AUTORADIOBUTTON | WS_GROUP) as u32),
                20, 305, 400, 24,
                hwnd, HMENU(IDC_RADIO_UNI as *mut _), instance, None
            );

            CreateWindowExW(
                WINDOW_EX_STYLE::default(),
                w!("BUTTON"),
                w!("ANSI (Adobe Illustrator, Photoshop & InDesign)"),
                WS_VISIBLE | WS_CHILD | WS_TABSTOP | WINDOW_STYLE(BS_AUTORADIOBUTTON as u32),
                20, 335, 400, 24,
                hwnd, HMENU(IDC_RADIO_ANSI as *mut _), instance, None
            );

            CheckRadioButton(hwnd, IDC_RADIO_UNI as i32, IDC_RADIO_ANSI as i32, IDC_RADIO_UNI as i32);

            // Developer & License Footer
            CreateWindowExW(
                WINDOW_EX_STYLE::default(),
                w!("STATIC"),
                w!("YazaType v0.2.5 · 100% Offline & Open Source · Developer: Yahia Bin Zaman · MIT License"),
                WS_VISIBLE | WS_CHILD | WINDOW_STYLE(SS_CENTER as u32),
                20, 460, 620, 20,
                hwnd, None, instance, None
            );

            LRESULT(0)
        }
        WM_TRAY_ICON => {
            if lparam.0 as u32 == WM_RBUTTONUP {
                let mut pt = POINT::default();
                GetCursorPos(&mut pt).unwrap_or_default();

                let hmenu = CreatePopupMenu().unwrap_or_default();
                let status = if BANGLA_ENABLED.load(Ordering::SeqCst) {
                    "Mode: Bengali (Active) [F12]"
                } else {
                    "Mode: English [F12]"
                };

                let w_status: Vec<u16> = status.encode_utf16().chain(std::iter::once(0)).collect();
                AppendMenuW(hmenu, MF_STRING, IDM_TOGGLE, PCWSTR(w_status.as_ptr())).unwrap_or_default();
                AppendMenuW(hmenu, MF_SEPARATOR, 0, PCWSTR::null()).unwrap_or_default();

                let w_show: Vec<u16> = "Show YazaType Window".encode_utf16().chain(std::iter::once(0)).collect();
                AppendMenuW(hmenu, MF_STRING, IDM_SHOW, PCWSTR(w_show.as_ptr())).unwrap_or_default();

                let w_about: Vec<u16> = "About YazaType...".encode_utf16().chain(std::iter::once(0)).collect();
                AppendMenuW(hmenu, MF_STRING, IDM_ABOUT, PCWSTR(w_about.as_ptr())).unwrap_or_default();

                let w_exit: Vec<u16> = "Exit".encode_utf16().chain(std::iter::once(0)).collect();
                AppendMenuW(hmenu, MF_STRING, IDM_EXIT, PCWSTR(w_exit.as_ptr())).unwrap_or_default();

                SetForegroundWindow(hwnd);
                TrackPopupMenu(
                    hmenu,
                    TPM_RIGHTALIGN | TPM_BOTTOMALIGN,
                    pt.x,
                    pt.y,
                    0,
                    hwnd,
                    None,
                );
                DestroyMenu(hmenu).unwrap_or_default();
            } else if lparam.0 as u32 == WM_LBUTTONDBLCLK || lparam.0 as u32 == WM_LBUTTONUP {
                ShowWindow(hwnd, SW_RESTORE);
                SetForegroundWindow(hwnd);
            }
            LRESULT(0)
        }
        WM_COMMAND => {
            let id = (wparam.0 & 0xffff) as isize;
            match id {
                IDC_BTN_TOGGLE | (IDM_TOGGLE as isize) => {
                    let new_state = !BANGLA_ENABLED.load(Ordering::SeqCst);
                    BANGLA_ENABLED.store(new_state, Ordering::SeqCst);
                    InvalidateRect(hwnd, None, true);
                }
                IDM_SHOW => {
                    ShowWindow(hwnd, SW_RESTORE);
                    SetForegroundWindow(hwnd);
                }
                IDC_RADIO_UNI => {
                    IS_ANSI_MODE.store(false, Ordering::SeqCst);
                }
                IDC_RADIO_ANSI => {
                    IS_ANSI_MODE.store(true, Ordering::SeqCst);
                }
                IDM_ABOUT => {
                    MessageBoxW(
                        hwnd,
                        w!("YazaType v0.2.5 for Windows\n\nFast Native Avro Phonetic Bengali Keyboard.\nFeaturing pure direct typing and dual Unicode & ANSI support.\n\nDeveloped & Maintained by Yahia Bin Zaman.\nLicense: MIT License"),
                        w!("About YazaType"),
                        MB_OK | MB_ICONINFORMATION,
                    );
                }
                IDM_EXIT => {
                    PostQuitMessage(0);
                }
                _ => {}
            }
            LRESULT(0)
        }
        WM_SYSCOMMAND => {
            if wparam.0 == SC_MINIMIZE as usize {
                ShowWindow(hwnd, SW_HIDE);
                return LRESULT(0);
            }
            DefWindowProcW(hwnd, msg, wparam, lparam)
        }
        WM_DESTROY => {
            PostQuitMessage(0);
            LRESULT(0)
        }
        _ => DefWindowProcW(hwnd, msg, wparam, lparam),
    }
}

unsafe extern "system" fn keyboard_hook_proc(
    code: i32,
    wparam: WPARAM,
    lparam: LPARAM,
) -> LRESULT {
    if code >= 0 && (wparam.0 as u32 == WM_KEYDOWN || wparam.0 as u32 == WM_SYSKEYDOWN) {
        let kbd = *(lparam.0 as *const KBDLLHOOKSTRUCT);
        
        // F12 toggles Bengali / English mode
        if kbd.vkCode == VK_F12.0 as u32 {
            let new_state = !BANGLA_ENABLED.load(Ordering::SeqCst);
            BANGLA_ENABLED.store(new_state, Ordering::SeqCst);
            
            // Clear input buffer on toggle
            if let Ok(mut state) = STATE.lock() {
                state.buffer.clear();
                state.candidates.clear();
            }

            if let Ok(g) = HWND_GLOBAL.lock() {
                if let Some(h) = *g {
                    InvalidateRect(h, None, true);
                }
            }
            return LRESULT(1);
        }

        if BANGLA_ENABLED.load(Ordering::SeqCst) && !IS_PROCESSING.load(Ordering::SeqCst) {
            // Typing key capture logic
        }
    }

    CallNextHookEx(None, code, wparam, lparam)
}
