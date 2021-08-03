VolumeName = node[:install][:VolumeName]
StackName = node[:install][:StackName]
Region = node[:install][:Region]
DocumentRoot = node[:install][:DocumentRoot]
InstallBucketName = node[:install][:InstallBucketName]
DBName = node[:install][:DBName]
DBHost = node[:install][:DBHost]
DBUser = node[:install][:DBUser]
DBPassword = node[:install][:DBPassword]
DeploymentType = node[:install][:DeploymentType]
SoftwareName = node[:install][:SoftwareName]
ClientName = node[:install][:ClientName]
MongoHost = node[:install][:MongoHost]

mount_path = "#{DocumentRoot}/#{SoftwareName}/clients/#{ClientName}"

Chef::Log.info(mount_path)

script "install_mysqldump" do
	not_if { ::File.exists?("/root/backupmysql.sh") }
	interpreter "bash"
	user "root"
	cwd "/root"
	code <<-EOH

		echo "#!/bin/bash" > /root/backupmysql.sh
		echo "# Example root cronjob:" >> /root/backupmysql.sh
		echo "# 0 5 * * * /root/backupmysql.sh >/dev/null 2>&1" >> /root/backupmysql.sh
		echo "# 1 day backup" >> /root/backupmysql.sh
		echo "PWD=#{mount_path}/dbdumps" >> /root/backupmysql.sh
		echo 'DBFILE=$PWD/databases.txt' >> /root/backupmysql.sh
		echo "# Remove old DBFILE" >> /root/backupmysql.sh
		echo 'rm -f $DBFILE' >> /root/backupmysql.sh
		echo "# Heavy Lifting" >> /root/backupmysql.sh
		echo '/usr/bin/mysql -h #{DBHost} -u #{DBUser} -p#{DBPassword} mysql -Ns -e "show databases" > $DBFILE' >> /root/backupmysql.sh
		echo 'for i in `cat $DBFILE` ; do mysqldump --opt --single-transaction -h #{DBHost} -u #{DBUser} -p#{DBPassword} $i > $PWD/$i.sql ; done' >> /root/backupmysql.sh
		echo "# Compress Backups" >> /root/backupmysql.sh
		echo 'for i in `cat $DBFILE` ; do gzip -f $PWD/$i.sql ; done' >> /root/backupmysql.sh
		echo "gunzip < #{mount_path}/dbdumps/#{DBName}.sql.gz | mysql -h #{DBHost} -u #{DBUser} -p#{DBPassword} #{DBName}" > /root/restoremysql.sh
		chmod 700 /root/backupmysql.sh /root/restoremysql.sh
		echo #{StackName} >> /root/stack.txt
		echo #{Region} >> /root/region.txt
		mkdir -p #{mount_path}/dbdumps
		(crontab -l 2>/dev/null; echo "30 3 * * 1-6 /root/backupmysql.sh") | crontab -

	EOH
end

script "install_mongo" do
	not_if { ::File.exists?("/root/restoremongo.sh") }
	interpreter "bash"
	user "root"
	cwd "/root"
	code <<-EOH

	touch /root/restoremongo.sh
	if((#{MongoHost} == "instance['private_ip']")); then
		echo "mongorestore --host \`mongo --quiet --eval \"db.isMaster()['primary']\"\` #{mount_path}/mongodumps > /root/restoremongo.log &" >> /root/restoremongo.sh
		echo "/root/heal_mongo.sh > /root/restore.log &" >> /root/restoremongo.sh
	else
		echo "mongorestore #{mount_path}/mongodumps > /root/restore.log &" >> /root/restoremongo.sh
		echo "rm -Rf #{mount_path}/stackname.txt && rm -Rf #{mount_path}/mongohosts.txt" >> /root/restoremongo.sh
	fi

	mkdir -p #{mount_path}/mongodumps
	touch /root/backupmongo.sh
	if((#{MongoHost} == "instance['private_ip']")); then
		echo "mongodump --host \`mongo --quiet --eval \"db.isMaster()['primary']\"\` --out #{mount_path}/mongodumps >/dev/null 2>&1" >> /root/backupmongo.sh
	else
		echo "mongodump --out #{mount_path}/mongodumps >/dev/null 2>&1" >> /root/backupmongo.sh
	fi

	chmod 700 /root/backupmongo.sh /root/restoremongo.sh
	(crontab -l 2>/dev/null; echo "30 3 * * 1-6 /root/backupmongo.sh") | crontab -
		
	EOH
end