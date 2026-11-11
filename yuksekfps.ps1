# ==============================================================================
#  YUKSEK FPS - Windows Optimization Tool (Nihai / Final Sürüm)
# ==============================================================================

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoExit -NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$Host.UI.RawUI.WindowTitle = "YUKSEK FPS - Final Version"
$ProgressPreference = 'SilentlyContinue'

Clear-Host
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "  __   ___   _  ___ _____ _____ _  __   _____ ___  ____  " -ForegroundColor Green
Write-Host "  \ \ / / | | |/ገል/| ____| ____| |/ /  |  ___| _ \/ ___| " -ForegroundColor Green
Write-Host "   \ V /| | | | ' / |  _| |  _| | ' /   | |_  | |_) \___ \ " -ForegroundColor Green
Write-Host "    | | | |_| | . \ | |___| |___| . \   |  _| |  __/ ___) |" -ForegroundColor Green
Write-Host "    |_|  \___/|_|\_\|_____|_____|_|\_\  |_|   |_|   |____/ " -ForegroundColor Green
Write-Host "                                                           " -ForegroundColor Green
Write-Host "                   Optimizasyon by opcin                   " -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""

# Yardımcı Fonksiyon: Registry Ayarları
function Set-Reg {
    param($Path, $Name, $Value, $Type = "DWord")
    if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
    if ($Name -eq "(Default)" -or $Name -eq "(default)") {
        Set-ItemProperty -Path $Path -Name "(default)" -Value $Value -ErrorAction SilentlyContinue
    } else {
        Set-ItemProperty -Path $Path -Name $Name -Type $Type -Value $Value -ErrorAction SilentlyContinue
    }
}

# ------------------------------------------------------------------------------
# 1. TEMEL TWEAKLER & CTT GELİŞMİŞ SİSTEM AYARLARI
# ------------------------------------------------------------------------------
Write-Host ">>> [01/47] ADIM: Etkinlik Gecmisi Kapatiliyor..." -ForegroundColor Yellow
Set-Reg -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Value 0

Write-Host ">>> [02/47] ADIM: BitLocker Kontrol Ediliyor ve Otomatik Sifreleme Engelleniyor..." -ForegroundColor Yellow
try {
    if (Get-Command Get-BitLockerVolume -ErrorAction SilentlyContinue) {
        $bl = Get-BitLockerVolume -MountPoint "C:" -ErrorAction SilentlyContinue
        if ($bl -and $bl.VolumeStatus -ne "FullyDecrypted") { Disable-BitLocker -MountPoint "C:" -ErrorAction SilentlyContinue }
    }
    Set-Reg -Path "HKLM:\SYSTEM\CurrentControlSet\Control\BitLocker" -Name "PreventDeviceEncryption" -Value 1
} catch {}

Write-Host ">>> [03/47] ADIM: Tuketici Ozellikleri ve Reklamlar Kapatiliyor..." -ForegroundColor Yellow
Set-Reg -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Value 1
Set-Reg -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableConsumerAccountStateContent" -Value 1
Set-Reg -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableCloudOptimizedContent" -Value 1

Write-Host ">>> [04/47] ADIM: Teslim İyilestirme Kapatiliyor..." -ForegroundColor Yellow
Set-Reg -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" -Name "DODownloadMode" -Value 0

Write-Host ">>> [05/47] ADIM: Sag Tik Gorevi Sonlandir Ekleniyor..." -ForegroundColor Yellow
Set-Reg -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarEndTask" -Value 1

Write-Host ">>> [06/47] ADIM: Otomatik Klasor Kesfi Kapatiliyor..." -ForegroundColor Yellow
Set-Reg -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell" -Name "FolderType" -Type "String" -Value "NotSpecified"

Write-Host ">>> [07/47] ADIM: Konum Takibi Kapatiliyor..." -ForegroundColor Yellow
Set-Reg -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Type "String" -Value "Deny"

Write-Host ">>> [08/47] ADIM: MS Store ve Bing Arama Onerileri Kapatiliyor..." -ForegroundColor Yellow
Set-Reg -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Value 1
Set-Reg -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Value 1

