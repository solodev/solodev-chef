DocumentRoot = node[:install][:DocumentRoot]
SoftwareName = node[:install][:SoftwareName]
ClientName = node[:install][:ClientName]
MongoHost = node[:install][:MongoHost]
ClientId = node[:install][:ClientId]
ClientSecret = node[:install][:ClientSecret]
StackName = node[:install][:StackName]

template '.env' do
	not_if { ::File.exists?("#{DocumentRoot}/#{SoftwareName}/clients/#{ClientName}/.env") }
  path "#{DocumentRoot}/#{SoftwareName}/clients/#{ClientName}/.env"
  variables( 
    MongoHost: "#{MongoHost}",
    ClientId: "#{ClientId}",
    ClientSecret: "#{ClientSecret}",
    StackName: "#{StackName}",
  )
  action :create
  source 'client.env.erb'
  owner 'apache'
  group 'apache'
  mode '0755'
end