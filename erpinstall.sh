sudo apt update -y

sudo apt upgrade -y  

sudo apt install lolcat -y

echo "Installing nvm"

curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash

source ~/.profile

nvm install --lts

echo "Installing dependencies" | lolcat

sudo apt install -y curl python3-dev python3-setuptools python3-pip virtualenv libmysqlclient-dev redis-server xvfb libfontconfig wkhtmltopdf python3-pip software-properties-common lolcat python3.10-venv mariadb-server npm

echo "Installing Yarn" | lolcat 

sudo npm install -g yarn 

echo "Installing frappe-bench using pip" | lolcat

pip3 install frappe-bench

echo "Mysql_secure_installation" | lolcat

sudo mysql_secure_installation

echo "Configuring my.cnf" | lolcat 

cat sql_my.cnf | sudo tee -a /etc/mysql/my.cnf

echo "Restarting mysql" | lolcat

sudo service mysql restart

echo "Init bench version 13" | lolcat

bench init frappe-bench --frappe-branch version-13 