Write-Host ">>> [09/47] ADIM: Sistem Geri Yukleme Noktasi Olusturuluyor..." -ForegroundColor Yellow
try {
    Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
    Set-Reg -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" -Name "SystemRestorePointCreationFrequency" -Value 0
    Checkpoint-Computer -Description "YuksekFPS_Final_RestorePoint" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue
} catch {}

Write-Host ">>> [10/47] ADIM: Gereksiz Hizmetler Elle Moduna Aliniyor..." -ForegroundColor Yellow
Set-Service -Name "RemoteRegistry" -StartupType Manual -ErrorAction SilentlyContinue
Set-Service -Name "MapsBroker" -StartupType Manual -ErrorAction SilentlyContinue

Write-Host ">>> [11/47] ADIM: Baslat Menusu Onerileri Kapatiliyor..." -ForegroundColor Yellow
Set-Reg -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_ShowRecommended" -Value 0

Write-Host ">>> [12/47] ADIM: Teleometri Hizmetleri Kapatiliyor..." -ForegroundColor Yellow
Stop-Service -Name "DiagTrack" -ErrorAction SilentlyContinue
Set-Service -Name "DiagTrack" -StartupType Disabled -ErrorAction SilentlyContinue
Stop-Service -Name "dmwappushservice" -ErrorAction SilentlyContinue
Set-Service -Name "dmwappushservice" -StartupType Disabled -ErrorAction SilentlyContinue

Write-Host ">>> [13/47] ADIM: Gecici Dosyalar Temizleniyor..." -ForegroundColor Yellow
Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ">>> [14/47] ADIM: Widget'lar Kaldiriliyor..." -ForegroundColor Yellow
Get-AppxPackage *WebExperience* | Remove-AppxPackage -ErrorAction SilentlyContinue

Write-Host ">>> [15/47] ADIM: WPBT (OEM Bloatware Injected BIOS) Kapatiliyor..." -ForegroundColor Yellow
Set-Reg -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name "DisableWPBT" -Value 1

Write-Host ">>> [16/47] ADIM: Ayrilmis Depolama (Reserved Storage) Kapatiliyor..." -ForegroundColor Yellow
Set-Reg -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager" -Name "ShippedWithReserves" -Value 0

# ------------------------------------------------------------------------------
# 2. GELİŞMİŞ SİSTEM VE PERFORMANS TWEAKLERİ
# ------------------------------------------------------------------------------
Write-Host ">>> [17/47] ADIM: Arka Plan Uygulamalari Kapatiliyor..." -ForegroundColor Yellow
Set-Reg -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Value 1

Write-Host ">>> [18/47] ADIM: IPv4 Öncelikli Hale Getiriliyor..." -ForegroundColor Yellow
Set-Reg -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" -Name "DisabledComponents" -Value 32

Write-Host ">>> [19/47] ADIM: Edge Arka Plan Hizmetleri Kapatiliyor..." -ForegroundColor Yellow
Set-Reg -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "StartupBoostEnabled" -Value 0
Set-Reg -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "HardwareAccelerationModeEnabled" -Value 0
Set-Reg -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "BackgroundModeEnabled" -Value 0
Set-Reg -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "HubsSidebarEnabled" -Value 0
Set-Service -Name "MicrosoftEdgeElevationService" -StartupType Disabled -ErrorAction SilentlyContinue
Set-Service -Name "edgeupdate" -StartupType Disabled -ErrorAction SilentlyContinue
Set-Service -Name "edgeupdatem" -StartupType Disabled -ErrorAction SilentlyContinue

Write-Host ">>> [20/47] ADIM: OneDrive Kaldiriliyor..." -ForegroundColor Yellow
Stop-Process -Name "OneDrive" -Force -ErrorAction SilentlyContinue
if (Test-Path "$env:SystemRoot\System32\OneDriveSetup.exe") {
    Start-Process "$env:SystemRoot\System32\OneDriveSetup.exe" -ArgumentList "/uninstall" -Wait
}

Write-Host ">>> [21/47] ADIM: Razer Otomatik Yukleme Engelleniyor..." -ForegroundColor Yellow
Set-Reg -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions" -Name "DenyDeviceIDs" -Value 1

