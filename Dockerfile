# Pull base image 
From tomcat 

# Maintainer 
MAINTAINER "mukhesh" 
COPY webapp/target/webapp.war /usr/local/tomcat/webapps
