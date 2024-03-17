# Use the official Superset image as the base
FROM apache/superset:3.0.4

# Expose the Superset web server port
EXPOSE 8088

# Optional: Set environment variables if needed
# ENV SUPERSET_ENV=production
# ENV SUPERSET_SECRET_KEY=my_secret_key

# Optional: Add custom configurations or files
# COPY superset_config.py /etc/superset/

# Start Superset web server
CMD ["superset", "run", "-p", "8088", "-h", "0.0.0.0"]
