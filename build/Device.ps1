class Device_Data {
    [bool]$online;
    [bool]$state;

    Device_Data([PSCustomObject]$data) {
        $this.online = $data.online;
        $this.state = $data.state;
    }
}

class Device {
    [device_data]$Data;
    [string]$Name;
    [string]$Icon;
    [string]$Id;
    [string]$Dev_Type;
    [string]$Ha_Type;

    Device([PSCustomObject]$device) {
        $this.Data = [device_data]::new($device.data);
        $this.Name = $device.name;
        $this.Icon = $device.icon;
        $this.Id = $device.id;
        $this.Dev_Type = $device.dev_type;
        $this.Ha_Type = $device.ha_type;
    }

    [bool] Toggle([bool]$state) {
        $new_state = 0;
        switch ($state) {
            $true { $new_state = 1; }
            $false { $new_state = 0; }
        }

        $endpoint = $global:Config.url + "skill"
        $body = @{
            header  = @{
                name           = "turnOnOff";
                namespace      = "control";
                payloadVersion = 1;
            };
            payload = @{
                accessToken = $global:Config.Authorization.Access_Token;
                devId       = $this.Id;
                value       = $new_state
            }
        } | ConvertTo-Json;

        try {
            $toggle_state = Invoke-RestMethod -Uri $endpoint -ContentType "application/json" -Method GET -Body $body;
            if ($toggle_state.header.code -eq "SUCCESS") {
                return $true;
            }
            else {
                return $false;
            }
        }
        catch {
            return $false;
        }

    }
}
