using namespace System.Timers;

. .\build\Json.ps1;
. .\build\Device.ps1;
. .\build\Config.ps1;
. .\build\Smart_Life.ps1;
. .\build\Script_Events.ps1;

[IO.Directory]::SetCurrentDirectory($PSScriptRoot);

## Make Thread Safe Hashtable
$global:Config = [Config]::New();

## Load Connection Events;
[Script_Events]::Start();

