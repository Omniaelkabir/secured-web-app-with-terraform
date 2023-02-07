resource "aws_s3_bucket" "terraform_state" {
    bucket = "terraform-bucket-2272"
    
    lifecycle {
        prevent_destroy = true
    } 
}

resource "aws_s3_bucket_versioning" "enabled" {
    bucket = aws_s3_bucket.terraform_state.id
    versioning_configuration {
      status= "Enabled"
    }
  
}

# resource "aws_dynamodb_table" "terraform_locks" {
#     name = "terraform-locks"
#     billing_mode = "PAY_PER_REQUEST"
#     hash_key = "LockID"

#     attribute {
#       name = "LockID"
#       type = "S"
#     }
  
# }

terraform {
  backend "s3"{
    bucket = "terraform-bucket-2272"
    key = "terraform.tfstate"
    region = "us-east-1"

    # dynamodb_table = "terraform-lock"
    # encrypt = true
  }
}