#!/bin/bash

DATE=`eval date +%Y%m%d`

MYSQL_DB=socialactions_development
MYSQL_USER=root

# don't use extentions, they are added automagically
MYSQL_DUMP_FILE=/var/data/socialactions/socialactions

# Once the whole db is dumped, we can also dump individual tables into individual files . .
MYSQL_TABLES_FOR_DUMP=(actions logs)

mysqldump -u $MYSQL_USER $MYSQL_DB > ${MYSQL_DUMP_FILE}.sql
gzip -f ${MYSQL_DUMP_FILE}.sql
cp ${MYSQL_DUMP_FILE}.sql.gz ${MYSQL_DUMP_FILE}-${DATE}.sql.gz


tablenum=${#MYSQL_TABLES_FOR_DUMP[*]}
for ((i=0;i<$tablenum;i++)); do
   cur_table=${MYSQL_TABLES_FOR_DUMP[${i}]}
   mysqldump -u $MYSQL_USER $MYSQL_DB ${cur_table} > ${MYSQL_DUMP_FILE}-${cur_table}.sql
   gzip -f ${MYSQL_DUMP_FILE}-${cur_table}.sql
   cp ${MYSQL_DUMP_FILE}-${cur_table}.sql.gz ${MYSQL_DUMP_FILE}-${cur_table}-${DATE}.sql.gz
done