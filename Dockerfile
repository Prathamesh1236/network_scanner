FROM python:3.9-slim

# Install required packages
RUN apt update && apt install -y sudo nmap libcap2-bin && rm -rf /var/lib/apt/lists/*

# Set capabilities on the nmap binary
RUN setcap cap_net_raw,cap_net_admin+eip $(which nmap)

# Install Flask and python-nmap
RUN pip install --upgrade pip && pip install flask python-nmap

# Copy project files
WORKDIR /app
COPY . .

# Expose port
EXPOSE 5000

# Run the Flask app
CMD ["python", "app.py"]

