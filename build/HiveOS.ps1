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
            if($Get_Workers.data.Count -eq 0) {
                Write-Host "HiveOS API was reached but no data was given" -ForegroundColor Red;
                $global:Config.HiveOSIsConnected = $false;
            }
            $global:Config.Workers = [List[Worker]]::New();
            foreach($worker in $Get_Workers.data) {
                $global:Config.Workers.Add([Worker]::New($worker));
            }
        }
        catch { 
            Write-Host "Message from HiveOS: $($_.Exception.Message)" -ForegroundColor Red;
            $global:Config.HiveOSIsConnected = $false
            return;
        }
        $global:Config.HiveOSIsConnected = $true;
        Write-Host "Farm Worker Details Gathered!" -ForegroundColor Green;
    }
}