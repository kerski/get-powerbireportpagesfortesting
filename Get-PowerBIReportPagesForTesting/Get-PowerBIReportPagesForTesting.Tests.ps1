Describe 'Get-PowerBIReportPagesForTesting' {
    BeforeAll { 
        $dir = (pwd).Path
        Remove-Module -Name Get-PowerBIReportPagesForTesting -Force -ErrorAction SilentlyContinue
        Import-Module "$($dir)\Get-PowerBIReportPagesForTesting\Get-PowerBIReportPagesForTesting.psm1"
        Import-Module -Name MicrosoftPowerBIMgmt
        Import-Module -Name SqlServer
        # Retrieve specific variables from json so we don't keep sensitive values in 
        # source control
        $variables = Get-Content .\Tests.config.json | ConvertFrom-Json
        $secret = $variables.TestClientSecret | ConvertTo-SecureString -AsPlainText -Force
        $badSecret = $variables.TestBadClientSecret | ConvertTo-SecureString -AsPlainText -Force
        $goodCredential = [System.Management.Automation.PSCredential]::new($variables.TestServicePrincipal, $secret)  
        $badCredential = [System.Management.Automation.PSCredential]::new($variables.TestBadServicePrincipal, $badSecret)      
        $testPath1 = ".\PowerBIReportPages1.csv"
        $testPath2 = ".\PowerBIReportPages2.csv"
        $testPath3 = ".\PowerBIReportPages3.csv"
        $testPath4 = ".\PowerBIReportPages4.csv"
        $alreadyExistPath = ".\AlreadyExists.csv"

        # Delete files
        if(Test-Path -Path $testPath1){
            Remove-Item -Path $testPath1 -Force
        }

        if(Test-Path -path $testPath2){
            Remove-Item -Path $testPath2 -Force
        }     

        if(Test-Path -path $testPath3){
            Remove-Item -Path $testPath3 -Force
        }   

        if(Test-Path -path $testPath4){
            Remove-Item -Path $testPath4 -Force
        }   
        
    }
    # Clean up
    AfterAll {
        Remove-Module -Name Get-PowerBIReportPagesForTesting -Force -ErrorAction SilentlyContinue     
        Remove-Module -Name SqlServer -Force -ErrorAction SilentlyContinue   
        # Disconnect from Power BI Service
        Disconnect-PowerBIServiceAccount
    }

    # Check if File Exists
    It 'Module should exist' {
        $isInstalled = Get-Command Get-PowerBIReportPagesForTesting
        $isInstalled | Should -Not -BeNullOrEmpty
    } 

    # Check for bad workspace Id
    It 'Should output a failure if the workspace Id is not valid' -Tag "Bad Workspace Id For Dataset"{
        $results1 = @(Get-PowerBIReportPagesForTesting -DatasetId $variables.TestDataset2 -WorkspaceId $variables.TestBadWorkspaceGuid `
                -WorkspaceIdsToCheck @($variables.TestWorkspaceToCheck2) ` -Credential $goodCredential `
                -TenantId "$($variables.TestTenant)" `
                -LogOutput "Table" `
                -Environment Public `
                -Path $testPath1
        )
        Write-Host ($results1 | Format-Table | Out-String)
        $errors1 = $results1 | Where-Object { $_.LogType -eq 'Error' }
        $len1 = $errors.Length 
        $errors1.Length | Should -BeGreaterThan 0
        $errors1[$len1 - 1].message.StartsWith("Unable to connect to Workspace") | Should -Be $true

        # Clean up
        if(Test-Path -path $testPath1){
            Remove-Item -Path $testPath1 -Force
        }         
    }    

    # Check for bad workspace guid
    It 'Should output a failure if the workspace guid is not valid' -Tag "Bad Workspace Guid" {
        $results = @(Get-PowerBIReportPagesForTesting -DatasetId $variables.TestDataset2 -WorkspaceId $variables.TestWorkspace2 `
            -WorkspaceIdsToCheck @($variables.TestBadWorkspaceToCheck) ` -Credential $goodCredential `
            -TenantId "$($variables.TestTenant)" `
            -LogOutput "Table" `
            -Environment Public `
            -Path $testPath1
        )
        Write-Host ($results | Format-Table | Out-String)
        $errors = $results | Where-Object { $_.LogType -eq 'Error' }
        $len = $errors.Length 
        $errors.Length | Should -BeGreaterThan 0
        $errors[$len - 1].message.StartsWith("Unable to identify workspace name from") | Should -Be $true

        # Clean up
        if(Test-Path -path $testPath1){
            Remove-Item -Path $testPath1 -Force
        }         

    }
    
    # Check for bad Client Id
    It 'Should output a failure if the credential is not valid' -Tag "Bad Credential" {
        $results1 = @(Get-PowerBIReportPagesForTesting -DatasetId $variables.TestDataset2 -WorkspaceId $variables.TestWorkspace2 `
            -WorkspaceIdsToCheck @($variables.TestWorkspaceToCheck2) ` -Credential $badCredential `
            -TenantId "$($variables.TestTenant)" `
            -LogOutput "Table" `
            -Environment Public `
            -Path $testPath1
        )
        Write-Host ($results1 | Format-Table | Out-String)
        $errors1 = $results1 | Where-Object { $_.LogType -eq 'Error' }
        $len1 = $errors.Length 
        $errors1.Length | Should -BeGreaterThan 0
        $errors1[$len1 - 1].message.StartsWith("Unable to connect") | Should -Be $true

        # Clean up
        if(Test-Path -path $testPath1){
            Remove-Item -Path $testPath1 -Force
        }         
    }

    # Check for bad tenant Id
    It 'Should output a failure if the Tenant Id is not valid' -Tag "Bad Tenant Id"{
        $results1 = @(Get-PowerBIReportPagesForTesting -DatasetId $variables.TestDataset2 -WorkspaceId $variables.TestWorkspace2 `
                -WorkspaceIdsToCheck @($variables.TestWorkspaceToCheck2) ` -Credential $goodCredential `
                -TenantId "$($variables.TestBadTenant)" `
                -LogOutput "Table" `
                -Environment Public `
                -Path $testPath1
        )
        Write-Host ($results1 | Format-Table | Out-String) 
        $errors1 = $results1 | Where-Object { $_.LogType -eq 'Error' }
        $len1 = $errors.Length 
        $errors1.Length | Should -BeGreaterThan 0
        $errors1[$len1 - 1].message.StartsWith("Unable to connect") | Should -Be $true

        # Clean up
        if(Test-Path -path $testPath1){
            Remove-Item -Path $testPath1 -Force
        }          
    }

    # Check for Contents of csv file
    It 'Should check if data is present in a PowerBIReportPages2.csv file with Dataset that has no RLS' -Tag "CSV File Content" {
        $results1 = @(Get-PowerBIReportPagesForTesting -DatasetId $variables.TestDataset2 -WorkspaceId $variables.TestWorkspace2 `
                -WorkspaceIdsToCheck @($variables.TestWorkspaceToCheck2) ` -Credential $goodCredential `
                -TenantId "$($variables.TestTenant)" `
                -LogOutput "Table" `
                -Environment Public `
                -Path $testPath2
        )

        Write-Host ($results1 | Format-Table | Out-String)        

        #Check if the CSV file exists
        Test-Path -Path $testPath2 | Should -Be $true
        if($testPath2){
            $csvContent = Import-Csv -Path $testPath2
            $csvContent.count | Should -BeGreaterThan 0
            $csvHeader = (Get-Content -Path $testPath2 -First 1) -split ','
            $csvHeader.count | Should -Be 4
        } 
        # Clean up
        if(Test-Path -path $testPath2){
            Remove-Item -Path $testPath2 -Force
        }           
    }

    # Check for Contents of csv file
    It 'Should check if data is present in a PowerBIReportPages2.csv file with Dataset that has RLS' -Tag "CSV File Content" {
        $results1 = @(Get-PowerBIReportPagesForTesting -DatasetId $variables.TestDataset1 -WorkspaceId $variables.TestWorkspace1 `
                -WorkspaceIdsToCheck @($variables.TestWorkspaceToCheck1) ` -Credential $goodCredential `
                -TenantId "$($variables.TestTenant)" `
                -LogOutput "Table" `
                -Environment Public `
                -Path $testPath2
        )

        Write-Host ($results1 | Format-Table | Out-String)        

        #Check if the CSV file exists
        Test-Path -Path $testPath2 | Should -Be $true
        if($testPath2){
            $csvContent = Import-Csv -Path $testPath2
            $csvContent.count | Should -BeGreaterThan 0
            $csvHeader = (Get-Content -Path $testPath2 -First 1) -split ','
            $csvHeader.count | Should -Be 7
        } 

        # Clean up
        if(Test-Path -path $testPath2){
            Remove-Item -Path $testPath2 -Force
        }         
    }

    # Check for Path
    It 'Should check if path already exist' -Tag "CSV File Content" {
        $results1 = @(Get-PowerBIReportPagesForTesting -DatasetId $variables.TestDataset1 -WorkspaceId $variables.TestWorkspace1 `
                -WorkspaceIdsToCheck @($variables.TestWorkspaceToCheck1) ` -Credential $goodCredential `
                -TenantId "$($variables.TestTenant)" `
                -LogOutput "Table" `
                -Environment Public `
                -Path $alreadyExistPath
        )
       
        Write-Host ($results1 | Format-Table | Out-String)
        $errors1 = $results1 | Where-Object { $_.LogType -eq 'Error' }
        $len1 = $errors.Length 
        $errors1.Length | Should -BeGreaterThan 0
        $errors1[$len1 - 1].message.StartsWith("The CSV file already exists") | Should -Be $true
           
    }
    
    # Check for Path
    It 'Should get SampleModelThin data' -Tag "Sample Model" {
        $results1 = @(Get-PowerBIReportPagesForTesting -DatasetId $variables.TestDataset3 -WorkspaceId $variables.TestWorkspace3 `
                -WorkspaceIdsToCheck @($variables.TestWorkspaceToCheck1) ` -Credential $goodCredential `
                -TenantId "$($variables.TestTenant)" `
                -LogOutput "Table" `
                -Environment Public `
                -Path $testPath3
        )
        Write-Host ($results1 | Format-Table | Out-String)
        #Check if the CSV file exists
        Test-Path -Path $testPath3 | Should -Be $true
        if($testPath3){
            $csvContent = Import-Csv -Path $testPath3
            $csvContent.count | Should -BeGreaterThan 0
            $csvHeader = (Get-Content -Path $testPath3 -First 1) -split ','
            $csvHeader.count | Should -Be 4

            # Check if report exists
            $jsonContent = $csvContent | ConvertTo-Json
            $psObj = $jsonContent | ConvertFrom-Json
            $reportCheck = $psObj | Where-Object {$_.report_id -eq $variables.TestReportThatShouldAppear3}
            $reportCheck.Length | Should -BeGreaterThan 0
        } 

        # Clean up
        if(Test-Path -path $testPath3){
            Remove-Item -Path $testPath3 -Force
        }             
    }    

    # Check for Cross Workspace
    It 'Should generate file for a dataset used cross workspaces' -Tag "Cross Workspace" {
        $wsCheck = @($variables.TestWorkspaceToCheck1,$variables.TestWorkspaceToCheck4) 
        $results1 = @(Get-PowerBIReportPagesForTesting -DatasetId $variables.TestDataset1 -WorkspaceId $variables.TestWorkspace1 `
                -WorkspaceIdsToCheck $wsCheck ` -Credential $goodCredential `
                -TenantId "$($variables.TestTenant)" `
                -LogOutput "Table" `
                -Environment Public `
                -Path $testPath4
        )
        Write-Host ($results1 | Format-Table | Out-String)
        #Check if the CSV file exists
        Test-Path -Path $testPath4 | Should -Be $true
        if($testPath4){
            $csvContent = Import-Csv -Path $testPath4
            $csvContent.count | Should -BeGreaterThan 0
            $csvHeader = (Get-Content -Path $testPath4 -First 1) -split ','
            $csvHeader.count | Should -Be 7

            # Check if report exists
            $jsonContent = $csvContent | ConvertTo-Json
            $psObj = $jsonContent | ConvertFrom-Json
            $reportCheck = $psObj | Where-Object {$_.report_id -eq $variables.TestReportThatShouldAppear4}
            $reportCheck.Length | Should -BeGreaterThan 0
        } 

        # Clean up
        if(Test-Path -path $testPath4){
           #Remove-Item -Path $testPath4 -Force
        }             
    }    

}