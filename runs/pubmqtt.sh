#!/bin/bash

declare -A mqttvar
mqttvar["evu/APhase1"]=bezuga1
mqttvar["evu/APhase2"]=bezuga2
mqttvar["evu/APhase3"]=bezuga3
mqttvar["evu/VPhase1"]=evuv1
mqttvar["evu/VPhase2"]=evuv2
mqttvar["evu/VPhase3"]=evuv3
mqttvar["evu/Hz"]=evuhz
mqttvar["evu/PfPhase1"]=evupf1
mqttvar["evu/PfPhase2"]=evupf2
mqttvar["evu/PfPhase3"]=evupf3
mqttvar["lp/1/ChargeStatus"]=ladestatus
mqttvar["lp/2/ChargeStatus"]=ladestatuss1
mqttvar["lp/3/ChargeStatus"]=ladestatuss2
mqttvar["lp/4/ChargeStatus"]=ladestatuslp4
mqttvar["lp/5/ChargeStatus"]=ladestatuslp5
mqttvar["lp/6/ChargeStatus"]=ladestatuslp6
mqttvar["lp/7/ChargeStatus"]=ladestatuslp7
mqttvar["lp/8/ChargeStatus"]=ladestatuslp8
mqttvar["lp/2/VPhase1"]=llvs11
mqttvar["lp/2/VPhase2"]=llvs12
mqttvar["lp/2/VPhase3"]=llvs13
mqttvar["lp/1/VPhase1"]=llv1
mqttvar["lp/1/VPhase2"]=llv2
mqttvar["lp/1/VPhase3"]=llv3
mqttvar["lp/3/VPhase1"]=llvs21
mqttvar["lp/3/VPhase2"]=llvs22
mqttvar["lp/3/VPhase3"]=llvs23
mqttvar["lp/2/APhase1"]=llas11
mqttvar["lp/2/APhase2"]=llas12
mqttvar["lp/2/APhase3"]=llas13
mqttvar["lp/3/APhase1"]=llas21
mqttvar["lp/3/APhase2"]=llas22
mqttvar["lp/3/APhase3"]=llas23
mqttvar["lp/1/APhase1"]=lla1
mqttvar["lp/1/APhase2"]=lla2
mqttvar["lp/1/APhase3"]=lla3
mqttvar["lp/1/kWhCounter"]=llkwh
mqttvar["lp/2/kWhCounter"]=llkwhs1
mqttvar["lp/3/kWhCounter"]=llkwhs2
mqttvar["Verbraucher/WNr1"]=verbraucher1_watt
mqttvar["Verbraucher/WhImportedNr1"]=verbraucher1_wh
mqttvar["Verbraucher/WhExportedNr1"]=verbraucher1_whe
mqttvar["Verbraucher/WNr2"]=verbraucher2_watt
mqttvar["Verbraucher/WhImportedNr2"]=verbraucher2_wh
mqttvar["Verbraucher/WhExportedNr2"]=verbraucher2_whe
mqttvar["evu/WhExported"]=einspeisungkwh
mqttvar["evu/WhImported"]=bezugkwh
mqttvar["housebattery/WhExported"]=speicherekwh
mqttvar["housebattery/WhImported"]=speicherikwh
mqttvar["pv/CounterTillStartPvCharging"]=pvcounter
mqttvar["pv/WhCounter"]=pvkwh
mqttvar["lp/1/PfPhase1"]=llpf1
mqttvar["lp/1/PfPhase2"]=llpf2
mqttvar["lp/1/PfPhase3"]=llpf3
mqttvar["lp/1/ChargePointEnabled"]=lp1enabled
mqttvar["lp/2/ChargePointEnabled"]=lp2enabled
mqttvar["lp/3/ChargePointEnabled"]=lp3enabled
mqttvar["lp/4/ChargePointEnabled"]=lp4enabled
mqttvar["lp/5/ChargePointEnabled"]=lp5enabled
mqttvar["lp/6/ChargePointEnabled"]=lp6enabled
mqttvar["lp/7/ChargePointEnabled"]=lp7enabled
mqttvar["lp/8/ChargePointEnabled"]=lp8enabled
mqttvar["evu/WAverage"]=glattwattbezug
mqttvar["global/strLastmanagementActive"]=lastregelungaktiv
mqttvar["lp/6/W"]=llaktuelllp6
mqttvar["lp/6/kWhCounter"]=llkwhlp6
mqttvar["lp/6/APhase1"]=lla1lp6
mqttvar["lp/6/APhase2"]=lla2lp6
mqttvar["lp/6/APhase3"]=lla3lp6
mqttvar["lp/6/VPhase1"]=llv1lp6
mqttvar["lp/6/VPhase2"]=llv2lp6
mqttvar["lp/6/VPhase3"]=llv3lp6
mqttvar["lp/7/W"]=llaktuelllp7
mqttvar["lp/7/kWhCounter"]=llkwhlp7
mqttvar["lp/7/APhase1"]=lla1lp7
mqttvar["lp/7/APhase2"]=lla2lp7
mqttvar["lp/7/APhase3"]=lla3lp7
mqttvar["lp/7/VPhase1"]=llv1lp7
mqttvar["lp/7/VPhase2"]=llv2lp7
mqttvar["lp/7/VPhase3"]=llv3lp7
mqttvar["lp/8/W"]=llaktuelllp8
mqttvar["lp/8/kWhCounter"]=llkwhlp8
mqttvar["lp/8/APhase1"]=lla1lp8
mqttvar["lp/8/APhase2"]=lla2lp8
mqttvar["lp/8/APhase3"]=lla3lp8
mqttvar["lp/8/VPhase1"]=llv1lp8
mqttvar["lp/8/VPhase2"]=llv2lp8
mqttvar["lp/8/VPhase3"]=llv3lp8
mqttvar["lp/4/W"]=llaktuelllp4
mqttvar["lp/4/kWhCounter"]=llkwhlp4
mqttvar["lp/4/APhase1"]=lla1lp4
mqttvar["lp/4/APhase2"]=lla2lp4
mqttvar["lp/4/APhase3"]=lla3lp4
mqttvar["lp/4/VPhase1"]=llv1lp4
mqttvar["lp/4/VPhase2"]=llv2lp4
mqttvar["lp/4/VPhase3"]=llv3lp4
mqttvar["lp/5/W"]=llaktuelllp5
mqttvar["lp/5/kWhCounter"]=llkwhlp5
mqttvar["lp/5/APhase1"]=lla1lp5
mqttvar["lp/5/APhase2"]=lla2lp5
mqttvar["lp/5/APhase3"]=lla3lp5
mqttvar["lp/5/VPhase1"]=llv1lp5
mqttvar["lp/5/VPhase2"]=llv2lp5
mqttvar["lp/5/VPhase3"]=llv3lp5
mqttvar["evu/ASchieflast"]=schieflast
mqttvar["evu/WPhase1"]=bezugw1
mqttvar["evu/WPhase2"]=bezugw2
mqttvar["evu/WPhase3"]=bezugw3
mqttvar["lp/1/AConfigured"]=llsoll
mqttvar["lp/2/AConfigured"]=llsolls1
mqttvar["lp/3/AConfigured"]=llsolls2
mqttvar["lp/4/AConfigured"]=llsolllp4
mqttvar["lp/5/AConfigured"]=llsolllp5
mqttvar["lp/6/AConfigured"]=llsolllp6
mqttvar["lp/7/AConfigured"]=llsolllp7
mqttvar["lp/8/AConfigured"]=llsolllp8
mqttvar["lp/1/kWhActualCharged"]=aktgeladen
mqttvar["lp/2/kWhActualCharged"]=aktgeladens1
mqttvar["lp/3/kWhActualCharged"]=aktgeladens2
mqttvar["lp/4/kWhActualCharged"]=aktgeladenlp4
mqttvar["lp/5/kWhActualCharged"]=aktgeladenlp5
mqttvar["lp/6/kWhActualCharged"]=aktgeladenlp6
mqttvar["lp/7/kWhActualCharged"]=aktgeladenlp7
mqttvar["lp/8/kWhActualCharged"]=aktgeladenlp8
mqttvar["lp/1/boolPlugStat"]=plugstat
mqttvar["lp/2/boolPlugStat"]=plugstats1
mqttvar["lp/3/boolPlugStat"]=plugstatlp3
mqttvar["lp/4/boolPlugStat"]=plugstatlp4
mqttvar["lp/5/boolPlugStat"]=plugstatlp5
mqttvar["lp/6/boolPlugStat"]=plugstatlp6
mqttvar["lp/7/boolPlugStat"]=plugstatlp7
mqttvar["lp/8/boolPlugStat"]=plugstatlp8
mqttvar["lp/1/boolChargeStat"]=chargestat
mqttvar["lp/2/boolChargeStat"]=chargestats1
mqttvar["lp/3/boolChargeStat"]=chargestatlp3
mqttvar["lp/4/boolChargeStat"]=chargestatlp4
mqttvar["lp/5/boolChargeStat"]=chargestatlp5
mqttvar["lp/6/boolChargeStat"]=chargestatlp6
mqttvar["lp/7/boolChargeStat"]=chargestatlp7
mqttvar["lp/8/boolChargeStat"]=chargestatlp8
mqttvar["lp/1/kWhChargedSincePlugged"]=pluggedladungbishergeladen
mqttvar["lp/2/kWhChargedSincePlugged"]=pluggedladungbishergeladenlp2
mqttvar["lp/3/kWhChargedSincePlugged"]=pluggedladungbishergeladenlp3
mqttvar["lp/4/kWhChargedSincePlugged"]=pluggedladungbishergeladenlp4
mqttvar["lp/5/kWhChargedSincePlugged"]=pluggedladungbishergeladenlp5
mqttvar["lp/6/kWhChargedSincePlugged"]=pluggedladungbishergeladenlp6
mqttvar["lp/7/kWhChargedSincePlugged"]=pluggedladungbishergeladenlp7
mqttvar["lp/8/kWhChargedSincePlugged"]=pluggedladungbishergeladenlp8
mqttvar["lp/1/AutolockStatus"]=autolockstatuslp1
mqttvar["lp/2/AutolockStatus"]=autolockstatuslp2
mqttvar["lp/3/AutolockStatus"]=autolockstatuslp3
mqttvar["lp/4/AutolockStatus"]=autolockstatuslp4
mqttvar["lp/5/AutolockStatus"]=autolockstatuslp5
mqttvar["lp/6/AutolockStatus"]=autolockstatuslp6
mqttvar["lp/7/AutolockStatus"]=autolockstatuslp7
mqttvar["lp/8/AutolockStatus"]=autolockstatuslp8
mqttvar["lp/1/AutolockConfigured"]=autolockconfiguredlp1
mqttvar["lp/2/AutolockConfigured"]=autolockconfiguredlp2
mqttvar["lp/3/AutolockConfigured"]=autolockconfiguredlp3
mqttvar["lp/4/AutolockConfigured"]=autolockconfiguredlp4
mqttvar["lp/5/AutolockConfigured"]=autolockconfiguredlp5
mqttvar["lp/6/AutolockConfigured"]=autolockconfiguredlp6
mqttvar["lp/7/AutolockConfigured"]=autolockconfiguredlp7
mqttvar["lp/8/AutolockConfigured"]=autolockconfiguredlp8
mqttvar["pv/DailyYieldKwh"]=daily_pvkwhk
mqttvar["global/boolRse"]=rsestatus

tempPubList=""
for mq in "${!mqttvar[@]}"; do
	declare o${mqttvar[$mq]}
	declare ${mqttvar[$mq]}
	tempnewname=${mqttvar[$mq]}

	tempoldname=o${mqttvar[$mq]}
	tempoldname=$(<ramdisk/mqtt"${mqttvar[$mq]}")
	tempnewname=$(<ramdisk/"${mqttvar[$mq]}")
	if [[ "$tempoldname" != "$tempnewname" ]]; then
		tempPubList="${tempPubList}\nopenWB/${mq}=${tempnewname}"
		echo $tempnewname > ramdisk/mqtt${mqttvar[$mq]}
	fi
	#echo ${mqttvar[$mq]} $mq 
done


#echo "Publist:"
#echo -e $tempPubList

#echo "Running Python:"
echo -e $tempPubList | python3 runs/mqttpub.py -q 0 -r &