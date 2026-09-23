#!/bin/bash

# ============================================================
# Linux Security Assignment
# Secure Departmental Directory
# ============================================================

set -e

# -----------------------------
# Configuration
# -----------------------------
GROUP_NAME="students"

USER1="student1"
USER2="student2"
UNAUTHORIZED="unauthorized"

BASE_DIR="/opt/department"
STUDENT_DIR="/opt/department/students"
TEST_FILE="/opt/department/students/student_info.txt"

# Select an appropriate SELinux type for your implementation.
# For a generic, securely restricted data directory, user_home_t or var_t variants work,
# but we will stick to your configured type or public_content_t depending on the policy.
SELINUX_TYPE="httpd_sys_content_t"

# Select/document an appropriate SELinux boolean.
# Example: Allow Apache to read/write content if needed, or leave blank if enforcing strict type rules.
SELINUX_BOOLEAN="httpd_builtin_scripting"

echo "======================================"
echo " Linux Security Assignment"
echo "======================================"

# ------------------------------------------------------------
# TODO 1: Check that the script is running as root
# ------------------------------------------------------------
echo "[1] Checking root privileges..."

if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root." >&2
    exit 1
fi
echo "Root privileges verified."

# ------------------------------------------------------------
# TODO 2: Check SELinux status
# ------------------------------------------------------------
echo "[2] Checking SELinux..."

SELINUX_STATUS=$(getenforce)
echo "Current SELinux mode: ${SELINUX_STATUS}"

if [ "${SELINUX_STATUS}" != "Enforcing" ]; then
    echo "Error: SELinux is not in Enforcing mode. Please enable it before running this script." >&2
    exit 1
fi

# ------------------------------------------------------------
# TODO 3: Create the students group
# ------------------------------------------------------------
echo "[3] Creating group: ${GROUP_NAME}"

if getent group "${GROUP_NAME}" > /dev/null 2>&1; then
    echo "Group '${GROUP_NAME}' already exists."
else
    groupadd "${GROUP_NAME}"
    echo "Group '${GROUP_NAME}' created successfully."
fi

# ------------------------------------------------------------
# TODO 4: Create users
# ------------------------------------------------------------
echo "[4] Creating users..."

# Function to safely create a user and add to secondary groups if specified
create_user_if_missing() {
    local username=$1
    local secondary_group=$2

    if id "$username" > /dev/null 2>&1; then
        echo "User '$username' already exists."
        if [ -n "$secondary_group" ]; then
            usermod -aG "$secondary_group" "$username"
        fi
    else
        if [ -n "$secondary_group" ]; then
            useradd -m -G "$secondary_group" "$username"
        else
            useradd -m "$username"
        fi
        echo "User '$username' created successfully."
    fi
}

# Create authorized students
create_user_if_missing "${USER1}" "${GROUP_NAME}"
create_user_if_missing "${USER2}" "${GROUP_NAME}"

# Create unauthorized user (explicitly not in the students group)
create_user_if_missing "${UNAUTHORIZED}" ""

echo "User and group configurations complete."
