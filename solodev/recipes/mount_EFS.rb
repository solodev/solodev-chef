EFSHost = node[:install][:EFSHost]
VolumeName = node[:install][:VolumeName]
StackName = node[:install][:StackName]
Region = node[:install][:Region]
DocumentRoot = node[:install][:DocumentRoot]
SoftwareName = node[:install][:SoftwareName]
ClientName = node[:install][:ClientName]

#Mount Client Brick
script "mount_client" do
	not_if { ::File.exists?("/home/ec2-user/efs") }
  interpreter "bash"
  user "root"
  cwd "/root"
  code <<-EOH
  
	yum -y nfs-utils
	mkdir -p #{DocumentRoot}/#{SoftwareName}/clients/#{ClientName}
	
	mount -t nfs4 -o nfsvers=4.1 $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone).#{EFSHost}.efs.#{Region}.amazonaws.com:/ #{DocumentRoot}/#{SoftwareName}/clients/#{ClientName}     
	echo "$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone).#{EFSHost}.efs.#{Region}.amazonaws.com:/ #{DocumentRoot}/#{SoftwareName}/clients/#{ClientName} nfs defaults 0 0" >> /etc/fstab
	
	chown -f apache.apache #{DocumentRoot}/#{SoftwareName}/clients/#{ClientName}
	chmod -f 2770 #{DocumentRoot}/#{SoftwareName}/clients/#{ClientName}
	
	touch /home/ec2-user/efs

  EOH
end