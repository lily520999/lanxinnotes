# 兰心运营笔记网站同步脚本
# 此脚本用于将网站文件同步到本地文件夹或上传到网站服务器

param (
    [Parameter(Mandatory=$false)]
    [string]$LocalDestination = "D:\网站备份\lxyybj2",
    
    [Parameter(Mandatory=$false)]
    [string]$FtpServer = "ftp.example.com",
    
    [Parameter(Mandatory=$false)]
    [string]$FtpUsername = "username",
    
    [Parameter(Mandatory=$false)]
    [string]$FtpPassword = "password",
    
    [Parameter(Mandatory=$false)]
    [string]$FtpRemoteDir = "/public_html/",
    
    [Parameter(Mandatory=$false)]
    [switch]$SyncLocal = $true,
    
    [Parameter(Mandatory=$false)]
    [switch]$SyncFtp = $false
)

# 显示脚本信息
Write-Host "=========================================="
Write-Host "   兰心运营笔记网站文件同步工具 v1.0"
Write-Host "=========================================="
Write-Host ""

# 确认操作
Write-Host "当前工作目录: $PWD"
Write-Host ""

if ($SyncLocal) {
    Write-Host "将同步文件到本地目录: $LocalDestination"
}

if ($SyncFtp) {
    Write-Host "将上传文件到FTP服务器: $FtpServer"
    Write-Host "远程目录: $FtpRemoteDir"
}

Write-Host ""
$confirmation = Read-Host "确认执行同步操作? (Y/N)"
if ($confirmation -ne 'Y' -and $confirmation -ne 'y') {
    Write-Host "操作已取消。" -ForegroundColor Yellow
    exit
}

# 检查WinSCP是否安装
function Test-WinSCP {
    try {
        $winscp = Get-Command WinSCP -ErrorAction Stop
        Write-Host "WinSCP已安装。" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "错误: WinSCP未安装，请先安装WinSCP。" -ForegroundColor Red
        return $false
    }
}

# 本地同步函数
function Sync-Local {
    param(
        [string]$Source,
        [string]$Destination
    )
    
    Write-Host "开始本地同步..." -ForegroundColor Cyan
    Write-Host "源目录: $Source"
    Write-Host "目标目录: $Destination"
    
    if (-not (Test-Path $Source)) {
        Write-Host "错误: 源目录不存在！" -ForegroundColor Red
        return $false
    }
    
    if (-not (Test-Path $Destination)) {
        Write-Host "创建目标目录..." -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $Destination -Force
    }
    
    Write-Host "正在同步文件..." -ForegroundColor Yellow
    # 使用Robocopy进行同步
    robocopy $Source $Destination /MIR /R:3 /W:5 /NP /NDL /NFL
    
    if ($LASTEXITCODE -le 7) {
        Write-Host "本地同步完成！" -ForegroundColor Green
        return $true
    }
    else {
        Write-Host "本地同步过程中出现错误，请检查日志。" -ForegroundColor Red
        return $false
    }
}

# FTP同步函数
function Sync-Ftp {
    param(
        [string]$Source,
        [string]$FtpServer,
        [string]$FtpUsername,
        [string]$FtpPassword,
        [string]$FtpRemoteDir
    )
    
    Write-Host "开始FTP同步..." -ForegroundColor Cyan
    
    if (-not (Test-WinSCP)) {
        Write-Host "请先安装WinSCP，或手动使用FTP客户端上传文件。" -ForegroundColor Red
        return $false
    }
    
    try {
        # 创建WinSCP会话选项
        $sessionOptions = New-Object WinSCP.SessionOptions
        $sessionOptions.Protocol = [WinSCP.Protocol]::Ftp
        $sessionOptions.HostName = $FtpServer
        $sessionOptions.UserName = $FtpUsername
        $sessionOptions.Password = $FtpPassword
        
        # 创建会话
        $session = New-Object WinSCP.Session
        
        Write-Host "正在连接到FTP服务器..." -ForegroundColor Yellow
        $session.Open($sessionOptions)
        
        Write-Host "正在同步文件..." -ForegroundColor Yellow
        $session.SynchronizeDirectories(
            [WinSCP.SynchronizationMode]::Remote,
            $Source,
            $FtpRemoteDir,
            $false
        )
        
        Write-Host "FTP同步完成！" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "FTP同步失败: $_" -ForegroundColor Red
        return $false
    }
    finally {
        if ($session) {
            $session.Dispose()
        }
    }
}

# 主程序
try {
    $currentDir = $PWD.Path
    
    if ($SyncLocal) {
        $localResult = Sync-Local -Source $currentDir -Destination $LocalDestination
        if (-not $localResult) {
            Write-Host "本地同步失败，请检查错误信息。" -ForegroundColor Red
        }
    }
    
    if ($SyncFtp) {
        $ftpResult = Sync-Ftp -Source $currentDir -FtpServer $FtpServer -FtpUsername $FtpUsername -FtpPassword $FtpPassword -FtpRemoteDir $FtpRemoteDir
        if (-not $ftpResult) {
            Write-Host "FTP同步失败，请检查错误信息。" -ForegroundColor Red
        }
    }
    
    Write-Host "`n同步操作完成！" -ForegroundColor Green
}
catch {
    Write-Host "发生错误: $_" -ForegroundColor Red
    exit 1
}

Write-Host "==========================================" 