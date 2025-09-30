#!/bin/bash

source ./common.sh
app_name=cart

app_setup
nodejs_setup
systemd_setup
nodejs_setup
systemd_setup
app_restart
print_total_time