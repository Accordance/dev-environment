# WARNING! Set-ExecutionPolicy

IF(!$Env:DOCKER_MACHINE_NAME) {
  $Env:DOCKER_MACHINE_NAME = "dev"
}
Write-Host "Docker machine name: " $Env:DOCKER_MACHINE_NAME

docker-machine.exe env --shell=powershell $Env:DOCKER_MACHINE_NAME | Invoke-Expression

IF(!$Env:DOCKER_HOST) {
  $Env:DOCKER_HOST = "tcp://192.168.99.100:2376"
}
Write-Host "Docker host Uri: " $Env:DOCKER_HOST

IF(!$Env:DOCKERHOST) {
  $Env:DOCKERHOST = ([System.Uri]$Env:DOCKER_HOST).Host
}
Write-Host "Docker host: " $Env:DOCKER_HOST

$Env:HOST_IP = (Get-WmiObject -class win32_NetworkAdapterConfiguration -Filter 'ipenabled = "true"').ipaddress[0]
Write-Host "Host IP: " $Env:HOST_IP

# $Env:WORK_DIR = Split-Path $script:MyInvocation.MyCommand.Path
IF(!$Env:WORK_DIR) {
  $Env:WORK_DIR="/home/accordance/dev-environment"
}
Write-Host "Working folder: " $Env:WORK_DIR
docker-machine ssh "$Env:DOCKER_MACHINE_NAME" mkdir /home/accordance
docker-machine ssh "$Env:DOCKER_MACHINE_NAME" sudo mount -t vboxsf -o uid=1000,gid=50 accordance /home/accordance

# $Env:LOG_LEVEL="DEBUG"
