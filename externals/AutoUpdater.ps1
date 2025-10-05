# AutoUpdater.ps1
# Godot 4.4.1 项目自动更新脚本

param(
    [string]$Mirror = "",
    [string]$RepoOwner,
    [string]$RepoName,
    [string]$AssetName,
    [int]$TargetPID,
    [bool]$CreateTempScript = $true
)

# 错误处理函数
function Handle-Error {
    param([string]$ErrorMessage)
    Write-Host "错误: $ErrorMessage" -ForegroundColor Red
    exit 1
}

# 构建 GitHub API URL
function Get-GitHubApiUrl {
    param(
        [string]$Owner,
        [string]$Repo
    )
    
    if ([string]::IsNullOrEmpty($Mirror)) {
        return "https://api.github.com/repos/$Owner/$Repo/releases/latest"
    } else {
        # 处理镜像URL格式
        $mirrorUrl = $Mirror.TrimEnd('/')
        if ($mirrorUrl -like "*api.github.com*") {
            return "$mirrorUrl/repos/$Owner/$Repo/releases/latest"
        } else {
            return "$mirrorUrl/repos/$Owner/$Repo/releases/latest"
        }
    }
}

# 构建下载 URL
function Get-DownloadUrl {
    param([string]$OriginalUrl)
    
    if ([string]::IsNullOrEmpty($Mirror)) {
        return $OriginalUrl
    } else {
        $mirrorUrl = $Mirror.TrimEnd('/')
        
        # 如果是完整的 GitHub API 镜像
        if ($mirrorUrl -like "*api.github.com*") {
            # 将 api.github.com 替换为实际下载域名
            $downloadUrl = $OriginalUrl -replace "https://api\.github\.com", "https://github.com"
            $downloadUrl = $downloadUrl -replace "https://github\.com", $mirrorUrl -replace "api\.", ""
            return $downloadUrl
        }
        # 如果是通用镜像（如 ghproxy.com）
        elseif ($mirrorUrl -like "*ghproxy.com*") {
            return "$mirrorUrl/$OriginalUrl"
        }
        # 其他镜像服务
        else {
            # 尝试直接替换域名
            $uri = [System.Uri]$OriginalUrl
            $newUri = New-Object System.Uri($mirrorUrl)
            $builder = New-Object System.UriBuilder($OriginalUrl)
            $builder.Host = $newUri.Host
            $builder.Scheme = $newUri.Scheme
            if ($newUri.Port -ne -1) {
                $builder.Port = $newUri.Port
            }
            return $builder.ToString()
        }
    }
}

# 获取进程信息
function Get-ProcessInfo {
    param([int]$ProcessId)
    
    try {
        $process = Get-Process -Id $ProcessId -ErrorAction Stop
        $processPath = $process.Path
        $processDir = Split-Path $processPath -Parent
        
        return @{
            Path = $processPath
            Directory = $processDir
            Name = $process.ProcessName
        }
    }
    catch {
        Handle-Error "无法找到PID为 $ProcessId 的进程: $($_.Exception.Message)"
    }
}

# 结束进程
function Stop-TargetProcess {
    param([int]$ProcessId)
    
    try {
        Write-Host "正在结束进程 (PID: $ProcessId)..." -ForegroundColor Yellow
        # 等待进程正常结束，超时后强制结束
        $process = Get-Process -Id $ProcessId -ErrorAction SilentlyContinue
        if ($process) {
            $process.CloseMainWindow()
            Start-Sleep -Seconds 2
            if (!$process.HasExited) {
                Stop-Process -Id $ProcessId -Force
            }
        }
        Write-Host "进程已结束" -ForegroundColor Green
    }
    catch {
        Handle-Error "无法结束进程: $($_.Exception.Message)"
    }
}

