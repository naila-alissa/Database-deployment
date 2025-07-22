

# # ...existing code...
# $folders = @("schema", "view", "data")
# $user = $env:USERNAME

# foreach ($folder in $folders) {
#     $folderPath = Join-Path $PSScriptRoot $folder
#     if (Test-Path $folderPath) {
#         $files = Get-ChildItem -Path $folderPath -Filter *.sql
#         $id = 1

#         foreach ($file in $files) {
#     $content = Get-Content $file.FullName
#     if ($content -and $content[0] -notlike '--liquibase formatted sql*') {
#         $changeset = "--liquibase formatted sql`n--changeset ${user}:$id-$($folder)-$($file.Name)   context:$folder-$id labels:$($file.Name)"
#         Set-Content $file.FullName "$changeset`n$(Get-Content $file.FullName | Out-String)"
#     }
#     $id++
# }
#     }
# }
# # ...existing code...

$folders = @("schema", "view", "data")
$user = $env:USERNAME


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

                $existingContent = Get-Content $file.FullName | Out-String
                Set-Content -Path $file.FullName -Value "$header`n$existingContent"

                Write-Host "Y Formatted: $file.FullName"
                $globalId++
            } else {
                Write-Host "x Skipped (already formatted): $file.FullName"
            }
        }
    }
}
