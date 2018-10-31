#!/bin/sh
'''auth mfstech
DMS tree report_generator'''

MY_PATH=/opt/gemalto/gemapp/GCS/OSG-CCR/logs

cd $MY_PATH
> file.txt
> summary2
dates=(`ls ccr.stat*`)

for x in ${dates[@]};do
	unset date
	date=`echo $x |awk -F. '{print $3}'`
	echo $date
	for i in ${date[@]};do
		cat $x | awk -F\| '{print ","$3","$4",""'$date'"}' | sort -n | uniq -c >> file.txt 
	done
done
############################################
FILE=file.txt
TREE=(`cat $FILE | awk -F, '{print $2}' | sort -n | uniq`)
DATE=(`cat $FILE | awk -F, '{print $4}'| sort -n | uniq`)
for x in ${TREE[@]};do
    echo $x
	cat $FILE | awk -F, 'BEGIN{OFS=","; print ("TREE","SUCCESS","FAILURE","TOTAL","SUCCESS_RATE","DATE");}
        {
        if ($3=="SUCCESS" && $2=="'$x'") suc=$1
        else if ($3=="FAILED" && $2=="'$x'") fail=$1
        else next
        total=suc+fail
        successrate=suc/total
        print ('$x',suc,fail,total,successrate,$4)
        }
        END{print "\n""======================""\n""Records Processed";
        }' >>summary2
	
done




