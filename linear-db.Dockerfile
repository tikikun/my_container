FROM node:25-alpine

WORKDIR /app

# Install build dependencies for better-sqlite3
RUN apk add --no-cache python3 make g++ git

# Copy from the cloned linear.db repo
COPY linear.db/sqlite-mcp-server /app
COPY linear.db/linear_schema.sql /linear_schema.sql

WORKDIR /app

# Install dependencies and build
RUN npm ci

# Initialize database and build
RUN npm run init-db
RUN npm run build

# Expose port
EXPOSE 3000

# Run the server
CMD ["npm", "start"]