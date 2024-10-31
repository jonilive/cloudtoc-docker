#!/bin/sh

# Exit on non defined variables and on non zero exit codes
set -eu

echo 'Debugging current directory and user id'
sudo chown -R 1000:1000 /cloudtoc
id
ls -la /cloudtoc

git config --global --add safe.directory /cloudtoc
git config --global init.defaultBranch ${GIT_BRANCH}

echo 'Getting latest version from cloudtoc git repo'
cd /cloudtoc
if [ -d .git ]; then
  echo 'Updating existent cloudtoc files'
  git pull
else
  echo 'Creating new cloudtoc installation'
  git init
  git remote add origin ${GIT_REPO}
  git fetch
  git checkout origin/${GIT_BRANCH} -ft
fi

echo 'Updating laravel .env file'
cat <<EOF > .env
APP_ENV=local
APP_KEY=${APP_KEY}
APP_URL="${APP_URL}"
FORCE_HTTPS=${FORCE_HTTPS}
DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE="${MYSQL_DATABASE}"
DB_USERNAME="root"
DB_PASSWORD="${MYSQL_ROOT_PASSWORD}"
BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DISK=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120
MAIL_MAILER=${MAIL_MAILER}
MAIL_HOST=${MAIL_HOST}
MAIL_PORT=${MAIL_PORT}
MAIL_USERNAME="${MAIL_USERNAME}"
MAIL_PASSWORD="${MAIL_PASSWORD}"
MAIL_ENCRYPTION=${MAIL_ENCRYPTION}
MAIL_FROM_ADDRESS="${MAIL_FROM_ADDRESS}"
MAIL_FROM_NAME="${MAIL_FROM_NAME}"
DISK_SPACE_MB=${DISK_SPACE_MB}
EOF

echo 'Updating client .env files'
for env_file in /cloudtoc/envs/.env.*; do
  if [ -f "$env_file" ]; then
    echo "Updating $env_file"
    sed -i -e "s;^APP_ENV=.*;APP_ENV=local;" "$env_file"
    sed -i -e "s;^APP_KEY=.*;APP_KEY=${APP_KEY};" "$env_file"
    sed -i -e "s;^APP_URL=.*;APP_URL=\"${APP_URL}\";" "$env_file"
    sed -i -e "s;^FORCE_HTTPS=.*;FORCE_HTTPS=${FORCE_HTTPS};" "$env_file"
    sed -i -e "s;^DB_CONNECTION=.*;DB_CONNECTION=mysql;" "$env_file"
    sed -i -e "s;^DB_HOST=.*;DB_HOST=mysql;" "$env_file"
    sed -i -e "s;^DB_PORT=.*;DB_PORT=3306;" "$env_file"
    sed -i -e "s;^DB_USERNAME=.*;DB_USERNAME=\"root\";" "$env_file"
    sed -i -e "s;^DB_PASSWORD=.*;DB_PASSWORD=\"${MYSQL_ROOT_PASSWORD}\";" "$env_file"
    sed -i -e "s;^BROADCAST_DRIVER=.*;BROADCAST_DRIVER=log;" "$env_file"
    sed -i -e "s;^CACHE_DRIVER=.*;CACHE_DRIVER=file;" "$env_file"
    sed -i -e "s;^FILESYSTEM_DISK=.*;FILESYSTEM_DISK=local;" "$env_file"
    sed -i -e "s;^QUEUE_CONNECTION=.*;QUEUE_CONNECTION=sync;" "$env_file"
    sed -i -e "s;^SESSION_DRIVER=.*;SESSION_DRIVER=file;" "$env_file"
    sed -i -e "s;^SESSION_LIFETIME=.*;SESSION_LIFETIME=120;" "$env_file"
    sed -i -e "s;^DISK_SPACE_MB=.*;DISK_SPACE_MB=${DISK_SPACE_MB};" "$env_file"
  fi
done

echo 'Running composer update'
composer update

echo 'Running artisan storage link'
php artisan storage:link

echo 'Running cron service'
sudo service cron start

echo 'Running apache2'
sudo /usr/sbin/apache2ctl -D FOREGROUND