#!/bin/bash

# This is installation script for WordPress development on localhost 
# 
# TODO:
# check OS
# check WP-CLI
# check Apache and MySQL running services
# check Apache DocumentRoot
# install WordPress
# open site in browser

# Check the number of arguments
if [ $# -lt 1 ]; then
  echo
  echo "Please type arguments"
  echo "Usage: $0 project (optional)dbpass"
  echo
  exit
fi

CHECK_OS="$(uname -s)"
PROJECT_NAME="$1"
DBNAME="$1_db"
DBPASS=${2:-root}
# WP_CLI_DIR="$HOME/.wp-cli"

# Check WP-CLI
if [ ! -z "$(command -v wp)" ]; then
  wp --info | grep 'WP-CLI version'
  CHECK_WP_CLI=true
else
  echo 'WP-CLI is not installed'
  echo 'This script requires WP-CLI for running'
  exit 1
fi

# Choose url for project
read -p "Are you using http://localhost/$1 as url? [y/n] " URL1

if [ "$URL1" == "y" ]; then
  PROJECT_URL="http://localhost/$1"
else
  read -p "Are you using http://$1.dev as url? [y/n] " URL2

  if [ "$URL2" == "y" ]; then
    PROJECT_URL="http://$1.dev"
  fi
fi

# Timer
SECONDS=0

# Check Apache root dir
if [ ! -z "$(command -v apache2ctl)" ]; then
  DOCROOT="$( apache2ctl -S | grep "Main DocumentRoot" | cut -d\  -f3 | tr -d '"' )"
elif [ ! -z "$(command -v apachectl)" ]; then
  DOCROOT="$( apachectl -S | grep "Main DocumentRoot" | cut -d\  -f3 | tr -d '"' )"
elif [ ! -z "$(command -v httpd)" ]; then
  DOCROOT="$( httpd -S | grep "Main DocumentRoot" | cut -d\  -f3 | tr -d '"' )"
fi

PROJECT_DIR="$DOCROOT/$1"

# Brace yourself, WordPress is installing
if [ "$CHECK_WP_CLI" ]; then

  mkdir -p "$PROJECT_DIR"

  cd "$PROJECT_DIR" || { echo "Cannot open directory. Aborting."; exit 1; }

  wp core download

  wp core config --dbhost=localhost --dbname="$DBNAME" --dbprefix=wpld_ --dbuser=root --dbpass="$DBPASS" 

  wp db create 

  wp core install --url="$PROJECT_URL" --title="$PROJECT_NAME" --admin_user=admin --admin_password="admin" --admin_email=admin@email.com 

  # Delete plugin: hello dolly
  wp plugin delete hello

fi

echo -e "\033[0;32m$SECONDS seconds\033[0m"

# Open project in OS default browser
case "$CHECK_OS" in
  Linux ) xdg-open "$PROJECT_URL" ;;
  Darwin ) open "$PROJECT_URL" ;;
  * ) echo "Your OS is not supported yet, sorry!" ;;
esac

exit 1