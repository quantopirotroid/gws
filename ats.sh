#!/bin/bash

NUM=$1

ssh $(mysql -h 10.0.0.1 -Bse "SELECT voip_ip FROM complete WHERE s_num = '${NUM}'" -D rbt)
