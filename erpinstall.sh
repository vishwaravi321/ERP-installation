echo "Updating apt" | lolcat

sudo apt update -y

echo "Install ing dependencies" | lolcat

sudo apt install -y python3-dev python3-setuptools python3-pip virtualenv libmysqlclient-dev redis-server xvfb libfontconfig wkhtmltopdf python3-pip software-properties-common lolcat python3.10-venv

echo "adding latest mariadb mirror" | lolcat

sudo apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
sudo add-apt-repository 'deb [arch=amd64,arm64,ppc64el] https://ftp.icm.edu.pl/pub/unix/database/mariadb/repo/10.3/ubuntu focal main'
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
sudo apt update -y 

echo "installing mariadb server" | lolcat

sudo apt install -y  mariadb-server

echo "adding new node repo to the apt" | lolcat


read -p "Enter the link for newest node repo (default: https://deb.nodesource.com/setup_16.x): " node_link

node_link=${node_link:-https://deb.nodesource.com/setup_16.x}

curl $node_link | sudo -E bash -

echo "Installing nodejs" | lolcat

sudo apt install nodejs -y

echo "Installing Yarn" | lolcat 

sudo npm install -g yarn 

echo "Installing frappe-bench using pip" | lolcat

pip3 install frappe-bench

echo "Mysql_secure_installation" | lolcat

#sudo mysql_secure_installation



echo "Configuring my.cnf" | lolcat 
#cat sql_my.cnf | sudo tee -a /etc/mysql/my.cnf

echo "Restarting mysql" | lolcat

sudo service mysql restart

echo "Init bench version 13" | lolcat

bench init frappe-bench --frappe-branch version-13 

