DocumentRoot = node[:install][:DocumentRoot]
SoftwareName = node[:install][:SoftwareName]
ClientName = node[:install][:ClientName]
MongoHost = node[:install][:MongoHost]

template 'Client_Settings.xml' do
	not_if { ::File.exists?("#{DocumentRoot}/#{SoftwareName}/clients/#{ClientName}/Client_Settings.xml") }
  path "#{DocumentRoot}/#{SoftwareName}/clients/#{ClientName}/Client_Settings.xml"
  variables( 
  	MongoHost: "#{MongoHost}"
  )
  action :create
  source 'Client_Settings.xml.erb'
  mode '0755'
end