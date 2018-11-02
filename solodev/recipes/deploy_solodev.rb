DocumentRoot = node[:install][:DocumentRoot]
SolodevUser = node[:install][:SolodevUser]
SolodevPassword = node[:install][:SolodevPassword]
SolodevWebsite = node[:install][:SolodevWebsite]
SolodevTheme = node[:install][:SolodevTheme]
SoftwareName = node[:install][:SoftwareName]
ClientName = node[:install][:ClientName]
EnterpriseMode = node[:install][:EnterpriseMode]

#Backup Software
script "backup_software" do
	only_if  { ::File.exists?("#{DocumentRoot}/#{SoftwareName}/modules") && "#{EnterpriseMode}" == "True"}
	interpreter "bash"
	user "root"
	cwd "/root"
	code <<-EOH
		rm -Rf #{DocumentRoot}/#{SoftwareName}/old
		mkdir "#{DocumentRoot}/#{SoftwareName}/old"
		mv #{DocumentRoot}/#{SoftwareName}/modules #{DocumentRoot}/#{SoftwareName}/old/
		mv #{DocumentRoot}/#{SoftwareName}/core #{DocumentRoot}/#{SoftwareName}/old/
		mv #{DocumentRoot}/#{SoftwareName}/vendor #{DocumentRoot}/#{SoftwareName}/old/
		mv #{DocumentRoot}/#{SoftwareName}/composer.json #{DocumentRoot}/#{SoftwareName}/old/
		mv #{DocumentRoot}/#{SoftwareName}/composer.lock #{DocumentRoot}/#{SoftwareName}/old/
		mv #{DocumentRoot}/#{SoftwareName}/version.txt #{DocumentRoot}/#{SoftwareName}/old/
		mv #{DocumentRoot}/#{SoftwareName}/public #{DocumentRoot}/#{SoftwareName}/old/
	EOH
end

#Install Software
script "install_software" do
  only_if  { "#{EnterpriseMode}" == "True"}
  interpreter "bash"
  user "root"
  cwd "/root"
  code <<-EOH
 
		#Make sure default html folder exists.  This will not be used.
		mkdir -p #{DocumentRoot}/html
		mkdir -p #{DocumentRoot}/#{SoftwareName}
	
		#Install Solodev CMS
		mkdir -p /root/solodev
		fn="$(aws s3 ls s3://solodev-release | sort | tail -n 1 | awk '{print \$4}')"
		aws s3 cp s3://solodev-release/$fn /root/solodev/Solodev.zip
		cd /root/solodev
		unzip Solodev.zip
		rm -Rf Solodev.zip
		
		service httpd stop
		if [ -f /etc/init.d/php72-php-fpm ]; then
			service php72-php-fpm stop
		fi

		cd ..
		chown -Rf apache.apache solodev
		chmod -Rf 2770 solodev
		mv solodev/modules #{DocumentRoot}/#{SoftwareName}/
		mv solodev/core #{DocumentRoot}/#{SoftwareName}/
		mv solodev/vendor #{DocumentRoot}/#{SoftwareName}/
		mv solodev/public #{DocumentRoot}/#{SoftwareName}/
		mv solodev/composer.json #{DocumentRoot}/#{SoftwareName}/
		mv solodev/composer.lock #{DocumentRoot}/#{SoftwareName}/
		mv solodev/version.txt #{DocumentRoot}/#{SoftwareName}/
		rm -Rf /root/solodev

		service httpd start
		if [ -f /etc/init.d/php72-php-fpm ]; then
			service php72-php-fpm start
		fi
		
	EOH
end

script "restart_web" do
    interpreter "bash"
    user "root"
    cwd "/root"
    code <<-EOH

		mkdir -p #{DocumentRoot}/#{SoftwareName}/tmp
		chmod 777 #{DocumentRoot}/#{SoftwareName}/tmp

        if [ -f /etc/init.d/httpd ]; then
            service httpd restart
        fi

    EOH
end