# Copyright (c) Microsoft Corporation.  All rights reserved.

$ErrorActionPreference = 'Stop'
$InitialDatabase = '0'

<#
.SYNOPSIS
    Adds or updates an Entity Framework provider entry in the project config
    file.

.DESCRIPTION
    Adds an entry into the 'entityFramework' section of the project config
    file for the specified provider invariant name and provider type. If an
    entry for the given invariant name already exists, then that entry is
    updated with the given type name, unless the given type name already
    matches, in which case no action is taken. The 'entityFramework'
    section is added if it does not exist. The config file is automatically
    saved if and only if a change was made.

    This command is typically used only by Entity Framework provider NuGet
    packages and is run from the 'install.ps1' script.

.PARAMETER Project
    The Visual Studio project to update. When running in the NuGet install.ps1
    script the '$project' variable provided as part of that script should be
    used.

.PARAMETER InvariantName
    The provider invariant name that uniquely identifies this provider. For
    example, the Microsoft SQL Server provider is registered with the invariant
    name 'System.Data.SqlClient'.

.PARAMETER TypeName
    The assembly-qualified type name of the provider-specific type that
    inherits from 'System.Data.Entity.Core.Common.DbProviderServices'. For
    example, for the Microsoft SQL Server provider, this type is
    'System.Data.Entity.SqlServer.SqlProviderServices, EntityFramework.SqlServer'.
#>
function Add-EFProvider
{
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [parameter(Position = 0, Mandatory = $true)]
        $Project,
        [parameter(Position = 1, Mandatory = $true)]
        [string] $InvariantName,
        [parameter(Position = 2, Mandatory = $true)]
        [string] $TypeName)

    $configPath = GetConfigPath $Project
    if (!$configPath)
    {
        return
    }

    [xml] $configXml = Get-Content $configPath

    $providers = $configXml.configuration.entityFramework.providers

    $providers.provider |
        where invariantName -eq $InvariantName |
        %{ $providers.RemoveChild($_) | Out-Null }

    $provider = $providers.AppendChild($configXml.CreateElement('provider'))
    $provider.SetAttribute('invariantName', $InvariantName)
    $provider.SetAttribute('type', $TypeName)

    $configXml.Save($configPath)
}

<#
.SYNOPSIS
    Adds or updates an Entity Framework default connection factory in the
    project config file.

.DESCRIPTION
    Adds an entry into the 'entityFramework' section of the project config
    file for the connection factory that Entity Framework will use by default
    when creating new connections by convention. Any existing entry will be
    overridden if it does not match. The 'entityFramework' section is added if
    it does not exist. The config file is automatically saved if and only if
    a change was made.

    This command is typically used only by Entity Framework provider NuGet
    packages and is run from the 'install.ps1' script.

.PARAMETER Project
    The Visual Studio project to update. When running in the NuGet install.ps1
    script the '$project' variable provided as part of that script should be
    used.

.PARAMETER TypeName
    The assembly-qualified type name of the connection factory type that
    implements the 'System.Data.Entity.Infrastructure.IDbConnectionFactory'
    interface.  For example, for the Microsoft SQL Server Express provider
    connection factory, this type is
    'System.Data.Entity.Infrastructure.SqlConnectionFactory, EntityFramework'.

.PARAMETER ConstructorArguments
    An optional array of strings that will be passed as arguments to the
    connection factory type constructor.
#>
function Add-EFDefaultConnectionFactory
{
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [parameter(Position = 0, Mandatory = $true)]
        $Project,
        [parameter(Position = 1, Mandatory = $true)]
        [string] $TypeName,
        [string[]] $ConstructorArguments)

    $configPath = GetConfigPath $Project
    if (!$configPath)
    {
        return
    }

    [xml] $configXml = Get-Content $configPath

    $entityFramework = $configXml.configuration.entityFramework
    $defaultConnectionFactory = $entityFramework.defaultConnectionFactory
    if ($defaultConnectionFactory)
    {
        $entityFramework.RemoveChild($defaultConnectionFactory) | Out-Null
    }
    $defaultConnectionFactory = $entityFramework.AppendChild($configXml.CreateElement('defaultConnectionFactory'))

    $defaultConnectionFactory.SetAttribute('type', $TypeName)

    if ($ConstructorArguments)
    {
        $parameters = $defaultConnectionFactory.AppendChild($configXml.CreateElement('parameters'))

        foreach ($constructorArgument in $ConstructorArguments)
        {
            $parameter = $parameters.AppendChild($configXml.CreateElement('parameter'))
            $parameter.SetAttribute('value', $constructorArgument)
        }
    }

    $configXml.Save($configPath)
}

<#
.SYNOPSIS
    Enables Code First Migrations in a project.

.DESCRIPTION
    Enables Migrations by scaffolding a migrations configuration class in the project. If the
    target database was created by an initializer, an initial migration will be created (unless
    automatic migrations are enabled via the EnableAutomaticMigrations parameter).

.PARAMETER ContextTypeName
    Specifies the context to use. If omitted, migrations will attempt to locate a
    single context type in the target project.

.PARAMETER EnableAutomaticMigrations
    Specifies whether automatic migrations will be enabled in the scaffolded migrations configuration.
    If omitted, automatic migrations will be disabled.

.PARAMETER MigrationsDirectory
    Specifies the name of the directory that will contain migrations code files.
    If omitted, the directory will be named "Migrations".

.PARAMETER ProjectName
    Specifies the project that the scaffolded migrations configuration class will
    be added to. If omitted, the default project selected in package manager
    console is used.

.PARAMETER StartUpProjectName
    Specifies the configuration file to use for named connection strings. If
    omitted, the specified project's configuration file is used.

.PARAMETER ContextProjectName
    Specifies the project which contains the DbContext class to use. If omitted,
    the context is assumed to be in the same project used for migrations.

.PARAMETER ConnectionStringName
    Specifies the name of a connection string to use from the application's
    configuration file.

.PARAMETER ConnectionString
    Specifies the connection string to use. If omitted, the context's
    default connection will be used.

.PARAMETER ConnectionProviderName
    Specifies the provider invariant name of the connection string.

.PARAMETER Force
    Specifies that the migrations configuration be overwritten when running more
    than once for a given project.

.PARAMETER ContextAssemblyName
    Specifies the name of the assembly which contains the DbContext class to use. Use this
    parameter instead of ContextProjectName when the context is contained in a referenced
    assembly rather than in a project of the solution.

.PARAMETER AppDomainBaseDirectory
    Specifies the directory to use for the app-domain that is used for running Migrations
    code such that the app-domain is able to find all required assemblies. This is an
    advanced option that should only be needed if the solution contains	several projects
    such that the assemblies needed for the context and configuration are not all
    referenced from either the project containing the context or the project containing
    the migrations.

.EXAMPLE
    Enable-Migrations
    # Scaffold a migrations configuration in a project with only one context

.EXAMPLE
    Enable-Migrations -Auto
    # Scaffold a migrations configuration with automatic migrations enabled for a project
    # with only one context

.EXAMPLE
    Enable-Migrations -ContextTypeName MyContext -MigrationsDirectory DirectoryName
    # Scaffold a migrations configuration for a project with multiple contexts
    # This scaffolds a migrations configuration for MyContext and will put the configuration
    # and subsequent configurations in a new directory called "DirectoryName"

