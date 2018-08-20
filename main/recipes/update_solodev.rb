document_root = node[:install][:document_root]
software_name = node[:install][:software_name]
client_name = node[:install][:client_name]
ADMINUSER = node[:install][:ADMINUSER]
ADMINPASSWORD = node[:install][:ADMINPASSWORD]
WEBSITE = node[:install][:WEBSITE]
THEME = node[:install][:THEME]

#Update Software
script "update_software" do
    interpreter "bash"
    user "root"
    cwd "/root"
    code <<-EOH

        echo "php #{document_root}/#{software_name}/core/update.php #{ADMINUSER} #{ADMINPASSWORD}" >> /root/phpinstall.log
        php #{document_root}/#{software_name}/core/update.php #{ADMINUSER} #{ADMINPASSWORD} #{WEBSITE} #{THEME} >> /root/phpinstall.log

    EOH
end