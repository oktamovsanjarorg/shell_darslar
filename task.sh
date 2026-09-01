#!/bin/bash
files=("app_nginx.prod.log" "app_postgres.prod.log" "app_redis.prod.log")

for file in ${files[@]}; do 
  name=${file#app_}
  name=${name%.prod.log}
  echo ${name^^}
done
