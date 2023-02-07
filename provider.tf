provider "aws"  {
  shared_config_files      = ["/home/omnia/.aws/conf"]
  shared_credentials_files = ["/home/omnia/.aws/creds"]
  profile                  = "lab1"
  region = "us-east-1"
}
