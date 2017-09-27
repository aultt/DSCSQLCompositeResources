Configuration SecondaryAlwaysOn {
Param(  [Parameter(Mandatory = $true)]
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
        $ClusterWaitRetryInterval = 10,

        [ValidateNotNullorEmpty()]
        [string]
        $ClusterWaitRetryCount = 60,
        
        [ValidateNotNullorEmpty()]
        [string]
        $SQLInstance = 'MSSQLSERVER',

        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [string]
        $SetupSourcePath,
        
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
        $SqlAgentServiceCredential = $SqlServiceCredential)

    Import-DscResource -ModuleName xFailovercluster -ModuleVersion 1.8.0.0
    Import-DscResource -ModuleName SQLCompositeResources -ModuleVersion 1.0

    SingleInstanceInstall Standalone 
    { 
        Server = $Server
        SetupSourcePath = $SetupSourcePath
        SQLSysAdminAccounts = $SQLSysAdminAccounts
        SqlInstallCredential = $SqlInstallCredential
        SqlServiceCredential = $SqlServiceCredential
        SqlAgentServiceCredential = $SqlAgentServiceCredential
    } 
    
    WindowsClusterInstall SecondaryNode
    {
        Ensure = 'Present'
        DependsOn = '[SingleInstanceInstall]Standalone'
    }
    
    xWaitForCluster WaitForMyCluster
    {
        Name = $ClusterName
        RetryIntervalSec = $ClusterWaitRetryInterval
        RetryCount = $ClusterWaitRetryCount
        PsDscRunAsCredential  = $SqlInstallCredential
        DependsOn = '[WindowsClusterInstall]SecondaryNode'
    }
    
    xCluster JoinNodeToCluster
    {
        Name                          = $ClusterName 
        StaticIPAddress               = $ClusterIP
        DomainAdministratorCredential = $SqlInstallCredential
        DependsOn                     = '[xWaitForCluster]WaitForMyCluster'
    }
    
    EnableAlwaysOn EnableSecondary
    {
        Server = $Server
        SqlInstallCredential = $SqlInstallCredential
    
        DependsOn = '[WindowsClusterInstall]SecondaryNode','[SingleInstanceInstall]Standalone'
    }

}