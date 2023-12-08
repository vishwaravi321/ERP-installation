sudo apt update -y

sudo apt upgrade -y  

sudo apt install lolcat -y

echo "Installing nvm" | lolcat

curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

source ~/.bashrc

nvm install --lts

nvm use --lts

nvm alias default $(node --version)

echo "Installing dependencies" | lolcat

sudo apt install -y curl python3-dev python3-setuptools python3-pip virtualenv libmysqlclient-dev redis-server xvfb libfontconfig wkhtmltopdf python3-pip software-properties-common lolcat python3.10-venv mariadb-server npm supervisor

echo "Installing Yarn" | lolcat 

sudo npm install -g yarn 

echo "Installing frappe-bench using pip" | lolcat

sudo -H pip3 install frappe-bench

echo "Mysql_secure_installation" | lolcat

sudo mysql_secure_installation

echo "Configuring my.cnf" | lolcat 

cat sql_my.cnf | sudo tee -a /etc/mysql/my.cnf

echo "Restarting mysql" | lolcat

sudo service mysql restart

echo "Init bench" | lolcat
read -p "Please provide the absolute path (/home/$USER/Public) for frappe DIR:" fraappe_dir
read -p "Please provide the version to init[version-13/version-14/version-15]:" frappe_version

bench init $fraappe_dir --frappe-branch $frappe_version

echo "Optional" | lolcat 

read -p "other apps(optional)[please split with comma(,) for multiple apps]:" apps
if [[ $apps ]]
then
    echo "Has Additional Apps" | lolcat
    for i in $(echo "$apps" | sed 's/,/ /g');
    do
        echo "$i"; | lolcat
        cd $fraappe_dir && bench get-app $i --branch $frappe_version
        echo "completed" | 
    done
else
    echo "No Additional Apps" | lolcat

echo "Setting Bench to production"

sudo bench setup production $USER







