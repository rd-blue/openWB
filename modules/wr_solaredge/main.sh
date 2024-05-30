#!/bin/bash

OPENWBBASEDIR=$(cd "$(dirname "$0")/../../" && pwd)
RAMDISKDIR="${OPENWBBASEDIR}/ramdisk"
DMOD="PV"
#DMOD="MAIN"

if [ $DMOD == "MAIN" ]; then
	MYLOGFILE="${RAMDISKDIR}/openWB.log"
else
	MYLOGFILE="${RAMDISKDIR}/nurpv.log"
fi

Solaredgebatwr="0"
if [[ "$solaredgespeicherip" == "$solaredgepvip" ]]; then
	Solaredgebatwr="1"
fi

modus=$(<ramdisk/lademodus)
lp1enabled=$(<ramdisk/lp1enabled)
lp1preisbasiert=$(<ramdisk/mqttlp1etbasedcharging)
# Nur im Modus Sofort Laden und preisbasiert und lp1enabled
aktiv=0
if (( modus == 0 )); then
	if (( lp1preisbasiert == 1 )); then
		if (( dischargelimitenabled == 1 )); then
			if (( lp1enabled == 1 )); then
				aktiv=1
			fi
		fi
	fi
fi
openwbDebugLog "MAIN" 2 "++++++ Limit Bat Modus:$modus Preis:$lp1preisbasiert Limit:$dischargelimitenabled LP1:$lp1enabled aktiv:$aktiv"

bash "$OPENWBBASEDIR/packages/legacy_run.sh" "modules.devices.solaredge.device" "inverter" "$solaredgepvip" "" "$solaredgepvslave1" "$solaredgepvslave2" "$solaredgepvslave3" "$solaredgepvslave4" "$Solaredgebatwr" "$wr1extprod" "$solaredgezweiterspeicher" "$solaredgesubbat" "$solaredgewr2ip" "1" "$aktiv" "$dischargepowerlimit" >>"$MYLOGFILE" 2>&1
ret=$?
openwbDebugLog ${DMOD} 2 "RET: ${ret}"

cat "$RAMDISKDIR/pvwatt"