# 获取GitHub最新Release信息
function Get-GitHubRelease {
    param(
        [string]$Owner,
        [string]$Repo
    )
    
    try {
        $releaseUrl = Get-GitHubApiUrl -Owner $Owner -Repo $Repo
        Write-Host "正在获取发布信息: $releaseUrl" -ForegroundColor Yellow
        
        $headers = @{
            'Accept' = 'application/vnd.github.v3+json'
            'User-Agent' = 'Godot-AutoUpdater'
        }
        
        # 添加镜像源特定的头部（如果需要）
        if (![string]::IsNullOrEmpty($Mirror)) {
            if ($Mirror -like "*ghproxy.com*") {
                $headers['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
            }
        }
        
        $response = Invoke-RestMethod -Uri $releaseUrl -Headers $headers -ErrorAction Stop
        
        # 处理镜像源的响应格式
        if ($response -and $response.assets) {
            return $response
        } else {
            Handle-Error "从镜像源获取的响应格式不正确"
        }
    }
    catch {
        if ($_.Exception.Response.StatusCode -eq 404) {
            Handle-Error "未找到仓库 $Owner/$Repo 或没有发布版本"
        } else {
            Handle-Error "无法获取GitHub发布信息: $($_.Exception.Message)"
        }
    }
}

# 下载资产文件
function Download-Asset {
    param(
        [string]$DownloadUrl,
        [string]$OutputPath
    )
    
    try {
        Write-Host "正在下载更新文件..." -ForegroundColor Yellow
        Write-Host "下载URL: $DownloadUrl" -ForegroundColor Gray
        Write-Host "保存路径: $OutputPath" -ForegroundColor Gray
        
        $progressPreference = 'SilentlyContinue'
        
        # 设置下载参数
        $webClient = New-Object System.Net.WebClient
        $webClient.Headers.Add('User-Agent', 'Godot-AutoUpdater/1.0')
        
        # 对于某些镜像源可能需要特殊的处理
        if ($DownloadUrl -like "*ghproxy.com*") {
            $webClient.Headers.Add('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36')
        }
        
        $webClient.DownloadFile($DownloadUrl, $OutputPath)
        $webClient.Dispose()
        
        $progressPreference = 'Continue'
        
        # 验证文件是否下载成功
        if (Test-Path $OutputPath) {
            $fileSize = (Get-Item $OutputPath).Length
            Write-Host "下载完成 - 文件大小: $([math]::Round($fileSize/1MB, 2)) MB" -ForegroundColor Green
        } else {
            Handle-Error "文件下载后未找到"
        }
    }
    catch {
        Handle-Error "下载失败: $($_.Exception.Message)"
    }
}

# 解压文件
function Extract-Archive {
    param(
        [string]$ArchivePath,
        [string]$ExtractPath
    )
    
    try {
        Write-Host "正在解压文件..." -ForegroundColor Yellow
        
        # 确保解压目录存在
        if (Test-Path $ExtractPath) {
            Remove-Item $ExtractPath -Recurse -Force
        }
        New-Item -ItemType Directory -Path $ExtractPath -Force | Out-Null
        
        # 解压文件
        Expand-Archive -Path $ArchivePath -DestinationPath $ExtractPath -Force
        
        Write-Host "解压完成" -ForegroundColor Green
        return $ExtractPath
    }
    catch {
        Handle-Error "解压失败: $($_.Exception.Message)"
    }
}

# 替换文件
function Replace-Files {
    param(
        [string]$SourceDir,
        [string]$TargetDir
    )
    
    try {
        Write-Host "正在替换文件..." -ForegroundColor Yellow
        
        # 确保目标目录存在
        if (!(Test-Path $TargetDir)) {
            New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
        }
        
        # 备份原始文件（可选）
        $backupDir = Join-Path $TargetDir "backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        if (Test-Path $TargetDir) {
            Write-Host "创建备份: $backupDir" -ForegroundColor Gray
            Copy-Item $TargetDir $backupDir -Recurse -Force -ErrorAction SilentlyContinue
        }
        
        # 复制所有文件和文件夹
        Get-ChildItem -Path $SourceDir | ForEach-Object {
            $relativePath = $_.Name
            $targetPath = Join-Path $TargetDir $relativePath
            
            if ($_.PSIsContainer) {
                # 如果是目录，递归复制
                if (Test-Path $targetPath) {
                    Remove-Item $targetPath -Recurse -Force
                }
                Copy-Item $_.FullName $targetPath -Recurse -Force
            } else {
                # 如果是文件，复制文件
                Copy-Item $_.FullName $targetPath -Force
            }
        }
        
        Write-Host "文件替换完成" -ForegroundColor Green
    }
    catch {
        Handle-Error "文件替换失败: $($_.Exception.Message)"
    }
}

