document_root = node[:install][:document_root]
software_name = node[:install][:software_name]
client_name = node[:install][:client_name]

directory document_root+'/'+software_name+'/clients/'+client_name+'/Vhosts' do
	not_if do ::File.exists?("#{document_root}/#{software_name}/clients/#{client_name}/Vhosts") end
  owner 'apache'
  group 'apache'
  mode '0755'
  recursive true
  ignore_failure true
  action :create
end

directory document_root+'/'+software_name+'/clients/'+client_name+'/s.Vhosts' do
	not_if do ::File.exists?("#{document_root}/#{software_name}/clients/#{client_name}/s.Vhosts") end
  owner 'apache'
  group 'apache'
  mode '0755'
  recursive true
  ignore_failure true
  action :create
end