Class Smart_Life {
    static [void] Begin_Auth() {
        $endpoint = $global:Config.url + "auth.do"
        $body = @{
            userName = $global:Config.Username;
            password = $global:Config.Password;
            countryCode = $global:Config.Location;
            bizType = "smart_life";
            from = "tuya";
        }
        
        Write-Host "Logging Into Smart Life..." -ForegroundColor Cyan;
        try {
            $authorization = Invoke-RestMethod -Uri $endpoint -ContentType "application/x-www-form-urlencoded" -Method POST -Body $body;
            if ($authorization.responseStatus -eq "error") {
                Write-Host "Failed to authorize: $($authorization.errorMsg)" -ForegroundColor Red;
                $global:Config.IsConnected = $false;
                return;
            }
            $global:Config.Authorization = [Auth_Token]::New($authorization);
        }
        catch {
            Write-Host "Failed To Get Authorization From Smart Life" -ForegroundColor Green;
            $global:Config.IsConnected = $false;
            return;
        }

        Write-Host "Log In Successfull" -ForegroundColor Green;
        $global:Config.IsConnected = $true;
    }

    static [void] GetDeviceList() {
        $endpoint = $global:Config.Url + "skill"
        $body = @{
            header = @{
                name = "Discovery";
                namespace = "discovery";
                payloadVersion = 1;
            };
            payload = @{
                accessToken = $global:Config.Authorization.Access_Token;
            };
        }

        $body = [Json]::Set($body)
    
        Write-Host "Gathering Device List And Status..." -ForegroundColor Cyan;
        try {
            $Get_Devices = Invoke-RestMethod -Uri $endpoint -ContentType "application/json" -Method GET -Body $body;
            if($Get_Devices.payload.devices.count -eq 0) {
                Write-Host "No Devices Found." -ForegroundColor Red;]
                $global:Config.IsConnected = $false;
                return;
            }
        }
        catch {
            Write-Host "Error: Failed To Gather Devices!" -ForegroundColor Red;
            $global:Config.IsConnected = $false;
            return;
        }
        foreach ($device in $Get_Devices.payload.devices) {
            $global:Config.Devices.Add([Device]::New($device));
        }
        $global:Config.IsConnected = $true;
        Write-Host "Device List Gathered!" -ForegroundColor Green;
    }    
}