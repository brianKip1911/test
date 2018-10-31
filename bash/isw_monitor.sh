#!/bin/bash
PATH=/telepin/TCS/log
cd $PATH
DATE=$(date +%d"-"%m"-"%y)
RECIPIENTS=msisdn_list.txt
PAYCODE_GEN='http://172.16.111.36:19090/api/v1/pwm/subscribers/'
PAYCODE_RED='http://172.16.111.36:19090/api/v1/cards/merchants/'
find . -name "*.log.*" -mmin -60 |xargs ggrep -B3 "Exception Read timed out" | grep "$DATE" >>out_file.txt
COUNT1=`cat out_file.txt | grep $PAYCODE_RED | wc -l`
COUNT2=`cat out_file.txt | grep $PAYCODE_GEN | wc -l`
if [ $COUNT1 -eq 0 ];
	then 
		exit 0
	else
		ERROR=`echo "Exception Read timed out" |sed 's/ /\+/g'`
		CHECK=`echo " $COUNT1 ISW Paycode Redemption Failing with the error "'$ERROR'""| sed 's/ /\+/g'`
		while read msisdn; do
                	curl "http://192.168.20.8:13013/cgi-bin/sendsms?username=tkinternal&password=1234&to="$msisdn"&from=25470050&text="${CHECK}""
        done < $RECIPIENTS
#               echo "exit"
fi
if [ $COUNT2 -eq 0 ];
	then 
		exit 0
	else
		ERROR=`echo "Exception Read timed out" |sed 's/ /\+/g'`
		CHECK=`echo " $COUNT2 ISW Paycode Generation Failing with the error "'$ERROR'""| sed 's/ /\+/g'`
		while read msisdn; do
                	curl "http://192.168.20.8:13013/cgi-bin/sendsms?username=tkinternal&password=1234&to="$msisdn"&from=25470050&text="${CHECK}""
        done < $RECIPIENTS
    
fi

