#!/bin/bash

services=("nginx" "mysql" "redis")
services+=("rabbitmq")
echo "xizmatlar : ${services[@]}"
echo "jami xizmatlar ${#services[@]}"

for say in "${services[@]}"; do
  echo "we have a $say services"
done
