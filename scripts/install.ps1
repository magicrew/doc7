[CmdletBinding()]
param(
    [string]$Version = $env:DOC7_VERSION,
    [string]$InstallDir = $env:DOC7_INSTALL_DIR,
    [string]$Repository = $env:DOC7_REPOSITORY
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Stop-Install {
    param([string]$Message)

    throw "doc7 installer: $Message"
}

function Get-RequestHeaders {
    $headers = @{
        Accept = "application/vnd.github+json"
        "User-Agent" = "doc7-installer"
    }

    if (-not [string]::IsNullOrWhiteSpace($env:GITHUB_TOKEN)) {
        $headers.Authorization = "Bearer $($env:GITHUB_TOKEN)"
    }

    return $headers
}

function Test-ChineseInstallLanguage {
    $preference = if (-not [string]::IsNullOrWhiteSpace($env:DOC7_LANG)) {
        $env:DOC7_LANG
    }
    else {
        [Globalization.CultureInfo]::CurrentUICulture.Name
    }

    return $preference -match '^zh(?:[-_]|$)'
}

$useChinese = Test-ChineseInstallLanguage

if ($env:OS -ne "Windows_NT") {
    Stop-Install "this installer supports Windows only"
}

if ([string]::IsNullOrWhiteSpace($Repository)) {
    $Repository = "magicrew/doc7"
}

if ($Repository -notmatch '^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$') {
    Stop-Install "invalid GitHub repository: $Repository"
}

if ([string]::IsNullOrWhiteSpace($InstallDir)) {
    if (-not [string]::IsNullOrWhiteSpace($env:LOCALAPPDATA)) {
        $InstallDir = Join-Path $env:LOCALAPPDATA "Programs\doc7"
    }
    else {
        $InstallDir = Join-Path $HOME "AppData\Local\Programs\doc7"
    }
}

$nativeArchitecture = if (-not [string]::IsNullOrWhiteSpace($env:PROCESSOR_ARCHITEW6432)) {
    $env:PROCESSOR_ARCHITEW6432
}
else {
    $env:PROCESSOR_ARCHITECTURE
}

if ([string]::IsNullOrWhiteSpace($nativeArchitecture)) {
    Stop-Install "could not detect the Windows architecture"
}

$Architecture = switch -Regex ($nativeArchitecture) {
    '^(AMD64|x86_64)$' { "amd64"; break }
    '^(ARM64|AARCH64)$' { "arm64"; break }
    default { Stop-Install "supported architectures are x86_64 and arm64" }
}

[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

$headers = Get-RequestHeaders
if ([string]::IsNullOrWhiteSpace($Version)) {
    $releaseRequest = @{
        Uri = "https://api.github.com/repos/$Repository/releases/latest"
        Headers = $headers
    }
    $release = Invoke-RestMethod @releaseRequest
    $Version = [string]$release.tag_name
}

if ($Version -notmatch '^[A-Za-z0-9._-]+$') {
    Stop-Install "invalid release version: $Version"
}

$packageName = "doc7_${Version}_windows_${Architecture}"
$assetName = "$packageName.zip"
$releaseUrl = "https://github.com/$Repository/releases/download/$Version"
$tempDir = Join-Path ([IO.Path]::GetTempPath()) ("doc7-install-" + [Guid]::NewGuid().ToString("N"))
$archivePath = Join-Path $tempDir $assetName
$checksumsPath = Join-Path $tempDir "checksums.txt"
$extractDir = Join-Path $tempDir "extract"

try {
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

    if ($useChinese) {
        Write-Host "正在下载 doc7 $Version（Windows/$Architecture）……"
    }
    else {
        Write-Host "Downloading doc7 $Version for Windows/$Architecture..."
    }
    $archiveRequest = @{
        Uri = "$releaseUrl/$assetName"
        Headers = $headers
        OutFile = $archivePath
        UseBasicParsing = $true
    }
    Invoke-WebRequest @archiveRequest

    $checksumsRequest = @{
        Uri = "$releaseUrl/checksums.txt"
        Headers = $headers
        OutFile = $checksumsPath
        UseBasicParsing = $true
    }
    Invoke-WebRequest @checksumsRequest

    $escapedAssetName = [Regex]::Escape($assetName)
    $checksumPattern = '^([0-9A-Fa-f]{64})\s+\*?(?:\./)?{0}$' -f $escapedAssetName
    [string]$expectedChecksum = ""

    foreach ($line in Get-Content -LiteralPath $checksumsPath) {
        if ($line -match $checksumPattern) {
            $expectedChecksum = $Matches[1].ToLowerInvariant()
            break
        }
    }

    if ([string]::IsNullOrWhiteSpace($expectedChecksum)) {
        Stop-Install "release checksums do not contain $assetName"
    }

    $actualChecksum = (Get-FileHash -LiteralPath $archivePath -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actualChecksum -ne $expectedChecksum) {
        Stop-Install "checksum verification failed"
    }

    Expand-Archive -LiteralPath $archivePath -DestinationPath $extractDir -Force
    $packageDir = Join-Path $extractDir $packageName
    $executablePath = Join-Path $packageDir "doc7.exe"
    $licensePath = Join-Path $packageDir "LICENSE"

    if (-not (Test-Path -LiteralPath $executablePath -PathType Leaf)) {
        Stop-Install "release archive does not contain doc7.exe"
    }
    if (-not (Test-Path -LiteralPath $licensePath -PathType Leaf)) {
        Stop-Install "release archive does not contain LICENSE"
    }

    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    Get-ChildItem -LiteralPath $packageDir -Force | ForEach-Object {
        Copy-Item -LiteralPath $_.FullName -Destination $InstallDir -Recurse -Force
    }

    $normalizedInstallDir = [IO.Path]::GetFullPath($InstallDir).TrimEnd('\')
    [string]$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $pathEntries = @($userPath -split ';' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    $pathContainsInstallDir = $false

    foreach ($entry in $pathEntries) {
        if ([string]::Equals($entry.TrimEnd('\'), $normalizedInstallDir, [StringComparison]::OrdinalIgnoreCase)) {
            $pathContainsInstallDir = $true
            break
        }
    }

    if (-not $pathContainsInstallDir) {
        $newUserPath = if ([string]::IsNullOrWhiteSpace($userPath)) {
            $normalizedInstallDir
        }
        else {
            "$userPath;$normalizedInstallDir"
        }
        [Environment]::SetEnvironmentVariable("Path", $newUserPath, "User")
    }

    $env:Path = "$normalizedInstallDir;$($env:Path)"
    $installedExecutable = Join-Path $normalizedInstallDir "doc7.exe"
    & $installedExecutable version | Out-Null

    if ($useChinese) {
        Write-Host "doc7 已安装：$installedExecutable"
        Write-Host ""
        Write-Host "安装完成。下面是 doc7 的使用说明："
        Write-Host ""
    }
    else {
        Write-Host "Installed executable: $installedExecutable"
        Write-Host ""
        Write-Host "Installation complete. Here is how to use doc7:"
        Write-Host ""
    }

    & $installedExecutable
}
finally {
    if (Test-Path -LiteralPath $tempDir) {
        Remove-Item -LiteralPath $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
