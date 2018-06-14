#!/usr/bin/env bash

rm -f /etc/httpd/conf.d/autoindex.conf

## declare array of modules to deactivate
declare -a arr=(
"authn_anon_module"
"authn_dbm_module"
"authn_default_module"
"authz_owner_module"
"authz_dbm_module"
"authz_default_module"
"ldap_module"
"authnz_ldap_module"
"include_module"
"ext_filter_module"
"usertrack_module"
"status_module"
"autoindex_module"
"info_module"
"dav_module"
"dav_fs_module"
"dav_lock_module"
"vhost_alias_module"
"negotiation_module"
"actions_module"
"speling_module"
"userdir_module"
"substitute_module"
"proxy_balancer_module"
"proxy_ftp_module"
"proxy_http_module"
"proxy_ajp_module"
"proxy_connect_module"
"cache_module"
"cache_disk"
"cache_socache"
"suexec_module"
"disk_cache_module"
"cgi_module"
"version_module"
"lua_module"
)

## now loop through the above array
for i in "${arr[@]}"
do
   #echo "disabling module $i"
   find /etc/httpd -name "*.conf" -type f -exec sed -i 's/^LoadModule '"${i}"'/#&/' {} + \
   # or do whatever with individual element of the array
done

exit 0
