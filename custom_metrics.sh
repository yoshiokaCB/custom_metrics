#!/bin/bash

export JAVA_HOME=/usr/lib/jvm/jre
export AWS_CLOUDWATCH_HOME=/opt/aws/apitools/mon
export EC2_REGION=ap-northeast-1
# If you use ubuntu servers, you must set below
# export JAVA_HOME=/usr/lib/jvm/default-java/jre
# export EC2_REGION=ap-northeast-1
# export AWS_CREDENTIAL_FILE=/home/ubuntu/cloudwatch/credentia

export AWS_CREDENTIAL_FILE=/home/ec2-user/cloudwatch/credential
instanceid=i-****

# http status check
domain_list="/home/ec2-user/cloudwatch/domain_list.txt"
IFS=$'\n'
domain_ary=(`cat "$domain_list"`)
for domain in ${domain_ary[@]}
do
  status=`/home/ec2-user/cloudwatch/http_status_check.sh "http://$domain"` # You must set the URI to check the web site.
  if [ $status -eq 200 ]; then
    Fail=0
  else
    Fail=1
  fi
  /opt/aws/bin/mon-put-data --metric-name "Http Status fail $domain" --namespace "Custom Metrix" --dimensions "InstanceId=$instanceid" --value "$Fail" --unit "Count"
done

# CPU idle percent
cpuidle=`vmstat | tail -n 1 | tr -s ' ' | cut -d ' ' -f 16`
/opt/aws/bin/mon-put-data --metric-name "CpuIdlePercent" --namespace "Custom Metrix" --dimensions "InstanceId=$instanceid" --value "$cpuidle" --unit "Percent"

# memory check
memtotal=`free -m | grep 'Mem' | tr -s ' ' | cut -d ' ' -f 2`
memfree=`free -m | grep 'buffers/cache' | tr -s ' ' | cut -d ' ' -f 4`
let "memused=100-memfree*100/memtotal"
/opt/aws/bin/mon-put-data --metric-name "FreeMemoryMBytes" --namespace "Custom Metrix" --dimensions "InstanceId=$instanceid" --value "$memfree" --unit "Megabytes"
/opt/aws/bin/mon-put-data --metric-name "UsedMemoryPercent" --namespace "Custom Metrix" --dimensions "InstanceId=$instanceid" --value "$memused" --unit "Percent"

# loadaverage check
loadave1=`uptime | tr -s ' ' | cut -d ' ' -f 11 | cut -d ',' -f 1`
/opt/aws/bin/mon-put-data --metric-name "LoadAverage" --namespace "Custom Metrix" --dimensions "InstanceId=$instanceid" --value "$loadave1" --unit "Count"

# Get percentage of quantity of filesysytem
usediskpercent=`/home/ec2-user/cloudwatch/get_filesystem_percent.sh /dev/xvda1` # You must set the filesystem.
/opt/aws/bin/mon-put-data --metric-name "DiskUsagePercent" --namespace "Custom Metrix" --dimensions "InstanceId=$instanceid" --value "$usediskpercent" --unit "Percent"

# Get percentage of quantity of filesysytem
remaindisk=`/home/ec2-user/cloudwatch/get_filesystem_remain.sh /dev/xvda1` # You must set the filesystem.
/opt/aws/bin/mon-put-data --metric-name "RemainDiskQuantity" --namespace "Custom Metrix" --dimensions "InstanceId=$instanceid" --value "$remaindisk" --unit "Megabytes"
