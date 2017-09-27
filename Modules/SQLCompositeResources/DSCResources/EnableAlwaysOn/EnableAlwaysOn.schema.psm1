Configuration EnableAlwaysOn {
Param(  
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [string]
        $Server,
        
        [ValidateNotNullorEmpty()]
        [string]
        $SQLInstance = 'MSSQLSERVER',
        
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $SqlInstallCredential,
        
        [ValidateNotNullorEmpty()]
        [string]
        $HADRPort =5022,
        
        [ValidateNotNullorEmpty()]
        [string]
        $RestartTimeout = 120
)

    Import-DscResource -ModuleName xSQLServer -ModuleVersion 8.1.0.0
    
    # Adding the required service account to allow the cluster to log into SQL
    xSQLServerLogin AddNTServiceClusSvc
    {
        Ensure               = 'Present'
        Name                 = 'NT SERVICE\ClusSvc'
        LoginType            = 'WindowsUser'
        SQLServer            = $Server
        SQLInstanceName      = $SQLInstance
        PsDscRunAsCredential = $SqlInstallCredential
    }

    # Add the required permissions to the cluster service login
    xSQLServerPermission AddNTServiceClusSvcPermissions
    {
        DependsOn            = '[xSQLServerLogin]AddNTServiceClusSvc'
        Ensure               = 'Present'
        NodeName             = $Server
        InstanceName         = $SQLInstance
        Principal            = 'NT SERVICE\ClusSvc'
        Permission           = 'AlterAnyAvailabilityGroup', 'ViewServerState'
        PsDscRunAsCredential = $SqlInstallCredential
    }

    # Create a DatabaseMirroring endpoint
    xSQLServerEndpoint HADREndpoint
    {
        EndPointName         = 'HADR'
        Ensure               = 'Present'
        Port                 = $HADRPort
        SQLServer            = $Server
        SQLInstanceName      = $SQLInstance
        PsDscRunAsCredential = $SqlInstallCredential
    }
    
    xSQLServerLogin AddSQLServiceAccount
    {
        Ensure               = 'Present'
        Name                 = $SqlServiceCredential.UserName
        LoginType            = 'WindowsUser'
        SQLServer            = $Server
        SQLInstanceName      = $SQLInstance
        PsDscRunAsCredential = $SqlInstallCredential
    }

    xSQLServerEndpointPermission SQLConfigureEndpointPermission
    {
        Ensure               = 'Present'
        NodeName             = $Server
        InstanceName         = $SQLInstance
        Name                 = 'HADR'
        Principal            = $SqlServiceCredential.UserName
        Permission           = 'CONNECT'
    
        PsDscRunAsCredential = $SqlInstallCredential
        DependsOn = '[xSQLServerEndpoint]HADREndpoint','[xSQLServerLogin]AddSQLServiceAccount'
    }
    
    xSQLServerAlwaysOnService 'EnableAlwaysOn'
    {
        Ensure               = 'Present'
        SQLServer            = $Server
        SQLInstanceName      = $SQLInstance
        RestartTimeout       = $RestartTimeout

        PsDscRunAsCredential = $SqlInstallCredential
    }


}