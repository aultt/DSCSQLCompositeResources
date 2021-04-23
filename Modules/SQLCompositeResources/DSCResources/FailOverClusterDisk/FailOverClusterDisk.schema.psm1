Configuration FailOverClusterDisk {
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [hashtable[]]
        $DiskConfiguration
    )
    
    Import-DscResource -ModuleName StorageDsc
    Import-DscResource -ModuleName xFailoverCluster

    foreach ($Disk in $DiskConfiguration) {
        xClusterDisk $Disk.Label {
            Number    = $Disk.Number
            Ensure    = 'Present'
            Label     = $Disk.Label

            DependsOn = "[Disk]$($Disk.Label)"
        }   

        WaitforDisk $Disk.Label {
            DiskId           = $Disk.Number
            RetryIntervalSec = $Disk.RetryInterval
            RetryCount       = $Disk.RetryCount

            DependsOn        = "[Disk]$($Disk.Label)"
        }
    
        Disk $Disk.Label {
            DiskId             = $Disk.Number
            DriveLetter        = $Disk.Letter
            FSFormat           = $Disk.Format
            AllocationUnitSize = 64KB
        }
    }
}
