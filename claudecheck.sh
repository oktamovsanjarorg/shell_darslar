#!/bin/bash

echo " SERVER HEALTH CHECK $(date) "

cpu=$(ps aux --sort=-%cpu)
echo "$cpu"
