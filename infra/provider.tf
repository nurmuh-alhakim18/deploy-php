provider "google" {
  # Set the credential using env
  credentials = var.google_credentials
  project = "deployment-php"
  region = "asia-southeast2"
}

variable "google_credentials" {
  
}