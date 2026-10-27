# PUCP-LAB-M2

Laboratorio 2 · Infraestructura como Código con Terraform. La guía paso a paso está en [GUIA.md](GUIA.md).

## Qué crea cada alumno

| Recurso | Nombre | Para qué |
|---|---|---|
| `aws_lambda_function` + `aws_lambda_function_url` | `m2-<alumno>-web` | Página web pública |
| `aws_cloudwatch_log_group` | `/aws/lambda/m2-<alumno>-web` | Logs de la función, retención de 1 día |
| `aws_dynamodb_table` | `m2-<alumno>-pedidos` | Base de datos; sirve para comparar modos de cobro |
| `aws_sqs_queue` | `m2-<alumno>-pedidos` | Cola; sirve para ver un reemplazo (`-/+`) |

Todo lleva las etiquetas `Curso=pucp-m2` y `Alumno=<alumno>` y se cobra por uso: sin tráfico, el costo es prácticamente cero. `aws_instance.comparacion` existe solo para que Infracost estime un servidor EC2 equivalente; una precondición impide crearlo.

## Por qué está diseñado así (AWS Educate)

El curso usa una cuenta de AWS Educate compartida, con USD 50 de presupuesto e IAM bloqueado. Esto se probó en vivo el 27/10/2026:

| Restricción | Consecuencia en el diseño |
|---|---|
| No se pueden crear usuarios ni roles IAM | Todos comparten las credenciales del laboratorio; los recursos se separan por el prefijo `m2-<alumno>-`. La Lambda usa el rol `LabRole`, que ya existe |
| Una política de la organización bloquea `s3:GetBucketObjectLockConfiguration` | El provider de AWS (v5 y v6) no puede leer buckets: **no hay S3 en el lab**. El backend `s3` del paso 8 sí funciona, con un bucket creado por CLI |
| Presupuesto de USD 50 para todo el curso | Todo es por uso (centavos por clase). El servidor EC2 solo se estima con Infracost: 5 servidores encendidos un mes serían unos USD 41 |
| Solo `us-east-1` y `us-west-2`; credenciales de unas 4 horas | La región está fija en `us-east-1`; la guía explica cómo renovar credenciales |

## Estructura

```
PUCP-LAB-M2/
├── .devcontainer/        # Codespaces con Terraform 1.14, AWS CLI e Infracost v2
├── GUIA.md               # Guía del alumno (9 pasos)
├── lab/                  # Proyecto Terraform del alumno
│   ├── versions.tf  providers.tf  variables.tf  main.tf  outputs.tf
│   ├── terraform.tfvars.example
│   ├── infracost.yml         # qué variables y qué uso estimado lee Infracost
│   ├── infracost-usage.yml   # uso estimado para recursos por consumo
│   ├── backend.tf.example    # paso opcional: state remoto en S3
│   └── tests/lab.tftest.hcl  # pruebas con provider simulado (terraform test)
└── .github/workflows/ci.yml  # pipeline de cada pull request
```

## Pipeline (CI)

En cada pull request hacia `main`, `.github/workflows/ci.yml` corre cuatro jobs. Ninguno crea nada en AWS.

| Job | Qué hace | Qué necesita |
|---|---|---|
| `validar` | `terraform fmt -check`, `validate` y `terraform test` (provider simulado) | Nada |
| `plan` | `terraform plan` contra AWS y lo comenta en el PR | Secretos `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN` |
| `costo` | `infracost diff` contra la rama base y lo comenta en el PR | Secreto `INFRACOST_CLI_AUTHENTICATION_TOKEN` |
| `devcontainer` | Construye el contenedor de Codespaces y comprueba Terraform, AWS CLI e Infracost | Nada |

Si falta un secreto, su job termina en verde con un aviso y no hace nada. Los secretos se cargan en `Settings → Secrets and variables → Actions`; los de Codespaces del paso 1 son otros y no sirven aquí.
