# Use the official Nginx image from Docker Hub
FROM nginx:latest

# Copy your static website files into the container
# Replace 'html' with the folder where your index.html and other files are located
COPY  /dist  /usr/share/nginx/html

# Expose port 80 so we can access the site
EXPOSE 80

# Nginx runs automatically when the container starts
