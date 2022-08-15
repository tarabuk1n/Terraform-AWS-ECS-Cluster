# Create VPC for ECS Cluster.
resource "aws_vpc" "ecs_cluster" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  tags = {
    Name = "${var.name}-vpc-${var.environment}"
  }
}

# Create Internet Gateway for VPC.
resource "aws_internet_gateway" "ecs_cluster" {
  vpc_id = "${aws_vpc.ecs_cluster.id}"
  tags = {
    Name = "${var.name}-igw-${var.environment}"
  }
}

# Create Public Subnets for VPC.
resource "aws_subnet" "public_subnet" {
  count                   = "${length(var.subnets)}"
  vpc_id                  = "${aws_vpc.ecs_cluster.id}"
  cidr_block              = "${cidrsubnet(aws_vpc.ecs_cluster.cidr_block, 8, count.index)}"
  map_public_ip_on_launch = true
  depends_on              = ["aws_internet_gateway.ecs_cluster"]
  availability_zone       = "${element(keys(var.subnets), count.index)}"
  tags = {
    Name = "${var.name}-public-subnet-${var.environment}-${format("%03d", count.index+1)}"
  }
}

# Create Private Subnets for VPC.
resource "aws_subnet" "private_subnet" {
  count             = "${length(var.subnets)}"
  vpc_id            = "${aws_vpc.ecs_cluster.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.ecs_cluster.cidr_block, 8, length(var.subnets) + count.index)}"
  availability_zone = "${element(keys(var.subnets), count.index)}"
  depends_on        = ["aws_internet_gateway.ecs_cluster"]
  tags = {
    Name = "${var.name}-private-subnet-${var.environment}-${format("%03d", count.index+1)}"
  }
}


# Create Route Table Allowing All Addresses Access to the IGW.
resource "aws_route_table" "public_routes" {
  vpc_id = "${aws_vpc.ecs_cluster.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.ecs_cluster.id}"
  }
  tags = {
    Name = "${var.name}-route-table-${var.environment}"
  }
}

# Associate the Route Table with Public Subnets.
resource "aws_route_table_association" "public_subnet_routes" {
  count = "${length(var.subnets)}"
  subnet_id = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.public_routes.id}"
}

# Create a NAT Gateway with an EIP for each Private Subnet to get Internet(Outbound) Connectivity.
resource "aws_eip" "eip" {
  count      = 3
  vpc        = true
  depends_on = ["aws_internet_gateway.ecs_cluster"]
}

resource "aws_nat_gateway" "gw" {
  count         = 3
  subnet_id     = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  allocation_id = "${element(aws_eip.eip.*.id, count.index)}"
}

# Create a new Route Table Private Subnets, route non-local traffic through the NAT Gateway.
resource "aws_route_table" "private" {
  count  = 3
  vpc_id = "${aws_vpc.ecs_cluster.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${element(aws_nat_gateway.gw.*.id, count.index)}"
  }
}

# Associate the Route Table to the Private Subnets.
resource "aws_route_table_association" "private" {
  count          = 3
  subnet_id      = "${element(aws_subnet.private_subnet.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}
