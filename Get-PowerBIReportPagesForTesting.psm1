$script:messages = @()
# Install MicrosoftPowerBIMgmt module if not already installed
if (-not (Get-Module -ListAvailable -Name "MicrosoftPowerBIMgmt")) {
    Install-Module -Name MicrosoftPowerBIMgmt -Scope CurrentUser -AllowClobber -Force
}
Import-Module -Name MicrosoftPowerBIMgmt

# Install SqlServer Powershell Module if Needed
if (Get-Module -ListAvailable -Name "SqlServer") {
    Write-Host -ForegroundColor Cyan "SqlServer already installed"
}
else {
    Install-Module -Name SqlServer -Scope CurrentUser -AllowClobber -Force
}
Import-Module -Name SqlServer

<#
    .SYNOPSIS
    This module runs through the DAX Query View files that end with .Tests or .Test and output the results. 
    The provided PowerShell script facilitates Data Query View (DQV) testing for datasets within a Powerbi workspace.

    Tests should follow the DAX Query View Testing Pattern that returns a table messages.

    For more information, please visit this link: https://github.com/kerski/fabric-dataops-patterns/blob/main/DAX%20Query%20View%20Testing%20Pattern/dax-query-view-testing-pattern.md

    
    .PARAMETER TenantId
    The ID of the tenant where the Power BI workspace resides.

    .PARAMETER WorkspaceName
    The name of the Power BI workspace where the datasets are located.

    .PARAMETER Credential
    A PSCredential object containing the credentials used for authentication.

    .PARAMETER ClientId
        ClientId used for authentication.

    .PARAMETER ClientSecret
        ClientSecret used for authentication.

    .PARAMETER DatasetId
    An optional array of dataset IDs to specify which datasets to test. If not provided, all datasets will be tested.

    .PARAMETER LogOutput
    Specifies where the log messages should be written. Options are 'ADO' (Azure DevOps Pipeline), 'Host', or 'Table'.

    When ADO is chosen:
    - Any warning will be logged as a warning in the pipeline. An example of a warning would be if a dataset/semantic model has no tests to conduct.
    - Any failed tests will be logged as an error in the pipeline.
    - Successfully tests will be logged as a debug in the pipeline.
    - If at least one failed test occurs, a failure is logged in the pipeline.

    When Host is chosen, all output is written via the Write-Output command.

    When Table is chosen:
    - An Array containing objects with the following properties:
        - Message (String): The description of the event.
        - LogType (String): This is either Debug, Warning, Error, or Failure.
        - IsTestResult (Boolean): This indicates if the event was a test or not. This is helpful for filtering results.
        - DataSource: The location of the workspace (if in the service) or the localhost (if local testing) of the semantic model.
        - ModelName: The name of the semantic model.


    .EXAMPLE
    Run tests for all datasets/semantic models in the workspace and log output using Azure DevOps' logging commands.
    Get-PowerBIReportPages -WorkspaceIds @("WORKSPACE GUID1","WORKSPACE GUID2") `
            -DatasetName "DATASET_NAME" `
            -ClientId "CLIENT_ID" `
            -ClientSecret "SECRET" `
            -TenantId "TENANT_ID" `
            -LogOutput "ADO" 

    .EXAMPLE
    Run tests for specific datasets/semantic models in the workspace and return output in an array of objects (table).
    Get-PowerBIReportPages -WorkspaceIds @("WORKSPACE GUID1","WORKSPACE GUID2") `
            -DatasetName "DATASET_NAME" `
            -ClientId "CLIENT_ID" `
            -ClientSecret "SECRET" `
            -TenantId "TENANT_ID" `
            -LogOutput "Table"
