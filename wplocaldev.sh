#!/bin/sh

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
  echo "Usage: $0 project (optional)dbpass (optional)arg3"
  echo
  exit
fi

CHECK_OS="$(uname -s)"

PROJECT_NAME="$1"
DBNAME="$1_db"
DBPASS=${2:-root}

# echo "$DBNAME"
# echo "$DBPASS"

read -p "Are you using http://localhost/$1 as url? [y/n] " URL1

if [ "$URL1" == "y" ]; then
  PROJECT_URL="http://localhost/$1"
else
  read -p "Are you using http://$1.dev as url? [y/n] " URL2

  if [ "$URL2" == "y" ]; then
    PROJECT_URL="http://$1.dev"
  fi
fi

# echo "$PROJECT_URL"


if [ ! -z "$(which apache2ctl)" ]; then
  DOCROOT="$( apache2ctl -S | grep 'Main DocumentRoot: ' | tr -d '"' | awk ' { print $3 } ' )"
elif [ ! -z "$(which apachectl)" ]; then
  DOCROOT="$( apachectl -S | grep 'Main DocumentRoot: ' | tr -d '"' | awk ' { print $3 } ' )"
elif [ ! -z "$(which httpd)" ]; then
  DOCROOT="$( httpd -S | grep 'Main DocumentRoot: ' | tr -d '"' | awk ' { print $3 } ' )"
fi

PROJECT_DIR="$DOCROOT/$1"

# echo "$PROJECT_DIR"

# MY_PARAM=${1:-default}

WP_CLI_DIR="$HOME/.wp-cli"

# echo "$CHECK_OS"

# Check WP-CLI
if [ ! -z "$(which wp)" ]; then
  echo 'WP-CLI installed'

  # mkdir -p "$WP_CLI_DIR"

  CHECK_WP_CLI="true"
else
  echo 'WP-CLI is not installed'
  echo 'This script requires WP-CLI for running'
  exit 1
fi

# echo "$CHECK_WP_CLI"

if [ "$CHECK_WP_CLI" == "true" ]; then

  mkdir -p "$PROJECT_DIR"

  cd "$PROJECT_DIR"

  wp core download

  wp core config --dbhost=localhost --dbname="$DBNAME" --dbprefix=wpld_ --dbuser=root --dbpass="$DBPASS" 

  wp db create 

  wp core install --url="$PROJECT_URL" --title="Test WPLOCALDEV" --admin_user=admin --admin_password="admin" --admin_email=admin@email.com 

  # Delete plugin: hello dolly
  wp plugin delete hello

fi




if [ "$CHECK_OS" == "Linux" ]; then
  # echo 'Linux'
  xdg-open "$PROJECT_URL"
elif [ "$CHECK_OS" == "Darwin" ]; then
  # echo 'Darwin'
  open "$PROJECT_URL"
fi