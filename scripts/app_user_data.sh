#!/bin/bash


cd /home/ubuntu/app
export DB_HOST=mongodb://${private_ip}:27017 
node app.js