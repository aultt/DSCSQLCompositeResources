Configuration SingleInstanceInstall {
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [string]
        $Server,

        [ValidateNotNullorEmpty()]
        [string]
        $SQLInstance = 'MSSQLSERVER',

        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [string]
        $SetupSourcePath,
        
        [ValidateNotNullorEmpty()]
        [bool]
        $UpdateEnabled = $False,
        
        [ValidateNotNullorEmpty()]
        [bool]
        $ForceReboot = $False,
        
        [ValidateNotNullorEmpty()]
        [string]
        $Features = 'SQLENGINE',
        
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [string]
        $SQLSysAdminAccounts,

        [ValidateNotNullorEmpty()]
        [string]
        $SQLCollation = 'SQL_Latin1_General_CP1_CI_AS',

        [ValidateNotNullorEmpty()]
        [string]
        $InstallSharedDir = 'C:\Program Files\Microsoft SQL Server',

        [ValidateNotNullorEmpty()]
        [string]
        $InstallSharedWOWDir = 'C:\Program Files (x86)\Microsoft SQL Server',


        [ValidateNotNullorEmpty()]
        [string]
        $InstanceDir = 'C:\Program Files\Microsoft SQL Server',

        [ValidateNotNullorEmpty()]
        [string]
        $InstallSQLDataDir = 'C:\Program Files\Microsoft SQL Server\MSSQL.MSSQLSERVER\MSSQL\Data',


        [ValidateNotNullorEmpty()]
        [string]
        $SQLUserDBDir = 'C:\Program Files\Microsoft SQL Server\MSSQL.MSSQLSERVER\MSSQL\Data',

        [ValidateNotNullorEmpty()]
        [string]
        $SQLUserDBLogDir = 'C:\Program Files\Microsoft SQL Server\MSSQL.MSSQLSERVER\MSSQL\Data',

        [ValidateNotNullorEmpty()]
        [string]
        $SQLTempDBDir = 'C:\Program Files\Microsoft SQL Server\MSSQL.MSSQLSERVER\MSSQL\Data',

        [ValidateNotNullorEmpty()]
        [string]
        $SQLTempDBLogDir = 'C:\Program Files\Microsoft SQL Server\MSSQL.MSSQLSERVER\MSSQL\Data',

        [ValidateNotNullorEmpty()]
        [string]
        $SQLBackupDir = 'C:\Program Files\Microsoft SQL Server\MSSQL.MSSQLSERVER\MSSQL\Backup',
        
        [ValidateNotNullorEmpty()]
        [string]
        $SQLPort = '1433',

        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $SqlInstallCredential,

        [Parameter()]
        [ValidateNotNullorEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $SqlAdministratorCredential = $SqlInstallCredential,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $SqlServiceCredential,

        [Parameter()]
        [ValidateNotNullorEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $SqlAgentServiceCredential = $SqlServiceCredential,
        
        [ValidateNotNullorEmpty()]
        [string]
        $VirtualMemoryInitialSize = 4096,
        
        [ValidateNotNullorEmpty()]
        [string]
        $VirtualMemoryMaximumSize = 4096,
        
        [ValidateNotNullorEmpty()]
        [string]
        $VirtualMemoryDrive = 'C',
        
        [ValidateNotNullorEmpty()]
        [string]
        $XpCmdShellEnabled = 0,

        [ValidateNotNullorEmpty()]
        [string]
        $OptimizeAdhocWorkloads = 0,

        [ValidateNotNullorEmpty()]
        [string]
        $CrossDBOwnershipChaining = 0,

        [ValidateNotNullorEmpty()]
        [string]
        $IsSqlClrEnabled = 0,
        
        [ValidateNotNullorEmpty()]
        [string]
        $AgentXPsEnabled = 1,

        [ValidateNotNullorEmpty()]
        [string]
        $DatabaseMailEnabled = 0,

        [ValidateNotNullorEmpty()]
        [string]
        $OleAutomationProceduresEnabled = 0,
        
        [ValidateNotNullorEmpty()]
        [string]
        $DefaultBackupCompression = 1,

        [ValidateNotNullorEmpty()]
        [string]
        $RemoteDacConnectionsEnabled = 0,

        [ValidateNotNullorEmpty()]
        [string]
        $AdHocDistributedQueriesEnabled = 0
    )
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName SqlServerDsc
    Import-DscResource -ModuleName SQLCompositeResources
    
    WindowsFeature 'NetFramework45' {
        Name   = 'NET-Framework-45-Core'
        Ensure = 'Present'
    }
    
    SqlSetup 'SQLInstall' {
        InstanceName         = $SQLInstance
        Features             = $Features
        SQLCollation         = $SQLCollation
        SQLSvcAccount        = $SqlServiceCredential
        AgtSvcAccount        = $SqlAgentServiceCredential
        SQLSysAdminAccounts  = $SQLSysAdminAccounts 
        InstallSharedDir     = $InstallSharedDir
        InstallSharedWOWDir  = $InstallSharedWOWDir
        InstanceDir          = $InstanceDir
        InstallSQLDataDir    = $InstallSQLDataDir
        SQLUserDBDir         = $SQLUserDBDir
        SQLUserDBLogDir      = $SQLUserDBLogDir
        SQLTempDBDir         = $SQLTempDBDir
        SQLTempDBLogDir      = $SQLTempDBLogDir
        SQLBackupDir         = $SQLBackupDir
        SourcePath           = $SetupSourcePath
        
        UpdateEnabled        = $UpdateEnabled
        ForceReboot          = $ForceReboot

        PsDscRunAsCredential = $SqlInstallCredential

        DependsOn            = '[WindowsFeature]NetFramework45'
    }

    SQLConfiguration 'ConfigureSQLInstall' {
        Server                         = $Server
        SQLInstance                    = $SQLInstance
        SQLPort                        = $SQLPort
        VirtualMemoryInitialSize       = $VirtualMemoryInitialSize
        VirtualMemoryMaximumSize       = $VirtualMemoryMaximumSize
        VirtualMemoryDrive             = $VirtualMemoryDrive
        XpCmdShellEnabled              = $XpCmdShellEnabled
        OptimizeAdhocWorkloads         = $OptimizeAdhocWorkloads
        CrossDBOwnershipChaining       = $CrossDBOwnershipChaining
        IsSqlClrEnabled                = $IsSqlClrEnabled
        AgentXPsEnabled                = $AgentXPsEnabled
        DatabaseMailEnabled            = $DatabaseMailEnabled
        OleAutomationProceduresEnabled = $OleAutomationProceduresEnabled
        DefaultBackupCompression       = $DefaultBackupCompression
        RemoteDacConnectionsEnabled    = $RemoteDacConnectionsEnabled
        AdHocDistributedQueriesEnabled = $AdHocDistributedQueriesEnabled
    
        DependsOn                      = '[SqlSetup]SQLInstall'
    }

}
