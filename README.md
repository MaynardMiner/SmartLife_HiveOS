# SMART_LIFE HiveOS

## What is it?

This is meant to be an automated script for people who have smart devices that work with Tuya SmartLife Application and a HiveOS farm.

Currently I have only setup of the SmartLife side of the application, but I intend to set this project up to have a script that will
contact HiveOS farm through its API, and if any devices are detected as offline: To reboot them automatically.

## How to use?

Fill out config.json with your data. Run the script.

### Region
Only these locations are accepted:

```
China

America

Europe

India
```

### Output

Once you have ran the script- The current shell with have the global variable devices.

Devices has a method to toggle devices on and off.

```pwsh
$global:Devices | Get-Member
```

Would output this:

```
   TypeName: Device

Name        MemberType Definition
----        ---------- ----------
Equals      Method     bool Equals(System.Object obj)
GetHashCode Method     int GetHashCode()
GetType     Method     type GetType()
Toggle      Method     bool Toggle(bool state)
ToString    Method     string ToString()
Data        Property   Device_Data Data {get;set;}
Dev_Type    Property   string Dev_Type {get;set;}
Ha_Type     Property   string Ha_Type {get;set;}
Icon        Property   string Icon {get;set;}
Id          Property   string Id {get;set;}
Name        Property   string Name {get;set;}
```

An example of toggling power on a device:

```pwsh
### $true means to turn on
### $false means to turn off

$success = $global:devices[0].Toggle($true)
```

The expiration time of the token is 3600 seconds. You will have to run the script again to re-authorize. I will factor that in later.
