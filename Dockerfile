# Use latest jboss/base-jdk:11 image as the base
FROM amazoncorretto:18-alpine3.15-jdk

# Set the WILDFLY_VERSION env variable
ENV WILDFLY_VERSION 26.1.1.Final
ENV WILDFLY_SHA1 c11076dd0ea3bb554c5336eeafdfcee18d94551d
ENV JBOSS_HOME /opt/jboss/wildfly

USER root


RUN apk add tar
RUN apk add curl

RUN addgroup jboss && adduser -D -h /opt/jboss -s /sbin/nologin -G jboss jboss && \
    chmod 755 /opt/jboss

# Add the WildFly distribution to /opt, and make wildfly the owner of the extracted tar content
# Make sure the distribution is available from a well-known place
WORKDIR /opt/jboss

RUN curl -L -O https://github.com/wildfly/wildfly/releases/download/$WILDFLY_VERSION/wildfly-preview-$WILDFLY_VERSION.tar.gz 
RUN tar xf wildfly-preview-$WILDFLY_VERSION.tar.gz
RUN mv wildfly-preview-$WILDFLY_VERSION $JBOSS_HOME 
RUN rm wildfly-preview-$WILDFLY_VERSION.tar.gz 
RUN chown -R jboss:0 ${JBOSS_HOME} 
RUN chmod -R g+rw ${JBOSS_HOME}

# Ensure signals are forwarded to the JVM process correctly for graceful shutdown
ENV LAUNCH_JBOSS_IN_BACKGROUND true

USER jboss

# Expose the ports in which we're interested
EXPOSE 8080

# Set the default command to run on boot
# This will boot WildFly in standalone mode and bind to all interfaces
CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0"]
