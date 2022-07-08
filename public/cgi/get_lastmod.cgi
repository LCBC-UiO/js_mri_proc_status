#!/usr/bin/env bash

printf "Content-Type: text/plain; charset=UTF-8\r\n"
printf "\r\n"

date -r ../json/data.json +"%Y-%m-%d at %H:%M:%S"