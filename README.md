# Network Failover Script for Windows

### Overview
This is a PowerShell script designed for Windows users to provide a seamless internet connection failover solution. It's ideal for gamers and streamers who need to protect their connection from sudden outages. The script continuously monitors a primary connection (e.g., Ethernet) and automatically switches to a backup (e.g., mobile hotspot) if the primary fails. It will then switch back to the primary once it's restored.

---

### Features
- **Automatic Failover:** Switches to a backup connection when the primary connection becomes unresponsive.
- **Automatic Failback:** Switches back to the primary connection once it is stable again.
- **Configurable Thresholds:** You can set the number of failed pings to trigger a failover, preventing a brief hiccup from causing a switch.
- **Advanced Monitoring:** Checks for both a complete connection failure and high latency.
- **Logging:** All actions and connection status updates are logged to a file on your desktop for review.
- **Easy to Configure:** All key settings (network names, ping targets) are in a dedicated configuration section at the top of the script.

---

### Prerequisites
- A PC running **Windows 10 or later**.
- **PowerShell 5.1** or higher.
- A **primary internet connection** (e.g., Ethernet).
- A **secondary internet connection** that can be enabled for tethering (e.g., a smartphone with a USB cable).

---

### Configuration Guide
1.  **Find Your Network Adapter Names:**
    - Press `Windows Key + R`, type `ncpa.cpl`, and hit Enter.
    - Note the exact names of your primary and secondary connections. Common names are "Ethernet" or "Wi-Fi," but yours may be different.

2.  **Edit the Script File:**
    - Open the `Network-Failover-V2.ps1` file in a text editor like Notepad or VS Code.
    - Go to the **`# --- CONFIGURATION ---`** section.
    - Change the values for `$mainAdapter` and `$backupAdapter` to the exact names you found in the previous step.
    - You can also adjust the ping targets, thresholds, and logging path if needed.

---

### Usage
1.  **Save the Script:** Save the file with a `.ps1` extension.
2.  **Enable Tethering:** Plug in your phone and enable USB tethering.
3.  **Run as Administrator:** Right-click the `.ps1` file and select "Run with PowerShell" or "Run as Administrator." This is required for the script to be able to enable and disable network adapters.
4.  **Monitor:** A console window will appear and show you real-time updates on the connection status. You can minimize this window.
5.  **Stop the Script:** To stop the script, simply close the PowerShell console window or press `Ctrl+C` in the window.

---

### Disclaimer
This script is provided as-is for personal use. While it is designed to be reliable, there is no guarantee it will work in all network conditions. Use at your own risk. The author is not responsible for any lost data or game progress.
