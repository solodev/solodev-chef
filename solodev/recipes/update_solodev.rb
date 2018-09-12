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
    cwd "/var/www/Solodev"
    code <<-EOH

        echo "php #{DocumentRoot}/#{SoftwareName}/core/update.php #{SolodevUser} #{SolodevPassword}" >> /var/www/Solodev/phpinstall.log
        php #{DocumentRoot}/#{SoftwareName}/core/update.php #{SolodevUser} #{SolodevPassword}  >> /var/www/Solodev/phpinstall.log

    EOH
end