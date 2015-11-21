# $DOCKER = (Get-Command docker | Select-Object -ExpandProperty Definition)
$DOCKER = (docker-machine ssh default which docker)
Write-Host $DOCKER
$HOST_IP = (Get-WmiObject -class win32_NetworkAdapterConfiguration -Filter 'ipenabled = "true"').ipaddress[0]
Write-Host $HOST_IP
$WORK_DIR = Split-Path $script:MyInvocation.MyCommand.Path
Write-Host $WORK_DIR
$DOCKERHOST = (docker-machine ip default)
Write-Host $DOCKERHOST

$DOCKER_CMD="docker run -ti -v `"$DOCKER`":`"$DOCKER`" -v `"/var/run/docker.sock:/var/run/docker.sock`" -e HOST_IP=`"$HOST_IP`" -e DOCKERHOST=`"$DOCKERHOST`" -e LOG_LEVEL=INFO -e WORK_DIR=`"$WORK_DIR`" accordance/dev-seed:0.0.3"
Write-Host $DOCKER_CMD
Invoke-Expression $DOCKER_CMD
