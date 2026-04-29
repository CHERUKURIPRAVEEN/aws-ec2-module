terraform {
  backend "s3" {
    bucket         = "277802554635-terraform-remote-backend"
    key            = "DEV/EC2-TEST/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "277802554635-terraform-remote-backend-lock"
  }
}