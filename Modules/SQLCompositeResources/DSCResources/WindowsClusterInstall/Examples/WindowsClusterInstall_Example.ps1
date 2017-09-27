#region Parms
$MofPath = 'C:\Mofs'
$ConfigData = @{
    AllNodes = @(
        @{
            NodeName             = '*'
        }
        @{NodeName ="DSC-SQL6"}
    )
}

#endregion
#region LCM Config
[DSCLocalConfigurationManager()]
Configuration LCMPush
{
    Node $allnodes.nodename
    {
        Settings
        {
            ActionafterReboot = 'ContinueConfiguration'
            AllowModuleOverwrite = $true
            ConfigurationMode = 'ApplyOnly'
            ConfigurationModeFrequencyMins = 15
            RefreshFrequencyMins = 30
            StatusRetentionTimeInDays = 7
            RebootNodeIfNeeded = $true
            RefreshMode = 'Push'
        }
    }
}

LCMPush -ConfigurationData $ConfigData -OutputPath $MofPath
Set-DscLocalConfigurationManager $ConfigData.AllNodes.nodename -Path $MofPath -Force
#endregion

### Example configuration referencing the new composite resource
Configuration MyWindowsClusterInstall {
    
    Import-DscResource -ModuleName SQLCompositeResources -ModuleVersion 1.0

    node $allNodes.nodename
    {

        WindowsClusterInstall PrimaryNode
        {
            Ensure = 'Present'
        }

    }
}

MyWindowsClusterInstall -ConfigurationData $ConfigData -OutputPath $MofPath

Start-DscConfiguration -ComputerName $ConfigData.AllNodes.nodename -Path $MofPath  -Force -Wait -verbose