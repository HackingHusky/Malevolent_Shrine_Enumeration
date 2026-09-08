#!/usr/bin/env bash
# ==============================================================================
#   SUKUNA RECON: Malevolent Shrine Enumeration
#   "Know your place. A script this grand deserves absolute subservience."
# ==============================================================================
set -u

HOSTNAME="$(hostname 2>/dev/null || echo "pathetic-mortal-host")"
TS="$(date +"%Y%m%d-%H%M%S")"
OUTFILE="shrine_recon_${HOSTNAME}_${TS}.txt"

# Sukuna's aesthetic printers
hr() {
    printf '\n%s\n\n' "◆━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━◆"
}

execute_technique() {
    local technique_name="$1"
    shift
    local command_string="$*"

    hr | tee -a "$OUTFILE"
    printf '⚔️  [TECHNIQUE]: %s\n' "$technique_name" | tee -a "$OUTFILE"
    printf '📜  [INCANTATION]: %s\n\n' "$command_string" | tee -a "$OUTFILE"

    eval "$command_string" 2>&1 | tee -a "$OUTFILE"
}

# --- Open the Domain ---
hr | tee "$OUTFILE"
printf '⛩️  DOMAIN EXPANSION: MALEVOLENT SHRINE  ⛩️\n' | tee -a "$OUTFILE"
printf 'Subject: %s | Time: %s (UTC)\n' "$HOSTNAME" "$(date -u +"%Y-%m-%d %H:%M:%S")" | tee -a "$OUTFILE"
printf '"Turn everything to ash. Let us peel back the layers of this world."\n' | tee -a "$OUTFILE"
hr | tee -a "$OUTFILE"

# =============================================================================
#   PHASE 1: IDENTITY & RECONNAISSANCE
# =============================================================================

# --- 1. Identity & Soul (User Identity) ---
execute_technique "SOUL INSPECTION (Identity)" 'id && echo && whoami'

# --- 2. Dominance & Authority (Sudo Privileges) ---
if sudo -n true 2>/dev/null; then
    execute_technique "ABSOLUTE AUTHORITY (Sudo -l)" 'sudo -n -l'
else
    execute_technique "STRUGGLING FOR POWER (Sudo -l - May Prompt)" 'sudo -l'
fi

# --- 3. Flaying the Flesh (OS Details) ---
execute_technique "DISMANTLE THE FLESH (Kernel Info)" 'uname -a'
execute_technique "PEELING THE SKIN (/etc/issue & /etc/os-release)" 'cat /etc/issue /etc/os-release 2>/dev/null || echo "The system resists my gaze."'

# =============================================================================
#   PHASE 2: PRIVILEGE ESCALATION VECTORS
# =============================================================================

# --- 4. Cleave & Dismantle (SUID Binaries) ---
execute_technique "CLEAVE (SUID Root Binaries)" 'find / -user root -perm /4000 2>/dev/null'

# --- 5. GTFOBins SUID Quick Hits ---
execute_technique "CURSED ARSENAL (GTFOBins SUID Quick Check)" '
GTFO_BINS="find wget bash nmap vim nano cp mv perl python python3 ruby gcc env awk less more ftp nmap node php lua openssl"
echo "[*] Checking for known GTFOBins SUID binaries..."
for bin in $GTFO_BINS; do
    FULL_PATH=$(which "$bin" 2>/dev/null)
    if [ -n "$FULL_PATH" ] && [ -u "$FULL_PATH" ]; then
        echo "[!] SUID HIT: $FULL_PATH"
        ls -la "$FULL_PATH"
    fi
done
echo "[*] GTFOBins check complete."
'

# --- 6. SGID Binaries ---
execute_technique "SHADOW CLEAVE (SGID Binaries)" 'find / -perm -2000 -type f 2>/dev/null | head -30'

# --- 7. File Capabilities ---
execute_technique "INNATE DOMAIN (File Capabilities)" 'getcap -r / 2>/dev/null || echo "getcap not available."'

# --- 8. Writable /etc/passwd ---
execute_technique "SOUL CORRUPTION (/etc/passwd Writability)" '
if [ -w /etc/passwd ]; then
    echo "[!] /etc/passwd IS WRITABLE - root via user injection possible!"
else
    echo "[-] /etc/passwd is not writable."
fi
if [ -w /etc/shadow ]; then
    echo "[!] /etc/shadow IS WRITABLE!"
else
    echo "[-] /etc/shadow is not writable."
fi
'

