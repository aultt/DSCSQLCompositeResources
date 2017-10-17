Configuration PrimaryAlwaysOn {
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [string]
        $Server,
        
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [string]
        $ClusterName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [string]
        $ClusterIP,

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
        $Features ='SQLENGINE',
        
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [string]
        $SQLSysAdminAccounts,

        [ValidateNotNullorEmpty()]
        [string]
        $SQLCollation ='SQL_Latin1_General_CP1_CI_AS',

        [ValidateNotNullorEmpty()]
        [string]
        $InstallSharedDir = 'C:\Program Files\Microsoft SQL Server',

        [ValidateNotNullorEmpty()]
        [string]
        $InstallSharedWOWDir = 'C:\Program Files (x86)\Microsoft SQL Server',

        [ValidateNotNullorEmpty()]
        [string]
        $InstanceDir ='C:\Program Files\Microsoft SQL Server',

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
        
        [ValidateNotNullorEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $DomainAdministratorCred = $SqlInstallCredential,
        
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
    Import-DscResource -ModuleName SQLCompositeResources
    Import-DscResource -ModuleName xFailoverCluster -ModuleVersion 1.8.0.0

    SingleInstanceInstall Standalone 
    { 
        Server = $Server
        SQLInstance = $SQLInstance
        SetupSourcePath = $SetupSourcePath
        UpdateEnabled = $UpdateEnabled
        ForceReboot = $ForceReboot
        Features = $Features
        SQLSysAdminAccounts = $SQLSysAdminAccounts
        SQLCollation = $SQLCollation
        InstallSharedDir = $InstallSharedDir
        InstallSharedWOWDir = $InstallSharedWOWDir
        InstanceDir = $InstanceDir
        InstallSQLDataDir = $InstallSQLDataDir
        SQLUserDBDir = $SQLUserDBDir
        SQLUserDBLogDir = $SQLUserDBLogDir
        SQLTempDBDir = $SQLTempDBDir
        SQLTempDBLogDir = $SQLTempDBLogDir
        SQLBackupDir = $SQLBackupDir
        SQLPort = $SQLPort
        SqlInstallCredential = $SqlInstallCredential
        SqlServiceCredential = $SqlServiceCredential
        SqlAgentServiceCredential = $SqlAgentServiceCredential
        VirtualMemoryInitialSize = $VirtualMemoryInitialSize
        VirtualMemoryMaximumSize = $VirtualMemoryMaximumSize
        VirtualMemoryDrive = $VirtualMemoryDrive
        XpCmdShellEnabled = $XpCmdShellEnabled
        OptimizeAdhocWorkloads= $OptimizeAdhocWorkloads
        CrossDBOwnershipChaining = $CrossDBOwnershipChaining
        IsSqlClrEnabled = $IsSqlClrEnabled
        AgentXPsEnabled = $AgentXPsEnabled
        DatabaseMailEnabled = $DatabaseMailEnabled
        OleAutomationProceduresEnabled = $OleAutomationProceduresEnabled
        DefaultBackupCompression = $DefaultBackupCompression
        RemoteDacConnectionsEnabled = $RemoteDacConnectionsEnabled
        AdHocDistributedQueriesEnabled = $AdHocDistributedQueriesEnabled

    } 

    WindowsClusterInstall PrimaryNode
    {
        Ensure = 'Present'
    }

    xcluster AlwaysOnClust
    {
        Name = $ClusterName 
        DomainAdministratorCredential = $DomainAdministratorCred
        StaticIPAddress = $ClusterIP
    
        DependsOn = "[WindowsClusterInstall]PrimaryNode"
    }

    EnableAlwaysOn EnablePrimary
    {
        Server = $Server
        SqlInstallCredential = $SqlInstallCredential

        DependsOn = '[WindowsClusterInstall]PrimaryNode','[xcluster]AlwaysOnClust'
    }
}