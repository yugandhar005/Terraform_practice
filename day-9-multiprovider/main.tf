provider "aws" {
  region = "ap-south-1"
}

#Another provider alias 
provider "aws" {
  region = "us-east-1"
  alias = "provider2"
}

resource "aws_s3_bucket" "test" {
  bucket = "del-hyd-naresh-it"

}
resource "aws_s3_bucket" "test2" {
  bucket = "del-hyd-naresh-it-test2"
  provider = aws.provider2  #provider value of alias
  
}