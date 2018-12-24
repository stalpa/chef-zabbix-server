# Cookbook:: chef-zabbix-server
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

# dpkg -i https://packages.chef.io/files/stable/chefdk/3.5.13/ubuntu/16.04/chefdk_3.5.13-1_amd64.deb

# ==> Install the repository configuration package
apt_repository 'zabbix' do
  uri          node['repository']['uri']
  components   node['repository']['components']
  distribution node['repository']['distribution']
  key          node['repository']['key']
end

# ==> Update cache
apt_update 'update' do
  action :update
end

# ==> Install Apache, Zabbix server with MySQL support and frontend
node['pkg'].each do |pkg|
  package pkg do
    action :install
  end
end

# ==> Start MySQL service
service 'mysql' do
  action [:enable, :start]
end

# ==> Settings for database
database_exists = node['database']['exists']
database_tables = node['database']['tables']

execute 'Create a new database' do
  command "echo \"create database #{node['database']['dbname']} character set utf8 collate utf8_bin;\" | mysql"
  not_if database_exists
end

execute 'Grant privileges' do
  command "echo \"grant all privileges on #{node['database']['dbname']}.* to #{node['database']['dbuser']}@#{node['database']['dbhost']} identified by '#{node['database']['dbpassword']}';\" | mysql"
end

# ==> Import initial schema and data for the MySQL server
execute 'create_zabbix_user' do
  command "zcat /usr/share/doc/zabbix-server-mysql/create.sql.gz | mysql -u#{node['database']['dbuser']} -p#{node['database']['dbpassword']} #{node['database']['dbname']}"
  not_if database_tables
end

execute 'Copy PHP-files for Frontend zabbix-web' do
  command 'cp -R /usr/share/zabbix/ /var/www/html/'
end

# ==> Setup zabbix_server.conf
template '/etc/zabbix/zabbix_server.conf' do
  source 'zabbix_server.conf.erb'
  owner 'zabbix'
  group 'zabbix'
  mode '0644'
  variables(
    zabbix_settings: node['settings']
  )
end

# ==> Unlink nginx-default config
link "#{node['nginx']['enabled']}/default" do
  action :delete
  only_if { file_exists? }
end

template "#{node['nginx']['available']}/zabbix.conf" do
  source 'zabbix.conf.erb'
  owner 'www-data'
  group 'www-data'
  mode '0644'
  verify 'nginx -t'
end

link "#{node['nginx']['enabled']}/zabbix.conf" do
  to "#{node['nginx']['available']}/zabbix.conf"
  action :create
  only_if 'nginx -t'
end

# ==> Setup PHP parameters
template '/etc/php/7.0/fpm/php.ini' do
  source 'php.ini.erb'
  variables(
    php: node['php']
  )
end

# ==> Restart services
# ==Errno::ENOENT: No such file or directory - /sbin/status
execute 'service nginx start' do
  only_if { index_exists? }
end

execute 'service php7.0-fpm start' do
end

['zabbix-server', 'zabbix-agent'].each do |srv|
  service srv do
    supports status: true
    action :start
  end
end
