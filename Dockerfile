# First stage: Build dependencies
FROM node:8-alpine AS builder

# Set working directory
WORKDIR /usr/src/app

# Install dependencies
COPY package*.json ./
RUN npm install

# Copy the application code
COPY . .

# Second stage: Final runtime image
FROM node:8-alpine

# Set working directory
WORKDIR /usr/src/app

# Copy only the needed files from the builder stage
COPY --from=builder /usr/src/app .

# Install only production dependencies
RUN npm install --only=production

# Expose the port and set the entry point
EXPOSE 8080
CMD ["npm", "start"]
