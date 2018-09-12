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
    cwd "#{DocumentRoot}/#{SoftwareName}"
    code <<-EOH

        echo "php #{DocumentRoot}/#{SoftwareName}/core/update.php #{SolodevUser} #{SolodevPassword}" >> #{DocumentRoot}/#{SoftwareName}/clients/solodev/phpinstall.log
        php #{DocumentRoot}/#{SoftwareName}/core/update.php #{SolodevUser} #{SolodevPassword}  >> #{DocumentRoot}/#{SoftwareName}/clients/solodev/phpinstall.log

    EOH
end