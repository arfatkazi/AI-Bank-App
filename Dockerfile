# syntax=docker/dockerfile:1

FROM eclipse-temurin:21-alpine AS builder

WORKDIR /app

COPY .mvn/ .mvn/

COPY mvnw pom.xml ./

RUN chmod +x ./mvnw

RUN --mount=type=cache,target=/root/.m2 ./mvnw -B  -ntp clean -DskipTests dependency:go-offline

COPY src/ src/

RUN --mount=type=cache,target=/root/.m2 ./mvnw -B -ntp -DskipTests clean package \
  && JAR="$(ls -1 target/*.jar | grep -vE '(-plain|-sources|-javadoc)\.jar$' | head -n 1)" \
  && cp "$JAR" /app/app.jar


FROM gcr.io/distroless/java21-debian13:nonroot

WORKDIR /app

COPY --from=builder /app/app.jar /app/app.jar

EXPOSE 8080

ENTRYPOINT [ "java", "-jar", "/app/app.jar" ]
