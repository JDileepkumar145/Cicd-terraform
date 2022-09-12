

resource "aws_security_group" "alb" {
  name        = "enduser"
  description = "allow enduser"
  vpc_id      = aws_vpc.dev-vpc1.id


  ingress {
    description = "Enduser"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "stage-alb"
  }
}
