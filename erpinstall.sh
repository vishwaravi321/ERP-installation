#!/bin/bash

path_exists() {
  if [ -e "$1" ]; then
    return 0  # Path exists
  else
    return 1  # Path does not exist
  fi
}

script(){
    sudo apt update -y

    sudo apt upgrade -y  

    printf "\033[38;2;255;0;255mInstalling Dependencies\033[0m\n"
    sudo apt install -y curl nginx python3-dev python3-setuptools python3-pip virtualenv fail2ban libmysqlclient-dev redis-server xvfb libfontconfig wkhtmltopdf python3-pip software-properties-common lolcat python3.10-venv mariadb-server supervisor


    printf "\033[38;2;255;0;255mInstalling nvm\033[0m\n"

    curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash

    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
    source ~/.bashrc

    printf "\033[38;2;255;0;255mInstalling Node LTS\033[0m\n"
    nvm install 18
    nvm use 18

    node_version=$(node --version)
    printf "\033[38;2;255;0;255mSetting $node_version as Default\033[0m\n"

    nvm alias default $node_version


    printf "\033[38;2;255;0;255mInstalling Yarn \033[0m\n"
    npm install -g yarn 

    printf "\033[38;2;255;0;255mInstalling frappe-bench using pip\033[0m\n"
    sudo -H pip3 install frappe-bench

    if [[ -e ~/.mariadb_conf_success.txt ]]; then
        printf "\033[38;2;255;0;255mmysql.config already exist\033[0m\n"
        printf "\033[38;2;255;0;255mSkipping mysql\033[0m\n"
    else
        printf "\033[38;2;255;0;255mMysql_secure_installation\033[0m\n"
        sudo mysql_secure_installation
        printf "\033[38;2;255;0;255mConfiguring my.cnf\033[0m\n"
        cat sql_my.cnf | sudo tee -a /etc/mysql/mariadb.conf.d/50-server.cnf
        touch ~/.mariadb_conf_success.txt
    fi

    printf "\033[38;2;255;0;255mRestarting mysql\033[0m\n"
    sudo service mysql restart

    printf "\033[38;2;255;0;255mPurging Unwanted Packages\033[0m\n"
    sudo apt autopurge


    printf "\033[38;2;255;0;255mInit bench\033[0m\n"
    while true;do
        read -p "Please provide the absolute path for frappe DIR[NOTE: Don't forget to add / in the end](default: /home/$USER/) :" frappe_dir
        frappe_dir=${frappe_dir:-/home/$USER/}
        printf "\033[38;2;255;0;255mChoosing $frappe_dir\033[0m\n"
        if path_exists "$frappe_dir"; then
            read -p "Please provide Bench project DIR(default: frappe-bench):" bench_dir
            bench_dir=${bench_dir:-frappe-bench}
            full_bench_dir=$frappe_dir$bench_dir
            printf "\033[38;2;255;0;255mInstalling Bench on $full_bench_dir\033[0m\n"
            while true;do
                read -p "Please provide the version to init[version-14/version-15](default:version-15):" frappe_version
                frappe_version=${frappe_version:-version-15}
                    if [[ $frappe_version == 'version-14' || $frappe_version == 'version-15' ]]; then
                        printf "\033[38;2;255;0;255mYou have choosen $frappe_version\033[0m\n"
                        bench init $full_bench_dir --frappe-branch $frappe_version

                        printf "\033[38;2;255;0;255mOptionals\033[0m\n"
                        read -p "other apps(optional)[please split with comma(,) for multiple apps]:" apps
                        if [[ $apps ]]
                        then
                            printf "\033[38;2;255;0;255mHas Additional Apps \033[0m\n"
                            for i in $(echo "$apps" | sed 's/,/ /g');
                            do
                                read -p "Version for $i(please don't make any spell mistake):" app_branch
                                printf "\033[38;2;255;0;255mGetting $i with branch $app_branch\033[0m\n"
                                cd $full_bench_dir && bench get-app $i --branch $app_branch
                                printf "\033[38;2;255;0;255mCompleted $i\033[0m\n"
                            done
                            printf "\033[38;2;255;0;255mFinished Additional Apps\033[0m\n"
                        else
                            printf "\033[38;2;255;0;255mNo Additional Apps\033[0m\n"
                        fi
                        printf "\033[38;2;255;0;255mChanging Permissions\033[0m\n"
                        sudo chown -R $USER:$USER /home/$USER
                        sudo chmod -R 755 /home/$USER
                        printf "\033[38;2;255;0;255mSetting Redis\033[0m\n"
                        cd $full_bench_dir && bench setup redis
                        printf "\033[38;2;255;0;255mSetting SocketIO\033[0m\n"
                        cd $full_bench_dir && bench setup socketio
                        printf "\033[38;2;255;0;255mSetting Supervisor\033[0m\n"
                        cd $full_bench_dir && bench setup supervisor
                        printf "\033[38;2;255;0;255mSetting Nginx\033[0m\n"
                        cd $full_bench_dir && bench setup nginx --log_format ''
                        break
                    else
                        printf "\033[38;2;255;0;255mPlease provide a valid version to install\033[0m\n"
                    fi
            done 
            printf "\033[38;2;255;0;255mPlease use 'source ~/.bashrc' or logout then login for further use\033[0m\n"
            printf "\033[38;2;255;0;255mPlease use 'cd $full_bench_dir && sudo bench setup production $USER' for production usage\033[0m\n"
            printf "\033[38;2;255;0;255mEnjoy :)\033[0m\n"
            break       
        else
            printf "\033[38;2;255;0;255mPlease provide a valid path\033[0m\n"
        fi
    done
}

# Function to display author and license information in a banner
show_info() {
    echo "Author: VISHWA R"
    echo "License: GPL-3.0 license"
}

# Function to create a simple banner with author and license information
create_banner() {
    echo
    echo "====================================="
    show_info
    echo "====================================="
    echo
}

show_important_notes() {
    printf "\e[1;31m=============================================================================\n"
    printf "⚠️⚠️ Important Notes ⚠️⚠️\n"
    printf "This script uses 'sudo' for certain operations.\n"
    printf "Review the script before execution.\n"
    printf "Use with caution.\n"
    printf "Ensure that you have the necessary permissions to execute the script.\n"
    printf "This script has interactive mode.\n"
    printf "Please read and understand every prompt\e[0m\n"
    printf "\e[1;31m=============================================================================\n\n\e[0m"
}


# Function to display the agreement and prompt for confirmation
show_agreement() {
    show_important_notes
    echo "By running this script, you agree to use it responsibly and understand the potential risks."
    read -p "Do you agree to proceed? (yes/no): " response

    if [[ "$response" == "yes" ]]; then
        check_version
    else
        echo "Script execution aborted."
        exit 1
    fi
}

check_version() {
    UBUNTU_VERSION=$(cat /etc/os-release | grep VERSION_ID | cut -d "=" -f 2 | sed 's/"/ /g')
    
    if [ "$(echo "$UBUNTU_VERSION >= 22.04" | bc -l)" -eq 1 ]; then
        script
    else
        printf "\033[38;2;255;0;255mUbuntu Not Compatible.\033[0m\n"
        printf "\033[38;2;255;0;255mAborted\033[0m\n"
    fi
}



show_agreement
create_banner




