#!/bin/bash -e

echo ">>>> Synching files for longknife"

echo ">> kernel config"
cp /usr/src/linux/.config kernel/.config

echo ">>>> Done"
