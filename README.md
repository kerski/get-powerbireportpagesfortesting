---
external help file: Get-PowerBIReportPagesForTesting-help.xml
Module Name: Get-PowerBIReportPagesForTesting
online version:
schema: 2.0.0
---

# Get-PowerBIReportPagesForTesting

This PowerShell module `Get-PowerBIReportPagesForTesting.psm1` helps identify the reports and pages in a Power BI workspace that use a specific dataset/semantic model. It also provides logging capabilities for various output formats, including Azure DevOps (ADO) pipelines, host console, and tables.

The file `Get-PowerBIReportPagesForTesting.Tests.ps1` contains a Pester test suite for the Get-PowerBIReportPagesForTesting PowerShell module, which verifies the module's functionality by testing various scenarios, including handling errors and validating outputs for different Power BI datasets and workspace configurations.

## Features

  1. Identify reports and pages using a specific dataset across multiple Power BI workspaces.
  2. Supports different Power BI environments (`Public`, `Germany`, `China`, `USGov`, etc.).
  3. Flexible logging options (ADO, Host, Table).
  4. Outputs results to a CSV file or as an array of objects.

## Prerequisites

1. Visual studio code
2. PowerShell 5.1 or higher.
3. PowerShell Modules:
   Note:  If the modules are not installed, the script will install them automatically.
   - `MicrosoftPowerBIMgmt` (for Power BI operations)
   -  `SqlServer` (for SQL-related operations)
4. Pester (for unit testing and test automation)
## Installation
To set up the Get-PowerBIReportPagesForTesting module on your local machine, follow these steps:
1. Clone the repository to your local machine using visual studio code.
   ![Clone in VS Code](Clonning%20in%20VS.jpg)
3. After cloning, import the module into your PowerShell session:
    ```powershell
    Import-Module -Name Get-PowerBIReportPagesForTesting.psm1
    ```
4. If you plan to run unit tests in file "Get-PowerBIReportPagesForTesting.Tests.ps1", you will need to install Pester:
    ```powershell
    Install-Module -Name Pester -Force -Scope CurrentUser
    ```
5. Alternatively, You can also install the module from the PowerShell Gallery using the following command:
    ```powershell
    Install-Module -Name Get-PowerBIReportPagesForTesting -AllowPrerelease
    ```

## Usage - Running the module locally to get the CSV file with the reports and pages in a Power BI workspace that use a specific dataset/semantic model.

The function `Get-PowerBIReportPagesForTesting` has several parameters that allow you to customize its behavior.
### PowerShell Module Parameters:
1. DatasetId (Mandatory): The unique identifier of the dataset/semantic model to test.
2. WorkspaceId (Mandatory): The unique identifier of the Power BI workspace containing the dataset.
3. WorkspaceIdsToCheck (Mandatory): An array of workspace IDs where reports using the dataset should be identified.
4. Credential (Mandatory): A PowerShell credential object for authenticating with the Power BI Service.
5. TenantId (Mandatory): The Azure AD tenant ID where the Power BI workspace resides.
6. Path (Mandatory): The path to the CSV file where results will be saved.
7. LogOutput (Mandatory): Specifies the log destination. {ADO, Host, Table}
   Logging Options
   ADO: Logs directly to Azure DevOps pipelines using task logging commands. Errors, warnings, and successful tests are logged with their respective statuses.
   Host: Logs output to the PowerShell console.
   Table: Logs output to an array of custom objects which can be used for further analysis or reporting.
8. Environment (Optional): Specifies the Power BI environment to connect to. {Public, Germany, China, USGov, USGovHigh, USGovDoD}
9. RoleUserName (Optional): The name of the user for which Role-Level Security (RLS) testing will be conducted.


### Syntax
You can run the following command in your PowerShell session to execute the module. Replace the placeholders (<String>, <Array>, <PSCredential>) with your actual parameter values.

```powershell
Get-PowerBIReportPagesForTesting -DatasetId <String> -WorkspaceId <String> `
    -WorkspaceIdsToCheck <Array> -Credential <PSCredential> `
    -TenantId <String> -Path <String> `
    -LogOutput <String> [-Environment <Microsoft.PowerBI.Common.Abstractions.PowerBIEnvironmentType>] `
    [-RoleUserName <String>]
```

## EXAMPLES

### EXAMPLE 1
This command will identify and list all the report pages in specified Power BI workspaces that use a particular dataset, logging the results to Azure DevOps and saving the details to a CSV file.
```
Get-PowerBIReportPagesForTesting -DatasetId $variables.TestDataset2 -WorkspaceId $variables.TestWorkspace2 `
        -WorkspaceIdsToCheck @($variables.TestWorkspaceToCheck2) ` -Credential $Credential `
        -TenantId "$($variables.TestTenant)" `
        -LogOutput "ADO" `
        -Environment Public `
        -Path $testPath1
```

