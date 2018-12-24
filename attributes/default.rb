# ==> Install packages
default['pkg'] = %w(
  nginx
  php-fpm
  zabbix-server-mysql
  zabbix-frontend-php
  zabbix-agent
  mariadb-server
)

# ==> Setup zabbix server config
default['settings'] = {
  logfile:          '/var/log/zabbix/zabbix_server.log',
  dbsocket:         '/var/lib/mysql/mysql.sock',
  pidfile:          '/var/run/zabbix/zabbix_server.pid',
  socketdir:        '/var/run/zabbix',
  alertscriptspath: '/usr/lib/zabbix/alertscripts',
  externalscripts:  '/usr/lib/zabbix/externalscripts',
  snmptrapperfile:  '/var/log/snmptrap/snmptrap.log',
  dbhost:           'localhost',
  dbname:           'zabbix',
  dbuser:           'zabbix',
  dbpassword:       'zabbix',
  logslowqueries:   '3000',
}

# ==> PHP configuration file
default['php'] = {
  post_max_size: '16M',
  max_execution_time: '300',
  max_input_time: '300',
  datetimezone: 'Europe/Chisinau',
}

# ==> Add zabbix repository
default['repository'] = {
  uri:              'http://repo.zabbix.com/zabbix/4.1/ubuntu',
  components:       ['main'],
  distribution:     'xenial',
  key:              'http://repo.zabbix.com/zabbix-official-repo.key',
}

# ==> Database parameters
default['database'] = {
  dbname:           'zabbix',
  dbuser:           'zabbix',
  dbhost:           'localhost',
  dbpassword:       'zabbix',
  dbport:           '3306',
  exists:           'echo "show databases" | mysql |grep zabbix',
  tables:           "echo \"select table_name from information_schema.tables where table_schema='zabbix'\" | mysql |grep hosts",
}

# ==> Web Server Nginx
default['nginx'] = {
  enabled:          '/etc/nginx/sites-enabled',
  available:        '/etc/nginx/sites-available',
}
