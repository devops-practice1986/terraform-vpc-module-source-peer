resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  enable_dns_hostnames = var.enable_dns_hostnames
  tags = merge(
    var.common_tags,
    var.vpc_tags,
    {
      Name = local.resource_name
    }
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id # connecting IGW to VPC

  tags = merge(
    var.common_tags,
    var.igw_tags,
    {
      Name = "${local.resource_name}-igw"
    }
  )
}
# this is public subnet1 and subnet2 are created in 2 different AZs for high availability
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = local.az_names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    var.public_subnet_tags[count.index],
    {
      Name = "${local.resource_name}-public-subnet-${count.index + 1}"
    }
  )
}
# private subnet1 and subnet2 are created in 2 different AZs for high availability
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]

  tags = merge(
    var.common_tags,
    var.private_subnet_tags[count.index],
    {
      Name = "${local.resource_name}-private-subnet-${count.index + 1}"
    }
  )
}

# database private subnet1 and subnet2 are created in 2 different AZs for high availability
resource "aws_subnet" "database_private" {
  count             = length(var.database_private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.database_private_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]

  tags = merge(
    var.common_tags,
    var.database_private_subnet_tags[count.index],
    {
      Name = "${local.resource_name}-database-private-subnet-${count.index + 1}"
    }
  )
}

# DB subnet group for RDS instances to be launched in private subnets
resource "aws_db_subnet_group" "main" {
  name       = "${local.resource_name}-db-subnet-group"
  subnet_ids = aws_subnet.database_private[*].id

  tags = merge(
    var.common_tags,
    var.database_subnet_tags,
    {
      Name = "${local.resource_name}-db-subnet-group"
    }
  )
}

# elastic IP for NAT gateway
resource "aws_eip" "nat" {
  domain = "vpc"
}

# NAT gateway in public subnet
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    var.common_tags,
    var.nat_gateway_tags,
    {
      Name = "${local.resource_name}-nat-gateway"
    }
  )
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}

# route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.public_route_table_tags,
    {
      Name = "${local.resource_name}-public-rt"
    }
  )
}
# route table for private subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name = "${local.resource_name}-private-rt"
    }
  )
}
# route table for database private subnets
resource "aws_route_table" "database_private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name = "${local.resource_name}-database-private-rt"
    }
  )
}

# route for public subnets to access the internet via IGW
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}
# route for private subnets to access the internet via NAT gateway
resource "aws_route" "private_internet_access" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}
# route for database private subnets to access the internet via NAT gateway
resource "aws_route" "database_private_internet_access" {
  route_table_id         = aws_route_table.database_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}

# associating public subnets with public route table
resource "aws_route_table_association" "public_subnet_association" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
# associating private subnets with private route table
resource "aws_route_table_association" "private_subnet_association" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
# associating database private subnets with database private route table
resource "aws_route_table_association" "database_private_subnet_association" {
  count          = length(aws_subnet.database_private)
  subnet_id      = aws_subnet.database_private[count.index].id
  route_table_id = aws_route_table.database_private.id
}

