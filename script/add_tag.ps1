


# $folders = @("schema", "data", "views")

# # Get author name
# $user = $env:GITHUB_USER
# if ([string]::IsNullOrEmpty($user)) {
#     $gitUserName = git config user.name 2>$null
#     if ($gitUserName) {
#         $user = $gitUserName.Trim()
#     } else {
#         $user = $env:USERNAME
#     }
# }

# foreach ($folder in $folders) {
#     if (!(Test-Path $folder)) {
#         Write-Warning "Folder not found: $folder"
#         continue
#     }

#     Get-ChildItem -Path $folder -Filter *.sql | ForEach-Object {
#         $sqlFile = $_.Name
#         $baseName = [System.IO.Path]::GetFileNameWithoutExtension($sqlFile)

#         $safeBaseName = $baseName -replace '[^a-zA-Z0-9_-]', '_'

#         $folderPath = $_.DirectoryName

#         # Only create the tag YAML file path
#         $tagYamlPath = Join-Path $folderPath "${baseName}_tag.yml"

#         # Create Tag changelog YAML if not exists
#         if (!(Test-Path $tagYamlPath)) {
#             $tagYamlContent = @"
# databaseChangeLog:
#   - changeSet:
#       id: tag-$safeBaseName
#       author: $user
#       changes:
#         - tagDatabase:
#             tag: tag_$safeBaseName
#             keepTagOnRollback: true
# "@
#             Set-Content -Path $tagYamlPath -Value $tagYamlContent -Encoding UTF8
#             Write-Host "Y Created $tagYamlPath"
#         }
#         else {
#             Write-Host "X Skipped existing $tagYamlPath"
#         }
#     }
# }

$folders = @("schema", "views", "data")

$user = $env:GITHUB_USER
if ([string]::IsNullOrEmpty($user)) {
    $gitUserName = git config user.name 2>$null
    if ($gitUserName) {
        $user = $gitUserName.Trim()
    } else {
        $user = $env:USERNAME
    }
}

foreach ($folder in $folders) {
    $folderPath = Join-Path $PSScriptRoot $folder

    if (Test-Path $folderPath) {
        $files = Get-ChildItem -Path $folderPath -Filter *.sql -File

        foreach ($file in $files) {
            $firstLine = Get-Content $file.FullName -First 1

            if ($firstLine -notlike '--liquibase formatted sql*') {
                $fileName = $file.Name
                $changeSetId = "$folder-$($file.BaseName)"
                $context = $folder
                $label = $file.BaseName
                $comment = "Change generated for $fileName in $folder"

                $header = @"
--liquibase formatted sql
--changeset ${user}:$changeSetId context:$context labels:$label
--comment: $comment

"@

                $contentLines = Get-Content $file.FullName
                $objectName = ""
                $rollback = ""

                foreach ($line in $contentLines) {
                    if ($line -match 'CREATE\s+TABLE\s+([^\s\(]+)') {
                        $objectName = $matches[1]
                        $rollback = "--rollback: DROP TABLE $objectName;"
                        break
                    }
                    elseif ($line -match 'CREATE\s+VIEW\s+([^\s\(]+)') {
                        $objectName = $matches[1]
                        $rollback = "--rollback: DROP VIEW $objectName;"
                        break
                    }
                }

                if (-not $rollback) {
                    $rollback = "--rollback: ROLLBACK $($file.BaseName)"
                }

                $rollback = "`n$rollback`n"

                $existingContent = $contentLines -join "`n"
                Set-Content -Path $file.FullName -Value "$header$existingContent$rollback"

                Write-Host "Formatted: $file.FullName"
            }
            else {
                Write-Host "Skipped (already formatted): $file.FullName"
            }
        }
    }
    else {
        Write-Warning "Folder not found: $folderPath"
    }
}
