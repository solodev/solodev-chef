Chef::Log.level = :debug
REPLICAS=()
ARBITERS=()
BADHOSTS=()
StackName = node[:install][:StackName]
Region = node[:install][:Region]
ClientName = node[:install][:ClientName]
SoftwareName = node[:install][:SoftwareName]
DeploymentType = node[:install][:DeploymentType]
DocumentRoot = node[:install][:DocumentRoot]

template 'heal_mongo.sh' do
	path "/root/heal_mongo.sh"
	source 'heal_mongo.sh.erb'
	owner 'root'
	group 'root'
	mode 0700
end

#Install Software
script "heal_mongo" do
  interpreter "bash"
  user "root"
  cwd "/root"
  code <<-EOH

	#!/bin/bash

	in_array() {
	    local haystack=${1}[@]
	    local needle=${2}
	    for i in ${!haystack}; do
	        if [[ ${i} == ${needle} ]]; then
	            return 0
	        fi
	    done
	    return 1
	}

	#Add buffer to wait for servers to go out of service.
	echo "Heal Mongo Cluster" >> /root/mongo-init.log
	sleep 50

	AWSHOSTS=$(aws ec2 describe-instances --region #{Region} --filter Name=instance-state-name,Values=running Name=tag-key,Values='opsworks:layer:#{ClientName}-web' Name=tag-value,Values='#{DeploymentType}' Name=tag-key,Values='opsworks:stack' Name=tag-value,Values='#{StackName}' --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text)
	aws ec2 describe-instances --region #{Region} --filter Name=instance-state-name,Values=running Name=tag-key,Values='opsworks:layer:#{ClientName}-web' Name=tag-value,Values='#{DeploymentType}' Name=tag-key,Values='opsworks:stack' Name=tag-value,Values='#{StackName}' --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text > #{DocumentRoot}/#{SoftwareName}/clients/#{client_name}/mongohosts.txt
	echo "#{StackName}" > #{DocumentRoot}/#{SoftwareName}/clients/#{ClientName}/stackname.txt

	#Loop through status and get ids
	IDS=()
	for id in `echo 'rs.status()' | mongo | egrep "_id" | awk -F : '{print $2}'| cut -f 1 -d ,`; do 
		echo $id
		IDS=(${IDS[@]} "$id")
	done 

	## Check whether host is slave and in good state 
	HOSTCOUNT=0
	for i in `echo 'rs.status()' | mongo | egrep "name" | awk -F \\" '{print $4}'| cut -f 1 -d :`; do 
		echo $i
		TheState=$(echo 'rs.status()'| mongo --host $i | grep -i mystate | awk -F : '{print $2}' | cut -f 1 -d ,) 
		
		CURRENT_ID=${IDS[$HOSTCOUNT]}
		
		if [ $TheState ]; then 
			echo '$i is accessible.'
			
			#Add into available replicas array
			host=$(echo $i | sed -r 's/ip-//g' | sed -r 's/-/\./g')
			
			#Test if master
			IsMaster=$(echo 'db.isMaster()'| mongo --host $i | grep ismaster| awk -F : '{print $2}' | cut -f 1 -d ,)
			if [ $IsMaster == "true" ]; then 
				echo '$i is Master.'
				REPLICAS[$CURRENT_ID]=$host
				MASTER=$host
			elif [ $TheState == "7" ]; then 
				ARBITERS[$CURRENT_ID]=$host
			else
				echo '$i is Slave.'
				REPLICAS[$CURRENT_ID]=$host
				REPLICA=$host
			fi
		else
			echo '$i not accessible.  Remove from Replica'
			
			#Add into remove replicas array
			BADHOSTS=(${BADHOSTS[@]} $i)
		fi 
		
		HOSTCOUNT=$((HOSTCOUNT+1))
	done 

	if [ $MASTER ]; then
		MONGOHOST=$MASTER
	else
		MONGOHOST=$REPLICA
	fi

	#echo "${REPLICAS[@]}"
	#Check available hosts to see if we have new available replicas to add
	HOSTID=$((CURRENT_ID+1))
	set -- junk $AWSHOSTS
	shift
	for host; do
		if in_array REPLICAS "$host"; then 
			echo '$host is already a replica'
		else 
			echo '$host is not a replica. Add host into available replicas'
			REPLICAS[$HOSTID]=$host
			HOSTID=$((HOSTID+1))
			ADDHOSTS=1
		fi
	done

	rm -Rf /root/mongoconfig.js
	echo -ne 'config = {' > /root/mongoconfig.js
	echo -ne '"_id" : "'#{StackName}'", ' >> /root/mongoconfig.js
	echo -ne '"members" : [' >> /root/mongoconfig.js
	REPLICACOUNT=0
	#Loop through available replicas and reconfigure mongo replica group

	for id in "${!REPLICAS[@]}"; do
		if [ $REPLICACOUNT -gt "0" ]; then
			echo -ne ', ' >> /root/mongoconfig.js
		fi
		echo -ne '{"_id" : '$id', "host" : "'${REPLICAS[$id]}':27017"}' >> /root/mongoconfig.js
		REPLICACOUNT=$((REPLICACOUNT+1))
	done

	for id in "${!ARBITERS[@]}"; do
		if [ $REPLICACOUNT -gt "0" ]; then
			echo -ne ', ' >> /root/mongoconfig.js
		fi
		echo -ne '{"_id" : '$id', "host" : "'${ARBITERS[$id]}':27017", "arbiterOnly" : true}' >> /root/mongoconfig.js
		REPLICACOUNT=$((REPLICACOUNT+1))
	done

	echo -ne ']' >> /root/mongoconfig.js
	echo '}' >> /root/mongoconfig.js
	echo 'config.protocolVersion=1;' >> /root/mongoconfig.js
	echo 'rs.reconfig(config, {force : true})' >> /root/mongoconfig.js
	echo 'rs.slaveOk()' >> /root/mongoconfig.js

	if [ $BADHOSTS ] || [ $ADDHOSTS ]; then 
		mongo --host $MONGOHOST < /root/mongoconfig.js &>> /root/mongo-init.log
	fi

	service mongod stop
	service mongod start

	exit 0

  EOH
end