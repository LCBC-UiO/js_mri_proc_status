#!/usr/bin/env bash

printf "Content-Type: text/plain; charset=UTF-8\r\n"
printf "\r\n"

date -r ${DATADIR}/${QUERY_STRING:1} +"%Y-%m-%d at %H:%M:%S"