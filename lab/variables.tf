variable "aws_region" {
  description = "Región de AWS. AWS Educate / Academy solo permite us-east-1 y us-west-2."
  type        = string
  default     = "us-east-1"
}

variable "alumno" {
  description = "Tu usuario del curso (minúsculas, números y guiones). Prefija todos los recursos."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{3,20}$", var.alumno))
    error_message = "alumno debe tener entre 3 y 20 caracteres: solo minúsculas, números y guiones."
  }
}

variable "mensaje" {
  description = "Texto que muestra la página web."
  type        = string
  default     = "Hola desde Terraform"
}

variable "memoria_mb" {
  description = "Memoria de la función Lambda. Lambda cobra por memoria x tiempo de ejecución."
  type        = number
  default     = 128

  validation {
    condition     = contains([128, 256, 512, 1024], var.memoria_mb)
    error_message = "memoria_mb debe ser 128, 256, 512 o 1024."
  }
}

variable "cola_fifo" {
  description = "Convierte la cola SQS en FIFO (respeta el orden de llegada). AWS no permite cambiarlo en una cola existente."
  type        = bool
  default     = false
}

variable "dynamodb_billing_mode" {
  description = "PAY_PER_REQUEST (se paga por uso) o PROVISIONED (se paga capacidad reservada por hora)."
  type        = string
  default     = "PAY_PER_REQUEST"

  validation {
    condition     = contains(["PAY_PER_REQUEST", "PROVISIONED"], var.dynamodb_billing_mode)
    error_message = "dynamodb_billing_mode debe ser PAY_PER_REQUEST o PROVISIONED."
  }
}

variable "dynamodb_capacidad" {
  description = "Unidades de lectura y escritura cuando dynamodb_billing_mode = PROVISIONED."
  type        = number
  default     = 5
}

variable "servidor_ec2" {
  description = "SOLO para estimar costo con Infracost: un servidor EC2 que haría lo mismo que la Lambda. Terraform no permite crearlo."
  type        = bool
  default     = false
}

variable "instance_type" {
  description = "Tipo de instancia del servidor EC2 de comparación."
  type        = string
  default     = "t3.micro"
}
