AWSAccessKeyId = node[:install][:AWSAccessKeyId]
AWSSecretKey = node[:install][:AWSSecretKey]
InstallBucketName = node[:install][:InstallBucketName]

#Install Software
script "setup_scripts" do
	not_if { ::File.exists?("/root/tune_apache.sh") }
  interpreter "bash"
  user "root"
  cwd "/root"
  code <<-EOH
	
		#Download and install monitoring scripts
    wget http://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.1.zip
    unzip CloudWatchMonitoringScripts-1.2.1.zip
    rm -f CloudWatchMonitoringScripts-1.2.1.zip
		mkdir -p /root/aws-scripts-mon
		echo AWSAccessKeyId=#{AWSAccessKeyId} >> /root/aws-scripts-mon/awscreds.template
    echo AWSSecretKey=#{AWSSecretKey} >> /root/aws-scripts-mon/awscreds.template
    
    #Install SSM
    yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
  	
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
    (crontab -l 2>/dev/null; echo "0,15,30,45 * * * * /root/check.sh") | crontab -

  EOH
end