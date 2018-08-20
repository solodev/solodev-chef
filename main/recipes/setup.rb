conf_available_dir = node[:apache][:conf_available_dir]

node[:deploy].each do |app_name, deploy|
	#Base Server Setup
	script "base_setup" do
		not_if { ::File.exists?("/root/mkswap.txt") }
		interpreter "bash"
		user "root"
		cwd "/root"
	  code <<-EOH
			
			chkconfig ntpd on
			service ntpd start
			
			# Add Swap
			touch /root/mkswap.txt
      /bin/dd if=/dev/zero of=/mnt/swapfile bs=1M count=2048
			chown root:root /mnt/swapfile
			chmod 600 /mnt/swapfile
			/sbin/mkswap /mnt/swapfile
			/sbin/swapon /mnt/swapfile
			
	  EOH
end