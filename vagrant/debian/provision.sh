
print_message () {
  echo "    >>>>>>>=============>  $1"
  echo "    >>>>>>>=============>  $1" >> /tmp/provision.log
}

quite_install () {
    if ! command -v $1 > /dev/null; then
        print_message "$1 installing"
        apt-get -qq install -y $1 >> /tmp/provision.log
        print_message "$1 installed"
    else
        print_message "$1 already installed!"
    fi
}

check () {
    if ! command -v $1 > /dev/null; then
        quite_install $1
    fi
}

set_sources () {
    print_message "Setting sources.list"
    cat > /etc/apt/sources.list << EOF
deb http://deb.debian.org/debian stretch main contrib non-free
deb http://http.debian.net/debian stretch-backports main contrib non-free
deb http://security.debian.org/debian-security stretch/updates main contrib non-free
EOF
    print_message "sources.list set"
}

reset_ssh_message () {
    print_message "Reseting SSH welcome message"
    echo -n > /etc/motd
    print_message "SSH welcome message reset"
}

update_repositories () {
    print_message "Updating repositories"
    apt-get -qq update >> /tmp/provision.log
    print_message "Updated repositories"
}

perform_upgrade () {
    print_message "Performing upgrade"
    apt-get -qq -y upgrade >> /tmp/provision.log
    print_message "Upgrade complete"
}

add_nodejs_repositories () {
    check curl
    print_message "Adding nodejs_8.x repositories"
    curl -s -o /tmp/setup_8.x https://deb.nodesource.com/setup_8.x >> /tmp/provision.log
    chmod a+x /tmp/setup_8.x
    /tmp/setup_8.x >> /tmp/provision.log
    print_message "nodejs_8.x repositories added"
}

install_pm2 () {
    check nodejs
    print_message "pm2 installing"
    npm install pm2 -s -g >> /tmp/provision.log
    print_message "pm2 installed"
}

install_lein () {
    check curl
    print_message "lein installing"
    curl -s -o /usr/bin/lein https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein >> /tmp/provision.log
    chmod a+x /usr/bin/lein
    /usr/bin/lein >> /tmp/provision.log
    print_message "lein installed"
}

install_rustc () {
    check curl
    print_message "rustc installing"
    curl -s -o /tmp/rustup.sh https://static.rust-lang.org/rustup.sh >> /tmp/provision.log
    chmod a+x /tmp/rustup.sh
    sh /tmp/rustup.sh >> /tmp/provision.log
    print_message "rustc installed"
}

set_samba_config () {
    print_message "Setting smb.conf"
    cat > /etc/samba/smb.conf << EOF
[global]
   workgroup = WORKGROUP
   server string = %h server (Samba, Ubuntu)
   dns proxy = no
   log file = /var/log/samba/log.%m
   max log size = 10000
   syslog = 0
   panic action = /usr/share/samba/panic-action %d
   server role = standalone server
   passdb backend = tdbsam
   obey pam restrictions = yes
   unix password sync = yes
   passwd program = /usr/bin/passwd %u
   passwd chat = *Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* .
   pam password change = yes
   map to guest = bad user
   load printers = no
   usershare allow guests = yes
   guest account = upseller
   usershare allow guests = yes

[printers]
   comment = All Printers
   browseable = no
   path = /var/spool/samba
   printable = yes
   guest ok = no
   read only = yes
   create mask = 0700

[print$]
   comment = Printer Drivers
   path = /var/lib/samba/printers
   browseable = yes
   read only = yes
   guest ok = no

[work]
   comment = /
   path = /
   browseable = yes
   read only = no
   public = yes
   available = yes
   writeable = yes
   guest ok = yes
   map archive = no
EOF
    print_message "smb.conf set"
}

main () {
    export DEBIAN_FRONTEND=noninteractive

    touch /tmp/provision.log
    echo > /tmp/provision.log

    set_sources
    reset_ssh_message
    update_repositories
    perform_upgrade
    add_nodejs_repositories

    quite_install curl
    quite_install sysvinit-utils
    quite_install vim
    quite_install rlwrap
    quite_install openjdk-9-jre
    quite_install openjdk-9-jdk
    quite_install git
    quite_install subversion
    quite_install samba
    quite_install sbcl
    quite_install nodejs
    quite_install build-essential

    install_pm2
    install_lein
    install_rustc

    set_samba_config

    print_message "Full logs at /tmp/provision.log"
    print_message "Provision complete."
}

main