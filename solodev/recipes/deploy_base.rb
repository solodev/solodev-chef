DocumentRoot = node[:install][:DocumentRoot]
SoftwareName = node[:install][:SoftwareName]
ClientName = node[:install][:ClientName]

directory DocumentRoot+'/'+SoftwareName+'/clients/'+ClientName+'/Vhosts' do
	not_if do ::File.exists?("#{DocumentRoot}/#{SoftwareName}/clients/#{ClientName}/Vhosts") end
  owner 'apache'
  group 'apache'
  mode '0755'
  recursive true
  ignore_failure true
  action :create
end

directory DocumentRoot+'/'+SoftwareName+'/clients/'+ClientName+'/s.Vhosts' do
	not_if do ::File.exists?("#{DocumentRoot}/#{SoftwareName}/clients/#{ClientName}/s.Vhosts") end
  owner 'apache'
  group 'apache'
  mode '0755'
  recursive true
  ignore_failure true
  action :create
end

directory DocumentRoot+'/'+SoftwareName+'/clients/'+ClientName+'/Websites' do
	not_if do ::File.exists?("#{DocumentRoot}/#{SoftwareName}/clients/#{ClientName}/Websites") end
  owner 'apache'
  group 'apache'
  mode '0755'
  recursive true
  ignore_failure true
  action :create
end

directory DocumentRoot+'/'+SoftwareName+'/clients/'+ClientName+'/Main' do
	not_if do ::File.exists?("#{DocumentRoot}/#{SoftwareName}/clients/#{ClientName}/Main") end
  owner 'apache'
  group 'apache'
  mode '0755'
  recursive true
  ignore_failure true
  action :create
end