DBUser = node[:install][:DBUser]
DBPassword = node[:install][:DBPassword]

script "init_mongo" do
	not_if { ::File.exists?('/root/initmongo.txt') }
	interpreter "bash"
	user "root"
	cwd "/root"
	code <<-EOH

		touch /root/initmongo.txt
		echo 'use solodev_views;' >> /root/initmongo.js
		echo 'db.createUser({"user": "#{DBUser}", "pwd": "#{DBPassword}", "roles": [ { role: "readWrite", db: "solodev_views" } ] })' >> /root/initmongo.js 
		mongo < /root/initmongo.js
		#rm -Rf /root/initmongo.js
		
	EOH
end