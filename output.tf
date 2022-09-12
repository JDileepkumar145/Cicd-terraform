output "azs" {
  value = (data.aws_availability_zones.available.names)
}

output "count" {
  value = length(data.aws_availability_zones.available.names)

}
