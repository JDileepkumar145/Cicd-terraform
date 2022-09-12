data "aws_availability_zones" "available" {}

# creating vpc
resource "aws_vpc" "dev-vpc1" {
  cidr_block         = "10.1.0.0/16"
  instance_tenancy   = "default"
  enable_dns_support = "true"

  tags = {
    Name = "stage-dev-vpc1"
  }
}


#create igw
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.dev-vpc1.id

  tags = {
    Name = "dev-internetgateway"
  }
}


#create subnet
resource "aws_subnet" "publics" {
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.dev-vpc1.id
  cidr_block              = element(var.pub-cidr, count.index)
  map_public_ip_on_launch = "true"
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  tags = {
    Name = "stage-public-subnet${count.index + 1}"
  }
}

resource "aws_subnet" "privates" {
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.dev-vpc1.id
  cidr_block              = element(var.pri-cidr, count.index)
  map_public_ip_on_launch = "false"
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  tags = {
    Name = "stage-private-subnet${count.index + 1}"
  }
}

resource "aws_subnet" "datas" {
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.dev-vpc1.id
  cidr_block              = element(var.data-cidr, count.index)
  map_public_ip_on_launch = "false"
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  tags = {
    Name = "stage-data-subnet-${count.index + 1}"
  }
}

#create EIP
resource "aws_eip" "eip" {
  vpc = true
  tags = {
    Name = "Eip"
  }
}

# create nat-gw
resource "aws_nat_gateway" "natgw" {
  # count = length(aws_subnets.publics)
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.publics[0].id

  tags = {
    Name = "stage-NATgw"
  }
}

# create route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.dev-vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }


  tags = {
    Name = "stage-public-route"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.dev-vpc1.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }


  tags = {
    Name = "stage-private-route"
  }
}

#create association
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.publics[*].id)
  subnet_id      = element(aws_subnet.publics[*].id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.privates[*].id)
  subnet_id      = element(aws_subnet.privates[*].id, count.index)
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "data" {
  count          = length(aws_subnet.datas[*].id)
  subnet_id      = element(aws_subnet.datas[*].id, count.index)
  route_table_id = aws_route_table.private.id
}