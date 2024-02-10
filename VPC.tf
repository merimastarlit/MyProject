# VPC config
resource "aws_vpc" "the_vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags                 = local.tags
}

# Main Route
# resource "aws_route_table" "rt" {
#   vpc_id = aws_vpc.the_vpc.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.igw.id
#   }

#   tags = local.tags
# }

# Internet Gateway for the VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.the_vpc.id

  tags = local.tags
}


# NAT Gateway

resource "aws_eip" "nat-gateway" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat-gateway.id
  subnet_id     = aws_subnet.public_subnet1.id

  tags = local.tags

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "nat" {
  vpc_id = aws_vpc.the_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = local.tags
}


# # Private instance association with NAT GW
# resource "aws_route_table_association" "nat-rt" {
#   subnet_id      = aws_subnet.private_subnet1.id
#   route_table_id = aws_route_table.nat.id
# }

# NACLs

resource "aws_network_acl" "nacl" {
  vpc_id = aws_vpc.the_vpc.id

  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "10.3.0.0/18"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.3.0.0/18"
    from_port  = 80
    to_port    = 80
  }

  tags = local.tags
}


resource "aws_network_acl_association" "private_nacl_association" {
  network_acl_id = aws_network_acl.nacl.id
  subnet_id      = aws_subnet.public_subnet1.id
}



#dns resolution enabled
#s3 endpoint


#Subnets

# 1st public subnet in us-east2a
resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.the_vpc.id
  cidr_block              = var.public-subnet1-cidr
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true


  tags = local.tags
}

# 2nd public subnet in us-east2b
resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.the_vpc.id
  cidr_block              = var.public-subnet2-cidr
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true


  tags = local.tags
}

# 1st private subnet in us-east2a

resource "aws_subnet" "private_subnet1" {
  vpc_id                  = aws_vpc.the_vpc.id
  cidr_block              = var.private-subnet1-cidr
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = false

  tags = local.tags
}

# 2nd private subnet in us-east2b

resource "aws_subnet" "private_subnet2" {
  vpc_id                  = aws_vpc.the_vpc.id
  cidr_block              = var.private-subnet2-cidr
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = false

  tags = local.tags
}

# 1st DB private subnet in us-east2a

resource "aws_subnet" "private_subnet1db" {
  vpc_id                  = aws_vpc.the_vpc.id
  cidr_block              = var.private-subnet1db-cidr
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = false

  tags = local.tags
}

# 2nd DB private subnet in us-east2b

resource "aws_subnet" "private_subnet2db" {
  vpc_id                  = aws_vpc.the_vpc.id
  cidr_block              = var.private-subnet2db-cidr
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = false

  tags = local.tags
}




# Public route table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.the_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = local.tags
}


# Route table association

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_rt.id
}



# Private route table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.the_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = local.tags
}

# Route table association with 1st private subnet

resource "aws_route_table_association" "nat_route1" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private_rt.id
}

# Route table association with 1st private subnet

resource "aws_route_table_association" "nat_route2" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.private_rt.id
}

# Route table association with 1st private subnet

resource "aws_route_table_association" "nat_route1db" {
  subnet_id      = aws_subnet.private_subnet1db.id
  route_table_id = aws_route_table.private_rt.id
}

# Route table association with 1st private subnet

resource "aws_route_table_association" "nat_route2db" {
  subnet_id      = aws_subnet.private_subnet2db.id
  route_table_id = aws_route_table.private_rt.id
}