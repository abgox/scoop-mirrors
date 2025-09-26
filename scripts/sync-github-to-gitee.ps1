$repoList = @(
    "ScoopInstaller/Main",
    "ScoopInstaller/Extras",
    "ScoopInstaller/Versions",
    "matthewjberger/scoop-nerd-fonts",
    "ScoopInstaller/Nirsoft",
    "niheaven/scoop-sysinternals",
    "ScoopInstaller/PHP",
    "ScoopInstaller/Nonportable",
    "ScoopInstaller/Java",
    "Calinou/scoop-games",
    "ScoopInstaller/Scoop",
    "ScoopInstaller/Install"
)

$currentDir = Get-Location

foreach ($repo in $repoList) {
    Set-Location $currentDir
    git clone "https://github.com/$repo.git"
    Set-Location "$($repo.Split("/")[-1])"
    git remote add gitee "https://gitee.com/scoop-installer-mirrors/$repo.git"
    git push gitee --force
}

Set-Location $currentDir

(Get-Date).ToUniversalTime().AddHours(8).ToString('o') | Out-File "last-sync.txt" -Force -Encoding utf8