#>
function Enable-Migrations
{
    [CmdletBinding(DefaultParameterSetName = 'ConnectionStringName', PositionalBinding = $false)]
    param(
        [string] $ContextTypeName,
        [alias('Auto')]
        [switch] $EnableAutomaticMigrations,
        [string] $MigrationsDirectory,
        [string] $ProjectName,
        [string] $StartUpProjectName,
        [string] $ContextProjectName,
        [parameter(ParameterSetName = 'ConnectionStringName')]
        [string] $ConnectionStringName,
        [parameter(ParameterSetName = 'ConnectionStringAndProviderName', Mandatory = $true)]
        [string] $ConnectionString,
        [parameter(ParameterSetName = 'ConnectionStringAndProviderName', Mandatory = $true)]
        [string] $ConnectionProviderName,
        [switch] $Force,
        [string] $ContextAssemblyName,
        [string] $AppDomainBaseDirectory)

    WarnIfOtherEFs 'Enable-Migrations'

    $project = GetProject $ProjectName
    $startupProject = GetStartupProject $StartUpProjectName $project

    if (!$ContextAssemblyName -and $ContextProjectName)
    {
        $contextProject = Get-Project $ContextProjectName
        $ContextAssemblyName = GetProperty $contextProject.Properties 'AssemblyName'
    }

    $params = 'migrations', 'enable', '--json'

    if ($ContextTypeName)
    {
        $params += '--context', $ContextTypeName
    }

    if ($ContextAssemblyName)
    {
        $params += '--context-assembly', $ContextAssemblyName
    }

    if ($EnableAutomaticMigrations)
    {
        $params += '--auto'
    }

    if ($MigrationsDirectory)
    {
        $params += '--migrations-dir', $MigrationsDirectory
    }

    $params += GetParams $ConnectionStringName $ConnectionString $ConnectionProviderName

    if ($Force)
    {
        $params += '--force'
    }

    # NB: -join is here to support ConvertFrom-Json on PowerShell 3.0
    $result = (EF6 $project $startupProject $AppDomainBaseDirectory $params) -join "`n" | ConvertFrom-Json

    $project.ProjectItems.AddFromFile($result.migrationsConfiguration) | Out-Null
    $DTE.ItemOperations.OpenFile($result.migrationsConfiguration) | Out-Null
    ShowConsole

    if ($result.migration)
    {
        $project.ProjectItems.AddFromFile($result.migration) | Out-Null
        $resourcesProperties = $project.ProjectItems.AddFromFile($result.migrationResources).Properties
        $project.ProjectItems.AddFromFile($result.migrationDesigner) | Out-Null
    }
}

<#
.SYNOPSIS
    Scaffolds a migration script for any pending model changes.

.DESCRIPTION
    Scaffolds a new migration script and adds it to the project.

.PARAMETER Name
    Specifies the name of the custom script.

.PARAMETER Force
    Specifies that the migration user code be overwritten when re-scaffolding an
    existing migration.

.PARAMETER ProjectName
    Specifies the project that contains the migration configuration type to be
    used. If omitted, the default project selected in package manager console
    is used.

.PARAMETER StartUpProjectName
    Specifies the configuration file to use for named connection strings. If
    omitted, the specified project's configuration file is used.

.PARAMETER ConfigurationTypeName
    Specifies the migrations configuration to use. If omitted, migrations will
    attempt to locate a single migrations configuration type in the target
    project.

.PARAMETER ConnectionStringName
    Specifies the name of a connection string to use from the application's
    configuration file.

.PARAMETER ConnectionString
    Specifies the connection string to use. If omitted, the context's
    default connection will be used.

.PARAMETER ConnectionProviderName
    Specifies the provider invariant name of the connection string.

.PARAMETER IgnoreChanges
    Scaffolds an empty migration ignoring any pending changes detected in the current model.
    This can be used to create an initial, empty migration to enable Migrations for an existing
    database. N.B. Doing this assumes that the target database schema is compatible with the
    current model.

.PARAMETER AppDomainBaseDirectory
    Specifies the directory to use for the app-domain that is used for running Migrations
    code such that the app-domain is able to find all required assemblies. This is an
    advanced option that should only be needed if the solution contains	several projects
    such that the assemblies needed for the context and configuration are not all
    referenced from either the project containing the context or the project containing
    the migrations.

.EXAMPLE
    Add-Migration First
    # Scaffold a new migration named "First"

.EXAMPLE
    Add-Migration First -IgnoreChanges
    # Scaffold an empty migration ignoring any pending changes detected in the current model.
    # This can be used to create an initial, empty migration to enable Migrations for an existing
    # database. N.B. Doing this assumes that the target database schema is compatible with the
    # current model.

#>
function Add-Migration
{
    [CmdletBinding(DefaultParameterSetName = 'ConnectionStringName', PositionalBinding = $false)]
    param(
        [parameter(Position = 0, Mandatory = $true)]
        [string] $Name,
        [switch] $Force,
        [string] $ProjectName,
        [string] $StartUpProjectName,
        [string] $ConfigurationTypeName,
        [parameter(ParameterSetName = 'ConnectionStringName')]
        [string] $ConnectionStringName,
        [parameter(ParameterSetName = 'ConnectionStringAndProviderName', Mandatory = $true)]
        [string] $ConnectionString,
        [parameter(ParameterSetName = 'ConnectionStringAndProviderName', Mandatory = $true)]
        [string] $ConnectionProviderName,
        [switch] $IgnoreChanges,
        [string] $AppDomainBaseDirectory)

    WarnIfOtherEFs 'Add-Migration'

    $project = GetProject $ProjectName
    $startupProject = GetStartupProject $StartUpProjectName $project

    $params = 'migrations', 'add', $Name, '--json'

    if ($Force)
    {
        $params += '--force'
    }

    if ($ConfigurationTypeName)
    {
        $params += '--migrations-config', $ConfigurationTypeName
    }

    if ($IgnoreChanges)
    {
        $params += '--ignore-changes'
    }

    $params += GetParams $ConnectionStringName $ConnectionString $ConnectionProviderName

    # NB: -join is here to support ConvertFrom-Json on PowerShell 3.0
    $result = (EF6 $project $startupProject $AppDomainBaseDirectory $params) -join "`n" | ConvertFrom-Json

    $project.ProjectItems.AddFromFile($result.migration) | Out-Null
    $DTE.ItemOperations.OpenFile($result.migration) | Out-Null
    $resourcesProperties = $project.ProjectItems.AddFromFile($result.migrationResources).Properties
    $project.ProjectItems.AddFromFile($result.migrationDesigner) | Out-Null
}

<#
.SYNOPSIS
    Applies any pending migrations to the database.

.DESCRIPTION
    Updates the database to the current model by applying pending migrations.

.PARAMETER SourceMigration
    Only valid with -Script. Specifies the name of a particular migration to use
    as the update's starting point. If omitted, the last applied migration in
    the database will be used.

.PARAMETER TargetMigration
    Specifies the name of a particular migration to update the database to. If
    omitted, the current model will be used.

.PARAMETER Script
    Generate a SQL script rather than executing the pending changes directly.

.PARAMETER Force
    Specifies that data loss is acceptable during automatic migration of the
    database.

.PARAMETER ProjectName
    Specifies the project that contains the migration configuration type to be
    used. If omitted, the default project selected in package manager console
    is used.

.PARAMETER StartUpProjectName
    Specifies the configuration file to use for named connection strings. If
    omitted, the specified project's configuration file is used.

.PARAMETER ConfigurationTypeName
    Specifies the migrations configuration to use. If omitted, migrations will
    attempt to locate a single migrations configuration type in the target
    project.

.PARAMETER ConnectionStringName
    Specifies the name of a connection string to use from the application's
    configuration file.

.PARAMETER ConnectionString
    Specifies the connection string to use. If omitted, the context's
    default connection will be used.

.PARAMETER ConnectionProviderName
    Specifies the provider invariant name of the connection string.

.PARAMETER AppDomainBaseDirectory
    Specifies the directory to use for the app-domain that is used for running Migrations
    code such that the app-domain is able to find all required assemblies. This is an
    advanced option that should only be needed if the solution contains	several projects
    such that the assemblies needed for the context and configuration are not all
    referenced from either the project containing the context or the project containing
    the migrations.

.EXAMPLE
    Update-Database
    # Update the database to the latest migration

.EXAMPLE
    Update-Database -TargetMigration Second
    # Update database to a migration named "Second"
    # This will apply migrations if the target hasn't been applied or roll back migrations
    # if it has

