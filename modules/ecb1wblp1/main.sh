#!/bin/bash
re='^[-+]?[0-9]+\.?[0-9]*$'
rekwh='^[-+]?[0-9]+\.?[0-9]*$'

# Hardy Barth Wallbox mit eCB1
output=$(curl --connect-timeout $ecb1wbtimeoutlp1 -s http://$ecb1wbiplp1/api/v1/meters?function=socket)
if [[ $? == "0" ]] ; then

	watt=$(echo $output | jq -r '.meters | .[] | .data.lgwb')
	watt=$(echo "scale=0;$watt * -1 /1" |bc)
	if [[ $watt =~ $re ]] ; then
		echo $watt > /var/www/html/openWB/ramdisk/llaktuell
	fi 

	lla1=$(echo $output | jq -r '.meters | .[] | .data."1-0:31.4.0"')
	lla1=$(echo "scale=3;$lla1 * 10 / 10" |bc)
	if [[ $lla1 =~ $re ]] ; then
		echo $lla1 > /var/www/html/openWB/ramdisk/lla1
	fi
	lla2=$(echo $output | jq -r '.meters | .[] | .data."1-0:51.4.0"')
	lla2=$(echo "scale=3;$lla2 * 10 / 10" |bc)
	if [[ $lla2 =~ $re ]] ; then
		echo $lla2 > /var/www/html/openWB/ramdisk/lla2
	fi
	lla3=$(echo $output | jq -r '.meters | .[] | .data."1-0:71.4.0"')
	lla3=$(echo "scale=3;$lla3 * 10 / 10" |bc)
	if [[ $lla3 =~ $re ]] ; then
		echo $lla3 > /var/www/html/openWB/ramdisk/lla3
	fi

	llv1=$(echo $output | jq -r '.meters | .[] | .data."1-0:32.4.0"')
	if [[ $llv1 =~ $re ]] ; then
		echo $llv1 > /var/www/html/openWB/ramdisk/llv1
	fi
	llv2=$(echo $output | jq -r '.meters | .[] | .data."1-0:52.4.0"')
	if [[ $llv2 =~ $re ]] ; then
		echo $llv2 > /var/www/html/openWB/ramdisk/llv2
	fi
	llv3=$(echo $output | jq -r '.meters | .[] | .data."1-0:72.4.0"')
	if [[ $llv3 =~ $re ]] ; then
		echo $llv3 > /var/www/html/openWB/ramdisk/llv3
	fi

	llpf1=$(echo $output | jq -r '.meters | .[] | .data."1-0:33.4.0"')
	if [[ $llpf1 =~ $re ]] ; then
		echo $llpf1 > /var/www/html/openWB/ramdisk/llpf1
	fi
	llpf2=$(echo $output | jq -r '.meters | .[] | .data."1-0:53.4.0"')
	if [[ $llpf2 =~ $re ]] ; then
		echo $llpf2 > /var/www/html/openWB/ramdisk/llpf2
	fi
	llpf3=$(echo $output | jq -r '.meters | .[] | .data."1-0:73.4.0"')
	if [[ $llpf3 =~ $re ]] ; then
		echo $llpf3 > /var/www/html/openWB/ramdisk/llpf3
	fi

	llkwh=$(echo $output | jq -r '.meters | .[] | .data."1-0:1.8.0"')
	llkwh=$(echo "scale=3;$llkwh * 1 / 1" |bc)
	if [[ $llkwh =~ $rekwh ]] ; then
		echo $llkwh > /var/www/html/openWB/ramdisk/llkwh
	fi
	openwbDebugLog "MAIN" 2 "+++ eCB1 meters: $watt W $llkwh kWh $lla1 A $lla2 A $lla3 A"
fi

output=$(curl --connect-timeout $ecb1wbtimeoutlp1 -s http://$ecb1wbiplp1/api/v1/chargecontrols)
if [[ $? == "0" ]] ; then

	car=$(echo $output | jq -r '.chargecontrols | .[] | .connected')	
	if [[ $car == "true" ]] ; then
		echo 1 > /var/www/html/openWB/ramdisk/plugstat
	else
		echo 0 > /var/www/html/openWB/ramdisk/plugstat
	fi

	car=$(echo $output | jq -r '.chargecontrols | .[] | .state')	
	if [[ $car == "C" ]] ; then
		echo 1 > /var/www/html/openWB/ramdisk/chargestat
	else
		echo 0 > /var/www/html/openWB/ramdisk/chargestat
	fi

fi
