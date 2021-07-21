VolumeName = node[:install][:VolumeName]
StackName = node[:install][:StackName]
Region = node[:install][:Region]
DocumentRoot = node[:install][:DocumentRoot]
AWSAccessKeyId = node[:install][:AWSAccessKeyId]
AWSSecretKey = node[:install][:AWSSecretKey]
RestoreBucketName = node[:install][:RestoreBucketName]
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
		echo "restoremongo --host \`mongo --quiet --eval \"db.isMaster()['primary']\"\` #{mount_path}/mongodumps > /root/restoremongo.log &" >> /root/restoremongo.sh
		echo "/root/heal_mongo.sh > /root/restore.log &" >> /root/restoremongo.sh
	else
		echo "restoremongo #{mount_path}/mongodumps > /root/restore.log &" >> /root/restoremongo.sh
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

# script "install_duplicity" do
# 	not_if { ::File.exists?("/root/restore.sh") }
# 	interpreter "bash"
# 	user "root"
# 	cwd "/root"
# 	code <<-EOH
		
# 		# Install Duplicy Filesystem Backups
# 		yum install -y duplicity duply python-boto mysql python-devel --enablerepo=epel
				
# 		duply backup create
# 		perl -pi -e 's/GPG_KEY/#GPG_KEY/g' /etc/duply/backup/conf
# 		perl -pi -e 's/GPG_PW/#GPG_PW/g' /etc/duply/backup/conf
# 		echo "GPG_PW='iYJQC1nt/CL7W+vi+t12WmqXpcI='" >> /etc/duply/backup/conf
# 		echo "TARGET='s3+http://#{StackName}-#{ClientName}/backups'" >> /etc/duply/backup/conf
# 		echo "TARGET_USER='#{AWSAccessKeyId}'" >> /etc/duply/backup/conf
# 		echo "TARGET_PASS='#{AWSSecretKey}'" >> /etc/duply/backup/conf
# 		echo "SOURCE='#{mount_path}'" >> /etc/duply/backup/conf
# 		echo "MAX_AGE='1W'" >> /etc/duply/backup/conf
# 		echo "MAX_FULL_BACKUPS='2'" >> /etc/duply/backup/conf
# 		echo "MAX_FULLBKP_AGE=1W" >> /etc/duply/backup/conf
# 		echo "VOLSIZE=100" >> /etc/duply/backup/conf
# 		echo 'DUPL_PARAMS="$DUPL_PARAMS --volsize $VOLSIZE --s3-use-new-style"' >> /etc/duply/backup/conf
# 		echo 'DUPL_PARAMS="$DUPL_PARAMS --full-if-older-than $MAX_FULLBKP_AGE"' >> /etc/duply/backup/conf
				
# 		# Restore Script
# 		echo "#!/bin/bash" >> /root/restore.sh
# 		echo "mv #{mount_path}/.env #{mount_path}/.env.bak" >> /root/restore.sh
# 		echo "sudo alternatives --install /usr/bin/python  python /usr/bin/python2.6 1" >> /root/restore.sh
# 		echo "sudo alternatives --set python /usr/bin/python2.6" >> /root/restore.sh
# 		echo "export PASSPHRASE=iYJQC1nt/CL7W+vi+t12WmqXpcI=" >> /root/restore.sh
# 		echo "duplicity --force -v8 restore s3+http://#{StackName}-#{ClientName}/backups/ #{mount_path} > /root/restore.log" >> /root/restore.sh
# 		echo "chmod -Rf 2770 #{mount_path}" >> /root/restore.sh
# 		echo "chown -Rf apache.apache #{mount_path}" >> /root/restore.sh
# 		echo "gunzip < #{mount_path}/dbdumps/#{DBName}.sql.gz | mysql -h #{DBHost} -u #{DBUser} -p#{DBPassword} #{DBName}" >> /root/restore.sh
# 		echo "rm -f #{mount_path}/.env" >> /root/restore.sh
# 		echo "mv #{mount_path}/.env.bak #{mount_path}/.env" >> /root/restore.sh

# 		echo "sudo alternatives --remove python /usr/bin/python2.6" >> /root/restore.sh
# 		chmod 700 /root/restore.sh
				
# 		echo "/root/backupmysql.sh >/dev/null 2>&1" >> /etc/duply/backup/pre

# 		echo "sudo alternatives --install /usr/bin/python  python /usr/bin/python2.6 1" >> /etc/duply/backup/pre
# 		echo "sudo alternatives --set python /usr/bin/python2.6" >> /etc/duply/backup/pre
# 		echo "sudo alternatives --remove python /usr/bin/python2.6" >> /etc/duply/backup/post

# 		(crontab -l 2>/dev/null; echo "30 3 * * 1-6 duply backup backup") | crontab -
# 		(crontab -l 2>/dev/null; echo "30 13 * * * duply backup backup") | crontab -
# 		(crontab -l 2>/dev/null; echo "30 3 * * 0 duply backup full_purge --force") | crontab -
	
# 		echo "sudo alternatives --install /usr/bin/python  python /usr/bin/python2.6 1" >> /root/backup.sh
# 		echo "sudo alternatives --set python /usr/bin/python2.6" >> /root/backup.sh
# 		echo "sudo duply backup full" >> /root/backup.sh
# 		echo "sudo duply backup cleanup" >> /root/backup.sh
# 		echo "sudo duply backup status" >> /root/backup.sh
# 		echo "sudo alternatives --remove python /usr/bin/python2.6" >> /root/backup.sh

# 		chmod 700 /root/backup.sh		
		
# 	EOH
end