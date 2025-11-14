 #!/bin/bash

source ./common.sh
app_name=shipping

check_root
app_setup
python_setup
systemd_setup  


app_restart
print_total_time