module "test" {
  source = "../day-2-basic-ec2"
  ami = "ami-037a2314eeca55594"
  instance_type = "t2.micro"
  key_name = "awskey"
}