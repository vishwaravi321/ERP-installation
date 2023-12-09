


path_exist(){
    if [[ -e "$1" ]];then   
        return 0
    else 
        return 1
    fi
}

sudo apt update -y

sudo apt upgrade -y  

sudo apt install lolcat -y

printf "\033[38;2;255;0;255mInstalling nvm\033[0m\n"

curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

source ~/.bashrc

nvm install --lts

nvm use --lts

nvm alias default $(node --version)

echo "Installing dependencies" | lolcat
printf "\033[38;2;255;0;255mInstalling Dependencies\033[0m\n"

sudo apt install -y curl python3-dev python3-setuptools python3-pip virtualenv libmysqlclient-dev redis-server xvfb libfontconfig wkhtmltopdf python3-pip software-properties-common lolcat python3.10-venv mariadb-server npm supervisor

echo "Installing Yarn" | lolcat 
printf "\033[38;2;255;0;255mInstalling Yarn \033[0m\n"

sudo npm install -g yarn 

echo "Installing Node SASS" | lolcat
printf "\033[38;2;255;0;255mInstalling Node SASS\033[0m\n"

npm add node-sass

echo "Installing frappe-bench using pip" | lolcat
printf "\033[38;2;255;0;255mInstalling frappe-bench using pip\033[0m\n"

sudo -H pip3 install frappe-bench

echo "Mysql_secure_installation" | lolcat
printf "\033[38;2;255;0;255mMysql_secure_installation\033[0m\n"


sudo mysql_secure_installation

echo "Configuring my.cnf" | lolcat 
printf "\033[38;2;255;0;255mConfiguring my.cnf\033[0m\n"

cat sql_my.cnf | sudo tee -a /etc/mysql/my.cnf

echo "Restarting mysql" | lolcat
printf "\033[38;2;255;0;255mRestarting mysql\033[0m\n"


sudo service mysql restart

echo "Init bench" | lolcat
printf "\033[38;2;255;0;255mInit bench\033[0m\n"

while true;do
    read -p "Please provide the absolute path for frappe DIR including bench dir (default: /home/$USER/frappe-bench) :" frappe_dir
    frappe_dir=${frappe_dir:-/home/$USER/frappe-bench}

    if path_exist "$frappe_dir"; then
        read -p "Please provide the version to init[version-13/version-14/version-15](default:version-14):" frappe_version
        frappe_version=${frappe_version:-version-14}

        bench init $frappe_dir --frappe-branch $frappe_version

        if [[ $frappe_version != 'version-13' ]]; then
            echo "Optionals" | lolcat 
            printf "\033[38;2;255;0;255mOptionals\033[0m\n"


            read -p "other apps(optional)[please split with comma(,) for multiple apps]:" apps
            if [[ $apps ]]
            then
                echo "Has Additional Apps" | lolcat
                printf "\033[38;2;255;0;255mHas Additional Apps \033[0m\n"

                for i in $(echo "$apps" | sed 's/,/ /g');
                do
                    echo "Getting $i" | lolcat
                    printf "\033[38;2;255;0;255mGetting $i\033[0m\n"

                    cd $frappe_dir && bench get-app $i --branch $frappe_version
                    echo "completed $i" | lolcat
                    printf "\033[38;2;255;0;255mCompleted $i\033[0m\n"

                done
                echo "Finished Additional Apps" | lolcat
                printf "\033[38;2;255;0;255mFinished Additional Apps\033[0m\n"

            else
                echo "No Additional Apps" | lolcat
                printf "\033[38;2;255;0;255mNo Additional Apps\033[0m\n"

            fi
        fi
        echo "Setting Bench to production"
        printf "\033[38;2;255;0;255mSetting Bench to production\033[0m\n"

        cd $frappe_dir && sudo bench setup production $USER

        echo "Changing Permissions" | lolcat
        printf "\033[38;2;255;0;255mChanging Permissions\033[0m\n"

        sudo chown -R $USER:$USER /home/$USER

        sudo chmod -R 755 /home/$USER
        break
    else
        echo "Path $frappe_dir does not exist.Please Provide a valid Path"
        printf "\033[38;2;255;0;255mPath $frappe_dir does not exist.Please Provide a valid Path\033[0m\n"

    fi

done