.EXAMPLE
    Update-Database -Script
    # Generate a script to update the database from its current state to the latest migration

.EXAMPLE
    Update-Database -Script -SourceMigration Second -TargetMigration First
    # Generate a script to migrate the database from a specified start migration
    # named "Second" to a specified target migration named "First"

.EXAMPLE
    Update-Database -Script -SourceMigration $InitialDatabase
    # Generate a script that can upgrade a database currently at any version to the latest version.
    # The generated script includes logic to check the __MigrationsHistory table and only apply changes
    # that haven't been previously applied.

.EXAMPLE
    Update-Database -TargetMigration $InitialDatabase
    # Runs the Down method to roll-back any migrations that have been applied to the database


#>
function Update-Database
{
    [CmdletBinding(DefaultParameterSetName = 'ConnectionStringName', PositionalBinding = $false)]
    param(
        [string] $SourceMigration,
        [string] $TargetMigration,
        [switch] $Script,
        [switch] $Force,
        [string] $ProjectName,
        [string] $StartUpProjectName,
        [string] $ConfigurationTypeName,
        [parameter(ParameterSetName = 'ConnectionStringName')]
        [string] $ConnectionStringName,
        [parameter(ParameterSetName = 'ConnectionStringAndProviderName', Mandatory = $true)]
        [string] $ConnectionString,
        [parameter(ParameterSetName = 'ConnectionStringAndProviderName', Mandatory = $true)]
        [string] $ConnectionProviderName,
        [string] $AppDomainBaseDirectory)

    WarnIfOtherEFs 'Update-Database'

    $project = GetProject $ProjectName
    $startupProject = GetStartupProject $StartUpProjectName $project

    $params = 'database', 'update'

    if ($SourceMigration)
    {
        $params += '--source', $SourceMigration
    }

    if ($TargetMigration)
    {
        $params += '--target', $TargetMigration
    }

    if ($Script)
    {
        $params += '--script'
    }

    if ($Force)
    {
        $params += '--force'
    }

    if ($ConfigurationTypeName)
    {
        $params += '--migrations-config', $ConfigurationTypeName
    }

    $params += GetParams $ConnectionStringName $ConnectionString $ConnectionProviderName

    $result = (EF6 $project $startupProject $AppDomainBaseDirectory $params) -join "`n"
    if ($result)
    {
        try
        {
            $window = $DTE.ItemOperations.NewFile('General\Sql File')
            $textDocument = $window.Document.Object('TextDocument')
            $editPoint = $textDocument.StartPoint.CreateEditPoint()
            $editPoint.Insert($result)
        }
        catch
        {
            $intermediatePath = GetIntermediatePath $project
            if (![IO.Path]::IsPathRooted($intermediatePath))
            {
                $projectDir = GetProperty $project.Properties 'FullPath'
                $intermediatePath = Join-Path $projectDir $intermediatePath -Resolve | Convert-Path
            }

            $fileName = [IO.Path]::ChangeExtension([IO.Path]::GetRandomFileName(), '.sql')
            $sqlFile = Join-Path $intermediatePath $fileName

            [IO.File]::WriteAllText($sqlFile, $result)

            $DTE.ItemOperations.OpenFile($sqlFile) | Out-Null
        }

        ShowConsole
    }
}

<#
.SYNOPSIS
    Displays the migrations that have been applied to the target database.

.DESCRIPTION
    Displays the migrations that have been applied to the target database.

.PARAMETER ProjectName
    Specifies the project that contains the migration configuration type to be
    used. If omitted, the default project selected in package manager console
    is used.

.PARAMETER StartUpProjectName
    Specifies the configuration file to use for named connection strings. If
    omitted, the specified project's configuration file is used.

.PARAMETER ConfigurationTypeName
    Specifies the migrations configuration to use. If omitted, migrations will
    attempt to locate a single migrations configuration type in the target
    project.

.PARAMETER ConnectionStringName
    Specifies the name of a connection string to use from the application's
    configuration file.

.PARAMETER ConnectionString
    Specifies the connection string to use. If omitted, the context's
    default connection will be used.

.PARAMETER ConnectionProviderName
    Specifies the provider invariant name of the connection string.

.PARAMETER AppDomainBaseDirectory
    Specifies the directory to use for the app-domain that is used for running Migrations
    code such that the app-domain is able to find all required assemblies. This is an
    advanced option that should only be needed if the solution contains	several projects
    such that the assemblies needed for the context and configuration are not all
    referenced from either the project containing the context or the project containing
    the migrations.
#>
function Get-Migrations
{
    [CmdletBinding(DefaultParameterSetName = 'ConnectionStringName', PositionalBinding = $false)]
    param(
        [string] $ProjectName,
        [string] $StartUpProjectName,
        [string] $ConfigurationTypeName,
        [parameter(ParameterSetName = 'ConnectionStringName')]
        [string] $ConnectionStringName,
        [parameter(ParameterSetName = 'ConnectionStringAndProviderName', Mandatory = $true)]
        [string] $ConnectionString,
        [parameter(ParameterSetName = 'ConnectionStringAndProviderName', Mandatory = $true)]
        [string] $ConnectionProviderName,
        [string] $AppDomainBaseDirectory)

    WarnIfOtherEFs 'Get-Migrations'

    $project = GetProject $ProjectName
    $startupProject = GetStartupProject $StartUpProjectName $project

    $params = 'migrations', 'list'

    if ($ConfigurationTypeName)
    {
        $params += '--migrations-config', $ConfigurationTypeName
    }

    $params += GetParams $ConnectionStringName $ConnectionString $ConnectionProviderName

    return EF6 $project $startupProject $AppDomainBaseDirectory $params
}

function WarnIfOtherEFs($cmdlet)
{
    if (Get-Module 'EntityFrameworkCore')
    {
        Write-Warning "Both Entity Framework 6 and Entity Framework Core are installed. The Entity Framework 6 tools are running. Use 'EntityFrameworkCore\$cmdlet' for Entity Framework Core."
    }

    if (Get-Module 'EntityFramework')
    {
        Write-Warning "A version of Entity Framework older than 6.3 is also installed. The newer tools are running. Use 'EntityFramework\$cmdlet' for the older version."
    }
}

function GetProject($projectName)
{
    if (!$projectName)
    {
        return Get-Project
    }

    return Get-Project $projectName
}

