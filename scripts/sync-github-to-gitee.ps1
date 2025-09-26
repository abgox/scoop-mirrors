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
    "ScoopInstaller/Install",
)

foreach ($repo in $repoList) {
    git clone "https://github.com/$repo.git"
    git remote add gitee "https://gitee.com/scoop-installer-mirrors/$repo.git"
    git push gitee --force
}
