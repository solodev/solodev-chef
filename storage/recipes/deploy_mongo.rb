template 'limits.conf' do
  path "/etc/security/limits.conf"
  source 'limits.conf.erb'
  owner 'root'
  group 'root'
  mode 0644
end

template 'mongodb-org-4.0.repo' do
  path '/etc/yum.repos.d/mongodb-org-4.0.repo'
  source 'mongodb-org-4.0.repo.erb'
  owner 'root'
  group 'root'
  mode 0644
end

template 'mongod.conf' do
  path "/etc/mongod.conf"
  source 'mongod.conf.erb'
  owner 'root'
  group 'root'
  mode 0644
end

directory '/mongo/data' do
	not_if do ::File.exists?("/mongo/data") end
  owner 'mongod'
  group 'mongod'
  mode '0770'
  recursive true
  ignore_failure true
  action :create
end

directory '/mongo/log' do
	not_if do ::File.exists?("/mongo/log") end
  owner 'mongod'
  group 'mongod'
  mode '0770'
  recursive true
  ignore_failure true
  action :create
end

#Init Mongo
script "init_mongo" do
	not_if { ::File.exists?('/mongo/data/journal') }
  interpreter "bash"
  user "root"
  cwd "/root"
  code <<-EOH 
    echo "Try to stop Mongo to load new configs"
    service mongod stop
    sleep 5
	  echo "Try to start Mongo"
	  service mongod start
    echo "Mongo started"
	  service mongod status
	  sleep 10
  EOH
end