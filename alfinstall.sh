#!/bin/bash
# -------
# Script for install of Alfresco
#
# This script is a fork of the original script : https://github.com/loftuxab/alfresco-ubuntu-install
# Copyright 2013-2014 Loftux AB, Peter Löfgren
# Distributed under the Creative Commons Attribution-ShareAlike 3.0 Unported License (CC BY-SA 3.0)
# -------

export BASE_DOWNLOAD=https://raw.githubusercontent.com/dixinfor/alfresco-debian-install/master

export KEYSTOREBASE=http://svn.alfresco.com/repos/alfresco-open-mirror/alfresco/HEAD/root/projects/repository/config/alfresco/keystore

#Change this to prefered locale to make sure it exists. This has impact on LibreOffice transformations
export LOCALESUPPORT=sv_SE.utf8

export TOMCAT_DOWNLOAD=http://apache.mirrors.spacedump.net/tomcat/tomcat-7/v7.0.56/bin/apache-tomcat-7.0.56.tar.gz
export JDBCPOSTGRESURL=http://jdbc.postgresql.org/download
export JDBCPOSTGRES=postgresql-9.3-1102.jdbc41.jar
export JDBCMYSQLURL=http://cdn.mysql.com/Downloads/Connector-J
export JDBCMYSQL=mysql-connector-java-5.1.32.tar.gz
export JASIG_DOWNLOAD=http://downloads.jasig.org/cas/cas-server-4.0.0-release.tar.gz

export LIBREOFFICE=http://download.documentfoundation.org/libreoffice/stable/4.2.6/deb/x86_64/LibreOffice_4.2.6-secfix_Linux_x86-64_deb.tar.gz

export SWFTOOLS=http://www.swftools.org/swftools-2013-04-09-1007.tar.gz

# Alfresco CE 5.0.b contains a bug with GoogleDocs not ready for use now : 
#	https://forums.alfresco.com/forum/installation-upgrades-configuration-integration/installation-upgrades/googledocs-failed-start
#	https://issues.alfresco.com/jira/browse/ACE-2320
# export GOOGLEDOCSREPO=http://dl.alfresco.com/release/community/5.0.b-build-00092/alfresco-googledocs-repo-2.0.7.amp
# export GOOGLEDOCSSHARE=http://dl.alfresco.com/release/community/5.0.b-build-00092/alfresco-googledocs-share-2.0.7.amp
# export ALFWARZIP=http://dl.alfresco.com/release/community/5.0.b-build-00092/alfresco-community-5.0.b.zip
# export SOLR=https://artifacts.alfresco.com/nexus/content/groups/public/org/alfresco/alfresco-solr/5.0.b/alfresco-solr-5.0.b-config.zip
# export SOLRWAR=https://artifacts.alfresco.com/nexus/content/groups/public/org/alfresco/alfresco-solr/5.0.b/alfresco-solr-5.0.b.war
# export SPP=https://artifacts.alfresco.com/nexus/content/groups/public/org/alfresco/alfresco-spp/5.0.b/alfresco-spp-5.0.b.amp

export ALFWARZIP=http://dl.alfresco.com/release/community/5.0.a-build-00023/alfresco-community-5.0.a.zip
export GOOGLEDOCSREPO=http://dl.alfresco.com/release/community/5.0.a-build-00023/alfresco-googledocs-repo-2.0.7.amp
export GOOGLEDOCSSHARE=http://dl.alfresco.com/release/community/5.0.a-build-00023/alfresco-googledocs-share-2.0.7.amp
export SOLR=https://artifacts.alfresco.com/nexus/service/local/repo_groups/public/content/org/alfresco/alfresco-solr/5.0.a/alfresco-solr-5.0.a-config.zip
export SOLRWAR=https://artifacts.alfresco.com/nexus/service/local/repo_groups/public/content/org/alfresco/alfresco-solr/5.0.a/alfresco-solr-5.0.a.war
export SPP=https://artifacts.alfresco.com/nexus/service/local/repo_groups/public/content/org/alfresco/alfresco-spp/5.0.a/alfresco-spp-5.0.a.amp


export APTVERBOSITY="-qq -y"

# Color variables
txtund=$(tput sgr 0 1)          # Underline
txtbld=$(tput bold)             # Bold
bldred=${txtbld}$(tput setaf 1) #  red
bldgre=${txtbld}$(tput setaf 2) #  red
bldblu=${txtbld}$(tput setaf 4) #  blue
bldwht=${txtbld}$(tput setaf 7) #  white
txtrst=$(tput sgr0)             # Reset
info=${bldwht}*${txtrst}        # Feedback
pass=${bldblu}*${txtrst}
warn=${bldred}*${txtrst}
ques=${bldblu}?${txtrst}

echoblue () {
  echo "${bldblu}$1${txtrst}"
}
echored () {
  echo "${bldred}$1${txtrst}"
}
echogreen () {
  echo "${bldgre}$1${txtrst}"
}

echogreen "Cleanup Alfresco Install Temp Folder"
TMPFOLDER="/tmp/alfinstall"
INCLUDEFOLDER="$TMPFOLDER/include"

if [ -d $TMPFOLDER ]; then
	rm -rf $TMPFOLDER
fi

