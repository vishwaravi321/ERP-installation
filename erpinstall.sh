#!/bin/bash

set -e

NVM_VERSION="0.39.7"
NODE_VERSION="18"
FRAPPE_DEFAULT_VERSION="version-15"

trap 'echo -e "\e[91m[ERROR] Something broke. Fix your crap.\e[0m"' ERR

check_os_version() {
    local version
    version=$(grep VERSION_ID /etc/os-release | cut -d '=' -f2 | tr -d '"')
    if (( $(echo "$version < 22.04" | bc -l) )); then
        echo -e "\e[91m[ABORTED] Requires Ubuntu 22.04 or higher.\e[0m"
        exit 1
    fi
}

install_packages() {
    echo -e "\e[95m[+] Installing dependencies...\e[0m"
    sudo apt update -y
    sudo apt upgrade -y
    sudo apt install -y curl nginx python3-dev python3-setuptools python3-pip virtualenv \
        fail2ban libmysqlclient-dev redis-server xvfb libfontconfig wkhtmltopdf \
        software-properties-common lolcat python3-venv mariadb-server supervisor file
    sudo apt autoremove --purge -y
}

install_nvm_node() {
    if ! command -v nvm &>/dev/null; then
        echo -e "\e[95m[+] Installing NVM...\e[0m"
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v$NVM_VERSION/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
    fi

    echo -e "\e[95m[+] Installing Node.js LTS...\e[0m"
    nvm install "$NODE_VERSION"
    nvm alias default "$NODE_VERSION"
    npm install -g yarn
}

install_frappe_bench() {
    echo -e "\e[95m[+] Installing frappe-bench...\e[0m"
    sudo -H pip3 install --upgrade frappe-bench
}

configure_mysql() {
    if [[ ! -f ~/.mariadb_conf_success.txt ]]; then
        echo -e "\e[95m[+] Running mysql_secure_installation...\e[0m"
        sudo mysql_secure_installation
        echo -e "\e[95m[+] Configuring MySQL (50-server.cnf)...\e[0m"
        sudo tee /etc/mysql/mariadb.conf.d/50-server.cnf > /dev/null <<EOF
[mysqld]
innodb_file_per_table = 1
max_allowed_packet = 64M
character-set-client-handshake = FALSE
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci
EOF
        touch ~/.mariadb_conf_success.txt
        sudo systemctl restart mariadb
    else
        echo -e "\e[93m[!] MySQL already configured. Skipping.\e[0m"
    fi
}

setup_frappe_bench() {
    read -p "Bench install path [default: /home/$USER/]: " frappe_dir
    frappe_dir="${frappe_dir:-/home/$USER/}"

    if [[ ! -d "$frappe_dir" ]]; then
        echo -e "\e[91m[!] Invalid path. Exiting.\e[0m"
        exit 1
    fi

    read -p "Bench directory name [default: frappe-bench]: " bench_dir
    bench_dir="${bench_dir:-frappe-bench}"
    full_dir="${frappe_dir}${bench_dir}"

    read -p "Frappe version [version-14/version-15] (default: $FRAPPE_DEFAULT_VERSION): " ver
    ver="${ver:-$FRAPPE_DEFAULT_VERSION}"

    echo -e "\e[95m[+] Initializing bench...\e[0m"
    bench init "$full_dir" --frappe-branch "$ver"

    read -p "Additional apps (comma-separated) [optional]: " apps
    if [[ -n "$apps" ]]; then
        for app in $(echo "$apps" | tr ',' ' '); do
            read -p "Branch for $app: " branch
            bench --site "$full_dir" get-app "$app" --branch "$branch"
        done
    fi

    echo -e "\e[95m[+] Applying permissions...\e[0m"
    sudo chown -R "$USER:$USER" "$full_dir"
    sudo chmod -R 755 "$full_dir"

    echo -e "\e[95m[+] Setting up Redis, Supervisor, SocketIO, Nginx...\e[0m"
    cd "$full_dir"
    bench setup redis
    bench setup socketio
    bench setup supervisor
    bench setup nginx --log_format ''

    echo -e "\e[92m[✔] Done. Run the following:\e[0m"
    echo -e "  source ~/.bashrc"
    echo -e "  cd $full_dir && sudo bench setup production $USER"
}

main() {
    echo -e "\e[91m⚠️  This script modifies your system. Use at your own risk.\e[0m"
    read -p "Continue? (yes/no): " confirm
    [[ "$confirm" != "yes" ]] && echo "Aborted." && exit 1

    check_os_version
    install_packages
    install_nvm_node
    install_frappe_bench
    configure_mysql
    setup_frappe_bench
}

main
