#region Credentials Management
    $secpassword = "P@ssw0rd" | ConvertTo-SecureString -AsPlainText -Force
    
    $SqlInstallCredential = New-Object System.Management.Automation.PSCredential("DSC\SQLInstall",$secpassword)
    $SqlServiceCredential = New-Object System.Management.Automation.PSCredential("DSC\SQLSvr",$secpassword)
    $SqlAgentServiceCredential = New-Object System.Management.Automation.PSCredential("DSC\SQLAgt",$secpassword)
#endregion
#region Parms
$MofPath = 'C:\Mofs'
$ConfigData = @{
    AllNodes = @(
        @{
            NodeName             = '*'
            MofPath              = 'C:\Mofs'
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser =$true
            DiskConfiguration = @(@{
                        Number = 1
                        Label = 'Data'
                        Letter = 'D'
                        Format = 'NTFS'
                        RetryInterval = 60
                        RetryCount =60
                       }
                     )
        }
        @{NodeName ="DSC-SQL7"}
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
Configuration DiskConfigurationSetup {
    
    Import-DscResource -ModuleName SQLCompositeResources

    Node $allNodes.nodename {

        FailOverClusterDisk SetupDisks
        {
            DiskConfiguration = $DiskConfiguration
        }

    }
}

#region Generate and Deploy
DiskConfigurationSetup -ConfigurationData $ConfigData -OutputPath $MofPath 
Start-DscConfiguration -ComputerName $ConfigData.AllNodes.nodename -Path $MofPath  -Force -Wait -verbose
#endregion