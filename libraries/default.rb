def index_exists?
  ::File.exist?('/etc/nginx/sites-enabled/zabbix.conf')
end

def file_exists?
  ::File.exist?('/etc/nginx/sites-enabled/default')
end
