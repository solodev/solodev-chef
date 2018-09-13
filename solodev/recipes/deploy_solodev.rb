DocumentRoot = node[:install][:DocumentRoot]
SolodevUser = node[:install][:SolodevUser]
SolodevPassword = node[:install][:SolodevPassword]
SolodevWebsite = node[:install][:SolodevWebsite]
SolodevTheme = node[:install][:SolodevTheme]
SoftwareName = node[:install][:SoftwareName]
ClientName = node[:install][:ClientName]

#Backup Software
script "backup_software" do
	only_if  { ::File.exists?("#{DocumentRoot}/#{SoftwareName}/modules") }
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
		rm -Rf #{DocumentRoot}/#{SoftwareName}/license.php
	EOH
end

#Install Software
script "install_software" do
  interpreter "bash"
  user "root"
  cwd "/root"
  code <<-EOH
 
		#Make sure default html folder exists.  This will not be used.
		mkdir -p #{DocumentRoot}/html
		mkdir -p #{DocumentRoot}/#{SoftwareName}
	
		#Install Solodev CMS
		mkdir -p /root/Solodev
		fn="$(aws s3 ls s3://solodev-release | sort | tail -n 1 | awk '{print \$4}')"
		aws s3 cp s3://solodev-release/$fn /root/Solodev/Solodev.zip
		cd /root/Solodev
		unzip Solodev.zip
		rm -Rf Solodev.zip
		
		service httpd stop
		if [ -f /etc/init.d/php72-php-fpm ]; then
			service php72-php-fpm stop
		fi

		cd ..
		chown -Rf apache.apache Solodev
		chmod -Rf 2770 Solodev
		mv Solodev/modules #{DocumentRoot}/#{SoftwareName}/
		mv Solodev/core #{DocumentRoot}/#{SoftwareName}/
		mv Solodev/vendor #{DocumentRoot}/#{SoftwareName}/
		mv Solodev/license.php #{DocumentRoot}/#{SoftwareName}/
		mv Solodev/composer.json #{DocumentRoot}/#{SoftwareName}/
		mv Solodev/composer.lock #{DocumentRoot}/#{SoftwareName}/
		rm -Rf /root/Solodev
		
		service httpd start
		if [ -f /etc/init.d/php72-php-fpm ]; then
			service php72-php-fpm start
		fi
		
	EOH
end