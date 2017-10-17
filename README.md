[![Build status](https://ci.appveyor.com/api/projects/status/6a59vfritv4kbc7d/branch/master?svg=true)](https://ci.appveyor.com/project/Microsoft/DSC-data-driven-deployment/branch/master)

# DSC SQL Composite Resources

SQL Server Composite Resources to simplify and reduce the duplication of code within Desired State Configuration.

## Why?

Reduce the amount of duplicated code throughout a configuration.  Simplify configuration making it easier to read and maintain. 

## Prerequisites

Requires PowerShell 5.0
Dependency on existing DSC resources from the Gallery.  Specific versions are leveraged and called out below.
	
	- xSQLServer 8.2.0.0
	- xFailoverCluster 1.8.0.0
	- xComputerManagement 2.1.0.0
	- xStorage 3.2.0.0

## Installation

Download zip file of module.  Extract and rename to SQLCompositeResources in the PowerShell modules directory

## Updates 

Version 2.0

Resources added

* FailOverClusterDisk
* FailOverClusterInstanceAdditionalNode
* FailOverClusterInstanceFirstNode


Resources Updated

* PrimaryAlwaysOn
* SecondaryAlwaysOn
* SingleInstanceInstall 
  

Version 1.0 - Initial Load 

Resources Added 

* AvailabilityGroup
* AvailabilityGroupJoin
* EnableAlwaysOn
* PrimaryAlwaysOn
* SecondaryAlwaysOn
* SingleInstanceInstall
* SQLConfiguration
* WindowsClusterInstall


## Contribute
There are many ways to contribute.

* [Submit bugs](https://github.com/Microsoft/DSC-data-driven-deployment/issues) and help us verify fixes as they are checked in.
* Review [code changes](https://github.com/Microsoft/DSC-data-driven-deployment/pulls).
* Contribute bug fixes and features.

For code contributions, you will need to complete a Contributor License Agreement (CLA). Briefly, this agreement testifies that you grant us permission to use the submitted change according to the terms of the project's license, and that the work being submitted is under the appropriate copyright.

## Code of Conduct 
This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
## License

This project is [licensed under the MIT License](LICENSE).