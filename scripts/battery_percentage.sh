#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/helpers.sh"

print_battery_percentage() {
	# percentage displayed in the 2nd field of the 2nd row
	if command_exists "pmset"; then
		pmset -g batt | grep -o "[0-9]\{1,3\}%"
	elif command_exists "upower"; then
        # use DisplayDevice if available otherwise battery
		local battery=$(upower -e | grep -E 'battery|DisplayDevice'| tail -n1)
		if [ -z "$battery" ]; then
			return
		fi
		local percentage=$(upower -i $battery | awk -v nrg="$percentage" '/percentage:/ {print nrg+$2}')
		echo "$percentage%"
	elif command_exists "acpi"; then
		acpi -b | grep -m 1 -Eo "[0-9]+%"
	elif command_exists "termux-battery-status"; then
		termux-battery-status | jq -r '.percentage' | awk '{printf("%d%%", $1)}'
	fi
}

main() {
	print_battery_percentage
}
main
