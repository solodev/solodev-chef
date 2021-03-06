DocumentRoot = node[:install][:DocumentRoot]
SolodevUser = node[:install][:SolodevUser]
SolodevPassword = node[:install][:SolodevPassword]
SolodevWebsite = node[:install][:SolodevWebsite]
SolodevTheme = node[:install][:SolodevTheme]
SoftwareName = node[:install][:SoftwareName]

#Update Software
script "update_software" do
    interpreter "bash"
    user "apache"
    group 'apache'
    cwd "#{DocumentRoot}/#{SoftwareName}"
    code <<-EOH

        echo "php #{DocumentRoot}/#{SoftwareName}/core/update.php #{SolodevUser} #{SolodevPassword}" >> #{DocumentRoot}/#{SoftwareName}/clients/solodev/phpinstall.log
        php #{DocumentRoot}/#{SoftwareName}/core/update.php #{SolodevUser} #{SolodevPassword}  >> #{DocumentRoot}/#{SoftwareName}/clients/solodev/phpinstall.log
        cd #{DocumentRoot}/#{SoftwareName}/clients/solodev/Main
        chmod -f 2770 *

    EOH
end

#Install JWT
script "install_JWT" do
	interpreter "bash"
	not_if { ::File.exists?("#{DocumentRoot}/#{SoftwareName}/clients/solodev/jwt/private.pem") }
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