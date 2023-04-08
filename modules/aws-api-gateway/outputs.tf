output "api_id" {
    value = aws_api_gateway_rest_api.CloudResumeAPI.id
}

output "api_resource_id" {
    value = aws_api_gateway_resource.CloudResumeResource.id
}