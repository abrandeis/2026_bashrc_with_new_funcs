#!/bin/bash

system_info() {

  ## --- Colors for Output ---
  CYAN='\033[0;36m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  NC='\033[0m' # No Color

  echo -e ""
  echo -e "${CYAN}==== SYSTEM INFORMATION REPORT ====${NC}"
  echo -e ""

  ## --- System Overview ---
  printf "%bHostname:%b %s\n" "$CYAN" "$NC" "$(hostname)"
  printf "%bUser:%b %s\n" "$CYAN" "$NC" "$USER"
  printf "%bOS:%b %s\n" "$CYAN" "$NC" "$(uname -s)"
  printf "%bKernel:%b %s\n" "$CYAN" "$NC" "$(uname -r)"
  printf "%bUptime:%b %s\n" "$CYAN" "$NC" "$(uptime -p)"

  ## --- CPU Information ---
  echo -e "\n${CYAN}[ CPU Information ]${NC}"

  printf "Load Average: %s\n" \
    "$(uptime | awk -F'load average:' '{print $2}')"

  if [[ "$(uname)" == "Darwin" ]]; then
    printf "CPU Model: %s\n" "$(sysctl -n machdep.cpu.brand_string)"
  else
    printf "CPU Model: %s\n" \
      "$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | xargs)"
  fi

  ## --- Memory Information ---
  echo -e "\n${CYAN}[ Memory Usage ]${NC}"

  if [[ "$(uname)" == "Darwin" ]]; then
    vm_stat | perl -ne '
      /page size of (\d+)/ and $s=$1;
      /Pages free:\s+(\d+)/ and $f=$1*$s;
      /Pages active:\s+(\d+)/ and $a=$1*$s;
      /Pages inactive:\s+(\d+)/ and $i=$1*$s;
      END {
        printf "Used: %.2fGB / Total: %.2fGB\n",
        ($a+$i)/1024/1024/1024,
        ($a+$i+$f)/1024/1024/1024
      }'
  else
    free -h | awk '/^Mem:/ {printf "Used: %s / Total: %s\n", $3, $2}'
  fi

  ## --- Disk Usage ---
  echo -e "\n${CYAN}[ Disk Usage ]${NC}"
  df -h / | awk 'NR==2 {printf "Used: %s / Total: %s (%s)\n", $3, $2, $5}'

  ## --- Network Information ---
  echo -e "\n${CYAN}[ Network Info ]${NC}"

  if [[ "$(uname)" == "Darwin" ]]; then
    printf "IP Address: %s\n" "$(ipconfig getifaddr en0)"
  else
    printf "IP Address: %s\n" "$(hostname -I | awk '{print $1}')"
    printf "Netmask Info:\n"
    ifconfig | grep -i netmask
  fi

  echo -e "\n${CYAN}==================================${NC}"
}

# Call the function
## system_info

