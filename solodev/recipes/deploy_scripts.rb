template 'tune_apache.sh' do
	path '/root/tune_apache.sh'
	source 'tune_apache.sh.erb'
	owner 'root'
	group 'root'
	mode 0700
end

#Install Software
script "setup_scripts" do
	not_if { ::File.exists?("/root/init.txt") }
  interpreter "bash"
  user "root"
  cwd "/root"
  code <<-EOH
  
    #Download and install monitoring scripts
    touch /root/init.txt
    
    #Install SSM
    yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
		
		#Set Crontab
    (crontab -l 2>/dev/null; echo "0 1,13 * * * /root/tune_apache.sh") | crontab -
    (crontab -l 2>/dev/null; echo "*/2 * * * * php /root/restart.php") | crontab -
    (crontab -l 2>/dev/null; echo "0,15,30,45 * * * * /root/check.sh") | crontab -
  
  EOH
end