### EXAMPLE 2

This command will identify and list all the report pages in specified Power BI workspaces that use a particular dataset, outputting the results as an array of objects in a table format and saving the details to a CSV file.
```
Get-PowerBIReportPagesForTesting -DatasetId $variables.TestDataset2 -WorkspaceId $variables.TestWorkspace2 `
        -WorkspaceIdsToCheck @($variables.TestWorkspaceToCheck2) ` -Credential $Credential `
        -TenantId "$($variables.TestTenant)" `
        -LogOutput "Table" `
        -Environment Public `
        -Path $testPath1
```
### EXAMPLE 3
This example logs output to Azure DevOps while testing role-based access for the user testuser@domain.com.
```
Get-PowerBIReportPagesForTesting -DatasetId "TestDataset" `
    -WorkspaceId "TestWorkspace2" `
    -WorkspaceIdsToCheck @("workspace1", "workspace2") `
    -Credential $Credential `
    -TenantId "tenant-id-here" `
    -Path "C:\output\PowerBIReportPages.csv" `
    -LogOutput "ADO" `
    -Environment "USGov" `
    -RoleUserName "testuser@domain.com"
```
## Testing
The module includes a suite of tests in `Get-PowerBIReportPagesForTesting.Tests.ps1` to ensure the module's functionality. The test script is written using Pester, a testing framework for PowerShell. 
### Running Tests
Install Pester (if not already installed):
``` 
Install-Module -Name Pester -Force -Scope CurrentUser
```
### Run the Tests:
```
Invoke-Pester
```
### Test Descriptions
1. Module Existence: Verifies that the Get-PowerBIReportPagesForTesting module is installed.
2. Invalid Workspace ID: Ensures the module handles invalid workspace IDs correctly.
3. Invalid Workspace GUID: Tests the module's response to incorrect workspace GUIDs.
4. Invalid Credentials: Checks how the module reacts to invalid credentials.
5. Invalid Tenant ID: Validates the module’s response to an incorrect tenant ID.
6. CSV File Content: Confirms the presence and correctness of data in CSV files generated by the module.
7. Sample Model Data: Verifies data retrieval and correctness from a sample model dataset.

## Configuration File (`Tests.config.json`)

The `Tests.config.json` file is used to store important settings and credentials needed for running tests with the `Get-PowerBIReportPagesForTesting` module. It helps keep sensitive information secure by not including it directly in the source code.

### What’s Inside `Tests.config.json`?

This file contains key pieces of information such as:

- **Client Secrets**: Passwords used for authentication.
- **Service Principals**: User accounts with specific permissions.
- **Dataset IDs**: Identifiers for different Power BI datasets.
- **Workspace IDs**: Identifiers for different Power BI workspaces.
- **Tenant ID**: Identifier for your Power BI tenant.

### How to Use It

1. **Create the File**: Create a file named `Tests.config.json` in the same folder as your test scripts.
2. **Add Your Data**: Fill in the file with the necessary information in JSON format. Here’s a basic example:

    ```json
    {
      "TestClientSecret": "your-client-secret",
      "TestServicePrincipal": "your-service-principal",
      "TestDataset1": "dataset-id-1",
      "TestWorkspace1": "workspace-id-1",
      "TestTenant": "tenant-id"
    }
    ```

3. **Keep It Secret**: Make sure not to include this file in your version control system (like Git) to keep your sensitive information safe. You can do this by adding it to your `.gitignore` file.

**Example `.gitignore` entry:**

```gitignore
# Ignore configuration file
Tests.config.json
```

By using the `Tests.config.json` file, you keep your sensitive information secure and separate from your code, which is a best practice for managing credentials and settings.

## CSV Output Format
When specifying a CSV output path using the -Path parameter, the following fields are included in the CSV:
 ![CSV Optput](CSV%20Output.jpg)

test_case: A unique identifier for each test case.
workspace_id: The workspace ID where the report resides.
report_id: The report ID.
page_id: The page name within the report.
dataset_id: The dataset/semantic model ID.
user_name: (Optional) The user for role-based security testing.
row: The RLS role name.

## Error Handling
The module handles errors such as connection failures, invalid workspaces, missing datasets, and more.
Errors are logged based on the specified LogOutput. When logging to Azure DevOps (ADO), errors trigger a failed build pipeline.

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
