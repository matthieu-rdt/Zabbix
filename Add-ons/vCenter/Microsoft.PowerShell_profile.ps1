Set-Location \/usr/local/share/powershell

function Get-CmdletAlias ($cmdletname) {
  Get-Alias |
    Where-Object -FilterScript {$_.Definition -like "$cmdletname"} |
      Format-Table -Property Definition, Name -AutoSize
}

function prompt {"PS [$(Get-Location)] > "}
