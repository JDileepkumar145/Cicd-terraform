data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "aws_security_group" "bastian" {
  name        = "ssh"
  description = "allow adim"
  vpc_id      = aws_vpc.dev-vpc1.id

  ingress {
    description = "admin"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  tags = {
    Name = "stage-bastian"
  }
}

resource "aws_instance" "bastian" {
  ami                    = "ami-0b89f7b3f054b957e"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.publics[0].id
  vpc_security_group_ids = [aws_security_group.bastian.id]
  tags = {
    Name = "bastian-app"
  }
}