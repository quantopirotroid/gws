#!/bin/bash

if [[ $1 == '-o' && $2 != 0 ]];
then
    NUM=$2
    ssh $(mysql -h 10.0.0.1 -Bse "SELECT ext_ip FROM complete WHERE s_num = '${NUM}'" -D rbt)
elif [[ $1 != 0 && $2 == '' ]];
then
    NUM=$1
    ssh $(mysql -h 10.0.0.1 -Bse "SELECT int_ip FROM complete WHERE s_num = '${NUM}'" -D rbt)
fi
