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
            SqlInstallCredential = $SqlInstallCredential
            MofPath              = 'C:\Mofs'
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser =$true
        }
        @{NodeName ="DSC-SQL4"}
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
### Example configuration referencing the new composite resource
Configuration EnableMyAlwaysOn
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName SQLCompositeResources -ModuleVersion 1.0
    
    node $allNodes.nodename
    {
        EnableAlwaysOn EnablePrimary
        {
            Server = $Node.Nodename
            SqlInstallCredential = $Node.SqlInstallCredential
        }
    }
}

EnableMyAlwaysOn -ConfigurationData $ConfigData -OutputPath $MofPath 

Start-DscConfiguration -ComputerName $ConfigData.AllNodes.nodename -Path $MofPath  -Force -Wait -verbose