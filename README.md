---
external help file: Get-PowerBIReportPagesForTesting-help.xml
Module Name: Get-PowerBIReportPagesForTesting
online version:
schema: 2.0.0
---

# Get-PowerBIReportPagesForTesting

## SYNOPSIS
This module identifies the reports and pages in a Power BI workspace that use a specific dataset/semantic model.

## SYNTAX

```
Get-PowerBIReportPagesForTesting [-DatasetId] <String> [-WorkspaceId] <String> [-WorkspaceIdsToCheck] <Array>
 [-Credential] <PSCredential> [-TenantId] <String> [-Path] <String> [-LogOutput] <String>
 [[-Environment] <PowerBIEnvironmentType>] [[-roleUserName] <Object>] [-ProgressAction <ActionPreference>]
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

### -roleUserName
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
