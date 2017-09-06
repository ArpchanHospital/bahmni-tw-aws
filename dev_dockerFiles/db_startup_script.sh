#!/bin/bash
set -e
container_name=$container_name
if [ -f /etc/my.cnf ]; then
    sudo mkdir -p /${container_name}/mysql && sudo chown -R mysql:mysql /${container_name}/mysql
    sudo sed -i "s|datadir=/var/lib/mysql|datadir=/${container_name}/mysql|g" /etc/my.cnf
    sudo sed -i.bak 's|[mysqld]|&\max_connections = 150|' /etc/my.cnf
    sudo rsync -avr -o -g /var/lib/mysql /${container_name}
    sudo service mysqld restart
else
   echo "File /etc/my.cnf does not exist."
fi

if [ -f /var/lib/pgsql/.bash_profile ]; then
    sudo mkdir -p /${container_name}/pgsql/9.2/data && sudo chown -R postgres:postgres /${container_name}/pgsql
    sudo sed -i "s|PGDATA=/var/lib/pgsql/9.4/data|PGDATA=/${container_name}/pgsql/9.2/data|g" /var/lib/pgsql/.bash_profile
    export PGDATA
    sudo rsync -avr -o -g /var/lib/pgsql /${container_name}
    sudo service postgresql-9.2 restart
else
   echo "File /var/lib/pgsql/.bash_profile does not exist."
fi

if [ -d /home/bahmni ]; then
   sudo bahmni -ilocal stop
   sudo rsync -avr -o -g /home/bahmni /${container_name}
   sudo rm -rf /home/bahmni
   ln -s /${container_name}/bahmni /home/bahmni && chown -h bahmni:bahmni /home/bahmni
   sudo bahmni -ilocal start
else
   echo "Directory /home/bahmni does not exists."
fi

if [ -f /etc/openerp/openerp-server.conf ]; then
    sudo rm -rf /var/run/openerp/openerp-server.pid
    sudo service openerp restart
else
   echo "Openerp not installed."
fi
