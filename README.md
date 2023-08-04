# DevOps Assesment

## 1. Specification and OS Server on GCP
- Machine Type: e2-small
- CPU: 2 vCPU
- Memory: 2 GB memory
- Storage: 30 GB
- OS: Ubuntu 22.04 LTS

To set up the vm with Terraform
1. Move to infra directory
   ```bash
   cd infra
   ```
2. Set environment variable to enable Terraform access to cloud using service account
   - Linux
   ```bash
   export TF_VAR_google_credentials=your_service_account_directory
   ```
   - PowerShell
   ```bash
   $env:TF_VAR_google_credentials="your_service_account_directory"
   ```
3. Initialize everything needed by Terraform to run
   ```bash
   terraform init
   ```
4. Check the resources that will be created
   ```bash
   terraform plan
   ```
5. Apply the resources that will be created
   ```bash
   terraform apply --auto-approve
   ```