# ====== 淇敼姝よ鏁板瓧鍗冲彲鏀瑰彉鍒嗚韩鏁伴噺 ======
$count = 10
# =========================================

Write-Host "========== Chrome 鍒嗚韩鍒涘缓鑴氭湰 ==========" -ForegroundColor Cyan
Write-Host "褰撳墠閰嶇疆锛氬垱寤?$count 涓垎韬玚n" -ForegroundColor Yellow

# 1. 鏌ユ壘 Chrome 瀹夎璺緞
Write-Host "[1/4] 姝ｅ湪鏌ユ壘 Chrome 璺緞..." -ForegroundColor White
$chromePaths = @(
    "${env:ProgramFiles}\Google\Chrome\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
    "${env:LOCALAPPDATA}\Google\Chrome\Application\chrome.exe"
)

$chromeExe = $null
foreach ($p in $chromePaths) {
    if (Test-Path $p) { $chromeExe = $p; break }
}

if (-not $chromeExe) {
    try {
        $chromeExe = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe" -ErrorAction Stop).'(default)'
    } catch {
        try {
            $chromeExe = (Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe" -ErrorAction Stop).'(default)'
        } catch {}
    }
}

if (-not $chromeExe -or -not (Test-Path $chromeExe)) {
    Write-Host "閿欒锛氭湭鎵惧埌 Chrome 瀹夎锛岃纭繚宸插畨瑁?Chrome 娴忚鍣ㄣ€? -ForegroundColor Red
    Write-Host "鎸変换鎰忛敭閫€鍑?.." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}
Write-Host "  鎵惧埌: $chromeExe" -ForegroundColor Green

# 2. 纭畾鏁版嵁瀛樺偍鐩橈紙浼樺厛 D 鐩橈級
Write-Host "[2/4] 姝ｅ湪纭鏁版嵁瀛樻斁浣嶇疆..." -ForegroundColor White
if (Test-Path "D:\") {
    $dataRoot = "D:\ChromeProfiles"
} elseif (Test-Path "E:\") {
    $dataRoot = "E:\ChromeProfiles"
} else {
    $dataRoot = "$env:USERPROFILE\ChromeProfiles"
}
Write-Host "  鏁版嵁鐩綍: $dataRoot" -ForegroundColor Green
New-Item -ItemType Directory -Path $dataRoot -Force | Out-Null

# 3. 妗岄潰"娴忚鍣ㄥ垎韬?鏂囦欢澶?Write-Host "[3/4] 姝ｅ湪鍒涘缓妗岄潰蹇嵎鏂瑰紡..." -ForegroundColor White
$desktopDir = "$([Environment]::GetFolderPath('Desktop'))\娴忚鍣ㄥ垎韬?
New-Item -ItemType Directory -Path $desktopDir -Force | Out-Null

# 4. 鍒涘缓 WScript.Shell 瀵硅薄鐢熸垚 .lnk 蹇嵎鏂瑰紡
$wshShell = New-Object -ComObject WScript.Shell
$created = 0

for ($i = 1; $i -le $count; $i++) {
    $profileDir = Join-Path $dataRoot "Profile_$i"
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null

    $shortcutPath = Join-Path $desktopDir "鍒嗚韩 $i.lnk"
    $lnk = $wshShell.CreateShortcut($shortcutPath)
    $lnk.TargetPath = $chromeExe
    $lnk.Arguments = "--user-data-dir=`"$profileDir`" --new-window"
    $lnk.WorkingDirectory = Split-Path $chromeExe -Parent
    $lnk.IconLocation = "$chromeExe,$i"
    $lnk.Save()
    $created++
}

Write-Host "[4/4] 瀹屾垚锛? -ForegroundColor White
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " 宸插垱寤?$created 涓?Chrome 鍒嗚韩" -ForegroundColor Green
Write-Host " 蹇嵎鏂瑰紡浣嶇疆: $desktopDir" -ForegroundColor Green
Write-Host " 鏁版嵁瀛樻斁浣嶇疆: $dataRoot" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "`n鎸変换鎰忛敭閫€鍑?.." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
