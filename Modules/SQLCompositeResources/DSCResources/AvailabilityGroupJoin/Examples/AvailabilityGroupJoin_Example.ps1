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
            MofPath              = $MofPath
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser =$true
            PrimaryAlwaysOnNode = 'DSC-SQL4'
            AvailabilityGroupName ='AG1'
        }
        @{NodeName ="DSC-SQL5"}
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
foreach ($node in $ConfigData.AllNodes.nodename)
{
    Set-DscLocalConfigurationManager $node -Path $MofPath -Force
}

#endregion### Example configuration referencing the new composite resource
Configuration MyAvailabilityGroupJoin {
    
    Import-DscResource -ModuleName SQLCompositeResources -ModuleVersion 1.0

    Node $allnodes.nodename
    {
        AvailabilityGroupJoin AllAvailabilityGroups
        {
            #Joins each Availability Group for Each provided all receive the same properties
            Server = $Node.nodename
            SqlInstallCredential = $Node.SqlInstallCredential
            AvailabilityGroupName = $Node.AvailabilityGroupName   
            PrimaryReplica = $Node.PrimaryAlwaysOnNode
        }
    }
}

MyAvailabilityGroupJoin -ConfigurationData $ConfigData -OutputPath $MofPath 
Start-DscConfiguration -ComputerName $ConfigData.AllNodes.nodename -Path $MofPath  -Force -Wait -verbose
