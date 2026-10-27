output "url" {
  description = "Página web servida por la función Lambda."
  value       = aws_lambda_function_url.web.function_url
}

output "funcion" {
  description = "Nombre de la función Lambda."
  value       = aws_lambda_function.web.function_name
}

output "tabla" {
  description = "Nombre de la tabla DynamoDB."
  value       = aws_dynamodb_table.pedidos.name
}

output "cola" {
  description = "URL de la cola SQS."
  value       = aws_sqs_queue.pedidos.url
}
