# Use the official Deno runtime as a parent image
FROM denoland/deno:2.5.0

# Set the working directory
WORKDIR /app

# Copy the dependency configuration
COPY deno.json .

# Copy source code
COPY src/ ./src/

# Expose the port the app runs on
EXPOSE 3000

# Cache the dependencies
RUN deno cache src/app.ts

# Run the application
CMD ["deno", "run", "-A", "src/app.ts"]