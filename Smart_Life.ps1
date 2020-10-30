using namespace System.Management.Automation;
using namespace System.Collections.Generic;

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
                accessToken = $global:config.authorization.access_token;
                devId       = $this.Id;
                value       = $new_state
            }
        }

        try {
            $toggle_state = Invoke-RestMethod -Uri $endpoint -ContentType "application/json" -Method GET -Body $body;
            return $true;
        }
        catch {
            return $false;
        }

    }
}

function Get-Config() {
    if (Test-Path ".\config.json") {
        $global:config = Get-Content ".\config.json" | ConvertFrom-Json;
        $global:config | Add-Member "authorization" $null;
        $global:config | Add-Member "location" $null;
        $global:config | Add-Member "url" $null;
        switch ($global:config.region) {
            "America" { 
                $global:config.url = "https://px1.tuyaus.com/homeassistant/";
                $global:config.location = "US";
            }
            "China" { 
                $global:config.url = "https://px1.tuyacn.com/homeassistant/";
                $global:config.location = "CN";
            }
            "Europe" { 
                $global:config.url = "https://px1.tuyaeu.com/homeassistant/";
                $global:config.location = "EU";
            }
            "India" { 
                $global:config.url = "https://px1.tuyain.com/homeassistant/";
                $global:config.location = "IN";
            }

        }
    }
}

function Start-Authorization() {
    $endpoint = $global:Config.url + "auth.do"
    $body = @{
        userName    = $global:Config.username;
        password    = $global:Config.password;
        countryCode = $global:Config.location;
        bizType     = "smart_life";
        from        = "tuya";
    }
    $global:Config.authorization = Invoke-RestMethod -Uri $endpoint -ContentType "application/x-www-form-urlencoded" -Method POST -Body $body
}

function Get-DeviceList([PSCustomObject]$config) {
    $endpoint = $global:Config.url + "skill"
    $body = @{
        header  = @{
            name           = "Discovery";
            namespace      = "discovery";
            payloadVersion = 1;
        };
        payload = @{
            accessToken = $global:config.authorization.access_token;
        };
    } | ConvertTo-Json;

    $Get_Devices = Invoke-RestMethod -Uri $endpoint -ContentType "application/json" -Method GET -Body $body

    [List[device]]$devices = [List[device]]::New();
    foreach ($device in $Get_Devices.payload.devices) {
        $devices.Add([Device]::New($device));
    }

    return $devices
}

Get-Config;
Start-Authorization;
$global:Devices = Get-DeviceList;