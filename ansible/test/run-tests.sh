#!/bin/bash
set -e

DISTRO=""
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
fi

echo "============================================"
echo " Testing Ansible playbook on $DISTRO"
echo "============================================"
echo ""

PLAYBOOK=""
if [ "$DISTRO" = "ubuntu" ]; then
    PLAYBOOK="ubuntu.yml"
elif [ "$DISTRO" = "fedora" ]; then
    PLAYBOOK="fedora.yml"
else
    if [ -f ubuntu.yml ]; then
        PLAYBOOK="ubuntu.yml"
    elif [ -f fedora.yml ]; then
        PLAYBOOK="fedora.yml"
    fi
fi

if [ -z "$PLAYBOOK" ] || [ ! -f "$PLAYBOOK" ]; then
    echo "ERROR: No playbook found"
    exit 1
fi

echo "--- 1. Syntax check ---"
ansible-playbook "$PLAYBOOK" -i inventory.ini --syntax-check
echo "PASSED"
echo ""

echo "--- 2. Dry-run (check mode, skip docker/cleanup) ---"
ansible-playbook "$PLAYBOOK" \
    -i inventory.ini \
    --check \
    --skip-tags "docker,cleanup,gui-apps" \
    -v
echo "PASSED"
echo ""

echo "--- 3. Inventory validation ---"
ansible-inventory -i inventory.ini --list
echo "PASSED"
echo ""

echo "============================================"
echo " All tests passed on $DISTRO"
echo "============================================"
