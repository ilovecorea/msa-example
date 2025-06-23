FROM openjdk:17-jre-slim

WORKDIR /app

COPY target/user-service-*.jar app.jar

EXPOSE 8080

ENV JAVA_OPTS=""

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"] 