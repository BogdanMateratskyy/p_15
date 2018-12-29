#!/bin/bash

user=$(whoami)
host=$(hostname)

logTemplate='{"datetime":"%s","user":"%s","host":"%s","cpuInfo":{"user":"%s","nice":"%s","system":"%s","idle":"%s","iowait":"%s","irq":"%s","softirq":"%s","steal":"%s"},"cpuUsage":"%s","status":"%s"}'

createFile(){
    local datetime=$(date +%s)
    local fileName="${datetime}_${host}.json"    
	
    touch $fileName    

    generateCpuInfo $fileName
}

generateCpuInfo(){
	local dateForm=$(date +%F" "%H:%M:%S)
	local userMod=`cat /proc/stat | grep -Ew ^cpu |gawk '{print $2}'`
	local nice=`cat /proc/stat | grep -Ew ^cpu |gawk '{print $3}'`
	local system=`cat /proc/stat | grep -Ew ^cpu |gawk '{print $4}'`
	local idle=`cat /proc/stat | grep -Ew ^cpu |gawk '{print $5}'`
	local iowait=`cat /proc/stat | grep -Ew ^cpu |gawk '{print $6}'`
	local irq=`cat /proc/stat | grep -Ew ^cpu |gawk '{print $7}'`
	local softirq=`cat /proc/stat | grep -Ew ^cpu |gawk '{print $8}'`
	local steal=`cat /proc/stat | grep -Ew ^cpu |gawk '{print $9}'`
	local TotalCpuTimeSinceBoot=`cat /proc/stat | grep -Ew ^cpu |gawk '{print $2+$3+$4+$5+$6+$7+$8+$9}'`
	local TotalCpuIdleTimeSinceBoot=`cat /proc/stat | grep -Ew ^cpu |gawk '{print $5+$6}'`
	local TotalCpuUsageTimeSinceBoot=$(($TotalCpuTimeSinceBoot-$TotalCpuIdleTimeSinceBoot))
	local cpuUsage=$(($TotalCpuUsageTimeSinceBoot/$TotalCpuTimeSinceBoot*100))
	
	if [ $cpuUsage -gt 50 ]; then
		local status="CRITICAL"
	else 
		local status="NORMAL"
	fi

    local infoJsonF=$(printf "$logTemplate" "$dateForm" "$user" "$host" "$userMod" "$nice" "$system" "$idle" "$iowait" "$irq" "$softirq" "$steal" "$cpuUsage" "$status")
    
    echo $infoJsonF > $1
    
    if [ $? -eq 0 ]; then
   	 echo "===> $(date) log $1 created"
    else
   	 echo "===> $(date) something wrong"
    fi
}

count=0
while true; do
    
    if [ $count -lt 10 ]; then
	createFile
	count=$((count + 1))
    else 
	tar -czvf "archive_$(date +%s).tar.gz" *.json
	rm *.json 
	count=0
    fi
    sleep 2s
done


