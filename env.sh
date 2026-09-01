#!/bin/bash
env="${environment:-development}"
echo "hozirgi muhit $env"

environment="production"
env="${environment:-development}"
echo "hozirgi muhit : $env"
