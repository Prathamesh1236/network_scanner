from flask import Flask, render_template, request
import subprocess
import re

app = Flask(__name__)

# Function to validate IP address format
def is_valid_ip(ip):
    # Improved regex pattern for IP address validation
    ip_regex = r'^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
    return re.match(ip_regex, ip) is not None

@app.route('/', methods=['GET', 'POST'])
def index():
    scan_result = ""
    if request.method == 'POST':
        ip_address = request.form.get('ip_address')
        scan_type = request.form.get('scan_type')

        # Validate input fields
        if not ip_address or not scan_type:
            scan_result = "Both IP address and scan type are required."
        elif not is_valid_ip(ip_address):
            scan_result = "Please enter a valid IP address."
        else:
            try:
                # Run Nmap command with sudo if necessary
                if scan_type in ['-O']:  # Add any other scan types that require root here
                    command = f"sudo nmap {scan_type} {ip_address}"
                else:
                    command = f"nmap {scan_type} {ip_address}"
                scan_result = subprocess.check_output(command, shell=True).decode()
            except subprocess.CalledProcessError as e:
                scan_result = f"Nmap error: {e.output.decode()}"
            except Exception as e:
                scan_result = f"Error: {e}"
    return render_template('index.html', result=scan_result)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
