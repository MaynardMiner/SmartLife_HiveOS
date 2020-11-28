using namespace System.Diagnostics.Stopwatch;

. .\build\Json.ps1;
. .\build\Device.ps1;
. .\build\Config.ps1;
. .\build\Smart_Life.ps1;
. .\build\HiveOS.ps1;

$global:Config = [Config]::New();

## Begin Intital Auth
[Smart_Life]::Begin_Auth();
if ($global:Config.SmartLifeIsConnected) {
    [Smart_Life]::GetDeviceList();
    Write-Host "SmartLife Connected";
}
[HiveOS]::GetWorkers();


While ($True) {
    ## Connect to smartlife
    Write-Host "Last Checked Smart Life: $($global:Config.SmartLifeRefresh.Elapsed.TotalSeconds) seconds ago" -Foreground Magenta
    if ($global:Config.SmartLifeRefresh.Elapsed.Seconds -gt 3600000) {
        [Smart_Life]::Begin_Auth();
        if ($global:Config.SmartLifeIsConnected) {
            [Smart_Life]::GetDeviceList();
            Write-Host "SmartLife Connected" -Foreground Green;
        }        
    }

    if ($global:Config.SmartLifeIsConnected -eq $false) {
        Write-Host "Sleeping then attempting to connect to Smart Life again" -ForegroundColor Red;
        Start-Sleep -Seconds 300;
        return;
    }

    ## Check HiveOs
    Write-Host "Last Checked HiveOS: $($global:Config.HiveOSRefresh.Elapsed.TotalSeconds) seconds ago" -Foreground Magenta
    if ($global:Config.HiveOSRefresh.Elapsed.Seconds -gt 300) {
        [HiveOS]::GetWorkers();
    }

    if ($global:Config.HiveOSIsConnected -eq $false) {
        Write-Host "Sleeping then attempting to connect to HiveOS again" -ForegroundColor Red;
        Start-Sleep -Seconds 300;
        return;
    }

    ## Reboot any devices that need to be booted.
    foreach ($worker in $Global:Config.Workers) {
        if ($worker.online -eq $false) {
            $global:Config.Devices | Where Name -eq $worker.Name | ForEach-Object {
                $device = $_
                $time_elapsed = ([datetime]::now - $worker.Restart_Date).TotalSeconds
                if ($time_elapsed -gt 300 -and $worker.Restarts -le 5) {
                    Write-Host "Restarting $($worker.Name)...";
                    Write-Host "Turning off..."
                    $null = $device.Toggle($false);
                    Start-Sleep -S 10
                    Write-Host "Turning on..."
                    $null = $device.Toggle($true);
                    $worker.Restarts++
                    $worker.Restart_Date = [Datetime]::Now;
                }
                else {
                    Write-Host "$($worker.name) needs to be restarted, but either 300 seconds hasn't passed or it has been restarted 5 times" -Foreground Yellow
                }
            }
        }
        else {
            $worker.Restarts = 0;
        }
    }

    Start-Sleep -S 30;
}