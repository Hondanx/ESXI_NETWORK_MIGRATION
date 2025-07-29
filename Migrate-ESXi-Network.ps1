# ESXi Network Migration Script
# Connects to two ESXi hosts, exports vSwitches and port groups from the old host,
# then recreates them on the new host.

# 1. Install and import VMware PowerCLI
Install-Module -Name VMware.PowerCLI -Scope CurrentUser -Force
Import-Module VMware.PowerCLI

# 2. Connect to the old ESXi host
$oldHostIP = "OLD_ESXi_IP"
Connect-VIServer -Server $oldHostIP

# 3. Export virtual switches and port groups
$oldHost = Get-VMHost -Name $oldHostIP
Get-VirtualSwitch -VMHost $oldHost | Export-Clixml -Path "vSwitches.xml"
Get-VirtualPortGroup -VMHost $oldHost | Export-Clixml -Path "PortGroups.xml"

# 4. Connect to the new ESXi host
$newHostIP = "192.168.203.9"
Connect-VIServer -Server $newHostIP
$vmhost = Get-VMHost -Name $newHostIP

# 5. Import configurations
$vswitches = Import-Clixml -Path "vSwitches.xml"
$portgroups = Import-Clixml -Path "PortGroups.xml"

# 6. Recreate virtual switches
foreach ($vswitch in $vswitches) {
    $nic = Get-VMHostNetworkAdapter -VMHost $vmhost | Where-Object { $_.Name -eq $vswitch.Nic }

    if (-not (Get-VirtualSwitch -VMHost $vmhost | Where-Object { $_.Name -eq $vswitch.Name })) {
        New-VirtualSwitch -VMHost $vmhost -Name $vswitch.Name -Nic $nic
        Write-Host "✅ Created vSwitch '$($vswitch.Name)'"
    } else {
        Write-Host "⚠️ vSwitch '$($vswitch.Name)' already exists"
    }
}

# 7. Recreate port groups
foreach ($pg in $portgroups) {
    $existingPG = Get-VirtualPortGroup -VMHost $vmhost | Where-Object {
        $_.Name -eq $pg.Name -and $_.VirtualSwitch.Name -eq $pg.VirtualSwitch
    }

    if (-not $existingPG) {
        $vSwitch = Get-VirtualSwitch -VMHost $vmhost -Name $pg.VirtualSwitch

        New-VirtualPortGroup -VirtualSwitch $vSwitch `
                             -Name $pg.Name `
                             -VLanId $pg.VLanId

        Write-Host "✅ Created port group '$($pg.Name)' on vSwitch '$($pg.VirtualSwitch)' with VLAN $($pg.VLanId)"
    } else {
        Write-Host "⚠️ Skipping existing port group '$($pg.Name)' on vSwitch '$($pg.VirtualSwitch)'"
    }
}
