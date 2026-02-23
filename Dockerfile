FROM tomcat:9.0.65-jdk8

# Remove default apps
RUN rm -rf /usr/local/tomcat/webapps/*

# Deploy your ROOT.war
COPY ROOT.war /usr/local/tomcat/webapps/ROOT.war

# Expose custom port
EXPOSE 9090

# Change Tomcat port from 8080 to 8787
RUN sed -i 's/port="8080"/port="9090"/g' /usr/local/tomcat/conf/server.xml

RUN sed -i 's/port="8005"/port="-1"/g' /usr/local/tomcat/conf/server.xml

