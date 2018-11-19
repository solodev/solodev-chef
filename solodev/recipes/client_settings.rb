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

#Install JWT
script "install_JWT" do
  interpreter "bash"
  user "root"
  cwd "/root"
  code <<-EOH
 
    #Add PEM
    mkdir -p #{DocumentRoot}/#{SoftwareName}/clients/solodev/jwt
    openssl genrsa -passout pass:ocoa -out #{DocumentRoot}/#{SoftwareName}/clients/solodev/jwt/private.pem 4096
    openssl rsa -pubout -passin pass:ocoa -in #{DocumentRoot}/#{SoftwareName}/clients/solodev/jwt/private.pem -out #{DocumentRoot}/#{SoftwareName}/clients/solodev/jwt/public.pem
    chown -Rf apache.apache #{DocumentRoot}/#{SoftwareName}/clients/solodev/jwt
    chmod -Rf 2770 #{DocumentRoot}/#{SoftwareName}/clients/solodev/jwt
		
	EOH
end