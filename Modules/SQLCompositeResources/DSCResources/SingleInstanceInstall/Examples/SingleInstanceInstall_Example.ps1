$secpassword = 'Somepass1' | ConvertTo-SecureString -AsPlainText -Force 
$SqlInstallCredential = New-Object System.Management.Automation.PSCredential("Contoso\Install", $secpassword)
$SqlServiceCredential = New-Object System.Management.Automation.PSCredential("Contoso\Install", $secpassword)
$SqlAgentServiceCredential = New-Object System.Management.Automation.PSCredential("Contoso\Install", $secpassword)

$MofPath = 'C:\Mofs'

$ConfigData = @{
    AllNodes = @(
        @{
            NodeName                    = '*'
            SqlInstallCredential        = $SqlInstallCredential
            SqlServiceCredential        = $SqlServiceCredential
            SqlAgentServiceCredential   = $SqlAgentServiceCredential
            MofPath                     = 'C:\Mofs'
            SetupSourcePath             = 'C:\SQL2017'
            SQLSysAdminAccounts         = 'Contoso\Administrator' 
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser        = $true
            InstanceName                = 'TestInstance'
            XpCmdShellEnabled           = 0
        }
        @{
            NodeName = "localhost" 
        }
    )
}

Configuration SqlStandAlone
{
    Import-DscResource -ModuleName SQLCompositeResources
    Import-DscResource -ModuleName SqlServerDsc

    node $allNodes.NodeName
    {
        SingleInstanceInstall StandAlone { 
            Server                    = $Node.Nodename
            SetupSourcePath           = $Node.SetupSourcePath
            SQLSysAdminAccounts       = $Node.SQLSysAdminAccounts
            SqlInstallCredential      = $Node.SqlInstallCredential
            SqlServiceCredential      = $Node.SqlServiceCredential
            SqlAgentServiceCredential = $Node.SqlAgentServiceCredential
            SQLInstance               = $Node.InstanceName
            XpCmdShellEnabled         = $Node.XpCmdShellEnabled
        }

        SqlServerLogin DisableSaAccount {
            ServerName   = $Node.Nodename
            InstanceName = $Node.InstanceName
            Name         = 'sa'
            Ensure       = 'Present'
            Disabled     = $true
            LoginType    = 'SqlLogin'
            DependsOn    = '[SingleInstanceInstall]StandAlone'
        }

        Service DisableSqlBrower {
            Name        = 'SQLBrowser'
            State       = 'Stopped'
            StartupType = 'Disabled'
            DependsOn   = '[SingleInstanceInstall]StandAlone'
        }
    }
}

SQLStandAlone -ConfigurationData $ConfigData -OutputPath $MofPath

Start-DscConfiguration -ComputerName $ConfigData.AllNodes.nodename -Path $MofPath  -Force -Wait -Verbose
