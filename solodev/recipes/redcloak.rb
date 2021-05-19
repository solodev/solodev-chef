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
        #{DocumentRoot}/#{SoftwareName}/clients/#{ClientName}/redcloak.sh
	EOH
end	