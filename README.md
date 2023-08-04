# DevOps Assesment

## 1. Specification and OS Server on GCP
- Machine Type: e2-small
- CPU: 2 vCPU
- Memory: 2 GB memory
- Storage: 30 GB
- OS: Ubuntu 22.04 LTS

To set up the vm with Terraform
1. Move to infra directory
   ```bash
   cd infra
   ```
2. Set environment variable to enable Terraform access to cloud using service account
   - Linux
   ```bash
   export TF_VAR_google_credentials=your_service_account_directory
   ```
   - PowerShell
   ```bash
   $env:TF_VAR_google_credentials="your_service_account_directory"
   ```
3. Initialize everything needed by Terraform to run
   ```bash
   terraform init
   ```
4. Check the resources that will be created
   ```bash
   terraform plan
   ```
5. Apply the resources that will be created
   ```bash
   terraform apply
   ```

## 2. Setting up server environment 
You need to open SSH before running these commands
### Install PHP 8.1
1. Update system
   ```bash
   sudo apt update
   ```
2. Run the command
   ```bash
   sudo apt install php8.1
   ```
3. Ensure you installed the correct php version
   ```bash
   php -v
   ```
### Install Nginx 1.18
1. Check if apache2 has been installed
   ```bash
   which apache2
   ```
2. The command above should return blank line, if not then stop it
   ```bash
   sudo service apache2 stop
   ```
3. Remove and clean up apache2 packages
   ```bash
   sudo apt-get purge apache2 apache2-utils apache2-bin apache2.2-common
   ```
4. Clean up dependencies
   ```bash
   sudo apt-get autoremove
   ```
5. Run this command to make sure that apache has been removed
   ```bash
   sudo service apache2 start
   ```
6. Run the command
   ```bash
   sudo apt install nginx=1.18.*
   ```
7. Ensure you installed the correct nginx version
   ```bash
   nginx -v
   ```
8. Restart nginx in case nginx doesn't run properly
   ```bash
   sudo service nginx restart
   ```
### Install MariaDB 10.6
1. Run the command to install
   ```bash
   sudo apt install mariadb-server
   ```
2. Check its status
   ```bash
   systemctl status mariadb
   ```
3. To protect the database run this command, you will be asked to configure few things
   ```bash
   sudo mysql_secure_installation
   ```
   - Password for root: Just press ENTER
   - Unix-socket authentication: type `n`
   - Change the root password: type `n`
   - Type `y` for the rest of configurations
4. Login to MariaDB
   ```bash
   sudo mariadb
   ```
5. Configure the database
   ```bash
   CREATE USER 'admin'@'localhost' IDENTIFIED BY 'admin';
   CREATE DATABASE deploy_db;
   GRANT ALL ON deploy_db.* TO 'admin'@'localhost';
   FLUSH PRIVILEGES;
   ```
6. Exit MariaDB
   ```bash
   QUIT;
   ```
### Install Composer 2.2
1. Install the required packages
   ```bash
   sudo apt install php-cli unzip
   ```
2. To install specific version, run these commands
   ```bash
   php -r "copy ('https://getcomposer.org/installer', 'composer-setup.php');"
   ```
   ```bash
   php composer-setup.php --version=2.2.21
   ```
3. Move `composer.phar`
   ```bash
   sudo mv composer.phar /usr/local/bin/composer
   ```
4. Check the composer
   ```bash
   composer -v
   ```
### Install NPM
1. Obtain the file from the source
   ```bash
   curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
   ```
2. Install it
   ```bash
   sudo apt-get install -y nodejs
   ```
3. Ensure that the latest version of NPM is installed
   ```bash
   sudo npm install -g npm@latest
   ```
4. Check node or npm version
   ```bash
   node -v
   ```
   ```bash
   npm -v
   ```
## 3. App deployment
1. Move to directory as below
   ```bash
   cd /var/www
   ```
2. Clone the app repository
   ```bash
   sudo git clone https://github.com/nasirkhan/laravel-starter.git
   ```
3. Install the extensions needed
   ````bash
   sudo apt install php8.1-dom php8.1-curl php8.1-xml php8.1-zip php8.1-mysql php8.1-mbstring php8.1-bcmath
   ``    
4. Run the following command
   ```bash
   sudo chown -R $(whoami) laravel-starter
   sudo chgrp -R www-data /var/www/laravel-starter
   sudo chmod -R 775 /var/www/laravel-starter/storage
   ```
5. Move to the cloned directory
   ```bash
   cd laravel-starter/
   ```
6. Run this command
   ```bash
   composer install
   ```
7. Copy `.env.example` to `.env` with
   ```bash
   cp .env.example .env
   ```
8. Run command `vim .env` and press `i` to insert before the cursor. After that set these fields as below
   ```bash
   DB_CONNECTION=mysql
   DB_HOST=127.0.0.1
   DB_PORT=3306
   DB_DATABASE=deploy_db
   DB_USERNAME=admin
   DB_PASSWORD=admin
   ```
9. Press `esc` to exit insert mode and type `:wq` to save and quit 
10. Run this command
    ```bash
    php artisan key:generate
    ```
11. Migrate table from laravel to mariadb
    ```bash
    php artisan migrate
    ```
12. Move directory
    ```bash
    cd /etc/nginx/sites-available/
    ```
13. Run `sudo vim deployphp.net` and press `i` to input this configuration
    ```bash
    server {
      listen 80;
      listen [::]:80;
      server_name http://34.101.120.146/;
      root /var/www/laravel-starter/public;
   
      add_header X-Frame-Options "SAMEORIGIN";
      add_header X-Content-Type-Options "nosniff";
   
      index index.php;
   
      charset utf-8;
   
      location / {
         try_files $uri $uri/ /index.php?$query_string;
      }
   
      location = /favicon.ico { access_log off; log_not_found off; }
      location = /robots.txt  { access_log off; log_not_found off; }
   
      error_page 404 /index.php;
   
      location ~ \.php$ {
         fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
         fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
         include fastcgi_params;
      }
   
      location ~ /\.(?!well-known).* {
         deny all;
      }
    }
    ```
14. Press `esc` to exit insert mode and type `:wq` to save and quit 
15. Restart nginx
    ```bash
    sudo systemctl reboot nginx
    ```