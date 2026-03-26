

#  Serverless Transaction Processing Engine

A production-ready, event-driven financial backend designed for high consistency, security, and scalability in the **af-south-1 (Cape Town)** region.

##  Technical Architecture Deep-Dive

This project implements a **Decoupled Event-Driven Architecture (EDA)**. Instead of a traditional monolithic server, the system is broken into specialized AWS components that communicate asynchronously to ensure reliability and data integrity.

### 1. Asynchronous Ingestion (The SQS Layer)
At the edge of the system sits **Amazon SQS**. 
* **Decoupling:** By using a queue, the "producer" (the client sending the transaction) doesn't have to wait for the database to finish writing. This prevents the front-end from hanging if the database is under high load.
* **Fault Tolerance:** If the database goes down for maintenance, messages stay safely in the queue for up to 4 days, ensuring zero data loss.



### 2. Isolated Compute (The VPC Lambda Layer)
The **AWS Lambda** function acts as the execution engine. 
* **Runtime:** Powered by **Node.js 22**, utilizing the latest V8 engine optimizations for asynchronous I/O.
* **Network Isolation:** The Lambda is placed inside **Private Subnets** within a custom VPC. It has no Public IP address and no route to the Internet, mitigating external attack vectors.
* **Warm-Start Optimization:** The code is designed to reuse database connections across invocations, significantly reducing the connection overhead typical in serverless-to-RDS patterns.



### 3. Relational Data Integrity (The RDS Layer)
For financial data, **PostgreSQL 16** (running on Amazon RDS) provides **ACID compliance** to guarantee that every transaction is valid.
* **Security:** The database is locked down by a **Security Group** that only accepts traffic on port **5432** originating specifically from the Lambda’s Security Group ID.
* **Idempotency Strategy:** The system handles the "Double-Spend" problem at the database level using `INSERT ... ON CONFLICT (id) DO NOTHING`. This ensures that even if a network retry sends the same message twice, the ledger remains accurate.



### 4. Zero-Trust Security (Secrets & PrivateLink)
Security is baked into the infrastructure, not added as an afterthought:
* **Secrets Management:** Database credentials are encrypted at rest using **AWS Secrets Manager**. The Lambda fetches these at runtime using its **IAM Execution Role**, meaning no passwords ever exist in the source code or environment variables.
* **VPC Endpoints (PrivateLink):** To communicate with Secrets Manager and CloudWatch without leaving the AWS network, the VPC uses **Interface Endpoints**. This keeps all traffic off the public internet, protecting sensitive data from interception.



---

## 🛡️ Operational Summary

| Feature | Implementation | Benefit |
| :--- | :--- | :--- |
| **Connectivity** | VPC Interface Endpoints | Data stays off the public internet |
| **Concurrency** | SQS-to-Lambda Trigger | Automatic scaling based on traffic volume |
| **Authentication** | IAM Role-based Access | No hardcoded API keys or passwords |
| **Persistence** | RDS PostgreSQL | Strong consistency and ACID compliance |

---

##  Deployment & Usage

### Infrastructure Setup
```bash
cd terraform
terraform init
terraform apply -var="rds_password=YourSecurePassword123"