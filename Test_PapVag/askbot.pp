

package { 'Development Tools':
    ensure => latest,
    name   => 'Development Tools'
}

package { 'epel-release':
    ensure => latest,
    name   => 'epel-release'
}

class sshd {
  package { 'sshd':
    ensure => latest,
	name   => 'openssh-server'
  }
  service { 'sshd':
    ensure    => running,
    enable    => true,
	name      => 'ssh'
	subscribe => File['sshd_config'],
    require   => Package['sshd']
  }
  file { 'sshd_config':
    path    => '/etc/ssh/sshd_config',
    ensure  => file,
    content => "Port 22
    Protocol 2
    HostKey /etc/ssh/ssh_host_rsa_key
    HostKey /etc/ssh/ssh_host_dsa_key
    HostKey /etc/ssh/ssh_host_ecdsa_key
    UsePrivilegeSeparation yes
    KeyRegenerationInterval 3600
    ServerKeyBits 768
    SyslogFacility AUTH
    LogLevel INFO
    LoginGraceTime 120
    PermitRootLogin yes
    StrictModes yes
    RSAAuthentication yes
    PubkeyAuthentication yes
    IgnoreRhosts yes
    RhostsRSAAuthentication no
    HostbasedAuthentication no
    PermitEmptyPasswords no
    ChallengeResponseAuthentication no
    X11Forwarding yes
    X11DisplayOffset 10
    PrintMotd no
    PrintLastLog yes
    TCPKeepAlive yes
    AcceptEnv LANG LC_*
    Subsystem sftp /usr/lib/openssh/sftp-server
    UsePAM yes",
    mode    => 0644,
    owner   => root,
    group   => root,
    require => Package['sshd']
  }
  
}

package { 'python-pip':
    ensure => latest,
    name   => 'python-pip'
}

package { 'python-devel':
    ensure => latest,
    name   => 'python-devel'
}

package { 'python-six':
    ensure => latest,
    name   => 'python-six'
}

package { 'wget':
    ensure => latest,
    name   => 'wget'
}

package { 'postgresql-server':
    ensure => latest,
    name   => 'postgresql-server',
	subscribe => File['pg_hba.conf']
}
 
package { 'postgresql-devel':
    ensure => latest,
    name   => 'postgresql-devel'
}

package { 'postgresql-contrib':
    ensure => latest,
    name   => 'postgresql-contrib'
}

exec { postgresql-setup initdb
}

file { 'pg_hba.conf':
    path    => '/var/lib/pgsql/data/pg_hba.conf',
    ensure  => file,
    content => "
	local   all   all                    md5
   # IPv4 local connections:
    host    all   all     127.0.0.1/32   md5
    # IPv6 local connections:
    host    all  all      ::1/128        md5
               ",
    mode    => 0644,
    owner   => root,
    group   => root,
    require => Package['postgresql-server']
}

service { 'postgresql':
   ensure => running,
   enable => true,
   require => Package['postgresql']
}


user { 'postgres':
	name      => 'postgres',
	home      => '/home/postgres',
    managehome => true,
	shell => '/bin/bash',
	ensure => present,
	password => 'postgres',
	groups => [sudo, wheel]
}

exec { create database askbotdb
}

user { 'hakaselabs':
	name      => 'hakaselabs',
	home      => '/home/hakaselabs',
    managehome => true,
	shell => '/bin/bash',
	ensure => present,
	password => 'hakase123',
	groups => [sudo, wheel]
}

exec { grant all privileges on database askbotdb to hakaselabs
}


exec { systemctl restart postgresql
}

user { 'askbot':
	name      => 'askbot',
	home      => '/home/askbot',
    managehome => true,
	shell => '/bin/bash',
	ensure => present,
	password => 'askbot',
	groups => [sudo, wheel]
}

exec { wget https://files.pythonhosted.org/packages/46/33/a8d578a8c04a3f90d2ebad9cbc3e9fcce2f233ca515b5f7837566f0825f2/askbot-0.10.2.tar.gz
}

exec { tar xvjf askbot-0.10.2.tar.gz
}

exec { rm askbot-0.10.2.tar.gz
}

exec { cd askbot-0.10.2/
}

exec { python setup.py install
}

exec { python manage.py collectstatic
}

exec { python manage.py syncdb
}

exec { python manage.py runserver 0.0.0.0:8080
}

exec { mkdir -p /etc/uwsgi/sites
}

class uwsgi {
  package { 'uwsgi':
    ensure => latest
  }
  service { 'uwsgi':
    ensure => running,
    enable => true,
    require => Package['uwsgi']
  }
  file { 'uwsgi.service':
    path    => '/etc/systemd/system/uwsgi.service',
    ensure  => file,
    content => "
    [uwsgi]
    # Project directory, Python directory
    chdir = /home/askbot/hakase-labs/myapp
    home = /home/askbot/hakase-labs/
    static-map = /m=/home/askbot/hakase-labs/myapp/static
    wsgi-file = /home/askbot/hakase-labs/myapp/django.wsgi
    master = true
    processes = 5
    # Askbot will running under the sock file
    socket = /run/uwsgi/askbot.sock
    chmod-socket = 664
    uid = askbot
    gid = nginx
    vacuum = true
    # uWSGI Log file
    logto = /var/log/uwsgi.log",
    mode    => 0644,
    owner   => root,
    group   => root,
    require => Package['nginx']
  }
 
}

class nginx {
  package { 'nginx':
    ensure => latest
  }
  service { 'nginx':
    ensure    => running,
    enable    => true,
	subscribe => File['conf.d'],
    require   => Package['nginx']
  }  
  file { 'conf.d':
    path    => '/etc/nginx/conf.d',
    ensure  => file,
    content => "user www-data;
    worker_processes auto;
    pid /run/nginx.pid;
   events {
    worker_connections 1024;
    multi_accept on;
    }
   http {
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 15;
    types_hash_max_size 2048;
    server_tokens off;
    include /etc/nginx/mime.types;
    default_type text/javascript;
    access_log off;
    error_log /var/log/nginx/error.log;
    gzip on;
    gzip_min_length 100;
    gzip_http_version 1.1;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
    client_max_body_size 8M;
   server {
      listen 80;
       server_name askbot.me www.askbot.me;
       location / {
       include   uwsgi_params;
       uwsgi_pass  unix:/run/uwsgi/askbot.sock;
       }
    } 
            ",
    mode    => 0644,
    owner   => root,
    group   => root,
    require => Package['nginx']
  }
}
node /^server(\d+)$/ {
  include nginx
}

exec { systemctl daemon-reload
}
