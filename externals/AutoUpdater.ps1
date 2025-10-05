# AutoUpdater.ps1
# Godot 4.4.1 ��Ŀ�Զ����½ű�

param(
    [string]$Mirror = "",
    [string]$RepoOwner,
    [string]$RepoName,
    [string]$AssetName,
    [int]$TargetPID,
    [bool]$CreateTempScript = $true
)

# ��������
function Handle-Error {
    param([string]$ErrorMessage)
    Write-Host "����: $ErrorMessage" -ForegroundColor Red
    exit 1
}

# ���� GitHub API URL
function Get-GitHubApiUrl {
    param(
        [string]$Owner,
        [string]$Repo
    )
    
    if ([string]::IsNullOrEmpty($Mirror)) {
        return "https://api.github.com/repos/$Owner/$Repo/releases/latest"
    } else {
        # ������URL��ʽ
        $mirrorUrl = $Mirror.TrimEnd('/')
        if ($mirrorUrl -like "*api.github.com*") {
            return "$mirrorUrl/repos/$Owner/$Repo/releases/latest"
        } else {
            return "$mirrorUrl/repos/$Owner/$Repo/releases/latest"
        }
    }
}

# �������� URL
function Get-DownloadUrl {
    param([string]$OriginalUrl)
    
    if ([string]::IsNullOrEmpty($Mirror)) {
        return $OriginalUrl
    } else {
        $mirrorUrl = $Mirror.TrimEnd('/')
        
        # ����������� GitHub API ����
        if ($mirrorUrl -like "*api.github.com*") {
            # �� api.github.com �滻Ϊʵ����������
            $downloadUrl = $OriginalUrl -replace "https://api\.github\.com", "https://github.com"
            $downloadUrl = $downloadUrl -replace "https://github\.com", $mirrorUrl -replace "api\.", ""
            return $downloadUrl
        }
        # �����ͨ�þ����� ghproxy.com��
        elseif ($mirrorUrl -like "*ghproxy.com*") {
            return "$mirrorUrl/$OriginalUrl"
        }
        # �����������
        else {
            # ����ֱ���滻����
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

# ��ȡ������Ϣ
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
        Handle-Error "�޷��ҵ�PIDΪ $ProcessId �Ľ���: $($_.Exception.Message)"
    }
}

# ��������
function Stop-TargetProcess {
    param([int]$ProcessId)
    
    try {
        Write-Host "���ڽ������� (PID: $ProcessId)..." -ForegroundColor Yellow
        # �ȴ�����������������ʱ��ǿ�ƽ���
        $process = Get-Process -Id $ProcessId -ErrorAction SilentlyContinue
        if ($process) {
            $process.CloseMainWindow()
            Start-Sleep -Seconds 2
            if (!$process.HasExited) {
                Stop-Process -Id $ProcessId -Force
            }
        }
        Write-Host "�����ѽ���" -ForegroundColor Green
    }
    catch {
        Handle-Error "�޷���������: $($_.Exception.Message)"
    }
}

# ��ȡGitHub����Release��Ϣ
function Get-GitHubRelease {
    param(
        [string]$Owner,
        [string]$Repo
    )
    
    try {
        $releaseUrl = Get-GitHubApiUrl -Owner $Owner -Repo $Repo
        Write-Host "���ڻ�ȡ������Ϣ: $releaseUrl" -ForegroundColor Yellow
        
        $headers = @{
            'Accept' = 'application/vnd.github.v3+json'
            'User-Agent' = 'Godot-AutoUpdater'
        }
        
        # ��Ӿ���Դ�ض���ͷ���������Ҫ��
        if (![string]::IsNullOrEmpty($Mirror)) {
            if ($Mirror -like "*ghproxy.com*") {
                $headers['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
            }
        }
        
        $response = Invoke-RestMethod -Uri $releaseUrl -Headers $headers -ErrorAction Stop
        
        # ������Դ����Ӧ��ʽ
        if ($response -and $response.assets) {
            return $response
        } else {
            Handle-Error "�Ӿ���Դ��ȡ����Ӧ��ʽ����ȷ"
        }
    }
    catch {
        if ($_.Exception.Response.StatusCode -eq 404) {
            Handle-Error "δ�ҵ��ֿ� $Owner/$Repo ��û�з����汾"
        } else {
            Handle-Error "�޷���ȡGitHub������Ϣ: $($_.Exception.Message)"
        }
    }
}

# �����ʲ��ļ�
function Download-Asset {
    param(
        [string]$DownloadUrl,
        [string]$OutputPath
    )
    
    try {
        Write-Host "�������ظ����ļ�..." -ForegroundColor Yellow
        Write-Host "����URL: $DownloadUrl" -ForegroundColor Gray
        Write-Host "����·��: $OutputPath" -ForegroundColor Gray
        
        $progressPreference = 'SilentlyContinue'
        
        # �������ز���
        $webClient = New-Object System.Net.WebClient
        $webClient.Headers.Add('User-Agent', 'Godot-AutoUpdater/1.0')
        
        # ����ĳЩ����Դ������Ҫ����Ĵ���
        if ($DownloadUrl -like "*ghproxy.com*") {
            $webClient.Headers.Add('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36')
        }
        
        $webClient.DownloadFile($DownloadUrl, $OutputPath)
        $webClient.Dispose()
        
        $progressPreference = 'Continue'
        
        # ��֤�ļ��Ƿ����سɹ�
        if (Test-Path $OutputPath) {
            $fileSize = (Get-Item $OutputPath).Length
            Write-Host "������� - �ļ���С: $([math]::Round($fileSize/1MB, 2)) MB" -ForegroundColor Green
        } else {
            Handle-Error "�ļ����غ�δ�ҵ�"
        }
    }
    catch {
        Handle-Error "����ʧ��: $($_.Exception.Message)"
    }
}

# ��ѹ�ļ�
function Extract-Archive {
    param(
        [string]$ArchivePath,
        [string]$ExtractPath
    )
    
    try {
        Write-Host "���ڽ�ѹ�ļ�..." -ForegroundColor Yellow
        
        # ȷ����ѹĿ¼����
        if (Test-Path $ExtractPath) {
            Remove-Item $ExtractPath -Recurse -Force
        }
        New-Item -ItemType Directory -Path $ExtractPath -Force | Out-Null
        
        # ��ѹ�ļ�
        Expand-Archive -Path $ArchivePath -DestinationPath $ExtractPath -Force
        
        Write-Host "��ѹ���" -ForegroundColor Green
        return $ExtractPath
    }
    catch {
        Handle-Error "��ѹʧ��: $($_.Exception.Message)"
    }
}

# �滻�ļ�
function Replace-Files {
    param(
        [string]$SourceDir,
        [string]$TargetDir
    )
    
    try {
        Write-Host "�����滻�ļ�..." -ForegroundColor Yellow
        
        # ȷ��Ŀ��Ŀ¼����
        if (!(Test-Path $TargetDir)) {
            New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
        }
        
        # ����ԭʼ�ļ�����ѡ��
        $backupDir = Join-Path $TargetDir "backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        if (Test-Path $TargetDir) {
            Write-Host "��������: $backupDir" -ForegroundColor Gray
            Copy-Item $TargetDir $backupDir -Recurse -Force -ErrorAction SilentlyContinue
        }
        
        # ���������ļ����ļ���
        Get-ChildItem -Path $SourceDir | ForEach-Object {
            $relativePath = $_.Name
            $targetPath = Join-Path $TargetDir $relativePath
            
            if ($_.PSIsContainer) {
                # �����Ŀ¼���ݹ鸴��
                if (Test-Path $targetPath) {
                    Remove-Item $targetPath -Recurse -Force
                }
                Copy-Item $_.FullName $targetPath -Recurse -Force
            } else {
                # ������ļ��������ļ�
                Copy-Item $_.FullName $targetPath -Force
            }
        }
        
        Write-Host "�ļ��滻���" -ForegroundColor Green
    }
    catch {
        Handle-Error "�ļ��滻ʧ��: $($_.Exception.Message)"
    }
}

# ����Ӧ�ó���
function Start-Application {
    param([string]$ExecutablePath)
    
    try {
        Write-Host "��������Ӧ�ó���..." -ForegroundColor Yellow
        Start-Process -FilePath $ExecutablePath
        Write-Host "Ӧ�ó���������" -ForegroundColor Green
    }
    catch {
        Handle-Error "�޷�����Ӧ�ó���: $($_.Exception.Message)"
    }
}

# ������ʱ���½ű�
function Create-TempUpdateScript {
    param(
        [string]$ProcessDir,
        [string]$ProcessPath,
        [string]$DownloadUrl,
        [string]$TempDir
    )
    
    $tempScriptPath = Join-Path $env:TEMP "GodotUpdate_$(Get-Date -Format 'yyyyMMdd_HHmmss').ps1"
    
    $scriptContent = @"
# ��ʱ���½ű� - �Զ�����
`$ErrorActionPreference = 'Stop'

try {
    Write-Host '����ִ�и��²���...' -ForegroundColor Yellow
    
    # �����ļ�
    `$zipPath = Join-Path `$env:TEMP 'update_package.zip'
    Write-Host '����URL: $DownloadUrl' -ForegroundColor Gray
    
    `$webClient = New-Object System.Net.WebClient
    `$webClient.Headers.Add('User-Agent', 'Godot-AutoUpdater/1.0')
    `$webClient.DownloadFile('$DownloadUrl', `$zipPath)
    `$webClient.Dispose()
    
    # ��֤����
    if (!(Test-Path `$zipPath)) {
        throw '�ļ�����ʧ��'
    }
    
    `$fileSize = (Get-Item `$zipPath).Length
    Write-Host "������� - �ļ���С: `$([math]::Round(`$fileSize/1MB, 2)) MB" -ForegroundColor Green
    
    # ��ѹ�ļ�
    `$extractPath = Join-Path `$env:TEMP 'update_extract'
    if (Test-Path `$extractPath) {
        Remove-Item `$extractPath -Recurse -Force
    }
    Expand-Archive -Path `$zipPath -DestinationPath `$extractPath -Force
    Write-Host '��ѹ���' -ForegroundColor Green
    
    # �滻�ļ�
    Write-Host '�����滻�ļ�...' -ForegroundColor Yellow
    `$sourceDir = `$extractPath
    `$targetDir = '$ProcessDir'
    
    # ������������
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
    
    Write-Host '�ļ��滻���' -ForegroundColor Green
    
    # ������ʱ�ļ�
    Remove-Item `$zipPath -Force -ErrorAction SilentlyContinue
    Remove-Item `$extractPath -Recurse -Force -ErrorAction SilentlyContinue
    
    # ����Ӧ�ó���
    Write-Host '��������Ӧ�ó���...' -ForegroundColor Yellow
    Start-Process -FilePath '$ProcessPath'
    Write-Host 'Ӧ�ó���������' -ForegroundColor Green
    
    Write-Host '�������!' -ForegroundColor Green
    
    # ɾ���Լ�
    Start-Sleep -Seconds 2
    Remove-Item '$tempScriptPath' -Force -ErrorAction SilentlyContinue
    
} catch {
    Write-Host "����ʧ��: `$(`$_.Exception.Message)" -ForegroundColor Red
    Read-Host "���س����˳�"
}
"@

    try {
        $scriptContent | Out-File -FilePath $tempScriptPath -Encoding UTF8
        Write-Host "�Ѵ�����ʱ���½ű�: $tempScriptPath" -ForegroundColor Yellow
        return $tempScriptPath
    }
    catch {
        Handle-Error "�޷�������ʱ�ű�: $($_.Exception.Message)"
    }
}

# ����������
function Start-UpdateProcess {
    Write-Host "=== Godot ��Ŀ�Զ����� ===" -ForegroundColor Cyan
    Write-Host "�ֿ�: $RepoOwner/$RepoName" -ForegroundColor White
    Write-Host "�ʲ�: $AssetName" -ForegroundColor White
    Write-Host "Ŀ��PID: $TargetPID" -ForegroundColor White
    if (![string]::IsNullOrEmpty($Mirror)) {
        Write-Host "����Դ: $Mirror" -ForegroundColor White
    }
    
    # ��ȡ������Ϣ
    $processInfo = Get-ProcessInfo -ProcessId $TargetPID
    Write-Host "Ӧ�ó���Ŀ¼: $($processInfo.Directory)" -ForegroundColor Gray
    Write-Host "��ִ���ļ�: $($processInfo.Path)" -ForegroundColor Gray
    
    # ��ȡGitHub������Ϣ
    $release = Get-GitHubRelease -Owner $RepoOwner -Repo $RepoName
    
    # ����ƥ����ʲ�
    $asset = $release.assets | Where-Object { $_.name -eq $AssetName }
    if (!$asset) {
        $availableAssets = ($release.assets | ForEach-Object { $_.name }) -join ", "
        Handle-Error "δ�ҵ���Ϊ '$AssetName' ���ʲ��ļ��������ʲ�: $availableAssets"
    }
    
    Write-Host "�ҵ����°汾: $($release.tag_name)" -ForegroundColor Green
    Write-Host "�ʲ���С: $([math]::Round($asset.size/1MB, 2)) MB" -ForegroundColor Gray
    
    # ��ȡʵ�ʵ�����URL�����Ǿ���
    $downloadUrl = Get-DownloadUrl -OriginalUrl $asset.browser_download_url
    Write-Host "ʵ������URL: $downloadUrl" -ForegroundColor Gray
    
    if ($CreateTempScript) {
        # ʹ����ʱ�ű���ʽ����
        Write-Host "ʹ����ʱ�ű����и���..." -ForegroundColor Yellow
        
        # ����Ŀ�����
        Stop-TargetProcess -ProcessId $TargetPID
        
        # ������ʱ���½ű�
        $tempScriptPath = Create-TempUpdateScript -ProcessDir $processInfo.Directory -ProcessPath $processInfo.Path -DownloadUrl $downloadUrl
        
        # ������ʱ�ű�
        Write-Host "������ʱ���½ű�..." -ForegroundColor Yellow
        Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File `"$tempScriptPath`""
        
    } else {
        # ֱ�Ӹ��·�ʽ
        Write-Host "ֱ�ӽ��и���..." -ForegroundColor Yellow
        
        # ����Ŀ�����
        Stop-TargetProcess -ProcessId $TargetPID
        
        # �����ļ�
        $tempDir = Join-Path $env:TEMP "GodotUpdate_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
        $zipPath = Join-Path $tempDir "update.zip"
        Download-Asset -DownloadUrl $downloadUrl -OutputPath $zipPath
        
        # ��ѹ�ļ�
        $extractPath = Join-Path $tempDir "extracted"
        Extract-Archive -ArchivePath $zipPath -ExtractPath $extractPath
        
        # �滻�ļ�
        Replace-Files -SourceDir $extractPath -TargetDir $processInfo.Directory
        
        # ����Ӧ�ó���
        Start-Application -ExecutablePath $processInfo.Path
        
        # ������ʱ�ļ�
        Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "��ʱ�ļ�������" -ForegroundColor Green
    }
    
    Write-Host "�����������!" -ForegroundColor Cyan
}

# ִ��������
try {
    Start-UpdateProcess
}
catch {
    Handle-Error $_.Exception.Message
}