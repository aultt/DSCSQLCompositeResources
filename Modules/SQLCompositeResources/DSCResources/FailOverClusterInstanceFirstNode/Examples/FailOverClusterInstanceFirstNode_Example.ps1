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
            ClusterName = 'DSCFCITestCluster'
            ClusterIP ='192.168.210.110'
            FailoverClusterNetworkName = 'DSCFCI1'
            FailoverClusterIPAddress = '192.168.210.111'
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser =$true
            InstallSQLDataDir = 'D:\MSSQL\Data'
            SQLUserDBDir = 'D:\MSSQL\Data'
            SQLUserDBLogDir = 'D:\MSSQL\Data'
            SQLTempDBDir = 'D:\MSSQL\Data'
            SQLTempDBLogDir = 'D:\MSSQL\Data'
            SQLBackupDir ='D:\MSSQL\Data'
            InstanceDir  = 'D:\MSSQL\Data'
            DiskConfiguration = @(@{
                        Number = 1
                        Label = 'Data'
                        Letter = 'D'
                        Format = 'NTFS'
                        RetryInterval = 60
                        RetryCount =60
                       }
                     )
            #AvailabilityGroupName =@('AG1','AG2')
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
#region SQL Config
Configuration FCIFirstNode {
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName SQLCompositeResources -ModuleVersion 1.0

    Node $allNodes.nodename {

        FailOverClusterInstanceFirstNode FirstNode {
            ClusterName = $Node.Clustername
            ClusterIP = $Node.ClusterIP
            SetupSourcePath = $Node.SetupSourcePath
            SQLSysAdminAccounts = $Node.SQLSysAdminAccounts
            FailoverClusterNetworkName = $Node.FailoverClusterNetworkName
            FailoverClusterIPAddress = $Node.FailoverClusterIPAddress
            SqlInstallCredential = $Node.SqlInstallCredential
            SqlServiceCredential =$Node.SqlServiceCredential
            SqlAgentServiceCredential = $Node.SqlAgentServiceCredential
            InstallSQLDataDir = $Node.InstallSQLDataDir
            SQLUserDBDir = $Node.SQLUserDBDir
            SQLUserDBLogDir = $Node.SQLUserDBLogDir
            SQLTempDBDir = $Node.SQLTempDBDir
            SQLTempDBLogDir = $Node.SQLTempDBLogDir
            SQLBackupDir = $Node.SQLBackupDir
            DiskConfiguration = $Node.DiskConfiguration
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
    if (Test-Path "$Destination\xStorage"){Remove-Item -Path "$Destination\xStorage"-Recurse -Force}
    Copy-Item 'C:\Program Files\WindowsPowerShell\Modules\xStorage' -Destination $Destination -Recurse -Force
}
#endregion
#region Generate and Deploy
FCIFirstNode -ConfigurationData $ConfigData -OutputPath $MofPath 
Start-DscConfiguration -ComputerName $ConfigData.AllNodes.nodename -Path $MofPath  -Force -Wait -verbose
#endregion