# --- 9. PATH Hijack - Writable Directories in PATH ---
execute_technique "DOMAIN DISTORTION (PATH Hijack Check)" '
echo "[*] Current PATH:"
echo "$PATH"
echo ""
echo "[*] Checking for writable directories in PATH..."
IFS=":" read -ra PATHDIRS <<< "$PATH"
for dir in "${PATHDIRS[@]}"; do
    if [ -d "$dir" ] && [ -w "$dir" ]; then
        echo "[!] WRITABLE PATH DIRECTORY: $dir"
        echo "    Position in PATH - earlier = higher priority for hijacking"
        ls -ld "$dir"
    fi
done
echo ""
echo "[*] PATH priority order (first match wins):"
echo "$PATH" | tr ":" "\n" | nl
'

# =============================================================================
#   PHASE 3: CREDENTIAL HARVESTING
# =============================================================================

# --- 10. Web Application Config Files ---
execute_technique "SOUL EXTRACTION (Web App Credentials)" '
echo "[*] Searching for web application config files with credentials..."
WEB_DIRS="/var/www /srv/www /var/www/html /opt /home"
for dir in $WEB_DIRS; do
    if [ -d "$dir" ]; then
        # PHP config files (MySQL creds, app secrets)
        find "$dir" -maxdepth 5 -type f \( -name "config.php" -o -name "config.inc.php" -o -name "wp-config.php" -o -name "configuration.php" -o -name "settings.php" -o -name "database.php" -o -name "db.php" -o -name "conn.php" -o -name "connect.php" -o -name ".env" \) 2>/dev/null | while read -r f; do
            echo "[!] CONFIG FILE: $f"
            grep -iE "(password|passwd|pass|pwd|db_pass|db_password|DB_PASSWORD|secret|key|token|mysql)" "$f" 2>/dev/null | head -5
            echo ""
        done

        # Python config files (Flask, Django)
        find "$dir" -maxdepth 5 -type f \( -name "settings.py" -o -name "config.py" -o -name "main.py" -o -name "app.py" \) 2>/dev/null | while read -r f; do
            echo "[!] PYTHON CONFIG: $f"
            grep -iE "(password|secret|key|token|os\.system|subprocess|exec)" "$f" 2>/dev/null | head -5
            echo ""
        done
    fi
done
'

# --- 11. XML Config Files (Jenkins, Tomcat, etc.) ---
execute_technique "ANCIENT SCROLLS (XML Config Files)" '
echo "[*] Searching for XML config files with credentials..."
find / -maxdepth 5 -type f \( -name "config.xml" -o -name "tomcat-users.xml" -o -name "web.xml" -o -name "server.xml" -o -name "context.xml" -o -name "credentials.xml" \) 2>/dev/null | while read -r f; do
    echo "[!] XML CONFIG: $f"
    grep -iE "(password|secret|key|token|username|user)" "$f" 2>/dev/null | head -5
    echo ""
done
'

# --- 12. Jenkins Specific ---
execute_technique "CURSED PUPPET MASTER (Jenkins Enumeration)" '
JENKINS_DIRS="/root/.jenkins /var/lib/jenkins /home/*/.jenkins /opt/jenkins"
for dir in $JENKINS_DIRS; do
    if [ -d "$dir" ] 2>/dev/null; then
        echo "[!] JENKINS FOUND: $dir"
        [ -f "$dir/secrets/initialAdminPassword" ] && echo "[!] INITIAL ADMIN PASSWORD:" && cat "$dir/secrets/initialAdminPassword" 2>/dev/null
        [ -f "$dir/config.xml" ] && echo "[!] Jenkins config.xml exists"
        [ -d "$dir/credentials" ] && echo "[!] Jenkins credentials directory exists"
        find "$dir" -name "credentials.xml" 2>/dev/null | while read -r f; do
            echo "[!] CREDENTIALS XML: $f"
        done
    fi
done 2>/dev/null
echo "[-] Jenkins scan complete."
'

