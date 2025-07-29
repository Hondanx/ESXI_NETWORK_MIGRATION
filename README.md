# 🖧 ESXi Network Configuration Migration Script

This PowerShell script automates the export and import of **vSwitches** and **port groups** from an old ESXi host to a new one using **VMware PowerCLI**.

> ✅ Useful when consolidating multiple ESXi hosts into a larger one or preparing for host replacements.

---

## 🔧 Requirements

- PowerShell 5.1 or later
- [VMware PowerCLI](https://developer.vmware.com/powercli)
- Network access to both ESXi hosts
- Proper credentials for each host

---

## 📦 Features

- Export virtual switches and port groups from a source ESXi host
- Recreate them on a destination ESXi host
- Skips existing switches or port groups to avoid duplication

---

## 🚀 How to Use

### 1. Clone or Download

```bash
git clone https://github.com/Hondanx/ESXI_NETWORK_MIGRATION.git
cd ESXI_NETWORK_MIGRATION

2. Edit the Script
Open the Migrate-ESXi-Network.ps1 script and update:

powershell

$oldHostIP = "OLD_ESXi_IP"
$newHostIP = "192.168.203.9"
Replace OLD_ESXi_IP with the source ESXi IP or hostname.

3. Run the Script
In PowerShell:

powershell

.\Migrate-ESXi-Network.ps1

You’ll be prompted to log in to each ESXi host.

