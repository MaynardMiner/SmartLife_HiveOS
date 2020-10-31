using namespace System.Timers;

Class Script_Events {
    static [void] Start() {
        ## Smart Life Auth & Devices
        $global:Config.SmartLifeRefresh = [Timer]::New();
        $global:Config.SmartLifeRefresh.Interval = 3600000;
        $script = [Script_Events]::SmartLifeAuth();
        $null = Register-ObjectEvent -SourceIdentifier SmartLifeAuthTimer -Action $script -EventName Elapsed -InputObject $global:Config.SmartLifeRefresh
        $global:Config.SmartLifeRefresh.AutoReset = $false;
        $global:Config.SmartLifeRefresh.Start()
        . $script;

        ## HiveOS API
        $global:Config.HiveOSRefresh = [Timer]::New();
        $global:Config.HiveOSRefresh.Interval = 30000;
        $script = [Script_Events]::HiveOSAuth();
        $null = Register-ObjectEvent -SourceIdentifier HiveOSAuthTimer -Action $script -EventName Elapsed -InputObject $global:Config.HiveOSRefresh
        $global:Config.HiveOSRefresh.AutoReset = $false;
        $global:Config.HiveOSRefresh.Start()
        . $script;
    }

    hidden static [scriptblock] SmartLifeAuth() {
        $script = {
            $global:Config.SmartLifeRefresh.Stop();
            [Smart_Life]::Begin_Auth();
            if ($global:Config.SmartLifeIsConnected) {
                [Smart_Life]::GetDeviceList();
            }
            if (!$global:Config.SmartLifeIsConnected) {
                $global:Config.SmartLifeRefresh.Interval = 30000;
                $global:Config.SmartLifeRefresh.Start();
                break;
            }
            $global:Config.SmartLifeRefresh.Interval = 3600000;
            $global:Config.SmartLifeRefresh.Start();
        }
        return $script;
    }

    hidden static [scriptblock] HiveOsAuth() {
        $script = {
            $global:Config.HiveOSRefresh.Stop();
            [HiveOS]::GetWorkers();
            $global:Config.HiveOSRefresh.Start();
        }
        return $script;
    }

}