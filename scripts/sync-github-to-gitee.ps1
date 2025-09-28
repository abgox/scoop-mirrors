#Requires -Version 7

$repoJsonPath = "$PSScriptRoot\..\repo.json"
$repoJsonInfo = Get-Content $repoJsonPath | ConvertFrom-Json

$currentDir = Get-Location

$headers = @{}

if ($env:GITHUB_TOKEN) {
    $headers.Authorization = "token $env:GITHUB_TOKEN"
}

foreach ($item in $repoJsonInfo.list) {
    $repoName = $item.repo.Split("/")[-1]

    $url = "https://github.com/$($item.repo)"

    $allCommits = @()

    try {
        $commits = Invoke-RestMethod "https://api.github.com/repos/$($item.repo)/commits?per_page=1" -Headers $headers
        $allCommits += @{
            Sha  = $commits[0].sha
            Date = [datetime]$commits[0].commit.committer.date
        }
    }
    catch {
        Write-Host "::error::$_" -ForegroundColor Red
        continue
    }

    if ($item.extra_branch) {
        foreach ($branch in $item.extra_branch) {
            try {
                $commit = Invoke-RestMethod "https://api.github.com/repos/$($item.repo)/commits/$branch" -Headers $headers
                $allCommits += @{
                    Sha  = $commit.sha
                    Date = [datetime]$commit.commit.committer.date
                }
            }
            catch {
                Write-Host "::error::$_" -ForegroundColor Red
                continue
            }
        }
    }

    $latestCommit = $allCommits | Sort-Object -Property Date -Descending | Select-Object -First 1

    if ($item.sha -eq $latestCommit.Sha) {
        Write-Host "::notice::Skip $url"
        continue
    }
    Write-Host "::notice::Sync $url"

    try {
        git clone $url $repoName
        if ($LASTEXITCODE -ne 0) { throw "Git clone failed" }
    }
    catch {
        Write-Host "::error::$_" -ForegroundColor Red
        continue
    }

    try {
        Set-Location $repoName -ErrorAction Stop
    }
    catch {
        Write-Host "::error::$_" -ForegroundColor Red
        continue
    }

    git remote add gitee "git@gitee.com:scoop-installer-mirrors/$repoName.git"

    git push gitee --force

    if ($item.extra_branch) {
        foreach ($branch in $item.extra_branch) {
            git checkout $branch
            git push gitee --force
        }
    }

    $item.sha = $latestCommit.Sha

    Set-Location $currentDir
}

$repoJsonInfo | ConvertTo-Json -Depth 100 | Out-File $repoJsonPath -Encoding utf8 -Force
