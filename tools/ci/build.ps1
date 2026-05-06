if(!(Test-Path -Path "C:/byond/bin/dm.exe")){
    if(Test-Path -Path "C:/byond"){
        Remove-Item -Recurse -Force C:/byond
    }
    bash tools/ci/download_byond.sh
    [System.IO.Compression.ZipFile]::ExtractToDirectory("C:/byond.zip", "C:/")
    Remove-Item C:/byond.zip
}

if(!(Test-Path -Path "C:/byond/bin/dm.exe")){
    Write-Error "dm.exe not found at C:/byond/bin/dm.exe - BYOND installation may have failed"
    dir C:/byond -Recurse -ErrorAction SilentlyContinue | Select-Object FullName
    exit 1
}

bash tools/ci/install_node.sh
bash tools/build/build -Werror

exit $LASTEXITCODE