#>
function Get-PowerBIReportPagesForTesting {
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        [Parameter(Position = 0, Mandatory = $true)][String]$DatasetId,
        [Parameter(Position = 1, Mandatory = $true)][String]$WorkspaceId,        
        [Parameter(Position = 2, Mandatory = $true)][array]$WorkspaceIdsToCheck,
        [Parameter(Position = 3, Mandatory = $true)][String]$ClientId,
        [Parameter(Position = 4, Mandatory = $true)][String]$ClientSecret,
        [Parameter(Position = 5, Mandatory = $true)][String]$TenantId,
        [Parameter(Position = 6, Mandatory = $true)][String]$Path,
        [Parameter(Position = 7, Mandatory = $true)][String]$LogOutput,
        [Parameter(Position = 8, Mandatory = $false)][Microsoft.PowerBI.Common.Abstractions.PowerBIEnvironmentType]$Environment,
        [Parameter(Position = 9, Mandatory = $false)]$roleUserName
    )

    # Setup TLS 12
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # Reset Message Table
    $script:messages = @()

    # Set error count
    $errorCount = 0

    try {

        # Map to correct XMLA Prefix
        $xMLAPrefix = "powerbi://api.powerbigov.com/v1.0/myorg/"

        switch($Environment){
            "Public" {$xMLAPrefix = "powerbi://api.powerbi.com/v1.0/myorg/"}
            "Germany" {$xMLAPrefix = "powerbi://api.powerbi.de/v1.0/myorg/"}
            "China" {$xMLAPrefix = "powerbi://api.powerbi.cn/v1.0/myorg/"}
            "USGov" {$xMLAPrefix = "powerbi://api.powerbigov.us/v1.0/myorg/"}
            "USGovHigh" {$xMLAPrefix = "powerbi://api.high.powerbigov.us/v1.0/myorg/"}
            "USGovDoD" {$xMLAPrefix = "powerbi://api.mil.powerbi.us/v1.0/myorg/"}
            Default {$xMLAPrefix = "powerbi://api.powerbi.com/v1.0/myorg/"}
        }

        # Establish Connection
        try {
            # Set Client Secret as Secure String
            $secret = $ClientSecret | ConvertTo-SecureString -AsPlainText -Force
            $credentials = [System.Management.Automation.PSCredential]::new($ClientId, $secret)

            # Connect to Power BI Service Account
            $connectionStatus = Connect-PowerBIServiceAccount -Credential $Credentials `
                                                              -ServicePrincipal `
                                                              -Tenant $TenantId `
                                                              -Environment $Environment

            # Check if connection status is valid
            if (-not $connectionStatus) {
                throw "Unable to connect to Power BI Service"
            }
        }
        catch {
            # Log connection errors
            $errObj = ($_).ToString()
            Write-ToLog -Message "$($errObj)" -LogType "Error" -LogOutput $LogOutput
            $errorCount++
            return $script:messages
            exit 1 # short-circuit because we can't connect
        }

        try{
            # Get Dataset 
            $datasetObj = Get-PowerBIDataset -WorkspaceId $WorkspaceId -Id $DatasetId -Verbose

            # Check returned object
            if(-not $datasetObj){
                throw "Unable to connect to Dataset $($DatasetId) in Workspace $($WorkspaceId)."
            }
        }catch{
            $errObj = ($_).ToString()
            Write-ToLog -Message "$($errObj)" -LogType "Error" -LogOutput $LogOutput
            $errorCount++
            return $script:messages
            exit 1 # short-circuit because we can't connect
        }# end try

        # Initialize an array to store report details
        $reportDetails = @()
        Write-ToLog -Message "Attempting to Get Workspace Name" -LogType "Debug" -LogOutput $LogOutput
        foreach ($workspaceId in $WorkspaceIdsToCheck) {
            Write-ToLog -Message "Attempting to Get Workspace Name from $($workspaceId)" -LogType "Debug" -LogOutput $LogOutput

            # Default workspace name to null
            $workspaceName = $null

            # Retrieve workspace name using filter capability
            try {
                $guid = [System.Guid]::Parse($($workspaceId))
                # Get workspace name
                $workspace = Get-PowerBIWorkspace -Id $guid
                $workspaceName = $workspace.Name
            }
            catch {
                # Log errors when retrieving workspace name
                $errObj = ($_).ToString()
                Write-ToLog -Message "$($errObj)" -LogType "Error" -LogOutput $LogOutput
                $errorCount++
                return $script:messages
            }

            # Validate Workspace was found
            if (-not $workspaceName) {
                Write-ToLog -Message "Unable to identify workspace name from $($workspaceId)" -LogType "Error" -LogOutput $LogOutput
                $errorCount++
            }
            else {
                $dataSource = "$($xMLAPrefix)$($workspaceName)"
                # Get Roles
                try {
                    $result = Invoke-ASCmd -Server $datasource `
                        -Database $datasetObj.Name `
                        -Query "select * from `$SYSTEM.DISCOVER_POWERBI_ROLES" `
                        -Credential $credentials `
                        -TenantId $TenantId `
                        -ServicePrincipal `
                        -Verbose

                    # Remove unicode chars for brackets and spaces from XML node names
                    $result = $result -replace '_x[0-9A-z]{4}_', ''

                    # Load result into XML and return
                    [System.Xml.XmlDocument]$xMLResult = New-Object System.Xml.XmlDocument
                    $xMLResult.LoadXml($Result)
                    $roles = $xMLResult.return.root.row
                }
                catch {
                    # Log errors from the pipeline execution
                    $errObj = ($_).ToString()
                    Write-ToLog -Message "$($errObj)" -LogType "Error" -LogOutput $LogOutput
                    $errorCount++
                }# end try

                # Get the list of reports in the workspace
                $reports = Get-PowerBIReport -WorkspaceId $workspaceId
                $counter = 1
                foreach ($report in $reports) {
                    # Check if the report uses the specified dataset ID
                    if (($report.Name -eq $datasetObj.Name)  -or ($report.DatasetId -eq $datasetObj.Id.Guid)) {
                        try {
                            # Get the pages for the report
                            $pagesUrl = "groups/$($workspaceId)/reports/$($report.Id)/pages"
                            $pageResponse = Invoke-PowerBIRestMethod -Url $pagesUrl -Method Get | ConvertFrom-Json

                            if ($pageResponse) {
                                $pages = $pageResponse.value

                                foreach ($page in $pages) {
                                    if($roles.length -gt 0){
                                        foreach ($row in $roles) {
                                            # Add details to the array
                                            $reportDetails += [PSCustomObject]@{
                                                test_case = "test_case_$((New-Guid).Guid)"
                                                workspace_id = $workspaceId
                                                report_id   = $report.Id
                                                page_id     = $page.Name
                                                dataset_id  = $datasetObj.Id.Guid
                                                user_name   = $roleUserName
                                                row       = $row.name
                                            }
                                            $counter++
                                        }# end foreach role
                                    }else{
                                            # Add details to the array
                                            $reportDetails += [PSCustomObject]@{
                                                test_case = "test_case_$((New-Guid).Guid)"
                                                workspace_id = $workspaceId
                                                report_id   = $report.Id
                                                page_id     = $page.Name
                                            }  
                                            $counter++                                      
                                    }#end role check
                                }# foreach page
                            }# end if page response
                        }
                        catch {
                            # Log errors when fetching report pages
                            Write-ToLog -Message "Failed to fetch pages for report '$($report.Name)': $_" -LogType "Error" -LogOutput $LogOutput
                            $errorCount++
                        }# end try
                    }# end check report name
                }# end foreach
            }# end validate Workspace was found
        }
        # Check if the Csv file already exists
        if(Test-Path -Path $Path){
            # Log errors the Csv file already exists
            Write-ToLog -Message "The CSV file already exists at path:'$($Path)'" -LogType "Error" -LogOutput $LogOutput
            $errorCount++
        }
        else{
            # Output the details to a CSV file
            $reportDetails | Export-Csv -Path "$($Path)" -NoTypeInformation
        }# end check on file path
    }
    catch {
        # Log general errors
        $ErrObj = ($_).ToString()
        Write-ToLog -Message "$($ErrObj)" -LogType "Error" -LogOutput $LogOutput
        exit 1
    }
    finally {
        # Disconnect from Power BI Service
        Disconnect-PowerBIServiceAccount
    }# end try

    # Handle switch for CI
    if ($LogOutput -eq "ADO") {
        return $script:messages 
        exit $errorCount
    }
    else {
        return $script:messages 
    } 
}


function Write-ToLog {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [Parameter(Mandatory = $false)]
        [ValidateSet('Debug', 'Warning', 'Error', 'Passed', 'Failure', 'Success')]
        [string]$LogType = 'Debug',
        [Parameter(Mandatory = $false)]
        [ValidateSet('ADO', 'Host', 'Table')]
        [string]$LogOutput = 'ADO'
    )

    # Set prefix for logging
    $prefix = ''

    # If LogOutput is 'Table', add message to script messages array
    if ($LogOutput -eq 'Table') {
        $temp = @([pscustomobject]@{Message = $Message; LogType = $LogType;})
        $script:messages += $temp
    }
    # If LogOutput is 'ADO', format the message for ADO logging
    elseif ($LogOutput -eq 'ADO') {
        $prefix = '##[debug]'
        switch ($LogType) {
            'Warning' { $prefix = "##vso[task.logissue type=warning]" }
            'Error' { $prefix = "##vso[task.logissue type=error]" }
            'Failure' { $prefix = "##vso[task.complete result=Failed;]" }
            'Success' { $prefix = "##vso[task.complete result=Succeeded;]" }
        }
        $Message = $prefix + $Message
        Write-Output $Message
    }
    # Otherwise, use the Host output with colored text
    else {
        $color = "White"
        switch ($LogType) {
            'Warning' { $color = "Yellow" }
            'Error' { $color = "Red" }
            'Failure' { $color = "Red" }
            'Success' { $color = "Green" }
            'Passed' { $color = "Green" }
        }
        Write-Host -ForegroundColor $color $Message
    }
}

# Export the function
Export-ModuleMember -Function Get-PowerBIReportPagesForTesting
