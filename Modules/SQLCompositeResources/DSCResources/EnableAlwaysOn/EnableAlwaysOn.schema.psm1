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
        $HADRPort = 5022,
        
        [ValidateNotNullorEmpty()]
        [string]
        $RestartTimeout = 120
    )

    Import-DscResource -ModuleName SqlServerDsc
    
    # Adding the required service account to allow the cluster to log into SQL
    SqlServerLogin AddNTServiceClusSvc {
        Ensure               = 'Present'
        Name                 = 'NT SERVICE\ClusSvc'
        LoginType            = 'WindowsUser'
        ServerName           = = $Server
        InstanceName         = $SQLInstance
        PsDscRunAsCredential = $SqlInstallCredential
    }

    # Add the required permissions to the cluster service login
    SqlServerPermission AddNTServiceClusSvcPermissions {
        DependsOn            = '[SqlServerLogin]AddNTServiceClusSvc'
        Ensure               = 'Present'
        ServerName           = = $Server
        InstanceName         = $SQLInstance
        Principal            = 'NT SERVICE\ClusSvc'
        Permission           = 'AlterAnyAvailabilityGroup', 'ViewServerState'
        PsDscRunAsCredential = $SqlInstallCredential
    }

    # Create a DatabaseMirroring endpoint
    SqlServerEndpoint HADREndpoint {
        EndPointName         = 'HADR'
        Ensure               = 'Present'
        Port                 = $HADRPort
        ServerName           = = $Server
        InstanceName         = $SQLInstance
        PsDscRunAsCredential = $SqlInstallCredential
    }
    
    SqlServerLogin AddSQLServiceAccount {
        Ensure               = 'Present'
        Name                 = $SqlServiceCredential.UserName
        LoginType            = 'WindowsUser'
        ServerName           = = $Server
        InstanceName         = $SQLInstance
        PsDscRunAsCredential = $SqlInstallCredential
    }

    SqlServerEndpointPermission SQLConfigureEndpointPermission {
        Ensure               = 'Present'
        ServerName           = = $Server
        InstanceName         = $SQLInstance
        Name                 = 'HADR'
        Principal            = $SqlServiceCredential.UserName
        Permission           = 'CONNECT'
    
        PsDscRunAsCredential = $SqlInstallCredential
        DependsOn            = '[SqlServerEndpoint]HADREndpoint', '[SqlServerLogin]AddSQLServiceAccount'
    }
    
    SqlAlwaysOnService 'EnableAlwaysOn' {
        Ensure               = 'Present'
        ServerName           = $Server
        InstanceName         = $SQLInstance
        RestartTimeout       = $RestartTimeout

        PsDscRunAsCredential = $SqlInstallCredential
    }

}
