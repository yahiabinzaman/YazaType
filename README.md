# YazaType — Bengali Keyboard for macOS & Windows

[![macOS](https://img.shields.io/badge/macOS-13.0%2B-black?logo=apple&logoColor=white)](https://github.com/yahiabinzaman/yazatype)
[![Windows](https://img.shields.io/badge/Windows-10%2F11-0078D6?logo=windows&logoColor=white)](https://github.com/yahiabinzaman/yazatype)
[![Apple Silicon](https://img.shields.io/badge/Apple%20Silicon-Universal%20Binary-blue)](https://github.com/yahiabinzaman/yazatype)
[![Output](https://img.shields.io/badge/Encoding-Unicode%20%2B%20ANSI-purple)](https://github.com/yahiabinzaman/yazatype)
[![Privacy](https://img.shields.io/badge/Privacy-100%25%20Offline-success)](https://github.com/yahiabinzaman/yazatype)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**YazaType** is a fast, minimal, native Bengali input method built for **macOS** and **Windows**. Designed for maximum typing speed, pure direct typing with zero floating popup disruption, and seamless dual-encoding support across **Unicode** and **ANSI** for professional graphic design in Adobe Illustrator, Photoshop, InDesign, Figma, MS Office, and all modern applications.

**বাংলা লিখুন, নিজের মতো।** Built by Yahia Bin Zaman.

[Website](https://yahiabinzaman.github.io/yazatype/) · [বাংলা](https://yahiabinzaman.github.io/yazatype/bn/) · [Unicode / ANSI converter](https://yahiabinzaman.github.io/yazatype/converter.html)

---

## ✨ Key Features

- 🚀 **Pure Direct Typing**: Characters stream directly into your active cursor without flickering popup overlays or lag.
- 🎨 **Dual Encoding Engine**:
  - **Unicode Mode**: Standard Bengali for Web, Chrome, Word, Notes, Messenger, Figma, and modern Unicode fonts (*Kalpurush, SolaimanLipi, Bornomala, Noto Sans*).
  - **ANSI Mode**: Real-time conversion to ANSI characters for **Adobe Illustrator, Photoshop, InDesign, and print publishing**. Automatically reorders pre-vowel signs (`ে`, `ি`, `ৈ`, `ো`, `ৌ`), Reph (`র্`), and complex Bengali conjuncts (যুক্তবর্ণ).
- ⌨️ **Multiple Keyboard Layouts**:
  - **YazaType (Phonetic)**: Intuitive Avro-compatible phonetic transliteration (`ami` → `আমি`, `bangla` → `বাংলা`).
  - **National / Bijoy (জাতীয়)**: Standard Bangladesh National (Bijoy) layout (`Av` → `আ`, `g` → `ম`, `h` → `ব`, `j` → `ক`).
  - **Probhat (প্রভাত)**: Classic Probhat fixed keyboard layout.
- ⚡️ **Native Performance**: Powered by a sub-millisecond Rust engine core (`riti`) paired with native macOS Swift IME and Windows Win32 integration.
- 🔒 **100% Offline & Private**: Zero network calls, zero telemetry or analytics. All processing occurs strictly on your device.

---

## ⚡️ Quick Install (1-Line Terminal Commands)

### 🍎 For macOS:
Open **Terminal** (`Command + Space` → search `Terminal`), paste this command and press **Return**:
```bash
curl -fsSL https://raw.githubusercontent.com/yahiabinzaman/yazatype/main/scripts/install.sh | bash
```
> Or download the pre-packaged **[YazaType.dmg](https://raw.githubusercontent.com/yahiabinzaman/yazatype/main/docs/YazaType.dmg)**.

---

### 🪟 For Windows:
Open **PowerShell** or **Windows Terminal**, paste this command and press **Enter**:
```powershell
irm https://raw.githubusercontent.com/yahiabinzaman/yazatype/main/scripts/install.ps1 | iex
```
> Or download the standalone **[YazaType-Setup-0.2.5.exe](https://github.com/yahiabinzaman/yazatype/releases)** installer.

---

## 🖥️ First-Time Setup

### 🍎 macOS:
1. Open **System Settings** → **Keyboard** → **Input Sources** (Click *Edit...*).
2. Click **`+`** (Add), search for **`YazaType`**, select it and click **Add**.
3. Toggle between English and YazaType using **`Control + Space`** or the **Globe (🌐)** key.

### 🪟 Windows:
1. YazaType runs automatically in the **System Tray** (near the taskbar clock).
2. Press **`F12`** anytime to toggle between **English ⇋ Bengali** mode.
3. Type in phonetic Avro or your selected layout across any Windows application.

---

## 🎨 How to Use ANSI Mode in Adobe Illustrator & Photoshop

YazaType allows you to type directly in ANSI without needing third-party converters or external copy-pasting:

1. **Switch Output Encoding to ANSI**:
   - In the macOS Menu Bar (or YazaType Settings), switch **Output Encoding** to **ANSI**.
2. **Select ANSI Font**:
   - In Adobe Illustrator, Photoshop, or InDesign, select your ANSI font in the Character panel.
3. **Type Naturally**:
   - Type using your preferred layout (Phonetic or National / Bijoy).
   - YazaType automatically handles all vowel sign reordering (আ-কার, ই-কার, এ-কার, ও-কার), Reph (`র্`), and conjuncts (যেমন: ক্ষ, জ্ঞ, ষ্ণ, ক্ত, ন্ত) in real-time.

---

## ⌨️ Typing Cheat-Sheet & Special Keys

| Key / Sequence | Bengali Output | Note |
| :--- | :---: | :--- |
| `a` / `i` / `u` / `e` / `o` | আ / ই / উ / এ / ও | Primary Vowels |
| `kkh` | ক্ষ | ক + ষ |
| `jng` | জ্ঞ | জ + ঞ |
| `..` | । | Bengali Dari (দাঁড়ি) |
| `$$` | ৳ | Taka Symbol |
| `,,` | ্ | Explicit Hasanta |
| `k-s` | কস্ | Joiner Break (`-`) |
| `w` or `v` | ব-ফলা | যেমন: `kw` → `ক্ব` |
| `y` or `Z` | য-ফলা | যেমন: `ky` → `ক্য` |
| `r` | র-ফলা | যেমন: `kr` → `ক্র` |
| `rr` | রেফ | যেমন: `rrk` → `র্ক` |

---

## 🛠️ Building from Source

### macOS:
```bash
git clone https://github.com/yahiabinzaman/yazatype.git
cd yazatype
make build
make install
```

### Windows:
```bash
git clone https://github.com/yahiabinzaman/yazatype.git
cd yazatype/windows
cargo build --release
```

---

## 👤 Credits & Author

- **Developer & Maintainer**: [Yahia Bin Zaman](https://github.com/yahiabinzaman)
- **Repository**: [https://github.com/yahiabinzaman/yazatype](https://github.com/yahiabinzaman/yazatype)
- **License**: [MIT License](LICENSE)
