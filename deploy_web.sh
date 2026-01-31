#!/bin/bash

# -------------------------------------------------
# Script Name : deploy_web.sh
# Purpose     : Build and deploy WAR to Tomcat
# Author      : sak_shetty
# -------------------------------------------------

TOMCAT_DIR="/root/apache-tomcat-9.0.111"
TOMCAT_WEBAPPS="$TOMCAT_DIR/webapps"
BASE_DIR="/root"

echo "=============================================="
echo " Fastrack Deployment Script"
echo " Designed and done by sak_shetty"
echo "=============================================="

# 1. Ask project directory name
read -p "Enter project directory name (example: fastrack): " PROJECT_NAME
PROJECT_DIR="$BASE_DIR/$PROJECT_NAME"

if [ ! -d "$PROJECT_DIR" ]; then
    echo "❌ Project directory not found: $PROJECT_DIR"
    exit 1
fi

cd "$PROJECT_DIR" || exit 1

# 2. Check Java 17
echo "Checking Java 17..."
if ! java -version 2>&1 | grep -q "17"; then
    echo "❌ Java 17 is NOT installed."
    echo "👉 Install Java 17 and re-run the script."
    exit 1
fi
echo "✅ Java 17 is installed."

# 3. Check Maven
echo "Checking Maven..."
if ! command -v mvn >/dev/null 2>&1; then
    echo "❌ Maven is NOT installed."
    echo "👉 Install Maven and re-run the script."
    exit 1
fi
echo "✅ Maven is installed."

# 4. Build WAR
echo "Building WAR..."
mvn clean package
if [ $? -ne 0 ]; then
    echo "❌ Maven build failed."
    exit 1
fi
echo "✅ Build completed."

# 5. Show WAR files
echo
echo "Available WAR files:"
ls target/*.war 2>/dev/null

if [ $? -ne 0 ]; then
    echo "❌ No WAR files found in target directory."
    exit 1
fi

# 6. Ask WAR selection
echo
read -p "Type the WAR file name to deploy: " WAR_NAME
WAR_FILE="$PROJECT_DIR/target/$WAR_NAME"

if [ ! -f "$WAR_FILE" ]; then
    echo "❌ WAR file not found."
    exit 1
fi

# 7. Confirm deployment
read -p "Do you want to deploy $WAR_NAME to Tomcat? (yes/no): " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
    echo "Deployment cancelled."
    exit 0
fi

# 8. Check Tomcat
echo "Checking Tomcat..."
if [ ! -d "$TOMCAT_DIR" ]; then
    echo "❌ Tomcat not found at $TOMCAT_DIR"
    exit 1
fi

if ! ps -ef | grep -v grep | grep -q "$TOMCAT_DIR"; then
    echo "❌ Tomcat is NOT running."
    echo "👉 Start Tomcat and re-run the script."
    exit 1
fi
echo "✅ Tomcat is running."

# 9. Deploy WAR
echo "Deploying WAR..."
cp "$WAR_FILE" "$TOMCAT_WEBAPPS/"
echo "✅ WAR deployed successfully."

echo "=============================================="
echo " 🎉 Application deployed in Tomcat"
echo " URL: http://<server-ip>:8080/${WAR_NAME%.war}"
echo "=============================================="
