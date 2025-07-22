

#  ...existing code..

$folders = @("schema", "view", "data")
$user = $env:GITHUB_USER
if ([string]::IsNullOrEmpty($user)) {
    # Try to get the local git user name from git config
    $gitUserName = git config user.name 2>$null
    if ($gitUserName) {
        $user = $gitUserName.Trim()
    }
    else {
        # Fallback default username
       $user = $env:USERNAME
    }
}

foreach ($folder in $folders) {
    $folderPath = Join-Path $PSScriptRoot $folder

    if (Test-Path $folderPath) {
        $files = Get-ChildItem -Path $folderPath -Filter *.sql -File
      $globalId = 1
        foreach ($file in $files) {
            $firstLine = (Get-Content $file.FullName -First 1)

            # ONLY update files that do NOT already have a formatted sql block
            if ($firstLine -notlike '--liquibase formatted sql*') {
           
                $fileName = $file.Name
                $changeSetId = "$globalId-$folder-$($file.BaseName)"
                $context = "$folder-$globalId"
                $label = $file.BaseName
                $comment = "Change generated for $fileName in $folder"

                $header = @"
--liquibase formatted sql
--changeset ${user}:$changeSetId context:$context labels:$label
--comment: $comment

"@

#                 $existingContent = Get-Content $file.FullName | Out-String
#                 Set-Content -Path $file.FullName -Value "$header`n$existingContent"

#                 Write-Host "Y Formatted: $file.FullName"
#                 $globalId++
#             } else {
#                 Write-Host "x Skipped (already formatted): $file.FullName"
#             }
#         }
#     }
# }


                # Detect CREATE TABLE or CREATE VIEW
                $contentLines = Get-Content $file.FullName
                $objectName = ""
                $rollback = ""

                foreach ($line in $contentLines) {
                    if ($line -match 'CREATE\s+TABLE\s+([^\s\(]+)') {
                        $objectName = $matches[1]
                        $rollback = "--rollback: DROP TABLE IF EXISTS $objectName;"
                        break
                    }
                    elseif ($line -match 'CREATE\s+VIEW\s+([^\s\(]+)') {
                        $objectName = $matches[1]
                        $rollback = "--rollback: DROP VIEW  $objectName;"
                        break
                    }
                }

                # Fallback rollback
                if (-not $rollback) {
                    $rollback = "--rollback: ROLLBACK COMMAND FOR $($file.BaseName)"
                }

                $rollback = "`n$rollback`n"

                $existingContent = $contentLines -join "`n"
                Set-Content -Path $file.FullName -Value "$header$existingContent$rollback"

                Write-Host "Formatted: $file.FullName"
                $globalId++
            } else {
                Write-Host "Skipped (already formatted): $file.FullName"
            }
        }
    }
}
   