Write-Host ">>> [22/47] ADIM: Eski Sag Tik Menusu Etkinlestiriliyor..." -ForegroundColor Yellow
Set-Reg -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34a9-4b08-ac74-0705a6e54656}\InprocServer32" -Name "(Default)" -Type "String" -Value ""

Write-Host ">>> [23/47] ADIM: Win32 Oncelik Ayarlari Yapilıyor..." -ForegroundColor Yellow
Set-Reg -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 38

Write-Host ">>> [24/47] ADIM: Windows Copilot Kapatiliyor..." -ForegroundColor Yellow
Set-Reg -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Value 1
Set-Reg -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Value 1

# ------------------------------------------------------------------------------
# 3. GÖREV ÇUBUĞU, BAŞLAT VE GEZGİN AYARLARI
# ------------------------------------------------------------------------------
Write-Host ">>> [25/47] ADIM: Gorev Cubugu Yapilandiriliyor..." -ForegroundColor Yellow
Set-Reg -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value 0
Set-Reg -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0
Set-Reg -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 0
Set-Reg -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" -Name "AllowNewsAndInterests" -Value 0

Write-Host ">>> [26/47] ADIM: Dosya Gezgini Ayarlari Yapiliyor..." -ForegroundColor Yellow
Set-Reg -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Value 1
Set-Reg -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0
Set-Reg -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Type "String" -Value "0"
Set-Reg -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1

Write-Host ">>> [27/47] ADIM: Koyu Tema Ayarlaniyor..." -ForegroundColor Yellow
Set-Reg -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0
Set-Reg -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0
Set-Reg -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 0

# ------------------------------------------------------------------------------
# 4. GAMING, GRAPHICS, PRIVACY & NETWORK TWEAKS
# ------------------------------------------------------------------------------
Write-Host ">>> [28/47] ADIM: Ses İyilestirmeleri Yapiliyor..." -ForegroundColor Yellow
Set-Reg -Path "HKCU:\Software\Microsoft\Multimedia\Audio" -Name "UserDuckingPreference" -Value 3
Set-Reg -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation" -Name "DisableStartupSound" -Value 1

Write-Host ">>> [29/47] ADIM: Fare Ivmesi Kapatiliyor..." -ForegroundColor Yellow
Set-Reg -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Type "String" -Value "0"
Set-Reg -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Type "String" -Value "0"
Set-Reg -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Type "String" -Value "0"

Write-Host ">>> [30/47] ADIM: Oyun Optimizasyonlari (GameDVR Off, HAGS ON)..." -ForegroundColor Yellow
Set-Reg -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0
Set-Reg -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Value 0
Set-Reg -Path "HKCU:\Software\Microsoft\GameBar" -Name "AutoGameModeEnabled" -Value 1

Set-Reg -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Value 4294967295
Set-Reg -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value 0
Set-Reg -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "GPU Priority" -Value 8
Set-Reg -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "Priority" -Value 6
Set-Reg -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "Scheduling Category" -Type "String" -Value "High"

# GPU Hardware-Accelerated GPU Scheduling (HAGS) & Timer
Set-Reg -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 2
Set-Reg -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" -Name "GlobalTimerResolutionRequests" -Value 1

Write-Host ">>> [31/47] ADIM: Multiplane Overlay (MPO) Kapatiliyor (Compatibility Mode)..." -ForegroundColor Yellow
Set-Reg -Path "HKLM:\SOFTWARE\Microsoft\Windows\Dwm" -Name "OverlayTestMode" -Value 5

Write-Host ">>> [32/47] ADIM: Ağ Gecikmesi Dusuruyor (Nagle Algoritmasi Kapatiliyor)..." -ForegroundColor Yellow
$netInterfaces = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
foreach ($interface in $netInterfaces) {
    Set-Reg -Path $interface.PSPath -Name "TcpAckFrequency" -Value 1
    Set-Reg -Path $interface.PSPath -Name "TCPNoDelay" -Value 1
}

Write-Host ">>> [33/47] ADIM: Gizlilik Sikilastirmalari Yapiliyor..." -ForegroundColor Yellow
$consentPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore"
$denyStores = @("userNotificationListener","userAccountInformation","contacts","appointments","phoneCall","phoneCallHistory","email","chat","radios","appDiagnostics")
foreach ($store in $denyStores) { Set-Reg -Path "$consentPath\$store" -Name "Value" -Type "String" -Value "Deny" }

