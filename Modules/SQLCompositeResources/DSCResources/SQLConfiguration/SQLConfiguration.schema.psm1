Configuration SQLConfiguration {
Param(  [Parameter(Mandatory = $true)]
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

    Import-DscResource -ModuleName xSQLServer -ModuleVersion 8.2.0.0
    Import-DscResource -ModuleName xComputerManagement -ModuleVersion 2.1.0.0  
    
    xPowerPlan SetPlanHighPerformance
    {
        IsSingleInstance = 'yes'
        Name = "High Performance"
    }

    xVirtualMemory SetVirtualMem
    {
         Drive = $VirtualMemoryDrive
         Type = 'CustomSize'
         InitialSize = $VirtualMemoryInitialSize
         MaximumSize = $VirtualMemoryMaximumSize
    }
    xSQLServerMemory 'SetSQLMemory'
    {
        SQLInstanceName = $SQLInstance
        DynamicAlloc = $true
        Ensure = 'Present'
    }

    xSQLServerMaxDop 'SetMaxXop'
    {
        SQLInstanceName = $SQLInstance
        DynamicAlloc = $true
        Ensure = 'Present'
    }

    xSQLServerNetwork 'ConfigNetwork'
    {
       InstanceName = $SQLInstance
       ProtocolName = 'TCP'
       IsEnabled = $true
       TcpPort = $SQLPort
       RestartService = $true
    }

    xSQLServerConfiguration 'XPCmdShellEnabled'
    {
        SQLServer = $Server
        SQLInstanceName = $SQLInstance
        OptionName = "xp_cmdshell" 
        OptionValue = $XpCmdShellEnabled
        RestartService = $false
    }


    xSQLServerConfiguration 'AgentXPsEnabled'
    {
        SQLServer = $Server
        SQLInstanceName = $SQLInstance
        OptionName = "Agent XPs" 
        OptionValue = $AgentXPsEnabled
        RestartService = $false
    }

    xSQLServerConfiguration 'DatabaseMailEnabled'
    {
        SQLServer = $Server
        SQLInstanceName = $SQLInstance
        OptionName = "Database Mail XPs" 
        OptionValue = $DatabaseMailEnabled
        RestartService = $false
    }

    xSQLServerConfiguration 'OptimizeAdhocWorkloads' 
    {
        SQLServer = $Server
        SQLInstanceName = $SQLInstance
        OptionName = "optimize for ad hoc workloads" 
        OptionValue = $OptimizeAdhocWorkloads
        RestartService = $false
    }

    xSQLServerConfiguration 'CrossDBOwnershipChaining'
    {
        SQLServer = $Server
        SQLInstanceName = $SQLInstance
        OptionName = "cross db ownership chaining" 
        OptionValue = $CrossDBOwnershipChaining
        RestartService = $false
    }

    xSQLServerConfiguration 'IsSqlClrEnabled'
    {
        SQLServer = $Server
        SQLInstanceName = $SQLInstance
        OptionName = "clr enabled" 
        OptionValue = $IsSqlClrEnabled
        RestartService = $false
    }

    xSQLServerConfiguration 'OleAutomationProceduresEnabled'
    {
        SQLServer = $Server
        SQLInstanceName = $SQLInstance
        OptionName = "Ole Automation Procedures" 
        OptionValue = $OleAutomationProceduresEnabled
        RestartService = $false
    }

    xSQLServerConfiguration 'DefaultBackupCompression'
    {
        SQLServer = $Server
        SQLInstanceName = $SQLInstance
        OptionName = "backup compression default" 
        OptionValue = $DefaultBackupCompression
        RestartService = $false
    }

    xSQLServerConfiguration 'RemoteDacConnectionsEnabled'
    {
        SQLServer = $Server
        SQLInstanceName = $SQLInstance
        OptionName = "remote admin connections" 
        OptionValue = $RemoteDacConnectionsEnabled
        RestartService = $false
    }

    xSQLServerConfiguration 'AdHocDistributedQueriesEnabled'
    {
        SQLServer = $Server
        SQLInstanceName = $SQLInstance
        OptionName = "Ad Hoc Distributed Queries" 
        OptionValue = $AdHocDistributedQueriesEnabled
        RestartService = $false
    }

}