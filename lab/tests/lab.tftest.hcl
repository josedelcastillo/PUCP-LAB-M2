# Pruebas del laboratorio. Corren sin credenciales de AWS: el provider es simulado.
#   terraform init -backend=false && terraform test

mock_provider "aws" {
  mock_data "aws_iam_role" {
    defaults = {
      arn = "arn:aws:iam::123456789012:role/LabRole"
    }
  }
}

variables {
  alumno = "prueba"
}

run "nombres_con_prefijo_del_alumno" {
  command = plan

  assert {
    condition     = aws_lambda_function.web.function_name == "m2-prueba-web"
    error_message = "La función debe llamarse m2-<alumno>-web."
  }
  assert {
    condition     = aws_dynamodb_table.pedidos.name == "m2-prueba-pedidos"
    error_message = "La tabla debe llamarse m2-<alumno>-pedidos."
  }
  assert {
    condition     = aws_sqs_queue.pedidos.name == "m2-prueba-pedidos"
    error_message = "La cola debe llamarse m2-<alumno>-pedidos."
  }
  assert {
    condition     = aws_cloudwatch_log_group.web.name == "/aws/lambda/m2-prueba-web"
    error_message = "El grupo de logs debe ser el que Lambda usa por defecto, para que no quede huérfano."
  }
  assert {
    condition     = aws_lambda_function.web.role == "arn:aws:iam::123456789012:role/LabRole"
    error_message = "La función debe usar LabRole: AWS Educate no permite crear roles."
  }
  assert {
    condition     = length(aws_instance.comparacion) == 0
    error_message = "Por defecto no se crea el servidor EC2."
  }
}

run "cola_fifo_cambia_el_nombre" {
  command = plan

  variables {
    cola_fifo = true
  }

  assert {
    condition     = aws_sqs_queue.pedidos.name == "m2-prueba-pedidos.fifo"
    error_message = "Una cola FIFO debe terminar en .fifo."
  }
}

run "dynamodb_provisionado_usa_capacidad" {
  command = plan

  variables {
    dynamodb_billing_mode = "PROVISIONED"
  }

  assert {
    condition     = aws_dynamodb_table.pedidos.read_capacity == 5 && aws_dynamodb_table.pedidos.write_capacity == 5
    error_message = "En modo PROVISIONED la tabla debe reservar 5 unidades."
  }
}

run "servidor_ec2_no_se_puede_crear" {
  command = plan

  variables {
    servidor_ec2 = true
  }

  expect_failures = [aws_instance.comparacion]
}

run "alumno_invalido_se_rechaza" {
  command = plan

  variables {
    alumno = "Pérez"
  }

  expect_failures = [var.alumno]
}

run "memoria_fuera_de_rango_se_rechaza" {
  command = plan

  variables {
    memoria_mb = 3000
  }

  expect_failures = [var.memoria_mb]
}
