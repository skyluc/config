#!/bin/bash -e

echo ">>>> Synching files for longknife"

echo ">> /etc"
cp /etc/portage/make.conf etc/portage/make.conf
cp /etc/portage/package.accept_keywords etc/portage/package.accept_keywords
cp /etc/conf.d/hostname etc/conf.d/hostname
cp /etc/conf.d/keymaps etc/conf.d/keymaps
cp /etc/env.d/02locale etc/env.d/02locale
cp /etc/timezone etc/timezone
cp /etc/hosts etc/hosts
cp /etc/locale.gen etc/locale.gen

echo ">> kernel config"
cp /usr/src/linux/.config kernel/.config

echo ">>>> Done"
