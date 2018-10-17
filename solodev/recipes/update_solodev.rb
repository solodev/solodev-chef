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

script "restart_web" do
    interpreter "bash"
    user "root"
    cwd "/root"
    code <<-EOH

        if [ -f /etc/init.d/httpd ]; then
            service httpd restart
        fi

    EOH
end