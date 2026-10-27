# Configuración del provider de AWS.
# Las credenciales NO van aquí: se toman del entorno
# (AWS_ACCESS_KEY_ID + AWS_SECRET_ACCESS_KEY + AWS_SESSION_TOKEN o AWS_PROFILE).
provider "aws" {
  region = var.aws_region

  # Etiquetas que se aplican automáticamente a todos los recursos.
  # Con la etiqueta Alumno, el profesor puede ver de quién es cada recurso
  # en la cuenta compartida.
  default_tags {
    tags = {
      Curso     = "pucp-m2"
      Alumno    = var.alumno
      ManagedBy = "terraform"
    }
  }
}
