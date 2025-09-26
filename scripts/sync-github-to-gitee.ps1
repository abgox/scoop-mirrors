#Requires -Version 7

$repoJsonPath = "$PSScriptRoot\..\repo.json"
$repoJsonInfo = Get-Content $repoJsonPath | ConvertFrom-Json

$currentDir = Get-Location

foreach ($item in $repoJsonInfo.list) {
    $repoName = $item.repo.Split("/")[-1]

    try {
        $repoInfo = Invoke-WebRequest "https://api.github.com/repos/$($item.repo)" | ConvertFrom-Json
    }
    catch {
        Write-Host "::error::$_" -ForegroundColor Red
        continue
    }

    $clone_url = $repoInfo.clone_url
    $updated_at = $repoInfo.updated_at

    if ($item.updated_at -eq $updated_at) {
        Write-Host "Skip $clone_url"
        continue
    }
    else {
        Write-Host "Sync $clone_url"
    }

    git clone --mirror $clone_url.Replace("https://github.com", "git@github.com") $repoName

    Set-Location $repoName

    git remote add gitee "git@gitee.com:scoop-installer-mirrors/$repoName.git"

    if ($repoName -eq "Install") {
        git push gitee --all --force
    }
    else {
        git push gitee --mirror --force
    }

    $item.updated_at = $updated_at

    Set-Location $currentDir
}

$repoJsonInfo | ConvertTo-Json -Depth 100 | Out-File $repoJsonPath -Encoding utf8 -Force
