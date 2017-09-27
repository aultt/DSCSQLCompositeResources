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
            SqlServiceCredential = $SqlServiceCredential
            SqlAgentServiceCredential = $SqlAgentServiceCredential
            MofPath              = 'C:\Mofs'
            SetupSourcePath      = '\\dsc-dc\sqlserver'
            SQLSysAdminAccounts  = 'DSC\Administrator' 
            ClusterName = 'DSCTestCluster'
            ClusterIP ='192.168.210.99'
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser =$true
            PrimaryAlwaysOnNode = 'DSC-SQL4'
            AvailabilityGroupName =@('AG1','AG2')
        }
        @{NodeName ="DSC-SQL5"}
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
foreach ($node in $ConfigData.AllNodes.nodename)
{
    Set-DscLocalConfigurationManager $node -Path $MofPath -Force
}

#endregion
#region SQL Config
Configuration SecondaryAlwaysOnConfig
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName SQLCompositeResources -ModuleVersion 1.0

    node $allNodes.nodename
    {
        SecondaryAlwaysOn Standalone
        { 
           Server = $Node.NodeName
           ClusterName = $Node.ClusterName
           ClusterIP = $Node.ClusterIp
           SetupSourcePath = $Node.SetupSourcePath
           SQLSysAdminAccounts = $Node.SQLSysAdminAccounts
           SqlInstallCredential = $Node.SQLInstallCredential
           SqlServiceCredential = $Node.SQLServiceCredential
           SqlAgentServiceCredential = $Node.SQLAgentServiceCredential
        }   
  
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
#endregion SQLConfig
#region Move Resources
foreach ($node in $ConfigData.AllNodes.nodename)
{
    Write-Output "Copy resources to $node"
    $Destination = "\\$($node)\\c$\Program Files\WindowsPowerShell\Modules"
    if (Test-Path "$Destination\xSqlServer"){Remove-Item -Path "$Destination\xSqlServer"-Recurse -Force}
    Copy-Item 'C:\Program Files\WindowsPowerShell\Modules\xSqlServer' -Destination $Destination -Recurse -Force
    if (Test-Path "$Destination\SqlServer"){Remove-Item -Path "$Destination\SqlServer"-Recurse -Force}
    Copy-Item 'C:\Program Files\WindowsPowerShell\Modules\SqlServer' -Destination $Destination -Recurse -Force
    if (Test-Path "$Destination\xComputerManagement"){Remove-Item -Path "$Destination\xComputerManagement"-Recurse -Force}
    Copy-Item 'C:\Program Files\WindowsPowerShell\Modules\xComputerManagement' -Destination $Destination -Recurse -Force
    if (Test-Path "$Destination\xFailoverCluster"){Remove-Item -Path "$Destination\xFailoverCluster"-Recurse -Force}
    Copy-Item 'C:\Program Files\WindowsPowerShell\Modules\xFailoverCluster' -Destination $Destination -Recurse -Force
}
#endregion
#region Generate and Deploy

SecondaryAlwaysOnConfig -ConfigurationData $ConfigData -OutputPath $MofPath 

foreach ($node in $ConfigData.AllNodes.nodename)
{
    Start-DscConfiguration -ComputerName $node -Path $MofPath  -Force -Wait -verbose
}


#StartConfigs -Computers $ConfigData.AllNodes.nodename -Path  $MofPath -Verbose
#endregion
