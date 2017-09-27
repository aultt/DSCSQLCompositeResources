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
            AvailabilityGroupName =@('AG1','AG2')
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
#endregion

### Example configuration referencing the nAvailabilityGroup
Configuration MyAvailabilityGroup {
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName SQLCompositeResources -ModuleVersion 1.0

    Node $allNodes.nodename
    {

        AvailabilityGroup AllAvailabilityGroups
        {
            #Creates Initial Availability Group for Each provided all receive the same properties
            Server = $node.nodename
            SqlInstallCredential = $SqlInstallCredential
            AvailabilityGroupName = $Node.AvailabilityGroupName     
        }
    }
}

MyAvailabilityGroup -ConfigurationData $ConfigData -OutputPath $MofPath 
Start-DscConfiguration -ComputerName $ConfigData.AllNodes.nodename -Path $MofPath  -Force -Wait -verbose