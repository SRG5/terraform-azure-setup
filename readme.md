# 📸 CloudPhoto Project — Full Stack Deployment with Flask, PostgreSQL & Auto-Scaling on Azure

## 🧠 Summary

This project demonstrates a full-stack cloud deployment of a Python Flask application with PostgreSQL on Microsoft Azure using **Terraform**, **cloud-init**, and **VM Scale Sets**. The infrastructure is highly automated and scalable, including a Load Balancer, auto-scaling rules, health checks, and secure networking.

Originally started as a training exercise and extended into a full production-like deployment, it showcases core DevOps principles such as infrastructure-as-code (IaC), cloud automation, service resiliency, autoscaling, and monitoring.

---

## 🎯 Project Objectives

* Provision Azure infrastructure for a full-stack app using Terraform.
* Use **VM Scale Sets (VMSS)** to deploy and auto-scale the web tier.
* Configure **Azure Load Balancer** to route traffic to VMSS.
* Enable **Auto Scaling** based on CPU usage.
* Set up a private PostgreSQL database.
* Automate deployment and service startup using `cloud-init` and `systemd`.
* Expose multiple application endpoints (`/image`, `/add`, `/healthz`).
* Use Terraform outputs to expose all key endpoints automatically.

---

## 💪 Technologies Used

| Component       | Tool                    |
| --------------- | ----------------------- |
| Cloud           | Azure                   |
| IaC             | Terraform               |
| App Framework   | Flask (Python)          |
| DB Engine       | PostgreSQL              |
| Web Tier        | VM Scale Set (VMSS)     |
| Load Balancer   | Azure LB (Layer 4)      |
| Automation      | cloud-init + systemd    |
| Auto Scaling    | Azure Monitor Autoscale |
| Debug & Testing | Postman, SSH            |

---

## 🏗️ Infrastructure Overview

### 1. Virtual Network

* **Address Space**: `10.1.0.0/16`
* **Subnets**:

  * `web_subnet`: `10.1.1.0/24`
  * `db_subnet`: `10.1.2.0/24`

### 2. Network Security Groups (NSG)

| NSG Target | Rules                                                          |
| ---------- | -------------------------------------------------------------- |
| Web Subnet | Allow 8080 only from Load Balancer IP, Allow SSH from anywhere |
| DB Subnet  | Allow PostgreSQL (5432) and SSH only from web subnet           |

### 3. VM Scale Set (`cloudphoto-vmss`)

* Runs Flask app on **port 8080**
* Created using `azurerm_linux_virtual_machine_scale_set`
* Size: `Standard_B1ms`
* Initial instance count: **1**
* Connects to Load Balancer backend pool
* Provisioned with `cloud-init-web.yaml`

### 4. Azure Load Balancer

* Public IP assigned
* Probes port 8080 for availability
* Load balancing rule maps port 80 to port 8080

### 5. PostgreSQL VM

* Installed and configured with `cloud-init-db.yaml`
* Uses private IP (10.1.2.5)
* Accepts connections only from web subnet
* Pre-creates `simple_net_db` and `records` table

---

## 🔎 Application Endpoints

All endpoints are exposed via Load Balancer public IP (output `load_balancer_ip`).

| Endpoint   | Purpose                             |
| ---------- | ----------------------------------- |
| `/image`   | Displays image from Azure Blob      |
| `/add`     | Inserts record to PostgreSQL        |
| `/healthz` | Returns `200 OK` if DB is reachable |

---

## 🔢 Terraform Outputs (Examples)

After running `terraform apply`, the following URLs are provided:

```bash
load_balancer_ip = "http://13.92.157.122"
app_url = "http://13.92.157.122/image"
add_record_url_example = "http://13.92.157.122/add?name=Baruchi&value=87&time=Wed%20Jun%2028%2018:05:52%20JDT%202023"
health_check_url = "http://13.92.157.122/healthz"
photo_url = "https://cloudphotoimages.blob.core.windows.net/photos/example.jpg"
```

---

## 🚪 Security Practices

* DB server is on private subnet, inaccessible from the internet
* Web tier only accepts traffic from Load Balancer
* No public IP assigned to VMSS instances
* NSG rules narrowly scoped to required traffic
* Secrets managed via Terraform variables

---

## 📈 Auto Scaling Logic

Auto scaling is enabled for the VMSS with the following rules:

| Trigger       | Action         |
| ------------- | -------------- |
| CPU > 20%     | Scale out by 1 |
| CPU < 10%     | Scale in by 1  |
| Min instances | 1              |
| Max instances | 3              |

Scale rules use Azure Monitor metrics over 2-minute windows.

---

## 🛠️ Automation Highlights

* All provisioning is done using `terraform apply`
* Flask app and PostgreSQL services auto-start on boot via `systemd`
* Application uses environment variables from `/etc/environment`
* Blob image URL passed dynamically to Flask from Terraform

---

## 📚 Repository Structure

```
terraform/
├── flask_app_simple_net/
│   ├── app.py
│   ├── config.py
│   ├── db.py
│   ├── init_db.py
│   └── requirements.txt
├── main.tf
├── db.tf
├── vmss.tf
├── autoscale.tf
├── outputs.tf
├── storage.tf
├── variables.tf
├── terraform.tfvars
├── cloud-init-web.yaml
├── cloud-init-db.yaml
├── example.jpg
```

---

## 💼 Author

**Rotem Gez**
DevOps Engineer
