#!/bin/bash

# ****************************************************************
#
# 	SCRIPT SETTINGS
#
# ----------------------------------------------------------------
#

	# Sqlite3 database filename
	SQLITE_FILE=testdb

	# Dump filename
	DUMP_FILE=dump.sql

	# MySQL script filename
	MYSQL_FILE=sailbot.mysql.sql

#
# ****************************************************************

printf "\n************************************************\n*                                              *\n"
printf "*   \033[32mSailing robot SQLite3 to MySQL converter\033[39m   *\n"
printf "*                                              *\n************************************************\n"

printf "\nDumping the SQLite3 database into \033[33m$DUMP_FILE\033[39m\n"
sqlite3 $SQLITE_FILE .dump > $DUMP_FILE
[ $? -ne 0 ] && exit -1

printf "\nConverting SQLite3 dump to MySQL syntax..."
printf " Done!\n"
sed -i s/\"/\`/g $DUMP_FILE
sed -i s/AUTOINCREMENT/AUTO_INCREMENT/g $DUMP_FILE
sed -i s/varchar/varchar\(255\)/g $DUMP_FILE
sed -i s/VARCHAR/varchar\(255\)/g $DUMP_FILE
printf "\nCreating MySQL import file \033[33m$MYSQL_FILE\033[39m\n"
echo -n "\
DROP DATABASE IF EXISTS asr;
CREATE DATABASE asr;
USE asr;
" > sailbot.mysql.sql
grep -v "DELETE FROM sqlite_sequence" $DUMP_FILE|\
grep -v "INSERT INTO .sqlite_sequence"|\
grep -v "PRAGMA foreign_keys"|\
grep -v "BEGIN TRANSACTION"|\
grep -v "COMMIT" >> $MYSQL_FILE.sql
printf "\n\033[33mFinished!\033[39m\n\n"
