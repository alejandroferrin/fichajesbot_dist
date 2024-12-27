#!/bin/sh

# Verificación de argumentos
if [ "$#" -ne 7 ]; then
    echo "Wrong number of arguments"
    echo "./setup.sh DBPASS MYSQL_ROOT_PASSWORD TELEGRAM_BOT_TOKEN TELEGRAM_BOT_NAME ENCRYPTION_KEY ADMIN_DEFAULT_ACTIVATION_CODE ADMIN_DEFAULT_NAME"
    exit 1
fi

DBPASS=$1
MYSQL_ROOT_PASSWORD=$2
TELEGRAM_BOT_TOKEN=$3
TELEGRAM_BOT_NAME=$4
ENCRYPTION_KEY=$5
ADMIN_DEFAULT_ACTIVATION_CODE=$6
ADMIN_DEFAULT_NAME=$7


#docker-compose
cat <<EOL > ./docker-compose.yml
services:
  db:
    container_name: fichajesbotdb
    image: 'linuxserver/mariadb:10.11.10'
    ports:
      - "3306:3306"
    environment:
      - MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD
      - MYSQL_DATABASE=db_fichajesbot
      - MYSQL_USER=fichajes
      - MYSQL_PASSWORD=$DBPASS
    volumes:
      - db_data:/var/lib/mysql
    restart: always

  app:
    container_name: fichajesbotapp
    image: 'alexfer/fichajesbot:0.1.0'
    environment:
      - SPRING_PROFILES_ACTIVE=docker
      - SPRING_DATASOURCE_URL=jdbc:mariadb://db:3306/db_fichajesbot
      - SPRING_DATASOURCE_USERNAME=fichajes
      - SPRING_DATASOURCE_PASSWORD=$DBPASS
      - TELEGRAM_BOT_TOKEN=$TELEGRAM_BOT_TOKEN
      - TELEGRAM_BOT_NAME=$TELEGRAM_BOT_NAME
      - ENCRYPTION_KEY=$ENCRYPTION_KEY
      - ADMIN_DEFAULT_ACTIVATION_CODE=$ADMIN_DEFAULT_ACTIVATION_CODE
      - ADMIN_DEFAULT_NAME=$ADMIN_DEFAULT_NAME
    ports:
      - "8080:8080"
    links:
      - "db"
    depends_on:
      - "db"
    restart: always
volumes:
  db_data:
EOL