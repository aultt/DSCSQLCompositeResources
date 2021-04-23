Configuration WindowsClusterInstall {
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [ValidateSet('Present', 'Absent')]
        [string]
        $Ensure)

    Import-DscResource -ModuleName xFailoverCluster

    WindowsFeature FailoverFeature {
        Name   = "Failover-Clustering"
        Ensure = $Ensure
    }
    
    WindowsFeature RSATClusteringMgmt {
        Ensure    = $Ensure
        Name      = "RSAT-Clustering-Mgmt"

        DependsOn = "[WindowsFeature]FailoverFeature"
    }

    WindowsFeature RSATClusteringPowerShell {
        Ensure    = $Ensure
        Name      = "RSAT-Clustering-PowerShell"

        DependsOn = "[WindowsFeature]FailoverFeature"
    }

    WindowsFeature RSATClusteringCmdInterface {
        Ensure    = $Ensure
        Name      = "RSAT-Clustering-CmdInterface"

        DependsOn = "[WindowsFeature]RSATClusteringPowerShell"
    }

}