# --- 13. Database Credentials ---
execute_technique "SOUL DATABASE (Database Credential Hunt)" '
echo "[*] Searching for database credentials..."
# MySQL/MariaDB config
for f in /etc/mysql/my.cnf /etc/my.cnf /root/.my.cnf /home/*/.my.cnf; do
    [ -r "$f" ] 2>/dev/null && echo "[!] MySQL config: $f" && grep -i "password" "$f" 2>/dev/null
done
# PostgreSQL
for f in /var/lib/postgresql/*/main/pg_hba.conf /etc/postgresql/*/main/pg_hba.conf; do
    [ -r "$f" ] 2>/dev/null && echo "[!] PostgreSQL config: $f"
done
# History files with credentials
for f in /home/*/.mysql_history /root/.mysql_history /home/*/.bash_history /root/.bash_history; do
    if [ -r "$f" ] 2>/dev/null; then
        HITS=$(grep -iE "(password|passwd|pass=|mysql.*-p)" "$f" 2>/dev/null | head -5)
        [ -n "$HITS" ] && echo "[!] CREDS IN HISTORY: $f" && echo "$HITS"
    fi
done
echo "[-] Database credential scan complete."
'

# =============================================================================
#   PHASE 4: SSH KEY DISCOVERY
# =============================================================================

# --- 14. World-Readable SSH Private Keys ---
execute_technique "STOLEN SOULS (SSH Private Key Hunt)" '
echo "[*] Searching for readable SSH private keys..."
find /home /root /tmp /opt /var /etc/ssh -maxdepth 4 -name "id_rsa" -o -name "id_dsa" -o -name "id_ecdsa" -o -name "id_ed25519" -o -name "*.pem" -o -name "*.key" 2>/dev/null | while read -r keyfile; do
    if [ -r "$keyfile" ]; then
        echo "[!] READABLE KEY: $keyfile"
        ls -la "$keyfile"
        head -2 "$keyfile"
        echo "..."
    fi
done
echo ""
echo "[*] Checking for authorized_keys (potential pivot targets)..."
find /home /root -maxdepth 3 -name "authorized_keys" 2>/dev/null | while read -r f; do
    echo "[!] authorized_keys: $f"
    wc -l < "$f" 2>/dev/null | xargs -I{} echo "    {} keys present"
done
echo "[-] SSH key scan complete."
'

# =============================================================================
#   PHASE 5: CRON & SCHEDULED TASKS
# =============================================================================

# --- 15. Binding Vows (Cron & Scheduled Tasks) ---
execute_technique "BINDING VOWS (User Crontab)" 'crontab -l 2>/dev/null || echo "No personal vows found."'
execute_technique "CURSED TIME RITUALS (System Cron Directories)" 'ls -la /etc/cron* 2>/dev/null'
execute_technique "DISTORTED SECRETS (/var/log Cron Logs)" 'grep -i "cron" /var/log/syslog 2>/dev/null || grep -i "cron" /var/log/cron 2>/dev/null || echo "Logs are silent."'

# --- 16. Writable Cron Scripts ---
execute_technique "BREAKING THE VOW (Writable Cron Scripts)" '
echo "[*] Checking for writable cron scripts..."
for crondir in /etc/cron.d /etc/cron.daily /etc/cron.hourly /etc/cron.weekly /etc/cron.monthly; do
    if [ -d "$crondir" ]; then
        for script in "$crondir"/*; do
            [ -f "$script" ] && [ -w "$script" ] && echo "[!] WRITABLE CRON SCRIPT: $script" && ls -la "$script"
        done
    fi
done
# Check /etc/crontab and crontab.bak
[ -r /etc/crontab ] && echo "[*] /etc/crontab:" && cat /etc/crontab
[ -r /etc/crontab.bak ] && echo "[!] /etc/crontab.bak found:" && cat /etc/crontab.bak
echo "[-] Cron writability check complete."
'

# --- 17. Systemd Timers ---
execute_technique "CURSED TIMERS (Systemd Timers)" 'systemctl list-timers --all 2>/dev/null || echo "systemctl not available."'

# =============================================================================
#   PHASE 6: GIT REPOSITORY ENUMERATION
# =============================================================================

# --- 18. Git Repositories ---
execute_technique "CURSED ARCHIVES (Git Repository Discovery)" '
echo "[*] Searching for git repositories..."
find / -maxdepth 5 -name ".git" -type d 2>/dev/null | while read -r gitdir; do
    REPO_DIR=$(dirname "$gitdir")
    echo "[!] GIT REPO: $REPO_DIR"
    echo "    Owner: $(ls -ld "$REPO_DIR" | awk "{print \$3}")"
    if [ -r "$gitdir/config" ]; then
        REMOTE=$(grep -A2 "remote" "$gitdir/config" 2>/dev/null | grep "url" | head -1)
        [ -n "$REMOTE" ] && echo "    Remote: $REMOTE"
    fi
    # Check for hooks
    if [ -d "$gitdir/hooks" ]; then
        for hook in "$gitdir/hooks"/*; do
            if [ -f "$hook" ] && [ ! "$hook" = *".sample" ] && file "$hook" 2>/dev/null | grep -q "script\|text"; then
                echo "    [!] ACTIVE HOOK: $hook"
                [ -w "$hook" ] && echo "        ^^ WRITABLE!"
            fi
        done
    fi
done
# Bare git repos (used by git servers)
find / -maxdepth 4 -name "HEAD" -path "*/refs/../HEAD" 2>/dev/null | while read -r headfile; do
    BARE_DIR=$(dirname "$headfile")
    if [ -d "$BARE_DIR/refs" ] && [ -d "$BARE_DIR/objects" ]; then
        echo "[!] BARE GIT REPO: $BARE_DIR"
        ls -ld "$BARE_DIR"
    fi
