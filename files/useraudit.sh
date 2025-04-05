#!/bin/bash

# Get all non-system users (UID >= 1000)
get_users() {
    awk -F: '$3 >= 1000 && $3 < 65534 {print $1}' /etc/passwd
}

# Delete the user
delete_user() {
    sudo deluser --remove-home "$1"
    echo "[+] Deleted user: $1"
}

# Change the password for the user
change_password() {
    echo "[*] Changing password for $1..."
    sudo passwd "$1"
}

# Main loop
echo -e "\n=== User Management Tool ==="

users=$(get_users)

if [ -z "$users" ]; then
    echo "No regular users found."
    exit 0
fi

for user in $users; do
    read -n 1 -p "User: $user [d=Delete, k=Keep, p=Change password]: " action
    echo ""

    case "$action" in
        d)
            delete_user "$user"
            ;;
        p)
            change_password "$user"
            ;;
        k)
            echo "[=] Kept user: $user"
            ;;
        *)
            echo "[!] Invalid option. Skipping $user..."
            ;;
    esac
done

echo -e "\n[✔️] User management completed!"
