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

# CHECK_APACHE=""
# CHECK_MYSQL=""
# CHECK_WP_CLI=""

WP_CLI_DIR="$HOME/.wp-cli"

DBNAME="$1"

echo "$1"
echo "$DBNAME"

# PROJECT_URL=""
# CONST=""
# ADMIN_USER=""
# ADMIN_PASS=""
# ADMIN_MAIL="$ADMIN_USER@email.com"

# Check MySQL
if [ ! -z "$(which mysql)" ]; then
  echo 'mysql installed'

  if [ "$(pgrep mysql | wc -l)" -ne 1 ]; then
    echo 'mysql down'
    exit 1
  else
    echo 'mysql up!'
  fi
else
  echo 'mysql not installed'
fi


# Check WP-CLI
if [ ! -z "$(which wp)" ]; then
  echo 'wp-cli installed'

  mkdir -p "$WP_CLI_DIR"
else
  echo 'wp-cli not installed'
fi

# Project URL
if [ ! -z "$(which dnsmasq)" ]; then
  echo 'dnsmasq'
  PROJECT_URL="http://$1.dev"
else
  PROJECT_URL="http://localhost/$1"
fi


wp core download

wp core config --dbhost=localhost --dbname="$DBNAME" --dbprefix=wp16_ --dbuser=root --dbpass="root" 

wp db create 

wp core install --url="$PROJECT_URL" --title="SiteTitle" --admin_user=admin --admin_password="admin" --admin_email=azh@sribu.com 

# if [ "$(uname -s)" != "Darwin" ]; then
#   echo "Sorry, Pow requires Mac OS X to run." >&2
#   exit 1
# fi