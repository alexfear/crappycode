#!/bin/bash
find "/usr/local/apache-tomcat/webapps/ROOT/$1" -size +10k -exec jpegtran -copy none -progressive -outfile "{}a" {} \; -exec mv "{}a" "{}" \;
find "/usr/local/apache-tomcat/webapps/ROOT/$1" -size -11k -exec jpegtran -copy none -optimize -outfile "{}a" {} \; -exec mv "{}a" "{}" \;
#mv "/usr/local/apache-tomcat/webapps/ROOT/$1"a "/usr/local/apache-tomcat/webapps/ROOT/$1"
