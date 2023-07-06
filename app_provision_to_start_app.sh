#!/bin/bash

#Creating DB_HOST env variable
export DB_HOST=mongodb://172.31.38.156:27017/posts
#getting inside app folder
cd repo/app
# installing the app
npm install
# repopulate db
node seeds/seed.js
# starting the app
pm2 start app.js  