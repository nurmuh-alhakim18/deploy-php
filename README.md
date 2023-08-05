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
2. Generate service account key from your project, refer to this link:
   ```bash
   https://cloud.google.com/iam/docs/keys-create-delete
   ```
3. Set environment variable to enable Terraform access to cloud using service account
   - Linux
   ```bash
   export TF_VAR_google_credentials=your_service_account_directory
   ```
   - PowerShell
   ```bash
   $env:TF_VAR_google_credentials="your_service_account_directory"
   ```
4. Initialize everything needed by Terraform to run
   ```bash
   terraform init
   ```
5. Check the resources that will be created
   ```bash
   terraform plan
   ```
6. Apply the resources that will be created
   ```bash
   terraform apply
   ```
   Run `terraform apply` until there is no change made by terraform, it takes approximately 3 times
## 2. Setting up server environment 
You need to open SSH before running these commands
### Install PHP 8.1
1. Update system
   ```bash
   sudo apt update
   ```
2. Install the packages needed
   ```bash
   sudo apt install php8.1-dom php8.1-curl php8.1-xml php8.1-zip php8.1-mysql php8.1-fpm php8.1-mbstring php8.1-bcmath php8.1-cli unzip
   ```    
3. Ensure you installed the correct php version
   ```bash
   php -v
   ```
### Install Nginx 1.18
1. Run the command
   ```bash
   sudo apt install nginx=1.18.*
   ```
2. Ensure you installed the correct nginx version
   ```bash
   nginx -v
   ```
3. Restart nginx in case nginx doesn't run properly
   ```bash
   sudo service nginx restart
   ```
### Install MariaDB 10.6
1. Run the command to install
   ```bash
   sudo apt install mariadb-server mariadb-client
   ```
2. Check its status
   ```bash
   systemctl status mariadb
   ```
   To exit press `ctrl + c`
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
1. To install specific version, run these commands
   ```bash
   php -r "copy ('https://getcomposer.org/installer', 'composer-setup.php');"
   ```
   ```bash
   php composer-setup.php --version=2.2.21
   ```
2. Move `composer.phar`
   ```bash
   sudo mv composer.phar /usr/local/bin/composer
   ```
3. Check the composer
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
### Local VM run
1. Move to directory as below
   ```bash
   cd /var/www
   ```
2. Clone the app repository
   ```bash
   sudo git clone https://github.com/nasirkhan/laravel-starter.git
   ``` 
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
6. Copy `.env.example` to `.env` with
   ```bash
   cp .env.example .env
   ```
7. Run command `sudo vim .env` and press `i` to insert before the cursor. After that set these fields as below
   ```bash
   DB_CONNECTION=mysql
   DB_HOST=127.0.0.1
   DB_PORT=3306
   DB_DATABASE=deploy_db
   DB_USERNAME=admin
   DB_PASSWORD=admin
   ```
8. Press `esc` to exit insert mode and type `:wq` to save and quit
9. Run this command
   ```bash
   composer install
   ``` 
10. Run this command
    ```bash
    php artisan key:generate
    ```
11. Migrate table from laravel to mariadb
    ```bash
    php artisan migrate --seed
    ```
12. Link storage directory
    ```bash
    php artisan storage:link
    ```
13. Test the server without nginx
    ```bash
    php artisan serve --host=0.0.0.0
    ```
### Configuring Nginx
1. Move directory
    ```bash
    cd /etc/nginx/sites-available/
    ```
2. Run `sudo vim deployphp.net` and press `gg` to move to the first line, then type `dG` to clear all text. After that press `i` to input this configuration
    ```bash
    server {
      listen 80;
      server_name server_domain_or_IP;
      root /var/www/laravel_starter/public;

      add_header X-Frame-Options "SAMEORIGIN";
      add_header X-XSS-Protection "1; mode=block";
      add_header X-Content-Type-Options "nosniff";

      index index.html index.htm index.nginx-debian.html index.php;

      charset utf-8;

      location / {
         try_files $uri $uri/ /index.php?$query_string;
      }

      location = /favicon.ico { access_log off; log_not_found off; }
      location = /robots.txt  { access_log off; log_not_found off; }

      error_page 404 /index.php;

      location ~ \.php$ {
         fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
         fastcgi_index index.php;
         fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
         include fastcgi_params;
      }

      location ~ /\.(?!well-known).* {
         deny all;
      }
    }
    ```
3. Press `esc` to exit insert mode and type `:wq` to save and quit 
4. Link to `sites-enabled`
    ```bash
    sudo ln -s /etc/nginx/sites-available/deployphp.net /etc/nginx/sites-enabled/
    ```
5. Confirm the configuration that are no error found
    ```bash
    sudo nginx -t
    ```
6. Apply the changes by reloading nginx
    ```bash
    sudo systemctl reload nginx
    ```