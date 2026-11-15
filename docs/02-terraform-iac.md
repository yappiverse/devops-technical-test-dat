# Task 2: Terraform

## 1. Spesifikasi Konfigurasi Environment Production

Modul di `terraform/modules/` menerima variabel input yang didefinisikan dengan nilai default production pada `terraform/variables.tf`:

- **VPC CIDR**: `10.30.0.0/16`
- **Availability Zones**: Multi-AZ (`ap-southeast-1a` & `ap-southeast-1b`)
- **RDS MySQL**: `db.r6g.large` (Multi-AZ Standby)
- **Performance Insights**: Enabled (7 Days Retention)
- **ElastiCache Redis**: 2 Cache Nodes (`cache.t4g.medium`)
- **EC2 Backend ASG**: `c6g.large` (Min: 2, Max: 10)
- **EC2 Frontend ASG**: `t4g.medium` (Min: 2, Max: 6)
- **NAT Gateway**: 1 NAT Gateway

---

## 2. Remote State & Keamanan

1. **Remote State Backend (S3 & DynamoDB Locking)**:
   - State file disimpan di S3 dengan enkripsi AES256 dan penguncian tabel DynamoDB untuk menghindari race-condition antar operator/pipeline:
   ```hcl
   terraform {
     required_version = ">= 1.5.0"
     backend "s3" {
       bucket         = "dat-devops-terraform-state"
       key            = "prod/laravel-vue/terraform.tfstate"
       region         = "ap-southeast-1"
       encrypt        = true
       dynamodb_table = "dat-devops-terraform-locks"
     }
   }
   ```
   - **Mekanisme State Lock**:
     - Setiap perintah `terraform plan` atau `terraform apply` membuat entri lock di DynamoDB memakai key `LockID`.
     - Proses lain yang mencoba run bersamaan akan langsung gagal dengan peringatan `Error acquiring the state lock` sampai proses pertama tuntas.
2. **Tanpa Plaintext Secret**:
   - Password database MySQL dan token auth Redis dibuat acak menggunakan resource `random_password`.
   - Nilai langsung disimpan ke `aws_secretsmanager_secret_version` dan dipakai pada `aws_db_instance.mysql.password`. Tidak ada password yang ditulis langsung di file `.tf`.
3. **RDS Performance Insights**:
   - Modul database menyalakan Performance Insights pada RDS MySQL secara otomatis:
   ```hcl
   performance_insights_enabled          = true
   performance_insights_retention_period = 7
   ```
4. **IAM & Akses Zero-SSH via AWS SSM**:
   - Role instance EC2 hanya memiliki permission: `AmazonSSMManagedInstanceCore`, ECR Read-Only, dan `secretsmanager:GetSecretValue` ke ARN rahasia terkait.
   - Port 22 ditutup total; akses shell dikelola melalui AWS SSM Session Manager.

---

## 3. Pipeline GitOps (GitHub Actions & AWS OIDC)

Eksekusi Terraform diotomatiskan via workflow `.github/workflows/terraform.yml`:

1. **Job 1: Lint & Syntax Check (Pull Request & Push)**:
   - Menjalankan `terraform fmt -check -recursive` dan `terraform validate`.
   - Berjalan tanpa perlu kredensial AWS.
2. **Job 2: Plan (Pull Request)**:
   - Autentikasi ke AWS via OpenID Connect (OIDC) tanpa static secret key.
   - Menjalankan `terraform init` dan `terraform plan -out=tfplan`.
   - Memasukkan output diff plan ke komentar Pull Request sebagai bahan review sebelum merge.
   - Job ini bersifat read-only (tidak mengubah infrastruktur AWS).
3. **Job 3: Apply (Merge ke `main`)**:
   - Menggunakan GitHub Environment (`environment: production`) untuk review approval sebelum eksekusi.
   - Menjalankan `terraform apply -auto-approve`.
