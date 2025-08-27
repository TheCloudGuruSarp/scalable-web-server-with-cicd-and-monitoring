# Use a lightweight Nginx image to serve static content
FROM nginx:1.21-alpine

# Copy the static content (our index.html) to the Nginx html directory
COPY index.html /usr/share/nginx/html/index.html

# Expose port 80 to the outside world
EXPOSE 80

# Command to run Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
