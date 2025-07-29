

# Add Liquiabase Tags to SQL Files and Create YAML Tag Files
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

foreach ($folder in $folders) {
    if (!(Test-Path $folder)) {
        Write-Warning "Folder not found: $folder"
        continue
    }

    $files = Get-ChildItem -Path $folder -Filter *.sql -File

    foreach ($file in $files) {
        $folderPath = $file.DirectoryName
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
        $safeBaseName = $baseName -replace '[^a-zA-Z0-9_-]', '_'
        $tagYamlPath = Join-Path $folderPath "${baseName}_tag.yml"

        ### --- PART 1: Format SQL file for Liquibase ---
        $firstLine = Get-Content $file.FullName -First 1

        if ($firstLine -notlike '--liquibase formatted sql*') {
            $changeSetId = "$folder-$baseName"
            $context = $folder
            $label = $baseName
            # $comment = "Change generated for $baseName in $folder"

            $header = @"
--liquibase formatted sql
--changeset ${user}:$changeSetId context:$context labels:$label


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
                $rollback = "--rollback: ROLLBACK $baseName"
            }

            $rollback = "`n$rollback`n"

            $existingContent = $contentLines -join "`n"
            Set-Content -Path $file.FullName -Value "$header$existingContent$rollback"

            Write-Host "[OK] Formatted SQL file: $($file.FullName)"
        } else {
            # Write-Host "[x] Skipped (already formatted): $($file.FullName)"
        } 

        ### --- PART 2: Create YAML Tag File ---
        if (!(Test-Path $tagYamlPath)) {
$tagYamlContent = @"
databaseChangeLog:
  - changeSet:
      id: tag-$safeBaseName
      author: $user
      changes:
        - tagDatabase:
            tag: tag_$safeBaseName
            keepTagOnRollback: true
"@
            Set-Content -Path $tagYamlPath -Value $tagYamlContent -Encoding UTF8
            Write-Host "[OK] Created Tag File: $tagYamlPath"
        } else {
            # Write-Host "[x] Skipped Tag File (already exists): $tagYamlPath"
        }
      
    Get-ChildItem -Path $folder -Filter *.sql | ForEach-Object {
        $sqlFile = $_.Name
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($sqlFile)
        $safeBaseName = $baseName -replace '[^a-zA-Z0-9_-]', '_'
        $folderPath = $_.DirectoryName

        # Path for the tag YAML file
        $tagYamlPath = Join-Path $folderPath "${baseName}_tag.yml"

        # Create tag YAML file if not already exists
        if (!(Test-Path $tagYamlPath)) {
            $tagYamlContent = @"
databaseChangeLog:
  - changeSet:
      id: tag-$safeBaseName
      author: $user
      changes:
        - tagDatabase:
            tag: tag_$safeBaseName
            keepTagOnRollback: true
"@

            Set-Content -Path $tagYamlPath -Value $tagYamlContent -Encoding UTF8
            Write-Host "✅ Created $tagYamlPath"
        } else {
            Write-Host "⚠️ Skipped existing $tagYamlPath"
        }
    }
   
    }   
}
