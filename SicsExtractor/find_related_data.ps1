$filepattern='c1a847c1-6789-4824-a987-bac35c09e619_e1cbe131-25b1-405a-b422-f82b9e39e360*'

$folders = Get-ChildItem -Directory -Path \\sirius.local\app\GPIDoc

foreach ($f in $folders) {
    Write-Host $f.FullName
    $fileRepos = Get-ChildItem -Directory -Path $f.FullName -Name "File Repository" -Recurse -Depth 1
    
    foreach ($fileRepo in $fileRepos) {
        $fileRepoDir = Join-Path -Path $f.FullName -ChildPath $fileRepo
        Write-Host $fileRepoDir
        $rltDir = Join-Path -Path $fileRepoDir -ChildPath "Rlt"
        Write-Host $rltDir
        $rltFiles = Get-ChildItem -File -Path $rltDir -Name $filepattern
        Write-Host $rltFiles
    }
}
