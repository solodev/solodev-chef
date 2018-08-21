script "mongo_brick" do
	not_if { ::File.exists?("/mongo/data/journal") }
  interpreter "bash"
  user "root"
  cwd "/root"
  code <<-EOH
		
    echo 'echo 300 > /proc/sys/net/ipv4/tcp_keepalive_time' >> /etc/rc.local
    echo 'touch /var/lock/subsys/local' >> /etc/rc.local
    
    #Make Mongo Node
    mkfs.ext4 /dev/sdm
    echo '/dev/sdm /mongo ext4 defaults,auto,noexec 0 0' >> /etc/fstab
    mount -a
    blockdev --setra 32 /dev/sdm

	EOH
end