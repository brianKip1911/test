#!bin/bash

MYPATH=/opt/gemalto/gemapp/GCS/OSG-CCR/logs/
HLR=/files/OTA_FILES/test/input_msisdn/
DEL=/files/OTA_FILES/test/deletion/xml/archive
PROV=/files/OTA_FILES/ready_for_provisioning/
INPUT=/files/OTA_FILES/test/input/
TEST=/files/OTA_FILES/test
OUTPUT=/files/batch_home/server/input_for_files/
LPM=/files/OTA_FILES/test/output
LPMCLR=/files/batch_home/server

cd $LPM
mv `find . -maxdepth 1 -type f | tail -10 |grep LPM` $INPUT
sh /files/batch_home/server/lpm_clear.sh

cd $MYPATH
mv latest last
LAST=`cat last`
echo $LAST
cat ccr.stat | grep FAILED | tail -1 | awk -F, '{print $1}'>latest
LATEST=`cat latest`
echo $LATEST
COUNT=`cat ccr.stat | grep FAILED | awk -F, -v var="$LAST" '$1> var' | wc -l`
echo $COUNT
#COUNT1=`strings ccr.log | grep FATAL | awk -F\- '{print $4}' | sort -n | uniq | wc -l`
#echo $COUNT1
if [ $COUNT -eq 0 ];
	then
		#echo "exit"
		exit 0
	else
		if [ $COUNT -gt 22 ];
			then
				exit 1
			else
				cat ccr.stat | grep FAILED | awk -F, -v var="$LAST" '$1> var' | awk -F\| '$2 ~ /254/ { print $2 }' | sed 's/\]//g' | sed 's/\[//g' | uniq > msisdn.txt
		fi
fi		
MSISDN=(`cat msisdn.txt`)

#cd $MYPATH
for x in ${MSISDN[@]};do
#	echo $x
	if [ $COUNT1 -gt 5 ];
		then 
			strings ccr.log | grep $x | grep "Failed to get SIMs for criteria\|Decryption Processor failed to process request" | wc -l > COUNT2
#			COUNT3=(`cat COUNT2`)
#			echo $COUNT2
			if [ $COUNT2 -eq 0 ];
				then
#					echo "exit1"
                	exit 2
			fi
	else
		cd $HLR
		DUMP=HLR_Dump20181018230002.csv
		grep $x $DUMP > HLR_$x.csv
		chmod 777 HLR_$x.csv
		HLR_dump=HLR_$x.csv
#		echo "HLR_$x.csv"
		OUTPUT_XML=$DEL/'DEL_TKN'$x'.XML'
		printf '<?xml version="1.0" encoding="ISO-8859-1" ?> \n
<ProvisioningOrders generateReport="true"> \n' >>$OUTPUT_XML
		while IFS=, read -r imsi msisdn
		do
			printf '       
<Order transactionId="'$imsi'"> \n
	<DeleteSubscription imsi="'$imsi'" deleteSecurity="true"/> \n
</Order> \n
<Order transactionId="'$msisdn'"> \n
	<DeleteSubscription msisdn="'$msisdn'" deleteSecurity="true"/> \n
</Order> \n' >>$OUTPUT_XML
		done < $HLR_dump
		printf '  
</ProvisioningOrders> \n\n' >>$OUTPUT_XML
#		echo "$OUTPUT_XML"
		mv $OUTPUT_XML $OUTPUT
#		sleep 1
		imsi=`awk -F, '{print $1}' $HLR_dump`
#		echo "$imsi"
#		cd $PROV
		BATCH=`zgrep $imsi $PROV * | awk -F\: '$1 ~ /.zip/ {print $1}'`
		echo "$BATCH"
		unzip $BATCH
		mv *.OTM *.XML $INPUT
		rm -rf *.OUT
		nohup sh $TEST/create_provision_file.sh $HLR/$HLR_dump &
		
	fi
#	sleep 1
done


