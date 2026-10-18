# ==============================================================================
# YazaType - 1-Line Windows Automated Installer
# Developed & Maintained by Yahia Bin Zaman
# ==============================================================================

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host " ======================================================= " -ForegroundColor Green
Write-Host "   🌟 YazaType — Bengali Input Method for Windows        " -ForegroundColor Cyan
Write-Host "   Developed & Maintained by Yahia Bin Zaman            " -ForegroundColor Gray
Write-Host " ======================================================= " -ForegroundColor Green
Write-Host ""

$Repo = "yahiabinzaman/yazatype"
$InstallDir = "$env:LOCALAPPDATA\Programs\YazaType"
if (!(Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
}

$YazaTypeExe = Join-Path $InstallDir "YazaType.exe"

# Stop existing processes
Get-Process -Name "YazaType" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process -Name "Borno" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

Write-Host "[-] Fetching latest YazaType release for Windows..." -ForegroundColor Yellow

try {
    # Default direct asset URL
    $DownloadUrl = "https://raw.githubusercontent.com/$Repo/main/docs/YazaType.exe"

    # Dynamic asset detection if available from releases
    try {
        $ApiUrl = "https://api.github.com/repos/$Repo/releases/latest"
        $ReleaseData = Invoke-RestMethod -Uri $ApiUrl -Headers @{"User-Agent"="YazaType-Installer"}
        $Asset = $ReleaseData.assets | Where-Object { $_.name -like "*YazaType*.exe" } | Select-Object -First 1
        if ($Asset) {
            $DownloadUrl = $Asset.browser_download_url
        }
    } catch {
        # Fallback to direct URL
    }

    Write-Host "[-] Downloading YazaType ($DownloadUrl)..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $YazaTypeExe -UseBasicParsing

    # Unblock the downloaded executable to remove Windows SmartScreen Mark-of-the-Web
    try {
        Unblock-File -Path $YazaTypeExe -ErrorAction SilentlyContinue
    } catch {
        # Fallback
    }

    # Create Desktop and Startup shortcuts
    $WshShell = New-Object -ComObject WScript.Shell
    
    # Clean up old Borno shortcuts
    Remove-Item -Path "$env:USERPROFILE\Desktop\Borno.lnk" -ErrorAction SilentlyContinue
    $StartupFolder = [Environment]::GetFolderPath("Startup")
    Remove-Item -Path "$StartupFolder\Borno.lnk" -ErrorAction SilentlyContinue

    # Desktop Shortcut
    $DesktopShortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\YazaType.lnk")
    $DesktopShortcut.TargetPath = $YazaTypeExe
    $DesktopShortcut.Description = "YazaType Bengali Keyboard"
    $DesktopShortcut.Save()

    # Startup Shortcut (Auto-start)
    $StartupShortcut = $WshShell.CreateShortcut("$StartupFolder\YazaType.lnk")
    $StartupShortcut.TargetPath = $YazaTypeExe
    $StartupShortcut.Description = "YazaType Bengali Keyboard"
    $StartupShortcut.Save()

    Write-Host ""
    Write-Host "[✓] YazaType has been installed successfully to $InstallDir!" -ForegroundColor Green
    Write-Host "[✓] Press F12 anytime in any application to toggle English ⇋ Bengali." -ForegroundColor Green
    Write-Host ""

    # Launch YazaType
    Start-Process -FilePath $YazaTypeExe

} catch {
    Write-Host "[!] Installation failed: $_" -ForegroundColor Red
    Write-Host "[-] Please download YazaType.exe manually from: https://github.com/$Repo/releases" -ForegroundColor Yellow
}
