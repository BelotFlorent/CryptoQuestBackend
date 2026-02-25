# ── Stage 1 : build ──────────────────────────────────────────────────────────
FROM maven:3.9-eclipse-temurin-11 AS builder

WORKDIR /build

# Copy parent pom first (better layer caching)
COPY pom.xml ./

# Copy both modules
COPY cryptator/  ./cryptator/
COPY cryptator-api/ ./cryptator-api/

# Build the whole multi-module project (cryptator first, then cryptator-api)
RUN mvn clean package -DskipTests --no-transfer-progress

# ── Stage 2 : runtime ────────────────────────────────────────────────────────
FROM eclipse-temurin:11-jre-alpine

WORKDIR /app

COPY --from=builder /build/cryptator-api/target/cryptator-api-1.0.1-SNAPSHOT.jar app.jar

# PORT is injected by Render at runtime
ENV PORT=10000
EXPOSE $PORT

ENTRYPOINT ["sh", "-c", "java -Xmx400m -Xms200m -jar app.jar --server.port=$PORT"]
