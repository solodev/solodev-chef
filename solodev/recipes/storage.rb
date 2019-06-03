StackName = node[:install][:StackName]
Region = node[:install][:Region]
ClientName = node[:install][:ClientName]
SoftwareName = node[:install][:SoftwareName]
DeploymentType = node[:install][:DeploymentType]
DocumentRoot = node[:install][:DocumentRoot]

template 'storage.sh' do
	path "/root/storage.sh"
	source 'storage.sh.erb'
	owner 'root'
	group 'root'
	mode 0700
end