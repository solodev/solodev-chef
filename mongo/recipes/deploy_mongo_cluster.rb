Region = node[:install][:Region]
StackName = node[:install][:StackName]
DBUser = node[:install][:DBUser]
DBPassword = node[:install][:DBPassword]
DeploymentType = node[:install][:DeploymentType]
DocumentRoot = node[:install][:DocumentRoot]
SoftwareName = node[:install][:SoftwareName]
ClientName = node[:install][:ClientName]

script "configure_mongo" do
	not_if { ::File.exists?("/root/mongo.lock") }
	interpreter "bash"
	user "root"
	cwd "/root"
	code <<-EOH
	
		aws ec2 describe-instances --region #{Region} --filter Name=tag-key,Values='opsworks:layer:solodev-web' Name=tag-value,Values='#{DeploymentType}' Name=tag-key,Values='opsworks:stack' Name=tag-value,Values='#{StackName}' --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text > #{DocumentRoot}/#{software_name}/clients/#{client_name}/mongohosts.txt

		MASTER=$(wget -O- -q http://169.254.169.254/latest/meta-data/local-ipv4)
		declare -i i=0
		while read host; do
		hosts[i]="$host"
		let i++
		done < #{DocumentRoot}/#{SoftwareName}/clients/#{ClientName}/mongohosts.txt

		echo 'Deploy Mongo Cluster' > /root/mongo-init.log
		echo 'rs.initiate()' | mongo --host ${hosts[0]} &>> /root/mongo-init.log
		sleep 20

		echo 'rs.add("'${hosts[1]}'")' | mongo --host ${hosts[0]} &>> /root/mongo-init.log
		echo 'rs.addArb("'$MASTER'")' | mongo --host ${hosts[0]} &>> /root/mongo-init.log
		echo 'rs.status()' | mongo --host ${hosts[0]} &>> /root/mongo-init.log
		sleep 20

		touch /root/mongo.lock
		echo 'cfg = rs.conf()' >> /root/mongouser.js
		echo 'cfg.members[0].host = "'${hosts[0]}':27017"' >> /root/mongouser.js
		echo 'cfg.protocolVersion=1;' >> /root/mongoconfig.js
		echo 'rs.reconfig(cfg)' >> /root/mongouser.js
		echo 'rs.slaveOk()' >> /root/mongoconfig.js
		echo 'use solodev_views;' >> /root/mongouser.js
		echo 'db.createUser({"user": "#{DBUser}", "pwd": "#{DBPassword}", "roles": [ { role: "readWrite", db: "solodev_views" } ] })' >> /root/mongouser.js 
		mongo --host ${hosts[0]} < /root/mongouser.js &>> /root/mongo-init.log
		rm -Rf /root/mongouser.js

		service mongod stop
		service mongod start
				
	EOH
	flags "-x"
end