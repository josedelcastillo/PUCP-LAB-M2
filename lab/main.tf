locals {
  # Todos los nombres empiezan con m2-<alumno>-: así no chocan entre alumnos
  # de la misma cuenta.
  prefijo = "m2-${var.alumno}"

  provisionado = var.dynamodb_billing_mode == "PROVISIONED"
}

# ---------------------------------------------------------------------------
# 1. Página web: función Lambda con una URL pública
# ---------------------------------------------------------------------------

# AWS Educate no permite crear roles IAM: se usa el rol LabRole que ya existe.
data "aws_iam_role" "lab" {
  name = "LabRole"
}

data "archive_file" "web" {
  type        = "zip"
  output_path = "${path.module}/.build/web.zip"

  source {
    filename = "index.py"
    content  = <<-EOT
      def handler(event, context):
          html = "<h1>${var.mensaje}</h1><p>Página de <b>${var.alumno}</b> creada con Terraform.</p>"
          return {"statusCode": 200, "headers": {"Content-Type": "text/html; charset=utf-8"}, "body": html}
    EOT
  }
}

resource "aws_lambda_function" "web" {
  function_name    = "${local.prefijo}-web"
  role             = data.aws_iam_role.lab.arn
  runtime          = "python3.12"
  handler          = "index.handler"
  filename         = data.archive_file.web.output_path
  source_code_hash = data.archive_file.web.output_base64sha256
  memory_size      = var.memoria_mb
  timeout          = 5

  depends_on = [aws_cloudwatch_log_group.web]
}

resource "aws_lambda_function_url" "web" {
  function_name      = aws_lambda_function.web.function_name
  authorization_type = "NONE"
}

# Logs de la función. Sin retención, CloudWatch los guarda (y cobra) para siempre.
resource "aws_cloudwatch_log_group" "web" {
  name              = "/aws/lambda/${local.prefijo}-web"
  retention_in_days = 1
}

# ---------------------------------------------------------------------------
# 2. Base de datos: tabla DynamoDB
# ---------------------------------------------------------------------------

resource "aws_dynamodb_table" "pedidos" {
  name         = "${local.prefijo}-pedidos"
  billing_mode = var.dynamodb_billing_mode
  hash_key     = "id"

  # Solo aplican en modo PROVISIONED.
  read_capacity  = local.provisionado ? var.dynamodb_capacidad : null
  write_capacity = local.provisionado ? var.dynamodb_capacidad : null

  attribute {
    name = "id"
    type = "S"
  }
}

# ---------------------------------------------------------------------------
# 3. Mensajería: cola SQS
# ---------------------------------------------------------------------------

resource "aws_sqs_queue" "pedidos" {
  # Las colas FIFO deben terminar en .fifo.
  name       = var.cola_fifo ? "${local.prefijo}-pedidos.fifo" : "${local.prefijo}-pedidos"
  fifo_queue = var.cola_fifo ? true : null

  message_retention_seconds = 86400
}

# ---------------------------------------------------------------------------
# 4. Solo para comparar costos: el mismo sitio en un servidor EC2.
#    Un servidor encendido todo el mes por alumno consumiría casi todo el
#    presupuesto de la cuenta compartida, así que la precondición impide
#    crearlo; Infracost sí lo estima.
# ---------------------------------------------------------------------------

resource "aws_instance" "comparacion" {
  count = var.servidor_ec2 ? 1 : 0

  ami           = "ami-00000000000000000" # no se usa: el recurso nunca se crea
  instance_type = var.instance_type

  root_block_device {
    volume_type = "gp3"
    volume_size = 8
  }

  lifecycle {
    precondition {
      condition     = !var.servidor_ec2
      error_message = "servidor_ec2 = true es solo para estimar costo con Infracost. Quita la línea de terraform.tfvars."
    }
  }
}
