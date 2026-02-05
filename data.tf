data "aws_availability_zones" "available" {
  state = "available"
}

# for getting default VPC ID
data "aws_vpc" "default" {
  default = true
}

# default route table id
data "aws_route_table" "main" {
  vpc_id = data.aws_vpc.default.id
  filter {
    name   = "association.main"
    values = ["true"]
  }
}



