output "vpc_id" {
  value = aws_vpc.main.id
}

# output "az_info" {
#   value = data.aws_availability_zones.available
# }

# output "default_vpc_info" {
#   value = data.aws_vpc.default
# }

# # output default route table ids
# output "default_route_table_ids" {
#   value = data.aws_route_tables.main.ids

# }
