#!/bin/bash

# Must run as root
if [ "$EUID" -ne 0 ]; then
  echo "======================================="
  echo "=   ERROR: phase2.sh must run as root  ="
  echo "======================================="
  exit 1
fi

# Prevent double-running
if [ -f /etc/enux-phase2-done ]; then
  exit 0
fi

clear
echo "========================================"
echo "         ENux PHASE 2 - INSTALLING E's"
echo "========================================"
echo

echo "Fetching Arch..."
brl fetch arch

echo "Fetching Fedora ..."
brl fetch fedora --release 41

echo "Fetching Void..."
brl fetch void

echo "Fetching Alpine..."
brl fetch alpine

echo "Fetching Gentoo..."
brl fetch gentoo

echo
echo "========================================"
echo "=          ENux 1.0 IS READY!          ="
echo "=         Run: enuxfetch anytime       ="
echo "========================================"
echo

# Mark phase 2 as done
mkdir -p /etc
touch /etc/enux-phase2-done
