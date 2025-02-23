<#
.SYNOPSIS
This script concatenates `.md` files whose headers match `uid` values extracted from `toc.yml`.

.DESCRIPTION
This script is designed to automate the process of merging Markdown files defined by a table of contents (TOC).
It performs the following tasks:
1. Extracts `uid` fields from the `toc.yml` file (based on Microsoft Docs format).
2. Searches all `.md` files in the current directory (and optionally subdirectories) for a matching `uid` in their frontmatter headers.
3. Outputs the content of those matched files in the order defined by the `toc.yml` file.

To use this script:
1. Create a `toc.yml` file based on the Microsoft Docs `toc.yml` format, but extract and keep only the parts relevant to your project.
   Example:
   ```yaml
   - name: Overview
     uid: yarp/overview
   - name: Getting Started
     uid: yarp/getting-started
2. Place all related .md files in one folder. Each file's header (in the frontmatter) must have a uid field matching a uid from your toc.yml. Example overview.md frontmatter:
```
---
uid: yarp/overview
title: Overview
---
```
3. Run this script in the same folder as the toc.yml file and the .md files.

.NOTES

Any uid from the toc.yml file that does not have a corresponding .md file will result in an error being sent to stderr.
Files are processed in the order in which uids are defined in the toc.yml.
#>

$output = sls -Path "./toc.yml" -Pattern "uid:" | % {
  ($_ -match "uid:\s*(.+)$") | Out-Null; $uid = $matches[1];
  $file = gci -Recurse -Filter "*.md" | ? { (cat $_.FullName -Raw) -match "uid:\s*$uid\b" };
  if ($file) { cat $file.FullName } else { Write-Error "No file found for UID: $uid" }
};

$output | Out-File book.md
