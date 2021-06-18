#!/bin/bash
echo "Calculate MaxClients by dividing biggest Apache thread by free memory"
APACHE="httpd"
APACHEMEM=$(ps -aylC $APACHE |grep "$APACHE" |awk '{print $8'} |sort -n |tail -n 1)
APACHEMEM=$(expr $APACHEMEM / 1024)
echo "Stopping $APACHE to calculate the amount of free memory"
/etc/init.d/$APACHE stop
TOTALFREEMEM=$(free -m |head -n 2 |tail -n 1 |awk '{free=($4); print free}')
TOTALMEM=$(free -m |head -n 2 |tail -n 1 |awk '{total=($2); print total}')
SWAP=$(free -m |head -n 4 |tail -n 1 |awk '{swap=($3); print swap}')
MAXCLIENTS=$(expr $TOTALFREEMEM / $APACHEMEM)
MINSPARESERVERS=$(expr $MAXCLIENTS / 4)
MAXSPARESERVERS=$(expr $MAXCLIENTS / 2)

echo "Total memory $TOTALMEM"
echo "Free memory $TOTALFREEMEM"
echo "Amount of virtual memory being used $SWAP"
echo "Largest Apache Thread size $APACHEMEM"
if [[ SWAP > TOTALMEM ]]; then
      ERR="Virtual memory is too high"
else
      ERR="Virtual memory is ok"
fi
echo "$ERR"
echo "Total Free Memory $TOTALFREEMEM"
echo "MaxClients should be around $MAXCLIENTS"
echo "MinSpareServers should be around $MINSPARESERVERS"
echo "MaxSpareServers should be around $MAXSPARESERVERS"

perl -0 -p -i -e 's/(\<IfModule\sprefork\.c\>(\n|[^\n])*?StartServers\s*?)\s\d+/\1\ '"$MINSPARESERVERS"'/;' \
-e 's/(\<IfModule\sprefork\.c\>(\n|[^\n])*?MinSpareServers\s*?)\s\d+/\1\ '"$MINSPARESERVERS"'/;' \
-e 's/(\<IfModule\sprefork\.c\>(\n|[^\n])*?MaxSpareServers\s*?)\s\d+/\1\ '"$(($MINSPARESERVERS*2 + 1))"'/;' \
-e 's/(\<IfModule\sprefork\.c\>(\n|[^\n])*?ServerLimit\s*?)\s\d+/\1\ '"$(( 50 + (($MINSPARESERVERS**2)*10) + (($MINSPARESERVERS-2)*10) ))"'/;' \
-e 's/(\<IfModule\sprefork\.c\>(\n|[^\n])*?MaxClients\s*?)\s\d+/\1\ '"$(( 50 + (($MINSPARESERVERS**2)*10) + (($MINSPARESERVERS-2)*10) ))"'/;' \
-e 's/(\<IfModule\sprefork\.c\>(\n|[^\n])*?MaxRequestsPerChild\s*?)\s\d+/\1\ '"$(( 2048 + ($MINSPARESERVERS*256) ))"'/;' /etc/httpd/conf/httpd.conf

perl -0 -p -i \
-e 's/#?(LoadModule\ authn_alias_module\ modules\/mod_authn_alias\.so)/#\1/;' \
-e 's/#?(LoadModule\ authn_anon_module\ modules\/mod_authn_anon\.so)/#\1/;' \
-e 's/#?(LoadModule\ authn_dbm_module\ modules\/mod_authn_dbm\.so)/#\1/;' \
-e 's/#?(LoadModule\ authnz_ldap_module\ modules\/mod_authnz_ldap\.so)/#\1/;' \
-e 's/#?(LoadModule\ authz_dbm_module\ modules\/mod_authz_dbm\.so)/#\1/;' \
-e 's/#?(LoadModule\ authz_owner_module\ modules\/mod_authz_owner\.so)/#\1/;' \
-e 's/#?(LoadModule\ cache_module\ modules\/mod_cache\.so)/#\1/;' \
-e 's/#?(LoadModule\ disk_cache_module\ modules\/mod_disk_cache\.so)/#\1/;' \
-e 's/#?(LoadModule\ ext_filter_module\ modules\/mod_ext_filter\.so)/#\1/;' \
-e 's/#?(LoadModule\ file_cache_module\ modules\/mod_file_cache\.so)/#\1/;' \
-e 's/#?(LoadModule\ info_module\ modules\/mod_info\.so)/#\1/;' \
-e 's/#?(LoadModule\ ldap_module\ modules\/mod_ldap\.so)/#\1/;' \
-e 's/#?(LoadModule\ mem_cache_module\ modules\/mod_mem_cache\.so)/#\1/;' \
-e 's/#?(LoadModule\ status_module\ modules\/mod_status\.so)/#\1/;' \
-e 's/#?(LoadModule\ speling_module\ modules\/mod_speling\.so)/#\1/;' \
-e 's/#?(LoadModule\ usertrack_module\ modules\/mod_usertrack\.so)/#\1/;' -e 's/#?(LoadModule\ version_module\ modules\/mod_version\.so)/#\1/;' /etc/httpd/conf/httpd.conf

echo "Starting $APACHE again"
/etc/init.d/$APACHE start