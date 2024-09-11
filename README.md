---
external help file: Get-PowerBIReportPagesForTesting-help.xml
Module Name: Get-PowerBIReportPagesForTesting
online version:
schema: 2.0.0
---

# Get-PowerBIReportPagesForTesting

# Get-PowerBIReportPagesForTesting Module

This PowerShell module `Get-PowerBIReportPagesForTesting` helps identify the reports and pages in a Power BI workspace that use a specific dataset/semantic model. It also provides logging capabilities for various output formats, including Azure DevOps (ADO) pipelines, host console, and tables.

## Features

1. Identify reports and pages using a specific dataset across multiple Power BI workspaces.
2. Supports different Power BI environments (`Public`, `Germany`, `China`, `USGov`, etc.).
3. Flexible logging options (ADO, Host, Table).
4. Outputs results to a CSV file or as an array of objects.

## Prerequisites

1. PowerShell 5.1 or higher.
2. PowerShell Modules:
  2.1 `MicrosoftPowerBIMgmt` (for Power BI operations)
  2.2 `SqlServer` (for SQL-related operations)
  2.3  `Pester` (for unit testing and test automation)
  
  If the modules are not installed, the script will install them automatically.

## Installation

1. Clone the repository or download the `.psm1` file.
2. Import the module using:

    ```powershell
    Import-Module -Name Get-PowerBIReportPagesForTesting.psm1
    ```
3. Install `Pester` for unit testing:

    ```powershell
    Install-Module -Name Pester -Force -Scope CurrentUser
    ```

## Usage

The function `Get-PowerBIReportPagesForTesting` has several parameters that allow you to customize its behavior.
### PowerShell Module Parameters:
1. DatasetId (Mandatory)
  -**Description**: The unique identifier of the dataset/semantic model to test.
2. WorkspaceId (Mandatory)
- **Description**: The unique identifier of the Power BI workspace containing the dataset.
3. WorkspaceIdsToCheck (Mandatory)
- **Description**: An array of workspace IDs where reports using the dataset should be identified.
4. Credential (Mandatory)
- **Description**: A PowerShell credential object for authenticating with the Power BI Service.
5. TenantId (Mandatory)
- **Description**: The Azure AD tenant ID where the Power BI workspace resides.
6. Path (Mandatory)
- **Description**: The path to the CSV file where results will be saved.
7. LogOutput (Mandatory)
- **Description**: Specifies the log destination.
- **Options**: 
  - 'ADO'
  - 'Host'
  - 'Table'
8. Environment (Optional)
- **Description**: Specifies the Power BI environment to connect to.
- **Options**: 
  - Public
  - Germany
  - China
  - USGov
  - USGovHigh
  - USGovDoD
9. RoleUserName (Optional)
- **Description**: The name of the user for which Role-Level Security (RLS) testing will be conducted.


### Syntax

```powershell
Get-PowerBIReportPagesForTesting -DatasetId <String> -WorkspaceId <String> `
    -WorkspaceIdsToCheck <Array> -Credential <PSCredential> `
    -TenantId <String> -Path <String> `
    -LogOutput <String> [-Environment <Microsoft.PowerBI.Common.Abstractions.PowerBIEnvironmentType>] `
    [-RoleUserName <String>]



##################################################################################################################################################################
## SYNOPSIS
This module identifies the reports and pages in a Power BI workspace that use a specific dataset/semantic model.

## SYNTAX

```
Get-PowerBIReportPagesForTesting [-DatasetId] <String> [-WorkspaceId] <String> [-WorkspaceIdsToCheck] <Array>
 [-Credential] <PSCredential> [-TenantId] <String> [-Path] <String> [-LogOutput] <String>
 [[-Environment] <PowerBIEnvironmentType>] [[-RoleUserName] <Object>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
This module identifies the reports and pages in a Power BI workspace that use a specific dataset/semantic model.

## EXAMPLES

### EXAMPLE 1
```
Run tests for all datasets/semantic models in the workspace and log output using Azure DevOps' logging commands.
Get-PowerBIReportPagesForTesting -DatasetId $variables.TestDataset2 -WorkspaceId $variables.TestWorkspace2 `
        -WorkspaceIdsToCheck @($variables.TestWorkspaceToCheck2) ` -Credential $Credential `
        -TenantId "$($variables.TestTenant)" `
        -LogOutput "ADO" `
        -Environment Public `
        -Path $testPath1
```

### EXAMPLE 2
```
Run tests for specific datasets/semantic models in the workspace and return output in an array of objects (table).
Get-PowerBIReportPagesForTesting -DatasetId $variables.TestDataset2 -WorkspaceId $variables.TestWorkspace2 `
        -WorkspaceIdsToCheck @($variables.TestWorkspaceToCheck2) ` -Credential $Credential `
        -TenantId "$($variables.TestTenant)" `
        -LogOutput "Table" `
        -Environment Public `
        -Path $testPath1
```

## PARAMETERS

### -DatasetId
The ID of the dataset to check for reports and pages.

```yaml
Type: String
Parameter Sets: (All)
Aliases: SemanticModelId

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WorkspaceId
The ID of the workspace where the dataset resides.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WorkspaceIdsToCheck
An array of workspace IDs to check for reports and pages that use the specified dataset.

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
A PSCredential object containing the credentials used for authentication.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TenantId
The ID of the tenant where the Power BI workspace resides.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
The path to the CSV file where the report details will be saved.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LogOutput
Specifies where the log messages should be written.
Options are 'ADO' (Azure DevOps Pipeline), 'Host', or 'Table'.

When ADO is chosen:
- Any warning will be logged as a warning in the pipeline.
An example of a warning would be if a dataset/semantic model has no tests to conduct.
- Any failed tests will be logged as an error in the pipeline.
- Successfully tests will be logged as a debug in the pipeline.
- If at least one failed test occurs, a failure is logged in the pipeline.

When Host is chosen, all output is written via the Write-Output command.

When Table is chosen:
- An Array containing objects with the following properties:
    - Message (String): The description of the event.
    - LogType (String): This is either Debug, Warning, Error, or Failure.
    - IsTestResult (Boolean): This indicates if the event was a test or not.
This is helpful for filtering results.
    - DataSource: The location of the workspace (if in the service) or the localhost (if local testing) of the semantic model.
    - ModelName: The name of the semantic model.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Environment
The Power BI environment to connect to.
Options are 'Public', 'Germany', 'China', 'USGov', 'USGovHigh', 'USGovDoD'.

```yaml
Type: PowerBIEnvironmentType
Parameter Sets: (All)
Aliases:
Accepted values: Public, Germany, USGov, China, USGovHigh, USGovMil, Custom

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RoleUserName
The name of the user to test the RLS for.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Object[]
## NOTES

## RELATED LINKS
