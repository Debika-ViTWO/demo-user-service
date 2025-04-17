# ----------- Stage 1: Build the application -----------
FROM maven:3.9.6-eclipse-temurin-17 AS builder

WORKDIR /app

# Copy pom.xml and resolve dependencies separately for better caching
COPY pom.xml .

# Pre-fetch dependencies
RUN mvn dependency:go-offline -B

# Now copy the source code
COPY src ./src

# Package the application without running tests
RUN mvn clean package -DskipTests -B


# ----------- Stage 2: Run the application -----------
FROM openjdk:17-jdk-slim

WORKDIR /app

# Copy the built JAR from the builder stage
COPY --from=builder /app/target/*.jar app.jar

# Expose port (matching with application.properties)
EXPOSE 8081

# Default command
ENTRYPOINT ["java", "-jar", "app.jar"]
