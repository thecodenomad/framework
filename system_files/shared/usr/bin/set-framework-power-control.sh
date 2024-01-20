#!/bin/sh

set -ouex pipefail

# Define Power Services
PPD="power-profiles-daemon"
TLP="tlp"

CPU_VENDOR=$(lshw -json -class CPU | jq -r ".[].vendor")

mask_service() {
  service="$1"
  query=$(systemctl is-enabled "${service}")

  if [[ "${query}" == "masked" ]]; then
    echo "Service ${service} is masked"
  else
    echo "Masking ${service}"  
    systemctl mask "${service}"
  fi  
}

enable_service() {
  service="$1"
  query=$(systemctl is-enabled "${service}")

  if [[ "${query}" == "masked" ]]; then
    echo "Unmasking ${service}"
    systemctl unmask "${service}"
  fi

  query=$(systemctl is-enabled "${service}")  
  if [[ "${query}" == "disabled" ]]; then
    echo "Enabling ${service}"
    systemctl enable "${service}"
  else
    echo "${service} is already enabled"
  fi
}

if [[ "${CPU_VENDOR^^}" =~ .*"AMD".* ]]; then
    mask_service "${TLP}"
    enable_service "${PPD}"
elif [[ "${CPU_VENDOR^^}" =~ .*"INTEL".* ]]; then
    mask_service "${PPD}"
    enable_service "${TLP}"
fi
