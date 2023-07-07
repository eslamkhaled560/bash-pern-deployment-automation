#!/bin/bash


install_node() {
	curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
	sudo apt-get update
	sudo apt-get install -y nodejs
}

clone_repo() {
    git clone https://github.com/omarmohsen/pern-stack-example.git
    cd pern-stack-example
}

configure_static_ip() {
	ip_address=$(hostname -I | awk '{print $1}')

	sudo tee /etc/netplan/50_new_configs.yaml <<EOF
network:
  version: 2
  renderer: NetworkManager
  ethernets:
    ens33:
      dhcp4: no
      addresses: [$ip_address/24]
      routes:
        - to: default
          via: 192.168.214.2
      nameservers:
          addresses: [8.8.8.8,8.8.8.4]
EOF
  	sudo netplan apply
  	sudo systemctl restart NetworkManager
}

postgres() {
	sudo adduser node --disabled-password --gecos ""
	sudo apt-get install postgresql postgresql-contrib
	sudo systemctl start postgresql
	sudo systemctl enable postgresql
	
	sudo -u postgres psql -c "CREATE DATABASE node;"
	sudo -u postgres psql -c "CREATE USER node WITH PASSWORD 'node';"
	sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE node TO node;"

}


run_ui_tests_and_build() {	
  	cd ui
  	sudo apt update && sudo apt upgrade
  	sudo apt install npm
  	npm ci
  	npm audit fix
  	npm run test &

  	npm install
  	npm run build
  	cd ..
}

modify_webpack_config() {
	npm install webpack webpack-cli
	cd api
	npm ci
	npm audit fix
	sed -i "s/module/else if (environment === 'demo') {\n  console.log('this is demo env')\n  ENVIRONMENT_VARIABLES = {\n    'process.env.HOST': JSON.stringify('$ip_address'),\n    'process.env.USER': JSON.stringify('node'),\n    'process.env.DB': JSON.stringify('node'),\n    'process.env.DIALECT': JSON.stringify('postgres'),\n    'process.env.PORT': JSON.stringify('3080'),\n    'process.env.PG_CONNECTION_STR': JSON.stringify('postgres:\/\/node:node@localhost:5432\/node')\n  };\n}\n\n&/" webpack.config.js

	ENVIRONMENT=demo npm run build
	cd ..
}

start_application() {
  	cp -r api/dist/* .
  	cp api/swagger.css .
  	node api.bundle.js
  	npm install
}

main(){
	install_node
	clone_repo
	configure_static_ip
	postgres
	run_ui_tests_and_build
	modify_webpack_config
	start_application
}

main