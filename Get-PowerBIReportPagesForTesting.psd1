#
# Module manifest for module 'Get-PowerBIReportPagesForTesting'
#
# Generated by: John Kerski
#
# Generated on: 8/13/2024
#

@{

    # Script module or binary module file associated with this manifest.
    RootModule = 'Get-PowerBIReportPagesForTesting.psm1'
    
    # Version number of this module.
    ModuleVersion = '0.0.1'
    
    # Supported PSEditions
    CompatiblePSEditions = @("Core")
    
    # ID used to uniquely identify this module
    GUID = '17299fa1-910f-4e8c-9dd0-e6ca7ed2a992'
    
    # Author of this module
    Author = 'John Kerski'
    
    # Company or vendor of this module
    CompanyName = 'kerski.tech'
    
    # Copyright statement for this module
    Copyright = '(c) kerski.tech. All rights reserved.'
    
    # Description of the functionality provided by this module
    Description = 'This module identifies the reports and pages in a Power BI workspace that use a specific dataset/semantic model.'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '7.4'
    
    # Name of the PowerShell host required by this module
    # PowerShellHostName = ''
    
    # Minimum version of the PowerShell host required by this module
    # PowerShellHostVersion = ''
    
    # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # DotNetFrameworkVersion = ''
    
    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # ClrVersion = ''
    
    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''
    
    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules = @("MicrosoftPowerBIMgmt","SqlServer")
    
    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @()
    
    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()
    
    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()
    
    # Format files (.ps1xml) to be loaded when importing this module
    # FormatsToProcess = @()
    
    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()
    
    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @("Get-PowerBIReportPagesForTesting")
    
    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = @()
    
    # Variables to export from this module
    VariablesToExport = '*'
    
    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @()
    
    # DSC resources to export from this module
    # DscResourcesToExport = @()
    
    # List of all modules packaged with this module
    # ModuleList = @()
    
    # List of all files packaged with this module
    # FileList = @()
    
    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{
    
        PSData = @{
    
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @("PowerBI", "Fabric")
    
            # A URL to the license for this module.
            LicenseUri = 'https://github.com/kerski/get-powerbireportpagesfortesting/blob/main/LICENSE'
    
            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/kerski/get-powerbireportpagesfortesting'
    
            # A URL to an icon representing this module.
            # IconUri = ''
    
            # ReleaseNotes of this module
            ReleaseNotes = 'Initial Release'
    
            # Prerelease string of this module
             Prerelease = 'rc'
    
            # Flag to indicate whether the module requires explicit user acceptance for install/update/save
            # RequireLicenseAcceptance = $false
    
            # External dependent modules of this module
            # ExternalModuleDependencies = @()
    
        } # End of PSData hashtable
    
    } # End of PrivateData hashtable
    
    # HelpInfo URI of this module
    # HelpInfoURI = ''
    
    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''
    
    }
    
    