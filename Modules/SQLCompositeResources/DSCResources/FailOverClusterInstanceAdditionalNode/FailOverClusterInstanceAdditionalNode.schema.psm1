Configuration FailOverClusterInstanceAdditionalNode {
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
        $FailoverClusterNetworkName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $SqlInstallCredential,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $SqlServiceCredential,

        [Parameter()]
        [ValidateNotNullorEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $SqlAgentServiceCredential = $SqlServiceCredential
    )
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName SQLCompositeResources -ModuleVersion 1.0
    Import-DscResource -ModuleName xFailoverCluster -ModuleVersion 1.8.0.0
    Import-DscResource -ModuleName xSQLServer -ModuleVersion 8.2.0.0

    WindowsClusterInstall AdditionalNode
    {
        Ensure = 'Present'
    }
    
    xWaitForCluster WaitForMyCluster
    {
        Name = $ClusterName
        RetryIntervalSec = $ClusterWaitRetryInterval
        RetryCount = $ClusterWaitRetryCount
        PsDscRunAsCredential  = $SqlInstallCredential
        DependsOn = '[WindowsClusterInstall]AdditionalNode'
    }
    
    xCluster JoinNodeToCluster
    {
        Name                          = $ClusterName 
        StaticIPAddress               = $ClusterIP
        DomainAdministratorCredential = $SqlInstallCredential
        DependsOn                     = '[xWaitForCluster]WaitForMyCluster'
    }
    
    WindowsFeature 'NetFramework45'
    {
        Name   = 'NET-Framework-45-Core'
        Ensure = 'Present'
    }

    xSQLServerSetup FCISQLAdditionalNode
    {
        Action                     = 'AddNode'
        ForceReboot                = $ForceReboot
        UpdateEnabled              = $UpdateEnabled
        SourcePath                 = $SetupSourcePath
        InstanceName               = $SQLInstance
        Features                   = $Features
        SQLSvcAccount              = $SqlServiceCredential
        AgtSvcAccount              = $SqlAgentServiceCredential
        FailoverClusterNetworkName = $FailoverClusterNetworkName

        PsDscRunAsCredential       = $SqlInstallCredential

        DependsOn                  = '[WindowsFeature]NetFramework45'
    }
}