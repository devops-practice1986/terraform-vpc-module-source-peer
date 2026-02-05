# peering connection to another VPC (optional, can be used for connecting to other VPCs in the same or different accounts)
resource "aws_vpc_peering_connection" "peering_connection" {
  count       = var.is_peering_required ? 1 : 0
  vpc_id      = aws_vpc.main.id         # requester VPC ID
  peer_vpc_id = data.aws_vpc.default.id # accepter VPC ID
  auto_accept = true

  tags = merge(
    var.common_tags,
    var.peering_connection_tags,
    {
      Name = "${local.resource_name}-peer-connection"
    }
  )
}

resource "aws_route" "public_peering" {
  count                     = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.public.id # route table associated with public subnets
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering_connection[count.index].id

}

resource "aws_route" "private_peering" {
  count                     = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.private.id # route table associated with private subnets
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering_connection[count.index].id

}

resource "aws_route" "database_private_peering" {
  count                     = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.database_private.id # route table associated with database private subnets
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering_connection[count.index].id
}

resource "aws_route" "default_peering" {
  count                     = var.is_peering_required ? 1 : 0
  route_table_id            = data.aws_route_table.main.route_table_id
  destination_cidr_block    = var.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peering_connection[count.index].id
}