mkdir -p $TMPFOLDER
cd $TMPFOLDER
mkdir -p $INCLUDEFOLDER

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echogreen "Alfresco Ubuntu installer by Loftux AB."
echogreen "Updated by ADN SYSTEMES / DIXINFOR (Yannick MOLINET) to used on debian,"
echogreen "with more deb package, manage sudo capacities, and installed some services remotly"
echogreen "Please read the documentation at"
echogreen "Original: https://github.com/loftuxab/alfresco-ubuntu-install"
echogreen "Fork : https://github.com/dixinfor/alfresco-debian-install"
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Using sudo ? ..."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo
read -e -p "Use sudo${ques} [y/n] " -i "n" usesudo
if [ "$usepack" = "y" ]; then
	if [ "`which sudo`" = "" ]; then
		echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
		echo "You need to install sudo."
		echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
		apt-get $APTVERBOSITY install sudo;
	else
		echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
		echo "sudo detected ..."
		echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	fi
	SUDO=`sudo`
else
	SUDO=''
fi

# Retrieve Dependancy and source it
cd $INCLUDEFOLDER
wget -r $BASE_DOWNLOAD/include

for dependency in * ; do
  if [ -f "$dependency" ] ; then
    . "$dependency"
  fi
done


echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Installing Method ..."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo
read -e -p "Use maximum system package (all except swftools)${ques} [y/n] " -i "y" usepack
if [ "$usepack" = "y" ]; then
	# export ALF_HOME=/opt/alfresco
	export CATALINA_HOME=/usr/share/tomcat7
	export CATALINA_BASE=/var/lib/tomcat7
	export CATALINA_CONF=/etc/tomcat7
	export CATALINA_PID=/var/run/tomcat7.pid
	export ALF_USER=tomcat7
	declare -a REMOTEFILES=($SWFTOOLS $ALFWARZIP $GOOGLEDOCSREPO $GOOGLEDOCSSHARE $SOLR $SPP $JASIG_DOWNLOAD)
else
	# export ALF_HOME=/opt/alfresco
	export CATALINA_HOME=$ALF_HOME/tomcat
	export CATALINA_BASE=$ALF_HOME/tomcat
	export CATALINA_CONF=$ALF_HOME/tomcat/conf
	export CATALINA_PID=$ALF_HOME/tomcat.pid
	export ALF_USER=alfresco
	declare -a REMOTEFILES=($TOMCAT_DOWNLOAD $JDBCPOSTGRESURL/$JDBCPOSTGRES $JDBCMYSQLURL/$JDBCMYSQL $LIBREOFFICE $SWFTOOLS $ALFWARZIP $GOOGLEDOCSREPO $GOOGLEDOCSSHARE $SOLR $SPP $JASIG_DOWNLOAD)
fi

# Check if remote files are available
CheckRemoteFiles

# Update APT sources.list
UpdateAPTSource

# Install
InstallUtilities
AskForGlusterFSServer
 

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Ubuntu/Debian default for number of allowed open files in the file system is too low"
echo "for alfresco use and tomcat may because of this stop with the error"
echo "\"too many open files\". You should update this value if you have not done so."
echo "Read more at http://wiki.alfresco.com/wiki/Too_many_open_files"
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Add limits.conf${ques} [y/n] " -i "y" updatelimits
if [ "$updatelimits" = "y" ]; then
  echo "$ALF_USER  soft  nofile  8192" | $SUDO tee -a /etc/security/limits.conf
  echo "$ALF_USER  hard  nofile  65536" | $SUDO tee -a /etc/security/limits.conf
  echo
  echogreen "Updated limits.conf"
  echo
else
  echo "Skipped updating limits.conf"
  echo
fi

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo " Define Alfresco Home Path ..."
echo " You can change (not recommanded) default Alfresco Home Path"
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo
read -e -p "Define the Alfresco Home Path (not recommanded, default is /opt/alfresco)${ques}" -i "/opt/alfresco" alfhome
export ALF_HOME=$alfhome
echo

AskForMountGlusterFS
AskForTomcat
AskForNginx

AskForOpenJDK
AskForLibreOffice
AskForImageMagick
AskForSwfTools
InstallAlfresco

AskForPostgresql
AskForCAS

echo
echogreen "- - - - - - - - - - - - - - - - -"
echo "Scripted install complete"
echored "Manual tasks remaining:"
if [ "$installpsql" = "n" ]; then
	echo "1. Add database. Install scripts available in $ALF_HOME/scripts"
	echored "   It is however recommended that you use a separate database server."
fi
echo "2. Verify Tomcat memory and locale settings in /etc/init/alfresco.conf (FOR UBUNTU)"
echo "   /etc/default/tomcat7 (FOR DEBIAN)"
echo "   Alfresco runs best with lots of memory. Add some more to \"lots\" and you will be fine!"
echo "   Match the locale LC_ALL (or remove) setting to the one used in this script."
echo "   Locale setting is needed for LibreOffice date handling support."
echo "3. Update database and other settings in alfresco-global.properties"
echo "   You will find this file in $CATALINA_BASE/shared/classes"
echo "4. Update cpu settings in $ALF_HOME/scripts/limitconvert.sh if you have more than 2 cores."
echo "5. Start nginx if you have installed it: /etc/init.d/nginx start"

read -e -p "Do you want to start tomcat now ?[y/n]" -i "y" start
if [ "$start" = "y" ]; then
	if [ "$usepack" = "y" ]; then
		service tomcat7 start
	else 
		service alfresco start
	fi
else
	echo "6. Start Alfresco/tomcat: $SUDO service alfresco start"
	echo
fi
