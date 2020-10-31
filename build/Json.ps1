using namespace Newtonsoft.Json;
using namespace System.Collections.Generic;

Class JSON {

    static [object] Get([string]$data, [type]$type, [bool]$IsPath) {
        [string] $json_data = $null;
        [object] $json = $null;
        [bool]$Exists = $false;

        if ($IsPath) {
            $Exists = [IO.File]::Exists($data);
            if ($Exists) {
                $json_data = [IO.File]::ReadLines($data);
            }
        }
        else {
            $json_data = $data;
        }

        if ($json_data) {
            try {
            $json = [JsonConvert]::DeserializeObject($json_data, $type);
            }
            catch {
            
            }
        }

        return $json;
    }

    static [void] Set([object]$object, [string]$file) {
        $data = [JsonConvert]::SerializeObject($object, [Formatting]::Indented);
        [IO.File]::WriteAllLines($file, $data);
    }

    static [string] Set([object]$object) {
        return [JsonConvert]::SerializeObject($object, [Formatting]::None);
    }
}