done 2>/dev/null
echo "[-] Git repository scan complete."
'

# =============================================================================
#   PHASE 7: NETWORK & INTERNAL SERVICES
# =============================================================================

# --- 19. Cursed Energy Flow (Network Listeners) ---
execute_technique "CURSED ENERGY FLOW (Network Sockets)" 'ss -tulpn 2>/dev/null || netstat -tulpn 2>/dev/null || echo "Network visibility blocked."'

# --- 20. Localhost-Only Services ---
execute_technique "HIDDEN DOMAINS (Localhost-Only Services)" '
echo "[*] Services bound to 127.0.0.1 / localhost only (port forward targets)..."
ss -tulpn 2>/dev/null | grep -E "127\.0\.0\.1|::1" | grep "LISTEN" || netstat -tulpn 2>/dev/null | grep -E "127\.0\.0\.1|::1" | grep "LISTEN" || echo "None found."
echo ""
echo "[*] Common internal service ports to check:"
for port in 3306 5432 6379 8080 8443 9090 9200 27017 11211; do
    if ss -tulpn 2>/dev/null | grep -q ":${port} " || netstat -tulpn 2>/dev/null | grep -q ":${port} "; then
        echo "[!] Port $port is listening ($(
            case $port in
                3306) echo "MySQL" ;;
                5432) echo "PostgreSQL" ;;
                6379) echo "Redis" ;;
                8080) echo "HTTP Proxy/Jenkins/Tomcat" ;;
                8443) echo "HTTPS alt" ;;
                9090) echo "Cockpit/Prometheus" ;;
                9200) echo "Elasticsearch" ;;
                27017) echo "MongoDB" ;;
                11211) echo "Memcached" ;;
            esac
        ))"
    fi
done
'

# --- 21. ARP & Host Discovery ---
execute_technique "DOMAIN AWARENESS (ARP/Hosts)" '
arp -a 2>/dev/null || echo "arp not available."
echo ""
echo "[*] /etc/hosts:"
cat /etc/hosts 2>/dev/null
echo ""
echo "[*] DNS resolv.conf:"
cat /etc/resolv.conf 2>/dev/null
'

# =============================================================================
#   PHASE 8: FILESYSTEM RECONNAISSANCE
# =============================================================================

# --- 22. Looting the Vault (/opt, /tmp, /var/backups) ---
execute_technique "TREASURE VAULT INSPECTION (/opt)" 'ls -la /opt 2>/dev/null'
execute_technique "CURSED REMNANTS (/tmp & /var/backups)" '
ls -la /tmp 2>/dev/null
echo ""
echo "[*] /var/backups:"
ls -la /var/backups 2>/dev/null
'