function GetStartupProject($name, $fallbackProject)
{
    if ($name)
    {
        return Get-Project $name
    }

    $startupProjectPaths = $DTE.Solution.SolutionBuild.StartupProjects
    if ($startupProjectPaths)
    {
        if ($startupProjectPaths.Length -eq 1)
        {
            $startupProjectPath = $startupProjectPaths[0]
            if (![IO.Path]::IsPathRooted($startupProjectPath))
            {
                $solutionPath = Split-Path (GetProperty $DTE.Solution.Properties 'Path')
                $startupProjectPath = Join-Path $solutionPath $startupProjectPath -Resolve | Convert-Path
            }

            $startupProject = GetSolutionProjects |
                ?{
                    try
                    {
                        $fullName = $_.FullName
                    }
                    catch [NotImplementedException]
                    {
                        return $false
                    }

                    if ($fullName -and $fullName.EndsWith('\'))
                    {
                        $fullName = $fullName.Substring(0, $fullName.Length - 1)
                    }

                    return $fullName -eq $startupProjectPath
                }
            if ($startupProject)
            {
                return $startupProject
            }

            Write-Warning "Unable to resolve startup project '$startupProjectPath'."
        }
        else
        {
            Write-Warning 'Multiple startup projects set.'
        }
    }
    else
    {
        Write-Warning 'No startup project set.'
    }

    Write-Warning "Using project '$($fallbackProject.ProjectName)' as the startup project."

    return $fallbackProject
}

function GetSolutionProjects()
{
    $projects = New-Object 'System.Collections.Stack'

    $DTE.Solution.Projects |
        %{ $projects.Push($_) }

    while ($projects.Count)
    {
        $project = $projects.Pop();

        <# yield return #> $project

        if ($project.ProjectItems)
        {
            $project.ProjectItems |
                ?{ $_.SubProject } |
                %{ $projects.Push($_.SubProject) }
        }
    }
}

function GetParams($connectionStringName, $connectionString, $connectionProviderName)
{
    $params = @()

    if ($connectionStringName)
    {
        $params += '--connection-string-name', $connectionStringName
    }

    if ($connectionString)
    {
        $params += '--connection-string', $connectionString,
            '--connection-provider', $connectionProviderName
    }

    return $params
}

function ShowConsole
{
    $componentModel = Get-VSComponentModel
    $powerConsoleWindow = $componentModel.GetService([NuGetConsole.IPowerConsoleWindow])
    $powerConsoleWindow.Show()
}

function WriteErrorLine($message)
{
    try
    {
        # Call the internal API NuGet uses to display errors
        $componentModel = Get-VSComponentModel
        $powerConsoleWindow = $componentModel.GetService([NuGetConsole.IPowerConsoleWindow])
        $bindingFlags = [Reflection.BindingFlags]::Instance -bor [Reflection.BindingFlags]::NonPublic
        $activeHostInfo = $powerConsoleWindow.GetType().GetProperty('ActiveHostInfo', $bindingFlags).GetValue($powerConsoleWindow)
        $internalHost = $activeHostInfo.WpfConsole.Host
        $reportErrorMethod = $internalHost.GetType().GetMethod('ReportError', $bindingFlags, $null, [Exception], $null)
        $exception = New-Object Exception $message
        $reportErrorMethod.Invoke($internalHost, $exception)
    }
    catch
    {
        Write-Host $message -ForegroundColor DarkRed
    }
}

function EF6($project, $startupProject, $workingDir, $params)
{
    $solutionBuild = $DTE.Solution.SolutionBuild
    $solutionBuild.BuildProject(
        $solutionBuild.ActiveConfiguration.Name,
        $project.UniqueName,
        <# WaitForBuildToFinish #> $true)
    if ($solutionBuild.LastBuildInfo)
    {
        throw "The project '$($project.ProjectName)' failed to build."
    }

    $projectDir = GetProperty $project.Properties 'FullPath'
    $outputPath = GetProperty $project.ConfigurationManager.ActiveConfiguration.Properties 'OutputPath'
    $targetDir = [IO.Path]::GetFullPath([IO.Path]::Combine($projectDir, $outputPath))
    $targetFrameworkMoniker = GetProperty $project.Properties 'TargetFrameworkMoniker'
    $frameworkName = New-Object 'System.Runtime.Versioning.FrameworkName' $targetFrameworkMoniker
    $targetFrameworkIdentifier = $frameworkName.Identifier
    $targetFrameworkVersion = $frameworkName.Version

    if ($targetFrameworkIdentifier -in '.NETFramework')
    {
        if ($targetFrameworkVersion -lt '4.5')
        {
            $frameworkDir = 'net40'
        }
        else
        {
            $frameworkDir = 'net45'
        }

        $platformTarget = GetPlatformTarget $project
        if ($platformTarget -eq 'x86')
        {
            $runtimeDir = 'win-x86'
        }
        elseif ($platformTarget -eq 'ARM64')
        {
            $runtimeDir = 'win-arm64'
        }
        elseif ($platformTarget -in 'AnyCPU', 'x64')
        {
            $runtimeDir = 'any'
        }
        else
        {
            throw "Project '$($project.ProjectName)' has an active platform of '$platformTarget'. Select a different " +
                'platform and try again.'
        }

        $exePath = Join-Path $PSScriptRoot "$frameworkDir\$runtimeDir\ef6.exe"
    }
    elseif ($targetFrameworkIdentifier -eq '.NETCoreApp')
    {
        $exePath = (Get-Command 'dotnet').Path

        $targetName = GetProperty $project.Properties 'AssemblyName'
        $depsFile = Join-Path $targetDir ($targetName + '.deps.json')
        $projectAssetsFile = GetCpsProperty $project 'ProjectAssetsFile'
        $runtimeConfig = Join-Path $targetDir ($targetName + '.runtimeconfig.json')
        $runtimeFrameworkVersion = GetCpsProperty $project 'RuntimeFrameworkVersion'
        $efPath = Join-Path $PSScriptRoot 'net6.0\any\ef6.dll'

        $dotnetParams = 'exec', '--depsfile', $depsFile

        if ($projectAssetsFile)
        {
            # NB: Don't use Get-Content. It doesn't handle UTF-8 without a signature
            # NB: Don't use ReadAllLines. ConvertFrom-Json won't work on PowerShell 3.0
            $projectAssets = [IO.File]::ReadAllText($projectAssetsFile) | ConvertFrom-Json
            $projectAssets.packageFolders.psobject.Properties.Name |
                %{ $dotnetParams += '--additionalprobingpath', $_.TrimEnd('\') }
        }

        if (Test-Path $runtimeConfig)
        {
            $dotnetParams += '--runtimeconfig', $runtimeConfig
        }
        elseif ($runtimeFrameworkVersion)
        {
            $dotnetParams += '--fx-version', $runtimeFrameworkVersion
        }

        $dotnetParams += $efPath

        $params = $dotnetParams + $params
    }
    else
    {
        throw "Project '$($startupProject.ProjectName)' targets framework '$targetFrameworkIdentifier'. The Entity Framework " +
            'Package Manager Console Tools don''t support this framework.'
    }

    $targetFileName = GetProperty $project.Properties 'OutputFileName'
    $targetPath = Join-Path $targetDir $targetFileName
    $rootNamespace = GetProperty $project.Properties 'RootNamespace'
    $language = GetLanguage $project

    $params += '--verbose',
        '--no-color',
        '--prefix-output',
        '--assembly', $targetPath,
        '--project-dir', $projectDir,
        '--language', $language

    if (IsWeb $startupProject)
    {
        $startupProjectDir = GetProperty $startupProject.Properties 'FullPath'
        $params += '--data-dir', (Join-Path $startupProjectDir 'App_Data')
    }

    if ($rootNamespace)
    {
        $params += '--root-namespace', $rootNamespace
    }

    $configFile = GetConfigPath $startupProject
    if ($configFile)
    {
        $params += '--config', $configFile
    }

    if (!$workingDir)
    {
        $workingDir = $targetDir
    }

    $arguments = ToArguments $params
    $startInfo = New-Object 'System.Diagnostics.ProcessStartInfo' -Property @{
        FileName = $exePath;
        Arguments = $arguments;
        UseShellExecute = $false;
        CreateNoWindow = $true;
        RedirectStandardOutput = $true;
        StandardOutputEncoding = [Text.Encoding]::UTF8;
        RedirectStandardError = $true;
        WorkingDirectory = $workingDir;
    }

    Write-Verbose "$exePath $arguments"

    $process = [Diagnostics.Process]::Start($startInfo)

    while (($line = $process.StandardOutput.ReadLine()) -ne $null)
    {
        $level = $null
        $text = $null

        $parts = $line.Split(':', 2)
        if ($parts.Length -eq 2)
        {
            $level = $parts[0]

            $i = 0
            $count = 8 - $level.Length
            while ($i -lt $count -and $parts[1][$i] -eq ' ')
            {
                $i++
            }

            $text = $parts[1].Substring($i)
        }

        switch ($level)
        {
            'error' { WriteErrorLine $text }
            'warn' { Write-Warning $text }
            'info' { Write-Host $text }
            'data' { Write-Output $text }
            'verbose' { Write-Verbose $text }
            default { Write-Host $line }
        }
    }

    $process.WaitForExit()

    if ($process.ExitCode)
    {
        while (($line = $process.StandardError.ReadLine()) -ne $null)
        {
            WriteErrorLine $line
        }

        exit
    }
}

function IsCpsProject($project)
{
    $hierarchy = GetVsHierarchy $project
    $isCapabilityMatch = [Microsoft.VisualStudio.Shell.PackageUtilities].GetMethod(
        'IsCapabilityMatch',
        [type[]]([Microsoft.VisualStudio.Shell.Interop.IVsHierarchy], [string]))

    return $isCapabilityMatch.Invoke($null, ($hierarchy, 'CPS'))
}

function IsWeb($project)
{
    $hierarchy = GetVsHierarchy $project

    $aggregatableProject = Get-Interface $hierarchy 'Microsoft.VisualStudio.Shell.Interop.IVsAggregatableProject'
    if (!$aggregatableProject)
    {
        $projectTypes = $project.Kind
    }
    else
    {
        $projectTypeGuids = $null
        $hr = $aggregatableProject.GetAggregateProjectTypeGuids([ref] $projectTypeGuids)
        [Runtime.InteropServices.Marshal]::ThrowExceptionForHR($hr)

        $projectTypes = $projectTypeGuids.Split(';')
    }

    foreach ($projectType in $projectTypes)
    {
        if ($projectType -in '{349C5851-65DF-11DA-9384-00065B846F21}', '{E24C65DC-7377-472B-9ABA-BC803B73C61A}')
        {
            return $true
        }
    }

    return $false;
}

function GetIntermediatePath($project)
{
    $intermediatePath = GetProperty $project.ConfigurationManager.ActiveConfiguration.Properties 'IntermediatePath'
    if ($intermediatePath)
    {
        return $intermediatePath
    }

    return GetMSBuildProperty $project 'IntermediateOutputPath'
}

function GetPlatformTarget($project)
{
    if (IsCpsProject $project)
    {
        $platformTarget = GetCpsProperty $project 'PlatformTarget'
        if ($platformTarget)
        {
            return $platformTarget
        }

        return GetCpsProperty $project 'Platform'
    }

    $platformTarget = GetProperty $project.ConfigurationManager.ActiveConfiguration.Properties 'PlatformTarget'
    if ($platformTarget)
    {
        return $platformTarget
    }

    # NB: For classic F# projects
    $platformTarget = GetMSBuildProperty $project 'PlatformTarget'
    if ($platformTarget)
    {
        return $platformTarget
    }

    return 'AnyCPU'
}

function GetLanguage($project)
{
    if (IsCpsProject $project)
    {
        return GetCpsProperty $project 'Language'
    }

    return GetMSBuildProperty $project 'Language'
}

function GetVsHierarchy($project)
{
    $solution = Get-VSService 'Microsoft.VisualStudio.Shell.Interop.SVsSolution' 'Microsoft.VisualStudio.Shell.Interop.IVsSolution'
    $hierarchy = $null
    $hr = $solution.GetProjectOfUniqueName($project.UniqueName, [ref] $hierarchy)
    [Runtime.InteropServices.Marshal]::ThrowExceptionForHR($hr)

    return $hierarchy
}

function GetProperty($properties, $propertyName)
{
    try
    {
        return $properties.Item($propertyName).Value
    }
    catch
    {
        return $null
    }
}

function GetCpsProperty($project, $propertyName)
{
    $browseObjectContext = Get-Interface $project 'Microsoft.VisualStudio.ProjectSystem.Properties.IVsBrowseObjectContext'
    $unconfiguredProject = $browseObjectContext.UnconfiguredProject
    $configuredProject = $unconfiguredProject.GetSuggestedConfiguredProjectAsync().Result
    $properties = $configuredProject.Services.ProjectPropertiesProvider.GetCommonProperties()

    return $properties.GetEvaluatedPropertyValueAsync($propertyName).Result
}

function GetMSBuildProperty($project, $propertyName)
{
    $msbuildProject = [Microsoft.Build.Evaluation.ProjectCollection]::GlobalProjectCollection.LoadedProjects |
        where FullPath -eq $project.FullName

    return $msbuildProject.GetProperty($propertyName).EvaluatedValue
}

function ToArguments($params)
{
    $arguments = ''
    for ($i = 0; $i -lt $params.Length; $i++)
    {
        if ($i)
        {
            $arguments += ' '
        }

        if (!$params[$i].Contains(' '))
        {
            $arguments += $params[$i]

            continue
        }

        $arguments += '"'

        $pendingBackslashs = 0
        for ($j = 0; $j -lt $params[$i].Length; $j++)
        {
            switch ($params[$i][$j])
            {
                '"'
                {
                    if ($pendingBackslashs)
                    {
                        $arguments += '\' * $pendingBackslashs * 2
                        $pendingBackslashs = 0
                    }
                    $arguments += '\"'
                }

                '\'
                {
                    $pendingBackslashs++
                }

                default
                {
                    if ($pendingBackslashs)
                    {
                        if ($pendingBackslashs -eq 1)
                        {
                            $arguments += '\'
                        }
                        else
                        {
                            $arguments += '\' * $pendingBackslashs * 2
                        }

                        $pendingBackslashs = 0
                    }

                    $arguments += $params[$i][$j]
                }
            }
        }

        if ($pendingBackslashs)
        {
            $arguments += '\' * $pendingBackslashs * 2
        }

        $arguments += '"'
    }

    return $arguments
}

function GetConfigPath($project)
{
    if (IsWeb $project)
    {
        $configFileName = 'web.config'
    }
    else
    {
        $configFileName = 'app.config'
    }

    $item = $project.ProjectItems |
        where Name -eq $configFileName |
        select -First 1

    return GetProperty $item.Properties 'FullPath'
}

Export-ModuleMember 'Add-EFDefaultConnectionFactory', 'Add-EFProvider', 'Add-Migration', 'Enable-Migrations', 'Get-Migrations', 'Update-Database' -Variable 'InitialDatabase'

# SIG # Begin signature block
# MIIn0QYJKoZIhvcNAQcCoIInwjCCJ74CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDbeCwMxGtKRttT
# ijQaHdjd2z/9CxF7jWlHbDuJIb0OjaCCDYUwggYDMIID66ADAgECAhMzAAADri01
# UchTj1UdAAAAAAOuMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjMxMTE2MTkwODU5WhcNMjQxMTE0MTkwODU5WjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQD0IPymNjfDEKg+YyE6SjDvJwKW1+pieqTjAY0CnOHZ1Nj5irGjNZPMlQ4HfxXG
# yAVCZcEWE4x2sZgam872R1s0+TAelOtbqFmoW4suJHAYoTHhkznNVKpscm5fZ899
# QnReZv5WtWwbD8HAFXbPPStW2JKCqPcZ54Y6wbuWV9bKtKPImqbkMcTejTgEAj82
# 6GQc6/Th66Koka8cUIvz59e/IP04DGrh9wkq2jIFvQ8EDegw1B4KyJTIs76+hmpV
# M5SwBZjRs3liOQrierkNVo11WuujB3kBf2CbPoP9MlOyyezqkMIbTRj4OHeKlamd
# WaSFhwHLJRIQpfc8sLwOSIBBAgMBAAGjggGCMIIBfjAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQUhx/vdKmXhwc4WiWXbsf0I53h8T8w
# VAYDVR0RBE0wS6RJMEcxLTArBgNVBAsTJE1pY3Jvc29mdCBJcmVsYW5kIE9wZXJh
# dGlvbnMgTGltaXRlZDEWMBQGA1UEBRMNMjMwMDEyKzUwMTgzNjAfBgNVHSMEGDAW
# gBRIbmTlUAXTgqoXNzcitW2oynUClTBUBgNVHR8ETTBLMEmgR6BFhkNodHRwOi8v
# d3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NybC9NaWNDb2RTaWdQQ0EyMDExXzIw
# MTEtMDctMDguY3JsMGEGCCsGAQUFBwEBBFUwUzBRBggrBgEFBQcwAoZFaHR0cDov
# L3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jZXJ0cy9NaWNDb2RTaWdQQ0EyMDEx
# XzIwMTEtMDctMDguY3J0MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQADggIB
# AGrJYDUS7s8o0yNprGXRXuAnRcHKxSjFmW4wclcUTYsQZkhnbMwthWM6cAYb/h2W
# 5GNKtlmj/y/CThe3y/o0EH2h+jwfU/9eJ0fK1ZO/2WD0xi777qU+a7l8KjMPdwjY
# 0tk9bYEGEZfYPRHy1AGPQVuZlG4i5ymJDsMrcIcqV8pxzsw/yk/O4y/nlOjHz4oV
# APU0br5t9tgD8E08GSDi3I6H57Ftod9w26h0MlQiOr10Xqhr5iPLS7SlQwj8HW37
# ybqsmjQpKhmWul6xiXSNGGm36GarHy4Q1egYlxhlUnk3ZKSr3QtWIo1GGL03hT57
# xzjL25fKiZQX/q+II8nuG5M0Qmjvl6Egltr4hZ3e3FQRzRHfLoNPq3ELpxbWdH8t
# Nuj0j/x9Crnfwbki8n57mJKI5JVWRWTSLmbTcDDLkTZlJLg9V1BIJwXGY3i2kR9i
# 5HsADL8YlW0gMWVSlKB1eiSlK6LmFi0rVH16dde+j5T/EaQtFz6qngN7d1lvO7uk
# 6rtX+MLKG4LDRsQgBTi6sIYiKntMjoYFHMPvI/OMUip5ljtLitVbkFGfagSqmbxK
# 7rJMhC8wiTzHanBg1Rrbff1niBbnFbbV4UDmYumjs1FIpFCazk6AADXxoKCo5TsO
# zSHqr9gHgGYQC2hMyX9MGLIpowYCURx3L7kUiGbOiMwaMIIHejCCBWKgAwIBAgIK
# YQ6Q0gAAAAAAAzANBgkqhkiG9w0BAQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlm
# aWNhdGUgQXV0aG9yaXR5IDIwMTEwHhcNMTEwNzA4MjA1OTA5WhcNMjYwNzA4MjEw
# OTA5WjB+MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSgwJgYD
# VQQDEx9NaWNyb3NvZnQgQ29kZSBTaWduaW5nIFBDQSAyMDExMIICIjANBgkqhkiG
# 9w0BAQEFAAOCAg8AMIICCgKCAgEAq/D6chAcLq3YbqqCEE00uvK2WCGfQhsqa+la
# UKq4BjgaBEm6f8MMHt03a8YS2AvwOMKZBrDIOdUBFDFC04kNeWSHfpRgJGyvnkmc
# 6Whe0t+bU7IKLMOv2akrrnoJr9eWWcpgGgXpZnboMlImEi/nqwhQz7NEt13YxC4D
# dato88tt8zpcoRb0RrrgOGSsbmQ1eKagYw8t00CT+OPeBw3VXHmlSSnnDb6gE3e+
# lD3v++MrWhAfTVYoonpy4BI6t0le2O3tQ5GD2Xuye4Yb2T6xjF3oiU+EGvKhL1nk
# kDstrjNYxbc+/jLTswM9sbKvkjh+0p2ALPVOVpEhNSXDOW5kf1O6nA+tGSOEy/S6
# A4aN91/w0FK/jJSHvMAhdCVfGCi2zCcoOCWYOUo2z3yxkq4cI6epZuxhH2rhKEmd
# X4jiJV3TIUs+UsS1Vz8kA/DRelsv1SPjcF0PUUZ3s/gA4bysAoJf28AVs70b1FVL
# 5zmhD+kjSbwYuER8ReTBw3J64HLnJN+/RpnF78IcV9uDjexNSTCnq47f7Fufr/zd
# sGbiwZeBe+3W7UvnSSmnEyimp31ngOaKYnhfsi+E11ecXL93KCjx7W3DKI8sj0A3
# T8HhhUSJxAlMxdSlQy90lfdu+HggWCwTXWCVmj5PM4TasIgX3p5O9JawvEagbJjS
# 4NaIjAsCAwEAAaOCAe0wggHpMBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBRI
# bmTlUAXTgqoXNzcitW2oynUClTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTAL
# BgNVHQ8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBRyLToCMZBD
# uRQFTuHqp8cx0SOJNDBaBgNVHR8EUzBRME+gTaBLhklodHRwOi8vY3JsLm1pY3Jv
# c29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFf
# MDNfMjIuY3JsMF4GCCsGAQUFBwEBBFIwUDBOBggrBgEFBQcwAoZCaHR0cDovL3d3
# dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFf
# MDNfMjIuY3J0MIGfBgNVHSAEgZcwgZQwgZEGCSsGAQQBgjcuAzCBgzA/BggrBgEF
# BQcCARYzaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9kb2NzL3ByaW1h
# cnljcHMuaHRtMEAGCCsGAQUFBwICMDQeMiAdAEwAZQBnAGEAbABfAHAAbwBsAGkA
# YwB5AF8AcwB0AGEAdABlAG0AZQBuAHQALiAdMA0GCSqGSIb3DQEBCwUAA4ICAQBn
# 8oalmOBUeRou09h0ZyKbC5YR4WOSmUKWfdJ5DJDBZV8uLD74w3LRbYP+vj/oCso7
# v0epo/Np22O/IjWll11lhJB9i0ZQVdgMknzSGksc8zxCi1LQsP1r4z4HLimb5j0b
# pdS1HXeUOeLpZMlEPXh6I/MTfaaQdION9MsmAkYqwooQu6SpBQyb7Wj6aC6VoCo/
# KmtYSWMfCWluWpiW5IP0wI/zRive/DvQvTXvbiWu5a8n7dDd8w6vmSiXmE0OPQvy
# CInWH8MyGOLwxS3OW560STkKxgrCxq2u5bLZ2xWIUUVYODJxJxp/sfQn+N4sOiBp
# mLJZiWhub6e3dMNABQamASooPoI/E01mC8CzTfXhj38cbxV9Rad25UAqZaPDXVJi
# hsMdYzaXht/a8/jyFqGaJ+HNpZfQ7l1jQeNbB5yHPgZ3BtEGsXUfFL5hYbXw3MYb
# BL7fQccOKO7eZS/sl/ahXJbYANahRr1Z85elCUtIEJmAH9AAKcWxm6U/RXceNcbS
# oqKfenoi+kiVH6v7RyOA9Z74v2u3S5fi63V4GuzqN5l5GEv/1rMjaHXmr/r8i+sL
# gOppO6/8MO0ETI7f33VtY5E90Z1WTk+/gFcioXgRMiF670EKsT/7qMykXcGhiJtX
# cVZOSEXAQsmbdlsKgEhr/Xmfwb1tbWrJUnMTDXpQzTGCGaIwghmeAgEBMIGVMH4x
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01p
# Y3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTECEzMAAAOuLTVRyFOPVR0AAAAA
# A64wDQYJYIZIAWUDBAIBBQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIBf2
# +UZ1V35D68eblBFde4xKErQLQBXaZSIuA5QJUVgxMEIGCisGAQQBgjcCAQwxNDAy
# oBSAEgBNAGkAYwByAG8AcwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20wDQYJKoZIhvcNAQEBBQAEggEALmJfYfj/kPvaDSa4naPORUr4QC/zCjlewmRH
# vQXMLbQv1uEfH435lUk41r8R2ZXZV062fT8AO8Lb59Ipqv8bfjOUjZ0x7A/3/WCE
# x0F9dLea9b9rDa59ikthuc0uzGKaEqbykyrqYXxUfR0PBqViR5d6mwXTitPuJtMC
# MRBu9HA5xKFGATQ4u6u1LloSTXUDpPjNy0Lp/hzKB8EXem7FjlifZ85gq34MUXdy
# SFRWbBAvvcusEacBv3KvHLwaw21aoi5jBXelGocwqPrGpY3H3RwDhxhF/2K8cBP0
# Z5dYdIXzY0gJZNEb3stuDQSlyvhyOSW0P7EjeifWz9DKI9kyeaGCFywwghcoBgor
# BgEEAYI3AwMBMYIXGDCCFxQGCSqGSIb3DQEHAqCCFwUwghcBAgEDMQ8wDQYJYIZI
# AWUDBAIBBQAwggFZBgsqhkiG9w0BCRABBKCCAUgEggFEMIIBQAIBAQYKKwYBBAGE
# WQoDATAxMA0GCWCGSAFlAwQCAQUABCDBcAYW9vKicJPyzFJaWWh9lOPExKoGgIbg
# rB3jqsKY2QIGZfxmpQEkGBMyMDI0MDMzMDIwNTMwMi41NjZaMASAAgH0oIHYpIHV
# MIHSMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQL
# EyRNaWNyb3NvZnQgSXJlbGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJjAkBgNVBAsT
# HVRoYWxlcyBUU1MgRVNOOjJBRDQtNEI5Mi1GQTAxMSUwIwYDVQQDExxNaWNyb3Nv
# ZnQgVGltZS1TdGFtcCBTZXJ2aWNloIIRezCCBycwggUPoAMCAQICEzMAAAHenkie
# lp8oRD0AAQAAAd4wDQYJKoZIhvcNAQELBQAwfDELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAg
# UENBIDIwMTAwHhcNMjMxMDEyMTkwNzEyWhcNMjUwMTEwMTkwNzEyWjCB0jELMAkG
# A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
# HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEtMCsGA1UECxMkTWljcm9z
# b2Z0IElyZWxhbmQgT3BlcmF0aW9ucyBMaW1pdGVkMSYwJAYDVQQLEx1UaGFsZXMg
# VFNTIEVTTjoyQUQ0LTRCOTItRkEwMTElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUt
# U3RhbXAgU2VydmljZTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBALSB
# 9ByF9UIDhA6xFrOniw/xsDl8sSi9rOCOXSSO4VMQjnNGAo5VHx0iijMEMH9LY2SU
# IBkVQS0Ml6kR+TagkUPbaEpwjhQ1mprhRgJT/jlSnic42VDAo0en4JI6xnXoAoWo
# KySY8/ROIKdpphgI7OJb4XHk1P3sX2pNZ32LDY1ktchK1/hWyPlblaXAHRu0E3yn
# vwrS8/bcorANO6DjuysyS9zUmr+w3H3AEvSgs2ReuLj2pkBcfW1UPCFudLd7IPZ2
# RC4odQcEPnY12jypYPnS6yZAs0pLpq0KRFUyB1x6x6OU73sudiHON16mE0l6LLT9
# OmGo0S94Bxg3N/3aE6fUbnVoemVc7FkFLum8KkZcbQ7cOHSAWGJxdCvo5OtUtRdS
# qf85FklCXIIkg4sm7nM9TktUVfO0kp6kx7mysgD0Qrxx6/5oaqnwOTWLNzK+BCi1
# G7nUD1pteuXvQp8fE1KpTjnG/1OJeehwKNNPjGt98V0BmogZTe3SxBkOeOQyLA++
# 5Hyg/L68pe+DrZoZPXJaGU/iBiFmL+ul/Oi3d83zLAHlHQmH/VGNBfRwP+ixvqhy
# k/EebwuXVJY+rTyfbRfuh9n0AaMhhNxxg6tGKyZS4EAEiDxrF9mAZEy8e8rf6dlK
# IX5d3aQLo9fDda1ZTOw+XAcAvj2/N3DLVGZlHnHlAgMBAAGjggFJMIIBRTAdBgNV
# HQ4EFgQUazAmbxseaapgdxzK8Os+naPQEsgwHwYDVR0jBBgwFoAUn6cVXQBeYl2D
# 9OXSZacbUzUZ6XIwXwYDVR0fBFgwVjBUoFKgUIZOaHR0cDovL3d3dy5taWNyb3Nv
# ZnQuY29tL3BraW9wcy9jcmwvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUy
# MDIwMTAoMSkuY3JsMGwGCCsGAQUFBwEBBGAwXjBcBggrBgEFBQcwAoZQaHR0cDov
# L3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jZXJ0cy9NaWNyb3NvZnQlMjBUaW1l
# LVN0YW1wJTIwUENBJTIwMjAxMCgxKS5jcnQwDAYDVR0TAQH/BAIwADAWBgNVHSUB
# Af8EDDAKBggrBgEFBQcDCDAOBgNVHQ8BAf8EBAMCB4AwDQYJKoZIhvcNAQELBQAD
# ggIBAOKUwHsXDacGOvUIgs5HDgPs0LZ1qyHS6C6wfKlLaD36tZfbWt1x+GMiazSu
# y+GsxiVHzkhMW+FqK8gruLQWN/sOCX+fGUgT9LT21cRIpcZj4/ZFIvwtkBcsCz1X
# EUsXYOSJUPitY7E8bbldmmhYZ29p+XQpIcsG/q+YjkqBW9mw0ru1MfxMTQs9MTDi
# D28gAVGrPA3NykiSChvdqS7VX+/LcEz9Ubzto/w28WA8HOCHqBTbDRHmiP7MIj+S
# QmI9VIayYsIGRjvelmNa0OvbU9CJSz/NfMEgf2NHMZUYW8KqWEjIjPfHIKxWlNMY
# huWfWRSHZCKyIANA0aJL4soHQtzzZ2MnNfjYY851wHYjGgwUj/hlLRgQO5S30Zx7
# 8GqBKfylp25aOWJ/qPhC+DXM2gXajIXbl+jpGcVANwtFFujCJRdZbeH1R+Q41Fjg
# Bg4m3OTFDGot5DSuVkQgjku7pOVPtldE46QlDg/2WhPpTQxXH64sP1GfkAwUtt6r
# rZM/PCwRG6girYmnTRLLsicBhoYLh+EEFjVviXAGTk6pnu8jx/4WPWu0jsz7yFzg
# 82/FMqCk9wK3LvyLAyDHN+FxbHAxtgwad7oLQPM0WGERdB1umPCIiYsSf/j79EqH
# doNwQYROVm+ZX10RX3n6bRmAnskeNhi0wnVaeVogLMdGD+nqMIIHcTCCBVmgAwIB
# AgITMwAAABXF52ueAptJmQAAAAAAFTANBgkqhkiG9w0BAQsFADCBiDELMAkGA1UE
# BhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc
# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0
# IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5IDIwMTAwHhcNMjEwOTMwMTgyMjI1
# WhcNMzAwOTMwMTgzMjI1WjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
# Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBv
# cmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDCC
# AiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAOThpkzntHIhC3miy9ckeb0O
# 1YLT/e6cBwfSqWxOdcjKNVf2AX9sSuDivbk+F2Az/1xPx2b3lVNxWuJ+Slr+uDZn
# hUYjDLWNE893MsAQGOhgfWpSg0S3po5GawcU88V29YZQ3MFEyHFcUTE3oAo4bo3t
# 1w/YJlN8OWECesSq/XJprx2rrPY2vjUmZNqYO7oaezOtgFt+jBAcnVL+tuhiJdxq
# D89d9P6OU8/W7IVWTe/dvI2k45GPsjksUZzpcGkNyjYtcI4xyDUoveO0hyTD4MmP
# frVUj9z6BVWYbWg7mka97aSueik3rMvrg0XnRm7KMtXAhjBcTyziYrLNueKNiOSW
# rAFKu75xqRdbZ2De+JKRHh09/SDPc31BmkZ1zcRfNN0Sidb9pSB9fvzZnkXftnIv
# 231fgLrbqn427DZM9ituqBJR6L8FA6PRc6ZNN3SUHDSCD/AQ8rdHGO2n6Jl8P0zb
# r17C89XYcz1DTsEzOUyOArxCaC4Q6oRRRuLRvWoYWmEBc8pnol7XKHYC4jMYcten
# IPDC+hIK12NvDMk2ZItboKaDIV1fMHSRlJTYuVD5C4lh8zYGNRiER9vcG9H9stQc
# xWv2XFJRXRLbJbqvUAV6bMURHXLvjflSxIUXk8A8FdsaN8cIFRg/eKtFtvUeh17a
# j54WcmnGrnu3tz5q4i6tAgMBAAGjggHdMIIB2TASBgkrBgEEAYI3FQEEBQIDAQAB
# MCMGCSsGAQQBgjcVAgQWBBQqp1L+ZMSavoKRPEY1Kc8Q/y8E7jAdBgNVHQ4EFgQU
# n6cVXQBeYl2D9OXSZacbUzUZ6XIwXAYDVR0gBFUwUzBRBgwrBgEEAYI3TIN9AQEw
# QTA/BggrBgEFBQcCARYzaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9E
# b2NzL1JlcG9zaXRvcnkuaHRtMBMGA1UdJQQMMAoGCCsGAQUFBwMIMBkGCSsGAQQB
# gjcUAgQMHgoAUwB1AGIAQwBBMAsGA1UdDwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/
# MB8GA1UdIwQYMBaAFNX2VsuP6KJcYmjRPZSQW9fOmhjEMFYGA1UdHwRPME0wS6BJ
# oEeGRWh0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01p
# Y1Jvb0NlckF1dF8yMDEwLTA2LTIzLmNybDBaBggrBgEFBQcBAQROMEwwSgYIKwYB
# BQUHMAKGPmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2kvY2VydHMvTWljUm9v
# Q2VyQXV0XzIwMTAtMDYtMjMuY3J0MA0GCSqGSIb3DQEBCwUAA4ICAQCdVX38Kq3h
# LB9nATEkW+Geckv8qW/qXBS2Pk5HZHixBpOXPTEztTnXwnE2P9pkbHzQdTltuw8x
# 5MKP+2zRoZQYIu7pZmc6U03dmLq2HnjYNi6cqYJWAAOwBb6J6Gngugnue99qb74p
# y27YP0h1AdkY3m2CDPVtI1TkeFN1JFe53Z/zjj3G82jfZfakVqr3lbYoVSfQJL1A
# oL8ZthISEV09J+BAljis9/kpicO8F7BUhUKz/AyeixmJ5/ALaoHCgRlCGVJ1ijbC
# HcNhcy4sa3tuPywJeBTpkbKpW99Jo3QMvOyRgNI95ko+ZjtPu4b6MhrZlvSP9pEB
# 9s7GdP32THJvEKt1MMU0sHrYUP4KWN1APMdUbZ1jdEgssU5HLcEUBHG/ZPkkvnNt
# yo4JvbMBV0lUZNlz138eW0QBjloZkWsNn6Qo3GcZKCS6OEuabvshVGtqRRFHqfG3
# rsjoiV5PndLQTHa1V1QJsWkBRH58oWFsc/4Ku+xBZj1p/cvBQUl+fpO+y/g75LcV
# v7TOPqUxUYS8vwLBgqJ7Fx0ViY1w/ue10CgaiQuPNtq6TPmb/wrpNPgkNWcr4A24
# 5oyZ1uEi6vAnQj0llOZ0dFtq0Z4+7X6gMTN9vMvpe784cETRkPHIqzqKOghif9lw
# Y1NNje6CbaUFEMFxBmoQtB1VM1izoXBm8qGCAtcwggJAAgEBMIIBAKGB2KSB1TCB
# 0jELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1Jl
# ZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEtMCsGA1UECxMk
# TWljcm9zb2Z0IElyZWxhbmQgT3BlcmF0aW9ucyBMaW1pdGVkMSYwJAYDVQQLEx1U
# aGFsZXMgVFNTIEVTTjoyQUQ0LTRCOTItRkEwMTElMCMGA1UEAxMcTWljcm9zb2Z0
# IFRpbWUtU3RhbXAgU2VydmljZaIjCgEBMAcGBSsOAwIaAxUAaKBSisy4y86pl8Xy
# 22CJZExE2vOggYMwgYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
# Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBv
# cmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAN
# BgkqhkiG9w0BAQUFAAIFAOmywSQwIhgPMjAyNDAzMzEwMDQ5NDBaGA8yMDI0MDQw
# MTAwNDk0MFowdzA9BgorBgEEAYRZCgQBMS8wLTAKAgUA6bLBJAIBADAKAgEAAgIG
# PAIB/zAHAgEAAgIRUjAKAgUA6bQSpAIBADA2BgorBgEEAYRZCgQCMSgwJjAMBgor
# BgEEAYRZCgMCoAowCAIBAAIDB6EgoQowCAIBAAIDAYagMA0GCSqGSIb3DQEBBQUA
# A4GBAInT0p0b/WTNvmCiONmacburzC28mFn8ek9rE6s/AUBwbHwjZ0v5xC+DhKs8
# yGpiNGBOoH+/n5/E4sI1YOOat4JCLgocHSBTQqOfUA6TkiY45UD0hh/yqylTEB/j
# EQPGrjm/sT/WDXkuo5uFAZ0QDWI3T7o4v85fR40LoJfDspnPMYIEDTCCBAkCAQEw
# gZMwfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcT
# B1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UE
# AxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTACEzMAAAHenkielp8oRD0A
# AQAAAd4wDQYJYIZIAWUDBAIBBQCgggFKMBoGCSqGSIb3DQEJAzENBgsqhkiG9w0B
# CRABBDAvBgkqhkiG9w0BCQQxIgQgixJ6S5+z3zBWF8s+m6cR1mEmTAkaGM9ui27L
# BlD5RoEwgfoGCyqGSIb3DQEJEAIvMYHqMIHnMIHkMIG9BCCOPiOfDcFeEBBJAn/m
# C3MgrT5w/U2z81LYD44Hc34dezCBmDCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFBDQSAyMDEwAhMzAAAB3p5InpafKEQ9AAEAAAHeMCIEIEo+1SABXs8IMUkCubS2
# hk4lUloQ6kOBUxLdDNs8hCVNMA0GCSqGSIb3DQEBCwUABIICADBNXLgJbqLWpIEc
# 1FNi3OOhuo+EWAsodfxshx3XEAlgI8rWvjnMWEPjYwcwdrBVs78Ex15uxyd+IS5y
# HA9yfvxolN+dEGsYeYVQ13u9wjhXvC1yXiEaa5lXQTWYLFw+QzBD25sem81fcDW0
# 76F/9mGhoQ5FY/QXqvUqtEx25b5WOr7If0GFTwjv2uIRx/ArJN0CCEj7ZiKrhq0r
# HYJBjm7MpFlqam0vIKS4PMyzuwdVflv7sEjx74KI6u8VvdeJ60QuiNjnLrc5oXxj
# pXTQEEXZoxdtJMzwOCBw5FgAjFOYDY0s019WnL9eBB+xK9xjFfOkbOw0NJV8gyw/
# XJ/guB6KsIBigFWFtx9V5/MSCm5ADHiUlvKXMmLFah+rtuXphliFDCWPhbup6UlF
# lVNs74iJrVKka1g4d2OkpY+6ZVxW2P7Xo5lDVMFU4bPVYGqR96/a8c3s0JkWCE4C
# +ITq2w2tCipmwrm2fHn2OhvQm9SBQd2ptr7TJZlr/RVdcH5GMo/rsPfcl8jDZNuZ
# t5PKfbp6USwIlliIzI2dnGePXELFrJ6/zKRF8+0GRUwrbNCug2CiOzqX6+eL/wrm
# WNWWzQCAUiNd8GclNR92bGOHHb5zSX7Tp6KqMWO1X/sVYbXxnAXuuFWpYfc8W2XO
# fCN0RBv03cgbiE04alhMa/Spwku+
# SIG # End signature block