Set-Reg -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Value 0
Set-Reg -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" -Name "SearchOrderConfig" -Value 0

# ------------------------------------------------------------------------------
# 5. POWER PLAN & PERFORMANCE ENGINE
# ------------------------------------------------------------------------------
Write-Host ">>> [34/47] ADIM: YUKSEKFPS opcin Guc Plani Etkinlestiriliyor..." -ForegroundColor Yellow
$pGuid = "99999999-9999-9999-9999-999999999999"
cmd /c "powercfg /duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 $pGuid >nul 2>&1"
cmd /c "powercfg /changename $pGuid `"YUKSEKFPS opcin`" >nul 2>&1"
cmd /c "powercfg /SETACTIVE $pGuid >nul 2>&1"

Write-Host ">>> [35/47] ADIM: Uyku ve Guc Kısıtlamalari Kapatiliyor..." -ForegroundColor Yellow
powercfg /hibernate off
Set-Reg -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power" -Name "HibernateEnabled" -Value 0
Set-Reg -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" -Name "PowerThrottlingOff" -Value 1

Write-Host ">>> [36/47] ADIM: USB Guc Tasarrufu Kapatiliyor..." -ForegroundColor Yellow
Set-Reg -Path "HKLM:\System\ControlSet001\Control\Power\PowerSettings\2a737441-1930-4402-8d77-b2bebba308a3\0853a681-27c8-4100-a2fd-82013e970683" -Name "Attributes" -Value 0
powercfg /setacvalueindex $pGuid 2a737441-1930-4402-8d77-b2bebba308a3 0853a681-27c8-4100-a2fd-82013e970683 0x00000000 2>$null

Write-Host ">>> [37/47] ADIM: Islemci Cekirdek Parki Kapatiliyor (%100 Güc)..." -ForegroundColor Yellow
powercfg /setacvalueindex $pGuid 54533251-82be-4824-96c1-47b60b740d00 893dee8e-2bef-41e0-89c6-b55d0929964c 0x00000064 2>$null
powercfg /setacvalueindex $pGuid 54533251-82be-4824-96c1-47b60b740d00 bc5038f7-23e0-4960-96da-33abaf5935ec 0x00000064 2>$null

Write-Host ">>> [38/47] ADIM: Ekran Kartı Guc Performansi Maksimuma Aliniyor..." -ForegroundColor Yellow
powercfg /setacvalueindex $pGuid 44f3beca-a7c0-460e-9df2-bb8b99e0cba6 3619c3f2-afb2-4afc-b0e9-e7fef372de36 002 2>$null

# ------------------------------------------------------------------------------
# 6. OFFICIAL RUNTIMES, NVIDIA SETTINGS & APPLICATIONS VIA WINGET
# ------------------------------------------------------------------------------
if (Test-Connection -ComputerName "8.8.8.8" -Count 1 -Quiet -ErrorAction SilentlyContinue) {
    Write-Host ">>> [39/47] ADIM: 7-Zip Yukleniyor..." -ForegroundColor Yellow
    winget install --id 7zip.7zip --silent --accept-package-agreements --accept-source-agreements

    Write-Host ">>> [40/47] ADIM: DirectX Yukleniyor..." -ForegroundColor Yellow
    winget install --id Microsoft.DirectX --silent --accept-package-agreements --accept-source-agreements

    Write-Host ">>> [41/47] ADIM: Visual C++ (x64) Yukleniyor..." -ForegroundColor Yellow
    winget install --id Microsoft.VCRedist.2015+.x64 --silent --accept-package-agreements --accept-source-agreements

    Write-Host ">>> [42/47] ADIM: Visual C++ (x86) Yukleniyor..." -ForegroundColor Yellow
    winget install --id Microsoft.VCRedist.2015+.x86 --silent --accept-package-agreements --accept-source-agreements

    Write-Host ">>> [43/47] ADIM: Nvidia Control Panel Yukleniyor..." -ForegroundColor Yellow
    winget install --id 9NF8H658275A --silent --accept-package-agreements --accept-source-agreements

    Write-Host ">>> [44/47] ADIM: Onerilen NVIDIA FPS Ayarlari Uygulaniyor..." -ForegroundColor Yellow
    try {
        # Unblock Drs files
        $drsPath = "C:\ProgramData\NVIDIA Corporation\Drs"
        if (Test-Path $drsPath) { Get-ChildItem -Path $drsPath -Recurse | Unblock-File -ErrorAction SilentlyContinue }

        # Registry tweaks for PhysX, Developer Tools, Tray Icon, and Legacy Sharpening
        Set-Reg -Path "HKLM:\SYSTEM\ControlSet001\Services\nvlddmkm\Parameters\Global\NVTweak" -Name "NvCplPhysxAuto" -Value 0
        Set-Reg -Path "HKLM:\SYSTEM\ControlSet001\Services\nvlddmkm\Parameters\Global\NVTweak" -Name "NvDevToolsVisible" -Value 1
        Set-Reg -Path "HKCU:\Software\NVIDIA Corporation\NvTray" -Name "StartOnLogin" -Value 0
        Set-Reg -Path "HKLM:\SYSTEM\CurrentControlSet\Services\nvlddmkm\FTS" -Name "EnableGR535" -Value 0
        Set-Reg -Path "HKLM:\SYSTEM\ControlSet001\Services\nvlddmkm\Parameters\FTS" -Name "EnableGR535" -Value 0

        # Create Directory and Download Nvidia Profile Inspector
        $inspectorDir = "$env:SystemDrive\Program Files (x86)\Nvidia Profile Inspector"
        New-Item -Path $inspectorDir -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
        Invoke-WebRequest "https://github.com/FR33THYFR33THY/Ultimate/releases/download/Files/inspector.exe" -OutFile "$inspectorDir\Nvidia Profile Inspector.exe" -ErrorAction SilentlyContinue

        # Create Desktop & Start Menu Shortcuts
        $WshShell = New-Object -ComObject WScript.Shell
        $Desktop = (New-Object -ComObject Shell.Application).Namespace('shell:Desktop').Self.Path
        $ShortcutDesktop = $WshShell.CreateShortcut("$Desktop\Nvidia Profile Inspector.lnk")
        $ShortcutDesktop.TargetPath = "$inspectorDir\Nvidia Profile Inspector.exe"
        $ShortcutDesktop.WorkingDirectory = $inspectorDir
        $ShortcutDesktop.Save()

        $ShortcutStart = $WshShell.CreateShortcut("$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Nvidia Profile Inspector.lnk")
        $ShortcutStart.TargetPath = "$inspectorDir\Nvidia Profile Inspector.exe"
        $ShortcutStart.WorkingDirectory = $inspectorDir
        $ShortcutStart.Save()

        # Create and Import Recommended NIP Configuration File
        $nipfile = @'
<?xml version="1.0" encoding="utf-16"?>
<ArrayOfProfile>
  <Profile>
    <ProfileName>Base Profile</ProfileName>
    <Executables/>
    <Settings>
      <ProfileSetting><SettingNameInfo>Frame Rate Limiter V3</SettingNameInfo><SettingID>277041154</SettingID><SettingValue>0</SettingValue><ValueType>Dword</ValueType></ProfileSetting>
      <ProfileSetting><SettingNameInfo>GSYNC - Application Mode</SettingNameInfo><SettingID>294973784</SettingID><SettingValue>0</SettingValue><ValueType>Dword</ValueType></ProfileSetting>
      <ProfileSetting><SettingNameInfo>GSYNC - Application State</SettingNameInfo><SettingID>279476687</SettingID><SettingValue>4</SettingValue><ValueType>Dword</ValueType></ProfileSetting>
      <ProfileSetting><SettingNameInfo>GSYNC - Global Feature</SettingNameInfo><SettingID>278196567</SettingID><SettingValue>0</SettingValue><ValueType>Dword</ValueType></ProfileSetting>
      <ProfileSetting><SettingNameInfo>GSYNC - Global Mode</SettingNameInfo><SettingID>278196727</SettingID><SettingValue>0</SettingValue><ValueType>Dword</ValueType></ProfileSetting>
      <ProfileSetting><SettingNameInfo>GSYNC - Indicator Overlay</SettingNameInfo><SettingID>268604728</SettingID><SettingValue>0</SettingValue><ValueType>Dword</ValueType></ProfileSetting>
      <ProfileSetting><SettingNameInfo>Maximum Pre-Rendered Frames</SettingNameInfo><SettingID>8102046</SettingID><SettingValue>1</SettingValue><ValueType>Dword</ValueType></ProfileSetting>
      <ProfileSetting><SettingNameInfo>Preferred Refresh Rate</SettingNameInfo><SettingID>6600001</SettingID><SettingValue>1</SettingValue><ValueType>Dword</ValueType></ProfileSetting>
      <ProfileSetting><SettingNameInfo>Ultra Low Latency - CPL State</SettingNameInfo><SettingID>390467</SettingID><SettingValue>2</SettingValue><ValueType>Dword</ValueType></ProfileSetting>
      <ProfileSetting><SettingNameInfo>Ultra Low Latency - Enabled</SettingNameInfo><SettingID>277041152</SettingID><SettingValue>1</SettingValue><ValueType>Dword</ValueType></ProfileSetting>
      <ProfileSetting><SettingNameInfo>Vertical Sync</SettingNameInfo><SettingID>11041231</SettingID><SettingValue>138504007</SettingValue><ValueType>Dword</ValueType></ProfileSetting>
      <ProfileSetting><SettingNameInfo>Vertical Sync - Smooth AFR Behavior</SettingNameInfo><SettingID>270198627</SettingID><SettingValue>0</SettingValue><ValueType>Dword</ValueType></ProfileSetting>
      <ProfileSetting><SettingNameInfo>Vertical Sync - Tear Control</SettingNameInfo><SettingID>5912412</SettingID><SettingValue>2525368439</SettingValue><ValueType>Dword</ValueType></ProfileSetting>
      <ProfileSetting><SettingNameInfo>Power Management - Mode</SettingNameInfo><SettingID>274197361</SettingID><SettingValue>1</SettingValue><ValueType>Dword</ValueType></ProfileSetting>
      <ProfileSetting><SettingNameInfo>Shader Cache - Cache Size</SettingNameInfo><SettingID>11306135</SettingID><SettingValue>4294967295</SettingValue><ValueType>Dword</ValueType></ProfileSetting>
      <ProfileSetting><SettingNameInfo>Threaded Optimization</SettingNameInfo><SettingID>549528094</SettingID><SettingValue>1</SettingValue><ValueType>Dword</ValueType></ProfileSetting>
    </Settings>
  </Profile>
</ArrayOfProfile>
'@
        Set-Content -Path "$env:SystemRoot\Temp\inspector.nip" -Value $nipfile -Force
        Start-Process -Wait "$inspectorDir\Nvidia Profile Inspector.exe" -ArgumentList "-silentImport -silent $env:SystemRoot\Temp\inspector.nip" -ErrorAction SilentlyContinue
    } catch {}
} else {
    Write-Host "[HATA] Internet Baglantisi Bulunamadi!" -ForegroundColor Red
}

Write-Host ">>> [46/47] ADIM: Gecici Klasorler Temizleniyor..." -ForegroundColor Yellow
Remove-Item -Path "$env:SystemRoot\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ">>> [47/47] ADIM: Disk Temizleme Calistiriliyor..." -ForegroundColor Yellow
Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches" -ErrorAction SilentlyContinue | ForEach-Object {
    Set-ItemProperty -Path $_.PSPath -Name "StateFlags0001" -Type DWord -Value 2 -ErrorAction SilentlyContinue
}
Start-Process cleanmgr.exe -ArgumentList "/sagerun:1" -NoNewWindow -Wait -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "==================================================================" -ForegroundColor Green
Write-Host "    YUKSEK FPS OPTIMIZASYONU BASARIYLA TAMAMLANDI!              " -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Green
Write-Host "                         Optimizasyon by opcin                    " -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Degisikliklerin tam etkili olmasi icin bilgisayari yeniden baslatin." -ForegroundColor Cyan
Write-Host "Pencereyi kapatmak icin Enter tusuna basin..." -ForegroundColor Yellow
Read-Host
