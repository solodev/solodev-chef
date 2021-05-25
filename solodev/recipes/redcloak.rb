DocumentRoot = node[:install][:DocumentRoot]
SoftwareName = node[:install][:SoftwareName]
ClientName = node[:install][:ClientName]

#redcloak
script "redcloak" do
	only_if  { ::File.exists?("#{DocumentRoot}/#{SoftwareName}/clients/#{ClientName}/redcloak.sh")}
	interpreter "bash"
	user "root"
	cwd "/root"
	code <<-EOH
		echo "Start Redcloak"
        #{DocumentRoot}/#{SoftwareName}/clients/#{ClientName}/redcloak.sh
		echo "End Redcloak"
	EOH
end	