# backend/Dockerfile

FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files and install deps
COPY package*.json ./
RUN npm install

# Copy backend source
COPY . .

# Expose port
EXPOSE 5000

# Start the app
CMD ["node", "server.js"]
