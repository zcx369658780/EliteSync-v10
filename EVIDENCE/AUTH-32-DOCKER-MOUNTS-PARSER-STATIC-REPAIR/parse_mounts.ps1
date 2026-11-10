Set-StrictMode -Version Latest

function Parse-Mounts {
    param([AllowNull()][object]$Mounts)

    $count = 'UNKNOWN'
    $allTmpfs = $false
    $destinationsAllowed = $false
    $parseOk = $false
    $allowed = @('/var/lib/mysql', '/run/mysqld', '/tmp')

    try {
        if ($null -eq $Mounts) {
            return [pscustomobject][ordered]@{
                count = 0; all_tmpfs = $false; destinations_allowed = $false; parse_ok = $true
            }
        }
        if ($Mounts -isnot [array]) {
            return [pscustomobject][ordered]@{
                count = 'UNKNOWN'; all_tmpfs = $false; destinations_allowed = $false; parse_ok = $false
            }
        }

        $count = [int]$Mounts.Length
        if ($count -eq 0) {
            return [pscustomobject][ordered]@{
                count = 0; all_tmpfs = $false; destinations_allowed = $false; parse_ok = $true
            }
        }

        $seen = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
        $allTmpfs = $true
        $destinationsAllowed = $true
        $wellFormed = $true
        foreach ($entry in $Mounts) {
            $type = $null
            $destination = $null
            if ($entry -is [pscustomobject]) {
                $typeProperty = $entry.PSObject.Properties['Type']
                $destinationProperty = $entry.PSObject.Properties['Destination']
                if ($null -eq $typeProperty -or $null -eq $destinationProperty) { $wellFormed = $false; break }
                $type = $typeProperty.Value
                $destination = $destinationProperty.Value
            } elseif ($entry -is [Collections.IDictionary]) {
                if (-not $entry.Contains('Type') -or -not $entry.Contains('Destination')) { $wellFormed = $false; break }
                $type = $entry['Type']
                $destination = $entry['Destination']
            } else {
                $wellFormed = $false; break
            }
            if ($type -isnot [string] -or $destination -isnot [string]) { $wellFormed = $false; break }
            if ($type -cne 'tmpfs') { $allTmpfs = $false }
            if ($destination -cnotin $allowed -or -not $seen.Add($destination)) { $destinationsAllowed = $false }
        }

        if (-not $wellFormed) {
            $allTmpfs = $false
            $destinationsAllowed = $false
        }
        $parseOk = $allTmpfs -and $destinationsAllowed
    } catch {
        $allTmpfs = $false
        $destinationsAllowed = $false
        $parseOk = $false
    }

    return [pscustomobject][ordered]@{
        count = $count
        all_tmpfs = $allTmpfs
        destinations_allowed = $destinationsAllowed
        parse_ok = $parseOk
    }
}
