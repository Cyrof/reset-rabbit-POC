# Reset Rabbit

## Introduction

A proof of concept (PoC) tool for testing Denial of Service (DoS) attacks on HTTP/2 web server, inspired by the technique described in [CVE-2023-44487](https://www.cve.org/CVERecord?id=CVE-2023-44487).

This repository has been extended to include both a vulnerable environment and a mitigation setup to demonstrate the effects of the attack and the effectiveness of mitigations.

## Repository Overview

### Original Features 
- A Go-based script (`reset-rabbit.go`) that performs the HTTP/2 rapid reset attack to simulate a DoS scenario.

### Added Features
1. **Exploit Setup**:
    - Created an `exploit` folder containing:
        - All Go fdiles. 
        - `simulation.yaml`: A `docker-compose` file to spin up the vulnerable Apache HTTP/2 server without mitigations, for demo purposes.
2. **Mitigation Setup**:
    - Created a `mitigation` folder with: 
        - `certs/`: Contains SSL certificates for Nginx (generated by `gen_ssl_cert.sh`).
        - `logs/`: Contains `access.log`, linked to the Nginx log directory in the container to track incoming requests.
        - `gen_ssl_cert.sh`: A script to automate SSL certificate generation for Nginx.
        - `nginx.conf`: Contains Nginx configuration for mitigating the attack, using: 
            - `keepalive_requests 1000` to limit the number of keepalive requests per connection.
            - `http2_max_concurrent_streams 128` to retrict concurrent HTTP/2 streams.
        - `mitigation.yaml`: A `docker-compose` file to run both the vulnerable server and the Nginx reverse proxy with mitigation.

---

## Usage

### **Building the Vulnerable Apache Docker Image**
Before running the exploit or mitigation setup, you need to create the Docker image for the vulnerable Apache server. Navigate to the `exploit` folder and run the following command:
```bash 
sudo docker build -t vulnerable-apache ./vulnerable-apache
```
This will build the `vulnerable-apache` image required for both the exploit and mitigation demonstrations.

### **Exploit Setup**
To run the vulnerable server and perform the attack: 

1. **Build and Start the Vulnerable Server**:
    ```bash
    cd exploit
    sudo docker-compose -f simulation.yaml up -d
    ```

2. **Run the Exploit**:
    ```bash 
    go run reset-rabbit.go -url https://localhost:8443 -limit 1000
    ```

    - You may need to adjust the `-limit` parameter to simulate the attack on servers with more resources.
    - After a few seconds, the server will stop responding a legitimate requests.

---
### **Mitigation Setup**
To run the server with Nginx mitigation enabled:

1. **Generate SSL Certificates for Nginx**:
    ```bash
    cd mitigation
    bash gen_ssl_cert.sh
    ```

2. **Start the Mitigated Environment**: 
    ```bash
    sudo docker-compose -f mitigation.yaml up -d 
    ```

3. **Run the Exploit Against the Mitigated Server**:
    ```bash 
    go run ../exploit/reset-rabbit.go -url https://localhost -limit 1000
    ```

    - The attack should be mitigated, and the server should continue to server legitimate requests. Nginx will log excessive requests and apply rate-limiting based on the configured thresholds.

---
## Directory Structure

```bash
.
├── exploit
│   ├── go.mod
│   ├── go.sum
│   ├── reset-rabbit.go
│   └── simulation.yaml
├── mitigation
│   ├── certs
│   │   ├── server.crt
│   │   └── server.key
│   ├── gen_ssl_cert.sh
│   ├── logs
│   │   └── access.log
│   ├── mitigation.yaml
│   └── nginx.conf
├── readme.md
└── vulnerable-apache
    └── Dockerfile
```

---

## Key Configuration Highlights

### **Nginx Mitigation Configuration**
In `mitigation/nginx.conf`: 
- **Limit Keepalive Requests**:
    ```nginx
    keepalive_requests 1000;
    ```
    Ensures that connections are automatically closed after 1000 requests, preventing prolonged abuse.

- **Restrict HTTP/2 COncurrent Streams**:
    ```nginx
    http2_max_concurrent_streams 128;
    ```
    Limits the number of concurrent HTTP/2 streams to prevent resource exhaustion.

---

## Notes

- This PoC is intended for demonstration purposes only.
- The tool and configurations are designed for testing and understanding the attack and mitigation in controlled environments.
- Using this tool on live systems without permission is strictly prohibited.

---

## Acknowledgements

Original repository by [PatrickTulskie reset-rabbit](https://github.com/PatrickTulskie/reset-rabbit).