# 启动应用程序
function Start-Application {
    param([string]$ExecutablePath)
    
    try {
        Write-Host "正在启动应用程序..." -ForegroundColor Yellow
        Start-Process -FilePath $ExecutablePath
        Write-Host "应用程序已启动" -ForegroundColor Green
    }
    catch {
        Handle-Error "无法启动应用程序: $($_.Exception.Message)"
    }
}

# 创建临时更新脚本
function Create-TempUpdateScript {
    param(
        [string]$ProcessDir,
        [string]$ProcessPath,
        [string]$DownloadUrl,
        [string]$TempDir
    )
    
    $tempScriptPath = Join-Path $env:TEMP "GodotUpdate_$(Get-Date -Format 'yyyyMMdd_HHmmss').ps1"
    
    $scriptContent = @"
# 临时更新脚本 - 自动生成
`$ErrorActionPreference = 'Stop'

try {
    Write-Host '正在执行更新操作...' -ForegroundColor Yellow
    
    # 下载文件
    `$zipPath = Join-Path `$env:TEMP 'update_package.zip'
    Write-Host '下载URL: $DownloadUrl' -ForegroundColor Gray
    
    `$webClient = New-Object System.Net.WebClient
    `$webClient.Headers.Add('User-Agent', 'Godot-AutoUpdater/1.0')
    `$webClient.DownloadFile('$DownloadUrl', `$zipPath)
    `$webClient.Dispose()
    
    # 验证下载
    if (!(Test-Path `$zipPath)) {
        throw '文件下载失败'
    }
    
    `$fileSize = (Get-Item `$zipPath).Length
    Write-Host "下载完成 - 文件大小: `$([math]::Round(`$fileSize/1MB, 2)) MB" -ForegroundColor Green
    
    # 解压文件
    `$extractPath = Join-Path `$env:TEMP 'update_extract'
    if (Test-Path `$extractPath) {
        Remove-Item `$extractPath -Recurse -Force
    }
    Expand-Archive -Path `$zipPath -DestinationPath `$extractPath -Force
    Write-Host '解压完成' -ForegroundColor Green
    
    # 替换文件
    Write-Host '正在替换文件...' -ForegroundColor Yellow
    `$sourceDir = `$extractPath
    `$targetDir = '$ProcessDir'
    
    # 复制所有内容
    Get-ChildItem -Path `$sourceDir | ForEach-Object {
        `$relativePath = `$_.Name
        `$targetPath = Join-Path `$targetDir `$relativePath
        
        if (`$_.PSIsContainer) {
            if (Test-Path `$targetPath) {
                Remove-Item `$targetPath -Recurse -Force
            }
            Copy-Item `$_.FullName `$targetPath -Recurse -Force
        } else {
            Copy-Item `$_.FullName `$targetPath -Force
        }
    }
    
    Write-Host '文件替换完成' -ForegroundColor Green
    
    # 清理临时文件
    Remove-Item `$zipPath -Force -ErrorAction SilentlyContinue
    Remove-Item `$extractPath -Recurse -Force -ErrorAction SilentlyContinue
    
    # 启动应用程序
    Write-Host '正在启动应用程序...' -ForegroundColor Yellow
    Start-Process -FilePath '$ProcessPath'
    Write-Host '应用程序已启动' -ForegroundColor Green
    
    Write-Host '更新完成!' -ForegroundColor Green
    
    # 删除自己
    Start-Sleep -Seconds 2
    Remove-Item '$tempScriptPath' -Force -ErrorAction SilentlyContinue
    
} catch {
    Write-Host "更新失败: `$(`$_.Exception.Message)" -ForegroundColor Red
    Read-Host "按回车键退出"
}
"@

    try {
        $scriptContent | Out-File -FilePath $tempScriptPath -Encoding UTF8
        Write-Host "已创建临时更新脚本: $tempScriptPath" -ForegroundColor Yellow
        return $tempScriptPath
    }
    catch {
        Handle-Error "无法创建临时脚本: $($_.Exception.Message)"
    }
}

# 主更新流程
function Start-UpdateProcess {
    Write-Host "=== Godot 项目自动更新 ===" -ForegroundColor Cyan
    Write-Host "仓库: $RepoOwner/$RepoName" -ForegroundColor White
    Write-Host "资产: $AssetName" -ForegroundColor White
    Write-Host "目标PID: $TargetPID" -ForegroundColor White
    if (![string]::IsNullOrEmpty($Mirror)) {
        Write-Host "镜像源: $Mirror" -ForegroundColor White
    }
    
    # 获取进程信息
    $processInfo = Get-ProcessInfo -ProcessId $TargetPID
    Write-Host "应用程序目录: $($processInfo.Directory)" -ForegroundColor Gray
    Write-Host "可执行文件: $($processInfo.Path)" -ForegroundColor Gray
    
    # 获取GitHub发布信息
    $release = Get-GitHubRelease -Owner $RepoOwner -Repo $RepoName
    
    # 查找匹配的资产
    $asset = $release.assets | Where-Object { $_.name -eq $AssetName }
    if (!$asset) {
        $availableAssets = ($release.assets | ForEach-Object { $_.name }) -join ", "
        Handle-Error "未找到名为 '$AssetName' 的资产文件。可用资产: $availableAssets"
    }
    
    Write-Host "找到最新版本: $($release.tag_name)" -ForegroundColor Green
    Write-Host "资产大小: $([math]::Round($asset.size/1MB, 2)) MB" -ForegroundColor Gray
    
    # 获取实际的下载URL（考虑镜像）
    $downloadUrl = Get-DownloadUrl -OriginalUrl $asset.browser_download_url
    Write-Host "实际下载URL: $downloadUrl" -ForegroundColor Gray
    
    if ($CreateTempScript) {
        # 使用临时脚本方式更新
        Write-Host "使用临时脚本进行更新..." -ForegroundColor Yellow
        
        # 结束目标进程
        Stop-TargetProcess -ProcessId $TargetPID
        
        # 创建临时更新脚本
        $tempScriptPath = Create-TempUpdateScript -ProcessDir $processInfo.Directory -ProcessPath $processInfo.Path -DownloadUrl $downloadUrl
        
        # 启动临时脚本
        Write-Host "启动临时更新脚本..." -ForegroundColor Yellow
        Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File `"$tempScriptPath`""
        
    } else {
        # 直接更新方式
        Write-Host "直接进行更新..." -ForegroundColor Yellow
        
        # 结束目标进程
        Stop-TargetProcess -ProcessId $TargetPID
        
        # 下载文件
        $tempDir = Join-Path $env:TEMP "GodotUpdate_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
        $zipPath = Join-Path $tempDir "update.zip"
        Download-Asset -DownloadUrl $downloadUrl -OutputPath $zipPath
        
        # 解压文件
        $extractPath = Join-Path $tempDir "extracted"
        Extract-Archive -ArchivePath $zipPath -ExtractPath $extractPath
        
        # 替换文件
        Replace-Files -SourceDir $extractPath -TargetDir $processInfo.Directory
        
        # 启动应用程序
        Start-Application -ExecutablePath $processInfo.Path
        
        # 清理临时文件
        Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "临时文件已清理" -ForegroundColor Green
    }
    
    Write-Host "更新流程完成!" -ForegroundColor Cyan
}

# 执行主函数
try {
    Start-UpdateProcess
}
catch {
    Handle-Error $_.Exception.Message
}