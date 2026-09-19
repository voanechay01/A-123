param(
    [string]$Action,
    [string]$Key,
    [string]$Value
)

$cfg = Join-Path $PSScriptRoot 'config.py'
if (-not (Test-Path $cfg)) { exit 1 }

$content = [IO.File]::ReadAllText($cfg, [Text.UTF8Encoding]::new($false))

function Get-Val($c, $k) {
    if ($c -match "(?m)^$k\s*=\s*([^#\r\n]+)") {
        return ($Matches[1].Trim() -replace '"', '')
    }
    return ''
}

switch ($Action) {
    'read' {
        Write-Output (Get-Val $content $Key)
    }
    'write' {
        $esc = [regex]::Escape($Key)
        $val = $Value
        # NUMBERS — WITHOUT QUOTES, STRINGS — WITH QUOTES
        if ($val -match '^-?\d+$') {
            $new = "$Key = $val"
        } else {
            $new = "$Key = `"$val`""
        }
        $content = $content -replace "(?m)^$esc\s*=\s*.*$", $new
        [IO.File]::WriteAllText($cfg, $content, [Text.UTF8Encoding]::new($false))
    }
    'toggle' {
        $cur = Get-Val $content $Key
        $new = if ($cur -eq '1') { '0' } else { '1' }
        $esc = [regex]::Escape($Key)
        $content = $content -replace "(?m)^$esc\s*=\s*.*$", "$Key = $new"
        [IO.File]::WriteAllText($cfg, $content, [Text.UTF8Encoding]::new($false))
        Write-Output $new
    }
}
