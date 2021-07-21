#Shutdown Mongo
script "shutdown_mongo" do
  interpreter "bash"
  user "root"
  cwd "/root"
  code <<-EOH 
    echo "Shut down mongo"
    service mongod stop
  EOH
end