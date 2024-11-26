terraform {
  backend "s3" {
    bucket         = "terraform-state-yug"
    key            = "terraform/state.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks" # Optional for state locking
  }
}
