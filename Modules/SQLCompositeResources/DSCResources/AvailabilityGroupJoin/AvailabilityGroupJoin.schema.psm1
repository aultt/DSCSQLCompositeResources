Configuration AvailabilityGroupJoin {
    Param(  
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [string]
        $Server,
        
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [string]
        $PrimaryReplica,
        
        [ValidateNotNullorEmpty()]
        [string]
        $SQLInstance = 'MSSQLSERVER',

        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $SqlInstallCredential,
    
        [Parameter(Mandatory = $true)]    
        [ValidateNotNullorEmpty()]
        [String[]]
        $AvailabilityGroupName,
         
        [ValidateNotNullorEmpty()]
        [String]
        $AvailabilityMode = 'SynchronousCommit',

        [ValidateNotNullorEmpty()]
        [int16]
        $BackupPriority = 50,

        [ValidateNotNullorEmpty()]
        [int16]
        $AvailabilityGroupRetryIntervalSec = 20,

        [ValidateNotNullorEmpty()]
        [int16]
        $AvailabilityGroupRetryCount = 30,

        [ValidateNotNullorEmpty()]
        [String]
        $ConnectionModeInPrimaryRole = 'AllowAllConnections',

        [ValidateNotNullorEmpty()]
        [String]
        $ConnectionModeInSecondaryRole = 'AllowNoConnections',

        [ValidateNotNullorEmpty()]
        [String]
        $FailoverMode = 'Automatic'
    )

    Import-DscResource -ModuleName SqlServerDsc
    
    foreach ($AG in $AvailabilityGroupName) {
        SqlWaitForAG $AG {
            Name                 = $AG
            RetryIntervalSec     = $AvailabilityGroupRetryIntervalSec 
            RetryCount           = $AvailabilityGroupRetryCount

            PsDscRunAsCredential = $SqlInstallCredential
        }
        
        SqlAGReplica $AG {
            Ensure                        = 'Present'
            Name                          = $Server
            AvailabilityGroupName         = $AG
            ServerName                    = = $Server
            InstanceName                  = $SQLInstance
            PrimaryReplicaServerName      = = $PrimaryReplica
            PrimaryReplicaInstanceName    = = $SQLInstance
            AvailabilityMode              = $AvailabilityMode             
            BackupPriority                = $BackupPriority               
            ConnectionModeInPrimaryRole   = $ConnectionModeInPrimaryRole  
            ConnectionModeInSecondaryRole = $ConnectionModeInSecondaryRole
            FailoverMode                  = $FailoverMode                 
                
            PsDscRunAsCredential          = $SqlInstallCredential
            DependsOn                     = "[SqlWaitForAG]$AG"           
        }
    }
}
