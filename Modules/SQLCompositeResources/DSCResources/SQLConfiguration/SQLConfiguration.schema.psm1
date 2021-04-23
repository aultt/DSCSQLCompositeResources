Configuration SQLConfiguration {
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [string]
        $Server,

        [ValidateNotNullorEmpty()]
        [string]
        $SQLInstance = 'MSSQLSERVER',
        
        [ValidateNotNullorEmpty()]
        [string]
        $SQLPort = '1433',
        
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

    Import-DscResource -ModuleName SQLServerDsc
    Import-DscResource -ModuleName ComputerManagementDsc
    
    PowerPlan SetPlanHighPerformance {
        IsSingleInstance = 'Yes'
        Name             = "High Performance"
    }

    VirtualMemory SetVirtualMem {
        Drive       = $VirtualMemoryDrive
        Type        = 'CustomSize'
        InitialSize = $VirtualMemoryInitialSize
        MaximumSize = $VirtualMemoryMaximumSize
    }
    SqlServerMemory 'SetSQLMemory' {
        InstanceName = $SQLInstance
        DynamicAlloc = $true
        Ensure       = 'Present'
    }

    SqlServerMaxDop 'SetMaxXop' {
        InstanceName = $SQLInstance
        DynamicAlloc = $true
        Ensure       = 'Present'
    }

    SqlServerNetwork 'ConfigNetwork' {
        InstanceName   = $SQLInstance
        ProtocolName   = 'TCP'
        IsEnabled      = $true
        TcpPort        = $SQLPort
        RestartService = $true
    }

    SqlServerConfiguration 'XPCmdShellEnabled' {
        ServerName     = $Server
        InstanceName   = $SQLInstance
        OptionName     = "xp_cmdshell" 
        OptionValue    = $XpCmdShellEnabled
        RestartService = $false
    }

    SqlServerConfiguration 'AgentXPsEnabled' {
        ServerName     = $Server
        InstanceName   = $SQLInstance
        OptionName     = "Agent XPs" 
        OptionValue    = $AgentXPsEnabled
        RestartService = $false
    }

    SqlServerConfiguration 'DatabaseMailEnabled' {
        ServerName     = $Server
        InstanceName   = $SQLInstance
        OptionName     = "Database Mail XPs" 
        OptionValue    = $DatabaseMailEnabled
        RestartService = $false
    }

    SqlServerConfiguration 'OptimizeAdhocWorkloads' {
        ServerName     = $Server
        InstanceName   = $SQLInstance
        OptionName     = "optimize for ad hoc workloads" 
        OptionValue    = $OptimizeAdhocWorkloads
        RestartService = $false
    }

    SqlServerConfiguration 'CrossDBOwnershipChaining' {
        ServerName     = $Server
        InstanceName   = $SQLInstance
        OptionName     = "cross db ownership chaining" 
        OptionValue    = $CrossDBOwnershipChaining
        RestartService = $false
    }

    SqlServerConfiguration 'IsSqlClrEnabled' {
        ServerName     = $Server
        InstanceName   = $SQLInstance
        OptionName     = "clr enabled" 
        OptionValue    = $IsSqlClrEnabled
        RestartService = $false
    }

    SqlServerConfiguration 'OleAutomationProceduresEnabled' {
        ServerName     = $Server
        InstanceName   = $SQLInstance
        OptionName     = "Ole Automation Procedures" 
        OptionValue    = $OleAutomationProceduresEnabled
        RestartService = $false
    }

    SqlServerConfiguration 'DefaultBackupCompression' {
        ServerName     = $Server
        InstanceName   = $SQLInstance
        OptionName     = "backup compression default" 
        OptionValue    = $DefaultBackupCompression
        RestartService = $false
    }

    SqlServerConfiguration 'RemoteDacConnectionsEnabled' {
        ServerName     = $Server
        InstanceName   = $SQLInstance
        OptionName     = "remote admin connections" 
        OptionValue    = $RemoteDacConnectionsEnabled
        RestartService = $false
    }

    SqlServerConfiguration 'AdHocDistributedQueriesEnabled' {
        ServerName     = $Server
        InstanceName   = $SQLInstance
        OptionName     = "Ad Hoc Distributed Queries" 
        OptionValue    = $AdHocDistributedQueriesEnabled
        RestartService = $false
    }

}