# --- 23. Home Directory Recon ---
execute_technique "SOUL HARVEST (Home Directories)" '
echo "[*] Listing all home directories..."
ls -la /home/ 2>/dev/null
echo ""
for userdir in /home/*/; do
    if [ -d "$userdir" ]; then
        USERNAME=$(basename "$userdir")
        echo "[*] User: $USERNAME"
        ls -la "$userdir" 2>/dev/null | head -20
        # Check for interesting files
        for interesting in .bash_history .mysql_history .wget-hsts .gitconfig local.txt user.txt; do
            [ -r "${userdir}${interesting}" ] && echo "    [!] Readable: ${interesting}"
        done
        echo ""
    fi
done
'

# --- 24. World-Writable Files & Directories ---
execute_technique "CORRUPTED GROUND (World-Writable Files)" '
echo "[*] World-writable directories (excluding /proc /sys /dev /run)..."
find / -writable -type d ! -path "/proc/*" ! -path "/sys/*" ! -path "/dev/*" ! -path "/run/*" ! -path "/tmp" ! -path "/var/tmp" 2>/dev/null | head -20
echo ""
echo "[*] World-writable files (excluding /proc /sys /dev /run /tmp)..."
find / -writable -type f ! -path "/proc/*" ! -path "/sys/*" ! -path "/dev/*" ! -path "/run/*" ! -path "/tmp/*" 2>/dev/null | head -20
'

# --- 25. Interesting File Extensions ---
execute_technique "HIDDEN SCROLLS (Interesting Files)" '
echo "[*] Backup and config files..."
find / -maxdepth 4 -type f \( -name "*.bak" -o -name "*.old" -o -name "*.conf" -o -name "*.log" -o -name "*.txt" -o -name "*.xml" -o -name "*.json" \) ! -path "/proc/*" ! -path "/sys/*" ! -path "/dev/*" ! -path "/usr/share/*" ! -path "/var/lib/*" 2>/dev/null | grep -vE "(locale|timezone|mime|font|man|doc)" | head -30
'

# =============================================================================
#   PHASE 9: PROCESS & SERVICE ENUMERATION
# =============================================================================

# --- 26. Retainers & Puppets (Root Processes) ---
execute_technique "MALEVOLENT PUPPETS (Root Processes)" 'ps aux 2>/dev/null | grep "^root" || echo "No puppets found."'

# --- 27. All Running Services ---
execute_technique "SERVANT ROLL CALL (All Processes)" 'ps aux 2>/dev/null | grep -v "^\[" | head -50'

# --- 28. Docker / LXC Containers ---
execute_technique "PRISON REALM CHECK (Container Detection)" '
# Check if we are inside a container
if [ -f /.dockerenv ]; then
    echo "[!] INSIDE A DOCKER CONTAINER"
elif grep -q "docker\|lxc\|kubepods" /proc/1/cgroup 2>/dev/null; then
    echo "[!] INSIDE A CONTAINER (cgroup detection)"
else
    echo "[-] Not inside a container."
fi
# Check if docker is available
if command -v docker &>/dev/null; then
    echo "[!] Docker binary available!"
    docker ps 2>/dev/null && echo "[!] Docker accessible - potential escape vector!"
    id | grep -q docker && echo "[!] Current user is in docker group!"
fi
if command -v lxc &>/dev/null; then
    echo "[!] LXC available!"
    lxc list 2>/dev/null
fi
'

# =============================================================================
#   PHASE 10: QUICK WINS SUMMARY
# =============================================================================

execute_technique "DOMAIN ASSESSMENT (Quick Wins Summary)" '
echo "============================================"
echo "  QUICK WINS CHECKLIST"
echo "============================================"
echo ""

# Kernel exploit potential
KVER=$(uname -r)
echo "[*] Kernel: $KVER"
echo "    -> Check: searchsploit linux kernel $KVER"
echo ""

# SUID quick check
for bin in find wget bash python python3 perl nmap vim nano cp env; do
    FULL=$(which "$bin" 2>/dev/null)
    if [ -n "$FULL" ] && [ -u "$FULL" ]; then
        echo "[!] SUID: $FULL -> check GTFOBins!"
    fi
done

# Sudo quick check
SUDO_OUT=$(sudo -n -l 2>/dev/null)
if [ -n "$SUDO_OUT" ]; then
    echo ""
    echo "[!] SUDO available without password:"
    echo "$SUDO_OUT" | grep -E "NOPASSWD|ALL" | head -5
fi

# Writable passwd
[ -w /etc/passwd ] && echo "[!] /etc/passwd is WRITABLE!"

# Writable PATH dirs
IFS=":" read -ra PD <<< "$PATH"
for d in "${PD[@]}"; do
    [ -d "$d" ] && [ -w "$d" ] && echo "[!] Writable PATH dir: $d"
done

# SSH keys
find /home /root -maxdepth 3 -name "id_rsa" -readable 2>/dev/null | while read -r k; do
    echo "[!] Readable SSH key: $k"
done

# Docker group
id | grep -q docker && echo "[!] In docker group!"

echo ""
echo "============================================"
echo "  END QUICK WINS"
echo "============================================"
'

# --- Close the Domain ---
hr | tee -a "$OUTFILE"
printf '💀  The Shrine closes. Your secrets are mine.  💀\n' | tee -a "$OUTFILE"
printf 'Scroll saved to: %s\n' "$OUTFILE" | tee -a "$OUTFILE"
hr | tee -a "$OUTFILE"
