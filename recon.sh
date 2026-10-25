
#!/bin/bash
# Automated Network Reconnaissance Tool
set -u

echo "=================================="
echo " Automated Network Recon Tool"
echo "=================================="

# Check whether Nmap is installed
if ! command -v nmap >/dev/null 2>&1; then
    echo "Error: Nmap is not installed."
    echo "Install it using: sudo apt install nmap"
    exit 1
fi

# Get target from user
read -r -p "Enter authorized target IP or domain: " TARGET

# Validate basic IP/domain characters
if [[ ! "$TARGET" =~ ^[a-zA-Z0-9.-]+$ ]] ||
   [[ "$TARGET" == -* ]]; then
    echo "Error: Invalid target format."
    exit 1
fi

# Create reports directory
mkdir -p reports

# Create timestamp and safe filename
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
SAFE_TARGET=$(printf '%s' "$TARGET" | tr '.' '_')
REPORT="reports/${SAFE_TARGET}_${TIMESTAMP}"

echo
echo "[1] Checking target reachability..."

if ping -c 1 -W 2 "$TARGET" >/dev/null 2>&1; then
    echo "Target responded to ping."
else
    echo "No ping response; the host may still be online."
fi

echo
echo "[2] Starting TCP port and service scan..."
echo "This may take some time."

nmap -sT -sV -T3 --top-ports 1000 \
    -oA "$REPORT" "$TARGET"

if [[ $? -eq 0 ]]; then
    echo
    echo "[3] Scan completed successfully."
    echo "Reports saved with this filename:"
    echo "$REPORT"
    echo "Files: .nmap, .xml, and .gnmap"
else
    echo "Scan failed. Check the target and permissions."
    exit 1
fi

echo
echo "Reconnaissance completed."
