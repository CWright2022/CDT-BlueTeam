#!/bin/bash

echo "Scanning systemd services..."
mapfile -t services < <(systemctl list-unit-files --type=service --no-pager --no-legend | awk '{print $1}')

for service in "${services[@]}"; do
    description=$(systemctl show "$service" --property=Description --value 2>/dev/null)
    enabled_state=$(systemctl is-enabled "$service" 2>/dev/null)
    active_state=$(systemctl is-active "$service" 2>/dev/null)

    echo "----------------------------------------------------"
    echo "Service:       $service"
    echo "Description:   $description"
    echo "Enabled:       $enabled_state"
    echo "Active:        $active_state"
    echo
    echo "[K]eep  [D]isable + Delete"
    read -n1 -r -p "Your choice: " choice
    echo ""

    case "$choice" in
        [Dd])
            echo "Disabling and deleting $service..."
            sudo systemctl stop "$service"
            sudo systemctl disable "$service"
            sudo systemctl reset-failed "$service"

            # Remove unit file if it's local
            if [ -f "/etc/systemd/system/$service" ]; then
                sudo rm "/etc/systemd/system/$service"
            elif [ -f "/lib/systemd/system/$service" ]; then
                sudo rm "/lib/systemd/system/$service"
            else
                echo "No removable unit file found for $service."
            fi

            sudo systemctl daemon-reexec
            sudo systemctl daemon-reload
            ;;
        [Kk])
            echo "Keeping $service."
            ;;
        *)
            echo "Invalid input. Skipping..."
            ;;
    esac

    echo
done

echo "Done processing all services."