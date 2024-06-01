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
	lmode=$(<ramdisk/lademodus)
	output=$(curl -s --connect-timeout $tout http://$ipa/api/v1/chargecontrols/1)
	if [[ $? == "0" ]] ; then
		state=$(echo $output | jq -r '.chargecontrol.stateid')
		openwbDebugLog "MAIN" 1 "+++ eCB1 stateid: $state"
		if [[ $newcurrent -eq 0 ]]; then
			# Ladung abschalten, falls nicht schon in state 17 (Ladung aus)
			if (( state != 17 )) ; then
				openwbDebugLog "MAIN" 0 "+++ eCB1: LADUNG abschalten"
				curl -s -X POST --connect-timeout $tout --header "Content-Type: application/json" --header "Accept: application/json" --header "Content-Length: 0" "http://$ipa/api/v1/chargecontrols/1/stop" > /dev/null
			fi
		else
			# Ladung aktivieren, falls nicht schon state 0 (kein Auto) und auch nicht in state 5 (mit Auto, Ladung)
			if (( state != 0 )) && (( state != 5 )) ; then
				openwbDebugLog "MAIN" 0 "+++ eCB1: disable AI-mode"
				curl -s -X PUT --connect-timeout $tout -d "autostartstop=false" "http://$ipa/api/v1/chargecontrols/1/mode/eco/startstop" > /dev/null
				# in PV or Min + PV
				if (( lmode == 2 )) || (( lmode == 1 )) ; then
					openwbDebugLog "MAIN" 0 "+++ eCB1: auf eco setzen"
					curl -s -X PUT --connect-timeout $tout -d "pvmode=eco" "http://$ipa/api/v1/pvmode" > /dev/null
				else
					openwbDebugLog "MAIN" 0 "+++ eCB1: auf manual setzen"
					curl -s -X PUT --connect-timeout $tout -d "pvmode=manual" "http://$ipa/api/v1/pvmode" > /dev/null
					openwbDebugLog "MAIN" 1 "+++ eCB1: $newcurrent A setzen"
					curl -s -X PUT --connect-timeout $tout -d "manualmodeamp=$newcurrent" http://$ipa/api/v1/chargecontrols/1/mode/manual/ampere > /dev/null
				fi				
				openwbDebugLog "MAIN" 0 "+++ eCB1: LADUNG aktivieren"
				curl -s -X POST --connect-timeout $tout --header "Content-Type: application/json" --header "Accept: application/json" --header "Content-Length: 0" "http://$ipa/api/v1/chargecontrols/1/start" > /dev/null
			else
				state=$(echo $output | jq -r '.chargecontrol.mode')
				# nur in Manual mode vom eCB1 Strom setzen
				if [[ $state == "manual" ]] ; then
					output=$(curl --connect-timeout $tout -s http://$ipa/api/v1/chargecontrols/1/mode/manual/ampere)
					oldcurrent=$(echo $output | jq -r '.manualmodeamp')
					oldcurrent=$(echo "scale=0;$oldcurrent / 1" |bc)
					if (( oldcurrent != newcurrent )) && (( newcurrent != 0 )); then
						openwbDebugLog "MAIN" 1 "+++ eCB1 Strom von $oldcurrent A --> $newcurrent A"
						curl -s -X PUT --connect-timeout $tout -d "manualmodeamp=$newcurrent" http://$ipa/api/v1/chargecontrols/1/mode/manual/ampere > /dev/null
					fi
				else
					openwbDebugLog "MAIN" 1 "+++ eCB1 Strom virtuell setzen --> $newcurrent A"
				fi
			fi
		fi
	fi
}
