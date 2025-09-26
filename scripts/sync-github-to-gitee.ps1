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
    git clone "git@github.com:$repo.git"
    $repoName = $repo.Split("/")[-1]
    Set-Location $repoName
    git remote add gitee "git@gitee.com:scoop-installer-mirrors/$repoName.git"
    git push gitee --force
}

Set-Location $currentDir

(Get-Date).ToUniversalTime().AddHours(8).ToString('o') | Out-File "last-sync.txt" -Force -Encoding utf8
