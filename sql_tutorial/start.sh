#!/bin/sh
gz_flag=$FLAG
length=$(echo -n "$gz_flag" | wc -c)
part_length=$((length / 3))

part1=$(echo -n "$gz_flag" | cut -c1-$part_length)
part2_start=$((part_length + 1))
part2_end=$((2 * part_length))
part2=$(echo -n "$gz_flag" | cut -c$part2_start-$part2_end)
part3_start=$((2 * part_length + 1))
part3=$(echo -n "$gz_flag" | cut -c$part3_start-)

mysqld_safe &
sleep 5
mysql -uroot -proot -e "CREATE DATABASE ctf;CREATE DATABASE secret;"
mysql -uroot -proot -D ctf < /var/ctf.sql
mysql -uroot -proot -D secret < /var/secret.sql
mysql -uroot -proot -e "SET NAMES utf8mb4;SET FOREIGN_KEY_CHECKS = 0;use secret;UPDATE password SET flag = '$part1' WHERE id = '1' LIMIT 1"
mysql -uroot -proot -e "SET NAMES utf8mb4;SET FOREIGN_KEY_CHECKS = 0;use ctf;UPDATE score SET grade = '$part2' WHERE student = 'begin' LIMIT 1"
echo $part3 > /flag
export GZCTF_FLAG=no_FLAG
apache2-foreground