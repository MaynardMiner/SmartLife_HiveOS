using namespace newtonsoft.json;
using namespace System.Diagnostics;
using namespace System.Collections.Generic;

Class Auth_Token {
    [string]$Access_Token;
    [string]$Refresh_Token;
    [string]$Token_Type;
    [int]$Expires_In;

    Auth_Token([PSCustomObject]$auth) {
        $this.Access_Token = $auth.access_token;
        $this.Refresh_Token = $auth.refresh_token;
        $this.Token_Type = $auth.token_type;
        $this.Expires_In = $auth.expires_in;
    }
}

Class Base_Config {
    [JsonProperty("Username")]
    [string]$Username;

    [JsonProperty("Password")]
    [string]$Password;

    [JsonProperty("Region")]
    [string]$Region;

    [JsonProperty("Hive_Api_Key")]
    [string]$Hive_Api_Key;

    [JsonProperty("Farm_Id")]
    [string]$Farm_Id;
}

Class Config : Base_Config {

    [string]$Location;
    [string]$Url;
    [Stopwatch]$SmartLifeRefresh;
    [Stopwatch]$HiveOSRefresh;
    [List[Device]]$Devices;
    [bool]$SmartLifeIsConnected = $false;
    [bool]$HiveOSIsConnected = $false;
    [Auth_Token]$Authorization;
    [String[]]$ErrorList;
    [List[Worker]]$Workers = [List[Worker]]::New();

    Config() {
        $this.SmartLifeRefresh = [Stopwatch]::New();
        $this.SmartLifeRefresh.Restart();
        $this.HiveOSRefresh = [Stopwatch]::New();
        $this.HiveOSRefresh.Restart();
        $IsConfig = [IO.File]::Exists("config.json");
        if ($IsConfig) {
            $this.Devices = [List[Device]]::New()
            $file = [Json]::Get("config.json", [Base_Config], $true);
            $this.Username = $file.Username;
            $this.Password = $file.Password;
            $this.Region = $file.Region;
            $this.Hive_Api_Key = $file.Hive_Api_Key;
            $this.Farm_Id = $file.Farm_Id;
            switch ($this.Region) {
                "America" { 
                    $this.Url = "https://px1.tuyaus.com/homeassistant/";
                    $this.Location = "US";
                }
                "China" { 
                    $this.Url = "https://px1.tuyacn.com/homeassistant/";
                    $this.Location = "CN";
                }
                "Europe" { 
                    $this.Url = "https://px1.tuyaeu.com/homeassistant/";
                    $this.Location = "EU";
                }
                "India" { 
                    $this.Url = "https://px1.tuyain.com/homeassistant/";
                    $this.Location = "IN";
                }
            }    
        }
        else {
            Write-Host "No config.json!" -ForegroundColor Red;
            exit;
        }
    }
}