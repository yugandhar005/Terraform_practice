resource "aws_key_pair" "name" {
    key_name = "testpublic"
    public_key = file("~/.ssh/id_rsa.pub") #here you need to define public key file path

  
}

resource "aws_instance" "dev" {
  ami                    = "ami-0440d3b780d96b29d"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.name.key_name
  tags = {
    Name="key-tf"
  }
}