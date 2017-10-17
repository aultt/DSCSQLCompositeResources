Configuration FailOverClusterInstanceFirstNode {
param
    (   
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

        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [string]
        $InstallSQLDataDir,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [string]
        $SQLUserDBDir,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [string]
        $SQLUserDBLogDir,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [string]
        $SQLTempDBDir,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [string]
        $SQLTempDBLogDir,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [string]
        $SQLBackupDir,
        
        [ValidateNotNullorEmpty()]
        [string]
        $SQLPort = '1433',

        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [string]
        $FailoverClusterNetworkName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [string]
        $FailoverClusterIPAddress,

        [ValidateNotNullorEmpty()]
        [string]
        $FailoverClusterGroupName = $FailoverClusterNetworkName,
        
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [hashtable[]]
        $DiskConfiguration,

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
    Import-DscResource -ModuleName xSQLServer -ModuleVersion 8.2.0.0

    WindowsClusterInstall FCINode1
    {
        Ensure = 'Present'
    }
    
    xcluster FCICluster
    {
        Name = $ClusterName 
        DomainAdministratorCredential = $DomainAdministratorCred
        StaticIPAddress = $ClusterIP
    
        DependsOn = '[WindowsClusterInstall]FCINode1'
    }
    
    FailOverClusterDisk SetupDisks
    {
        DiskConfiguration = $DiskConfiguration

        DependsOn = '[xcluster]FCICluster'
    }


    WindowsFeature 'NetFramework45'
    {
        Name   = 'NET-Framework-45-Core'
        Ensure = 'Present'
    }
    
    xSQLServerSetup FCISQLNode1
    {
        Action                     = 'InstallFailoverCluster'
        ForceReboot                = $ForceReboot
        UpdateEnabled              = $UpdateEnabled
        SourcePath                 = $SetupSourcePath
    
        InstanceName               = $SQLInstance
        Features                   = $Features
    
        InstallSharedDir           = $InstallSharedDir
        InstallSharedWOWDir        = $InstallSharedWOWDir
        InstanceDir                = $InstanceDir
    
        SQLCollation               = $SQLCollation
        SQLSvcAccount              = $SqlServiceCredential
        AgtSvcAccount              = $SqlAgentServiceCredential
        SQLSysAdminAccounts        = $SQLSysAdminAccounts
    
        # Drive: must be a shared disk.
        InstallSQLDataDir          = $InstallSQLDataDir
        SQLUserDBDir               = $SQLUserDBDir
        SQLUserDBLogDir            = $SQLUserDBLogDir
        SQLTempDBDir               = $SQLTempDBDir
        SQLTempDBLogDir            = $SQLTempDBLogDir
        SQLBackupDir               = $SQLBackupDir
    
        FailoverClusterNetworkName = $FailoverClusterNetworkName
        FailoverClusterIPAddress   = $FailoverClusterIPAddress
        FailoverClusterGroupName   = $FailoverClusterGroupName
    
        PsDscRunAsCredential       = $SqlInstallCredential
    
        DependsOn                  = '[WindowsFeature]NetFramework45', '[FailOverClusterDisk]SetupDisks'
    }

    SQLConfiguration 'ConfigureSQLInstall'
    {
        Server = $FailoverClusterNetworkName
        SQLInstance = $SQLInstance
        SQLPort = $SQLPort
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

        DependsOn            = '[xSQLServerSetup]FCISQLNode1'
    }
}