Class HiveOS {
    static [void] GetWorkers() {
        $API = @{
            Method      = "GET";
            Uri         = "https://api2.hiveos.farm/api/v2/farms/$($Global:Config.Farm_Id)/workers?token=$($global:Config.Hive_Api_Key)";
            ContentType = "application/json";
            Headers     = @{Authorization = $global:Config.Hive_Api_Key };
            Body        = $null;
        }
        Write-Host "Contacting HiveOS For Worker Details..." -ForegroundColor Cyan;
        try { 
            $Get_Workers = Invoke-RestMethod @API -TimeoutSec 10 -ErrorAction Stop;
            if ($Get_Workers.data.Count -eq 0) {
                Write-Host "HiveOS API was reached but no data was given" -ForegroundColor Red;
                $global:Config.HiveOSIsConnected = $false;
            }
            foreach ($worker in $Get_Workers.data) {
                $IsWorker = $global:Config.Workers | Where Name -eq $worker.name;
                if (!$IsWorker) {
                    $global:Config.Workers.Add([Worker]::New($worker));
                }
                else {
                    foreach($Work in ($global:Config.Workers | Where Name -eq $worker.name)) {
                        $Work.Online = $worker.stats.online
                    }
                }
            }
        }
        catch { 
            Write-Host "Message from HiveOS: $($_.Exception.Message)" -ForegroundColor Red;
            $global:Config.HiveOSIsConnected = $false
            return;
        }
        Write-Host "Farm Worker Details Gathered!" -ForegroundColor Green;
        $global:Config.HiveOSIsConnected = $true;
    }
}