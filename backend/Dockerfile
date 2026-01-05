# Use Node.js 20 Alpine for smaller image size
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy source code
COPY . .

# Expose port (Cloud Run uses PORT environment variable, defaulting to 8080)
EXPOSE 8080

# Start the application
CMD ["npm", "start"]
