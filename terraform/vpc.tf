# VPC Configuration for Redemption Platform
# VPC CIDR: 10.0.0.0/16
# 2 Availability Zones: ap-southeast-1a, ap-southeast-1b

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "redemption-vpc"
    Project     = var.project_name
    Environment = "prod"
    ManagedBy   = "terraform"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "redemption-igw"
    Project     = var.project_name
    Environment = "prod"
    ManagedBy   = "terraform"
  }
}

# Public Subnets (10.0.1.0/24, 10.0.2.0/24)
resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[0]
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true

  tags = {
    Name        = "redemption-public-1a"
    Project     = var.project_name
    Environment = "prod"
    ManagedBy   = "terraform"
    Type        = "public"
  }
}

resource "aws_subnet" "public_1b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[1]
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = true

  tags = {
    Name        = "redemption-public-1b"
    Project     = var.project_name
    Environment = "prod"
    ManagedBy   = "terraform"
    Type        = "public"
  }
}

# Private App Subnets (10.0.10.0/24, 10.0.20.0/24)
resource "aws_subnet" "private_app_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_app_subnet_cidrs[0]
  availability_zone = var.availability_zones[0]

  tags = {
    Name        = "redemption-private-app-1a"
    Project     = var.project_name
    Environment = "prod"
    ManagedBy   = "terraform"
    Type        = "private-app"
  }
}

resource "aws_subnet" "private_app_1b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_app_subnet_cidrs[1]
  availability_zone = var.availability_zones[1]

  tags = {
    Name        = "redemption-private-app-1b"
    Project     = var.project_name
    Environment = "prod"
    ManagedBy   = "terraform"
    Type        = "private-app"
  }
}

# Private Data Subnets (10.0.30.0/24, 10.0.40.0/24)
resource "aws_subnet" "private_data_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_data_subnet_cidrs[0]
  availability_zone = var.availability_zones[0]

  tags = {
    Name        = "redemption-private-data-1a"
    Project     = var.project_name
    Environment = "prod"
    ManagedBy   = "terraform"
    Type        = "private-data"
  }
}

resource "aws_subnet" "private_data_1b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_data_subnet_cidrs[1]
  availability_zone = var.availability_zones[1]

  tags = {
    Name        = "redemption-private-data-1b"
    Project     = var.project_name
    Environment = "prod"
    ManagedBy   = "terraform"
    Type        = "private-data"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "redemption-public-rt"
    Project     = var.project_name
    Environment = "prod"
    ManagedBy   = "terraform"
  }
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_1b" {
  subnet_id      = aws_subnet.public_1b.id
  route_table_id = aws_route_table.public.id
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat_1a" {
  domain = "vpc"

  tags = {
    Name        = "redemption-nat-eip-1a"
    Project     = var.project_name
    Environment = "prod"
    ManagedBy   = "terraform"
  }
}

resource "aws_eip" "nat_1b" {
  domain = "vpc"

  tags = {
    Name        = "redemption-nat-eip-1b"
    Project     = var.project_name
    Environment = "prod"
    ManagedBy   = "terraform"
  }
}

# NAT Gateways
resource "aws_nat_gateway" "nat_1a" {
  allocation_id = aws_eip.nat_1a.id
  subnet_id     = aws_subnet.public_1a.id

  tags = {
    Name        = "redemption-nat-1a"
    Project     = var.project_name
    Environment = "prod"
    ManagedBy   = "terraform"
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "nat_1b" {
  allocation_id = aws_eip.nat_1b.id
  subnet_id     = aws_subnet.public_1b.id

  tags = {
    Name        = "redemption-nat-1b"
    Project     = var.project_name
    Environment = "prod"
    ManagedBy   = "terraform"
  }

  depends_on = [aws_internet_gateway.main]
}

# Private App Route Tables
resource "aws_route_table" "private_app_1a" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_1a.id
  }

  tags = {
    Name        = "redemption-private-app-rt-1a"
    Project     = var.project_name
    Environment = "prod"
    ManagedBy   = "terraform"
  }
}

resource "aws_route_table" "private_app_1b" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_1b.id
  }

  tags = {
    Name        = "redemption-private-app-rt-1b"
    Project     = var.project_name
    Environment = "prod"
    ManagedBy   = "terraform"
  }
}

# Associate Private App Subnets with Private App Route Tables
resource "aws_route_table_association" "private_app_1a" {
  subnet_id      = aws_subnet.private_app_1a.id
  route_table_id = aws_route_table.private_app_1a.id
}

resource "aws_route_table_association" "private_app_1b" {
  subnet_id      = aws_subnet.private_app_1b.id
  route_table_id = aws_route_table.private_app_1b.id
}

# Private Data Route Tables
resource "aws_route_table" "private_data_1a" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_1a.id
  }

  tags = {
    Name        = "redemption-private-data-rt-1a"
    Project     = var.project_name
    Environment = "prod"
    ManagedBy   = "terraform"
  }
}

resource "aws_route_table" "private_data_1b" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_1b.id
  }

  tags = {
    Name        = "redemption-private-data-rt-1b"
    Project     = var.project_name
    Environment = "prod"
    ManagedBy   = "terraform"
  }
}

# Associate Private Data Subnets with Private Data Route Tables
resource "aws_route_table_association" "private_data_1a" {
  subnet_id      = aws_subnet.private_data_1a.id
  route_table_id = aws_route_table.private_data_1a.id
}

resource "aws_route_table_association" "private_data_1b" {
  subnet_id      = aws_subnet.private_data_1b.id
  route_table_id = aws_route_table.private_data_1b.id
}