# Runtime stage
FROM mcr.microsoft.com/dotnet/core/runtime:3.1

# set working directory
WORKDIR /app

# Copy compiled binaries
COPY ./obj ./bin

# Copy configuration
COPY config/*.* ./config/

# Set environment variables
ENV MONGO_SERVICE_URI ""
ENV MONGO_SERVICE_HOST mongo
ENV MONGO_SERVICE_PORT 27017
ENV MONGO_DB app

# Expose http and grpc ports
EXPOSE 8080
EXPOSE 8090

# Set container entrypoint
CMD ["dotnet", "./bin/run.dll", "-c", "./config/config.yml"]
