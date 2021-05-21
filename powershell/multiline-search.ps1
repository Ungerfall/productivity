param (
  [string]$folder = $PSScriptRoot,
  [string]$filter = "*.*",
  [string[]]$matches
)

$matchesHash = @{}
$matches | % {i = 0} {$matchesHash[$_.Value;i++}

Get-ChildItem $folder -Filter $filter -Recurse |
Foreach-Object {
  foreach($line in Get-Content $_.FullName) {
    if (
  }
}
