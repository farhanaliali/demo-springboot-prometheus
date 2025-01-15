# Stage 1: Build the application using Maven
FROM maven:3.8.5-openjdk-17-slim AS build

# Set the working directory inside the container
WORKDIR /app

# Copy the pom.xml and download dependencies first (this helps with caching layers)
COPY pom.xml .

# Download the Maven dependencies (this will be cached unless pom.xml changes)
RUN mvn dependency:go-offline

# Copy the rest of the application files (source code)
COPY src /app/src

# Build the application and package it as a JAR
RUN mvn clean package -DskipTests

# Stage 2: Run the application using OpenJDK 17
FROM openjdk:17-jdk-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the JAR file from the build stage
COPY --from=build /app/target/demo-0.0.1-SNAPSHOT.jar app.jar

# Expose the port that the Spring Boot app will run on
EXPOSE 8080

# Command to run the Spring Boot app
ENTRYPOINT ["java", "-jar", "app.jar"]
