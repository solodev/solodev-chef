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