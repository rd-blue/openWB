#!/bin/bash
#######################################
# function for setting the current - eCB1 Hardy Barth
# Parameters:
# 1: current
# 2: timeout
# 3: IP address
setChargingCurrentecb1(){
	newcurrent=$1
	tout=$2
	ipa=$3
	output=$(curl -s --connect-timeout $tout http://$ipa/api/v1/chargecontrols/1)
	if [[ $? == "0" ]] ; then
		state=$(echo $output | jq -r '.chargecontrol.stateid')
		openwbDebugLog "MAIN" 1 "+++ eCB1 stateid: $state"
		if [[ $newcurrent -eq 0 ]]; then
			# Ladung abschalten, falls nicht schon in state 17 (Ladung aus)
			if (( state != 17 )) ; then
				curl -s -X POST --connect-timeout $tout --header "Content-Type: application/json" --header "Accept: application/json" --header "Content-Length: 0" "http://$ipa/api/v1/chargecontrols/1/stop" > /dev/null
				openwbDebugLog "MAIN" 0 "+++ eCB1: LADUNG abgeschaltet"
			fi
		else
			# Ladung aktivieren, falls nicht schon state 0 (kein Auto) und auch nicht in state 5 (mit Auto, Ladung)
			if (( state != 0 )) && (( state != 5 )) ; then
				curl -s -X POST --connect-timeout $tout --header "Content-Type: application/json" --header "Accept: application/json" --header "Content-Length: 0" "http://$ipa/api/v1/chargecontrols/1/start" > /dev/null
				openwbDebugLog "MAIN" 0 "+++ eCB1: LADUNG aktiviert"
			fi
			state=$(echo $output | jq -r '.chargecontrol.mode')
			# nur in Manual mode vom eCB1
			if [[ $state == "manual" ]] ; then
				output=$(curl --connect-timeout $tout -s http://$ipa/api/v1/chargecontrols/1/mode/manual/ampere)
				oldcurrent=$(echo $output | jq -r '.manualmodeamp')
				oldcurrent=$(echo "scale=0;$oldcurrent / 1" |bc)
				if (( oldcurrent != newcurrent )) && (( newcurrent != 0 )); then
					curl -s -X PUT --connect-timeout $tout -d "manualmodeamp=$newcurrent" http://$ipa/api/v1/chargecontrols/1/mode/manual/ampere > /dev/null
					openwbDebugLog "MAIN" 1 "+++ eCB1 Strom setzen: $oldcurrent A --> $newcurrent A"
				fi
			fi
		fi
	fi
}
