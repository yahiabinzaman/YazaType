# 🪟 YazaType for Windows

**YazaType** is a fast, native Avro Phonetic Bengali input method for Windows 10 & 11.

---

## 📥 Installation Guide for Windows (ইনস্টলেশন নির্দেশিকা)

### ধাপ ১: ডাউনলোড (Download)
1. GitHub Release পেইজ থেকে **`YazaType-Setup-0.2.5.exe`** বা পোর্টেবল **`YazaType.exe`** ডাউনলোড করুন।
   - ডাউনলোড লিংক: [YazaType GitHub Releases](https://github.com/yahiabinzaman/yazatype/releases)

### ধাপ ২: ইনস্টল (Install)
1. ডাউনলোড করা `YazaType-Setup-0.2.5.exe` ফাইলে ডাবল-ক্লিক করুন।
2. যদি Windows SmartScreen সতর্কতা দেখায়, তবে **"More info"**-এ ক্লিক করে **"Run anyway"** দিন।
3. ইনস্টলেশন উইজার্ডে **"Next"** ক্লিক করে ইনস্টল সম্পন্ন করুন।

### ধাপ ৩: ব্যবহার শুরু (How to Use)
1. ইনস্টল শেষে YazaType স্বয়ংক্রিয়ভাবে ব্যাকগ্রাউন্ডে চালু হবে এবং টাস্কবারের **System Tray (ঘড়ির পাশে)** সবুজ রঙের আইকন দেখা যাবে।
2. কীবোর্ডের **`F12`** কি চাপলেই তাৎক্ষণিকভাবে **English ⇋ Bengali** মোড পরিবর্তন হবে।
3. যেকোনো সফটওয়্যারে (MS Word, Excel, Chrome, Notepad, Photoshop ইত্যাদি) অভ্র ফোনেটিক নিয়মে (যেমন `ami` = `আমি`) টাইপ করতে থাকুন!

---

## 🛠️ Building from Source (ডেভেলপারদের জন্য)

### Prerequisites:
- Rust (stable): `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`
- Inno Setup 6 (for creating the setup installer): `choco install innosetup`

### Build Command:
```bash
cd windows
cargo build --release
```
