# Sukuna Recon: Malevolent Shrine Enumeration
<img width="1376" height="768" alt="image" src="https://github.com/user-attachments/assets/60af0070-21c3-4d7e-b42f-afae5a1ec85b" />


> "Know your place. A script this grand deserves absolute subservience."

sukuna-recon is a high-efficiency Linux system enumeration script. It is designed to analyze a target system's configuration, kernel details, privileges, and network sockets for security auditing purposes.

---

## Domain Expansion: Features

This script executes a series of enumeration techniques to gather intelligence from the host:

*   Soul Inspection: Identifies current user identity and environment context.
*   Absolute Authority: Evaluates sudo configurations and permissions.
*   Cleave & Dismantle: Searches the filesystem for root-owned SUID binaries.
*   Peeling the Skin: Collects OS details, kernel versions, and release banners.
*   Binding Vows: Inspects system crontabs and scheduled cron directories.
*   Cursed Energy Flow: Maps active network listeners using socket tracking tools like ss or netstat.
*   Treasure Vault: Lists the contents of the /opt directory.
*   Malevolent Puppets: Enumerates processes running with root privileges.

---

## Invocation (Usage)

To use this tool for authorized security testing, ensure the script has execution permissions.

### Local Execution
```bash
chmod +x sukuna_recon.sh
./sukuna_recon.sh
```

---

## Scroll Output (Artifacts)

Execution generates a time-stamped report detailing the system's configuration layout. The report is saved to the current directory:
shrine_recon_[hostname]_[timestamp].txt

---

