AWSAccessKeyId = node[:install][:AWSAccessKeyId]
AWSSecretKey = node[:install][:AWSSecretKey]
InstallBucketName = node[:install][:InstallBucketName]
ApacheConfDir = node[:install][:ApacheConfDir]

#Install Software
script "setup_scripts" do
	not_if { ::File.exists?("/root/tune_apache.sh") }
  interpreter "bash"
  user "root"
  cwd "/root"
  code <<-EOH
	
		#Download and install monitoring scripts
		wget http://ec2-downloads.s3.amazonaws.com/cloudwatch-samples/CloudWatchMonitoringScripts-v1.1.0.zip
		unzip CloudWatchMonitoringScripts-v1.1.0.zip
		rm CloudWatchMonitoringScripts-v1.1.0.zip	
		mkdir -p /root/aws-scripts-mon
		echo AWSAccessKeyId=#{AWSAccessKeyId} >> /root/aws-scripts-mon/awscreds.template
		echo AWSSecretKey=#{AWSSecretKey} >> /root/aws-scripts-mon/awscreds.template
  	
		#Create script to tune apache settings based on load
		aws s3 cp s3://#{InstallBucketName}/tune_apache.sh /root/tune_apache.sh
    chmod 700 /root/tune_apache.sh
    sed -i 's/\r//' tune_apache.sh
    ./root/tune_apache.sh
    sleep 10
		
		#Set Crontab
    (crontab -l 2>/dev/null; echo "*/5 * * * * /root/aws-scripts-mon/mon-put-instance-data.pl --mem-util --disk-space-util --disk-path=/ --from-cron --auto-scaling") | crontab -
    (crontab -l 2>/dev/null; echo "0 1,13 * * * /root/tune_apache.sh") | crontab -
    (crontab -l 2>/dev/null; echo "*/2 * * * * php /root/restart.php") | crontab -

  EOH
end