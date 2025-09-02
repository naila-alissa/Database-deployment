# Define root path relative to script location
$rootPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$folders = @("schema", "views", "data")

# Get author name
$user = $env:GITHUB_USER
if ([string]::IsNullOrEmpty($user)) {
    $gitUserName = git config user.name 2>$null
    if ($gitUserName) {
        $user = $gitUserName.Trim()
    } else {
        $user = $env:USERNAME
    }
}

# Clean author for YAML safe string
$user = $user -replace '[^a-zA-Z0-9_-]', '_'

foreach ($folder in $folders) {
    $fullFolderPath = Join-Path $rootPath $folder

    if (!(Test-Path $fullFolderPath)) {
        Write-Warning "Folder not found: $folder"
        continue
    }

    $files = Get-ChildItem -Path $fullFolderPath -Filter *.sql -File

    foreach ($file in $files) {
        $folderPath = $file.DirectoryName
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
        # $safeBaseName = $baseName -replace '[^a-zA-Z0-9_-]', '_'
        $yamlPath = Join-Path $folderPath "${baseName}_changelog.yml"

        # Read entire SQL content as a single string, preserving line breaks properly
        $sqlContentLines = Get-Content $file.FullName
        $sqlContent = ($sqlContentLines -join "`n").Trim()

        # Initialize rollback
        $rollbackSql = "-- Rollback statement not detected. Please add manually."

        # Detect rollback based on SQL content patterns (case-insensitive)
        if ($sqlContent -match '(?i)CREATE\s+TABLE\s+([^\s\(;]+)') {
            $objectName = $matches[1]
            $rollbackSql = "DROP TABLE $objectName;"
        }
        elseif ($sqlContent -match '(?i)CREATE\s+VIEW\s+([^\s\(;]+)') {
            $objectName = $matches[1]
            $rollbackSql = "DROP VIEW $objectName;"
        }
        elseif ($sqlContent -match '(?i)INSERT\s+INTO\s+([^\s\(]+)\s*\(([^)]+)\)\s*VALUES\s*\(([^)]+)\)') {
            $tableName = $matches[1]
            $columns = $matches[2] -split '\s*,\s*'
            $values = $matches[3] -split '\s*,\s*'

            # Assume first column is primary key (may need adjustment)
            $keyColumn = $columns[0]
            $keyValue = $values[0].Trim()

            # Add quotes if keyValue is not purely numeric and not already quoted
            if ($keyValue -notmatch '^\d+$' -and $keyValue -notmatch "^'.*'$") {
                $keyValue = $keyValue.Trim("'`"")
                $keyValue = "'$keyValue'"
            }

            $rollbackSql = "DELETE FROM $tableName WHERE $keyColumn = $keyValue;"
        }

        $changeSetId = "$folder-$baseName"

        # Compose YAML content using here-string with indentation
        $yamlContent = @"
databaseChangeLog:
  - changeSet:
      id: $changeSetId
      author: $user
      changes:
        - tagDatabase:
            tag: v1.0
            keepTagOnRollback: true

        - sql:
            sql: >
$( $sqlContentLines | ForEach-Object { "              $_" } | Out-String )

      rollback: >
        $rollbackSql
"@

        # Save YAML changelog
        Set-Content -Path $yamlPath -Value $yamlContent -Encoding UTF8

        Write-Host "[OK] Created YAML changelog with rollback: $yamlPath"
    }
}

# foreach ($folder in $folders) {
#     $fullFolderPath = Join-Path $rootPath $folder
#     if (!(Test-Path $fullFolderPath)) {
#         Write-Warning "Folder not found: $folder"
#         continue
#     }

#     $files = Get-ChildItem -Path $fullFolderPath -Filter *.sql -File
#     foreach ($file in $files) {
#         $folderPath = $file.DirectoryName
#         $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
#         $safeBaseName = $baseName -replace '[^a-zA-Z0-9_-]', '_'
#         $yamlPath = Join-Path $folderPath "${baseName}_changelog.yml"

#         # Read entire SQL content, escape for YAML inline block
#         $sqlContent = Get-Content $file.FullName | ForEach-Object { $_.TrimEnd() } | Out-String
#         $sqlContent = $sqlContent.Trim()

#         # You might want to detect the rollback sql - example only for INSERT statement
#         # This logic can be enhanced based on your SQL files
#         $rollbackSql = ""
#         if ($sqlContent -match 'INSERT\s+INTO\s+([^\s(]+).*\((.*)\)\s*VALUES\s*\((.*)\);?') {
#             $table = $matches[1]
#             # Here a simplistic rollback that deletes inserted rows by matching columns, adjust as needed
#             $rollbackSql = "DELETE FROM $table WHERE /* add your WHERE condition here */;"
#         } else {
#             $rollbackSql = "-- rollback statement needed"
#         }

#         $changeSetId = "$folder-$baseName"

#         $yamlContent = @"
# databaseChangeLog:
#   - changeSet:
#       id: $changeSetId
#       author: $user
#       changes:
#         - tagDatabase:
#             tag: v1.0
#             keepTagOnRollback: true

#         - sql:
#             sql: >
#               $sqlContent

#       rollback: >
#         $rollbackSql
# "@

#         Set-Content -Path $yamlPath -Value $yamlContent -Encoding UTF8
#         Write-Host "[OK] Created YAML changelog: $yamlPath"
#     }
# }
