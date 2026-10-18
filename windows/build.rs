fn main() {
    if std::env::var("CARGO_CFG_TARGET_OS").unwrap_or_default() == "windows" {
        let mut res = winres::WindowsResource::new();
        res.set_icon("resources/yazatype.ico");
        res.set("ProductName", "YazaType Bengali Keyboard");
        res.set("FileDescription", "YazaType Native Bengali Input Method");
        res.set("CompanyName", "Yahia Bin Zaman");
        res.set("LegalCopyright", "Copyright © 2026 Yahia Bin Zaman");
        res.set("FileVersion", "0.2.5.0");
        res.set("ProductVersion", "0.2.5.0");
        if let Err(e) = res.compile() {
            eprintln!("Warning: Failed to compile Windows resource: {}", e);
        }
    }
}
