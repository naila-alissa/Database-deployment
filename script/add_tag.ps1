


$folders = @("schema", "data", "views")

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

    Get-ChildItem -Path $folder -Filter *.sql | ForEach-Object {
        $sqlFile = $_.Name
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($sqlFile)

        $safeBaseName = $baseName -replace '[^a-zA-Z0-9_-]', '_'

        $folderPath = $_.DirectoryName

        # Only create the tag YAML file path
        $tagYamlPath = Join-Path $folderPath "${baseName}_tag.yml"

        # Create Tag changelog YAML if not exists
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
            Write-Host "Y Created $tagYamlPath"
        }
        else {
            Write-Host "X Skipped existing $tagYamlPath"
        }
    }
}
