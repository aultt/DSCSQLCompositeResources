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
#region SQL Config
Configuration PrimaryAlwaysOnConfig
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName SQLCompositeResources -ModuleVersion 1.0

    node $allNodes.nodename
    {
        #Installs SQL Server, Installs Windows Clusting, Creates Cluster and enables AlwaysOn
        PrimaryAlwaysOn Standalone 
        { 
           Server = $Node.Nodename
           ClusterName = $Node.ClusterName
           ClusterIP = $Node.ClusterIP
           SetupSourcePath = $Node.SetupSourcePath
           SQLSysAdminAccounts = $Node.SQLSysAdminAccounts
           SqlInstallCredential = $Node.SqlInstallCredential
           SqlServiceCredential = $Node.SqlServiceCredential
           SqlAgentServiceCredential = $Node.SqlAgentServiceCredential
        }   

        AvailabilityGroup AllAvailabilityGroups
        {
            #Creates Initial Availability Group for Each provided all receive the same properties
            Server = $Node.nodename
            SqlInstallCredential = $SqlInstallCredential
            AvailabilityGroupName = $Node.AvailabilityGroupName     
        }
    }
}
#endregion SQLConfig
#region Move Resources
foreach ($server in $ConfigData.AllNodes.nodename)
{
    Write-Output "Copy resources to $Server"
    $Destination = "\\$($server)\\c$\Program Files\WindowsPowerShell\Modules"
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

PrimaryAlwaysOnConfig -ConfigurationData $ConfigData -OutputPath $MofPath 

Start-DscConfiguration -ComputerName $ConfigData.AllNodes.nodename -Path $MofPath  -Force -Wait -verbose
#endregion
