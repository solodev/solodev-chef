DocumentRoot = node[:install][:DocumentRoot]
SolodevUser = node[:install][:SolodevUser]
SolodevPassword = node[:install][:SolodevPassword]
SolodevWebsite = node[:install][:SolodevWebsite]
SolodevTheme = node[:install][:SolodevTheme]
SoftwareName = node[:install][:SoftwareName]
ClientName = node[:install][:ClientName]
EnterpriseMode = node[:install][:EnterpriseMode]
ApacheConfDir = node[:install][:ApacheConfDir]
CMSVersion = node[:install][:CMSVersion]

if(File.exist?('/etc/opt/remi/php74/php-fpm.conf'))
	PHPVersion  = '74'
	PHPVersionLong = '7.4'
else
	PHPVersion = '72'
	PHPVersionLong  = '7.2'
end

script "stop_web" do
    interpreter "bash"
    user "root"
    cwd "/root"
    code <<-EOH
		service httpd stop
		service php#{PHPVersion}-php-fpm stop
    EOH
end

#Update NPM
script "update_npm" do
    interpreter "bash"
    user "root"
    cwd "/root"
    code <<-EOH
		npm install --unsafe-perm -g node-sass
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
		if [ "#{CMSVersion}" = "" ]; then
			file="$(aws s3 ls s3://solodev-release | sort | tail -n 1 | awk '{print \$4}')"
		else
			file="solodev-v#{CMSVersion}.zip"
		fi
		aws s3 cp s3://solodev-release/$file /root/solodev/Solodev.zip
	EOH
end

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
		mv #{DocumentRoot}/#{SoftwareName}/connectors #{DocumentRoot}/#{SoftwareName}/old/
		mv #{DocumentRoot}/#{SoftwareName}/core #{DocumentRoot}/#{SoftwareName}/old/
		mv #{DocumentRoot}/#{SoftwareName}/vendor #{DocumentRoot}/#{SoftwareName}/old/
		mv #{DocumentRoot}/#{SoftwareName}/composer.json #{DocumentRoot}/#{SoftwareName}/old/
		mv #{DocumentRoot}/#{SoftwareName}/composer.lock #{DocumentRoot}/#{SoftwareName}/old/
		mv #{DocumentRoot}/#{SoftwareName}/version.txt #{DocumentRoot}/#{SoftwareName}/old/
		mv #{DocumentRoot}/#{SoftwareName}/license.txt #{DocumentRoot}/#{SoftwareName}/old/
		mv #{DocumentRoot}/#{SoftwareName}/public #{DocumentRoot}/#{SoftwareName}/old/
	EOH
end	

#Update Software
script "update_software" do
  only_if  { "#{EnterpriseMode}" == "True"}
  interpreter "bash"
  user "root"
  cwd "/root"
  code <<-EOH
		cd /root/solodev
		unzip Solodev.zip
		rm -Rf Solodev.zip

		cd ..
		chown -Rf apache.apache solodev
		chmod -Rf 2770 solodev
		mv solodev/modules #{DocumentRoot}/#{SoftwareName}/
		mv solodev/connectors #{DocumentRoot}/#{SoftwareName}/
		mv solodev/core #{DocumentRoot}/#{SoftwareName}/
		mv solodev/vendor #{DocumentRoot}/#{SoftwareName}/
		mv solodev/public #{DocumentRoot}/#{SoftwareName}/
		mv solodev/resolve #{DocumentRoot}/#{SoftwareName}/
		mv solodev/composer.json #{DocumentRoot}/#{SoftwareName}/
		mv solodev/composer.lock #{DocumentRoot}/#{SoftwareName}/
		mv solodev/version.txt #{DocumentRoot}/#{SoftwareName}/
		mv solodev/license.txt #{DocumentRoot}/#{SoftwareName}/
		rm -Rf /root/solodev
		cd #{DocumentRoot}
		ln -sf #{DocumentRoot}/#{SoftwareName} Solodev
	EOH
end

#Install restart.php
template 'restart.php' do
	path '/root/restart.php'
	source 'restart.php.erb'
	owner 'root'
	group 'root'
	mode 0644
end

#Install CMS Apache conf
template 'solodev.conf' do
	path ApacheConfDir+'/solodev.conf'
	source 'solodev.conf.erb'
	owner 'root'
	group 'root'
	mode 0644
end

#Install Check
template 'check.sh' do
	path '/root/check.sh'
	source 'check.sh.erb'
	owner 'root'
	group 'root'
	mode 0700
end

#Update PHP 
template 'php-fpm.conf' do
	variables(
    	'PHPVersion': PHPVersion
  	)
	path "/etc/opt/remi/php#{PHPVersion}/php-fpm.d/www.conf"
	source 'php-fpm.conf.erb'
	owner 'root'
	group 'root'
	mode 0700
end

#Update PHP.INI
template 'php.ini' do
	variables(
    	'PHPVersion': PHPVersion,
		'PHPVersionLong': PHPVersionLong
  	)
	path "/etc/opt/remi/php#{PHPVersion}/php.ini"
	source 'php.ini.erb'
	owner 'root'
	group 'root'
	mode 0644
end

script "restart_web" do
    interpreter "bash"
    user "root"
    cwd "/root"
    code <<-EOH
		mkdir -p #{DocumentRoot}/#{SoftwareName}/tmp
		chmod 777 #{DocumentRoot}/#{SoftwareName}/tmp
		service httpd start
		service php#{PHPVersion}-php-fpm start
    EOH
end