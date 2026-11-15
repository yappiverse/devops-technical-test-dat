# DevOps Technical Test: Laravel & Vue.js on AWS

**PT. Darmawan Aryansyah Teknologi**

Repositori ini berisi implementasi teknis untuk arsitektur cloud, pipeline CI/CD, Terraform IaC, serta setup monitoring aplikasi Laravel API dan Vue.js SPA di AWS.

---

## Indeks Dokumentasi

Detail implementasi dibagi ke dalam dokumen terpisah di direktori docs/:

- **01. Arsitektur & DevSecOps CI/CD (`docs/01-architecture-and-cicd.md`)**
  Topologi 3-tier multi-AZ, pipeline CI/CD GitHub ke AWS CodeBuild/ECR, immutable backend image (CONTAINER_ROLE=app/worker/scheduler), dan secret management via Secrets Manager & AppConfig.

- **02. Terraform Infrastructure as Code (`docs/02-terraform-iac.md`)**
  Struktur modul Terraform, spesifikasi konfigurasi environment Production, remote backend S3 + DynamoDB locking, integrasi RDS Performance Insights, dan validasi sintaks.

- **03. Monitoring & Alerting Strategy (`docs/03-monitoring-and-alerting.md`)**
  Setup OpenTelemetry (OTel Collector) untuk log, metrik, dan trace. Monitoring host/redis/mysql, integrasi RDS Performance Insights, routing alert P1/P2 (Slack, PagerDuty, Email), dan mitigasi otomatis via AppConfig kill switch.

---

## Validasi Terraform

Uji konfigurasi lokal:

```bash
cd terraform
terraform init -backend=false
terraform validate
terraform fmt -check -recursive
```
