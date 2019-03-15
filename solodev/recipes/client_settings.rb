DocumentRoot = node[:install][:DocumentRoot]
SoftwareName = node[:install][:SoftwareName]
ClientName = node[:install][:ClientName]
MongoHost = node[:install][:MongoHost]

template '.env' do
	not_if { ::File.exists?("#{DocumentRoot}/#{SoftwareName}/clients/#{ClientName}/.env") }
  path "#{DocumentRoot}/#{SoftwareName}/clients/#{ClientName}/.env"
  variables( 
  	MongoHost: "#{MongoHost}"
  )
  action :create
  source 'client.env.erb'
  owner 'apache'
  group 'apache'
  mode '0755'
end