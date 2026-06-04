# Multi-stage production build for FashionHub ERP-CRM-WMS
FROM node:20-slim AS builder

WORKDIR /usr/src/app

# Copy package configurations
COPY package*.json ./

# Install dependencies including build utilities
RUN npm ci

# Copy the rest of the source code
COPY . .

# Run production build (Vite client-side assets + esbuild server transpilation)
RUN npm run build

# Runtime container state
FROM node:20-slim AS runner

WORKDIR /usr/src/app

# Set production context
ENV NODE_ENV=production
ENV PORT=3000

# Copy necessary files from the builder stage
COPY --from=builder /usr/src/app/package*.json ./
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app/dist ./dist
COPY --from=builder /usr/src/app/assets ./assets

# Expose server ingress port
EXPOSE 3000

# Start deployment server
CMD ["npm", "run", "start"]
