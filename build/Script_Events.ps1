using namespace System.Timers;

Class Script_Events {
    static [void] Start() {
        ## Smart Life Auth & Devices
        $global:Config.Refresh = [Timer]::New();
        $global:Config.Refresh.Interval = 3600000;
        $script = [Script_Events]::Auth();
        $null = Register-ObjectEvent -SourceIdentifier authtime -Action $script -EventName Elapsed -InputObject $global:Config.Refresh
        $global:Config.Refresh.AutoReset = $false;
        $global:Config.Refresh.Start()
        . $script;

        ## HiveOS API
        
    }

    hidden static [scriptblock] Auth() {
        $script = {
            $global:Config.Refresh.Stop();
            [Smart_Life]::Begin_Auth();
            if ($global:Config.IsConnected) {
                [Smart_Life]::GetDeviceList();
            }
            if (!$global:Config.IsConnected) {
                $global:Config.Refresh.Interval = 30000;
                $global:Config.Refresh.Start();
                break;
            }
            
            $global:Config.Refresh.Interval = 3600000;
            $global:Config.Refresh.Start();
        }
        return $script;
    }

}