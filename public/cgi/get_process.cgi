#!/usr/bin/env bash

echo "Content-Type: application/json; charset=UTF-8"
echo "Status: 200"
echo ""

cat ${DATADIR}/process.json
