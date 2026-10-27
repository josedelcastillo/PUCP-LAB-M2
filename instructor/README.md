# Instructor · PUCP-LAB-M2

Esta carpeta, `PRESENTACION.md` y `PRESENTACION.pptx` viven solo en la rama `instructor`. La rama `main` es la plantilla de los alumnos.

## Antes de la clase

1. Inicia la sesión del laboratorio de AWS Educate (`Start Lab`) y copia las credenciales de `AWS Details → AWS CLI`. Duran unas 4 horas: inicia la sesión poco antes de la clase.
2. Configura un perfil local con esas credenciales y crea el bucket de estado:

```bash
export AWS_PROFILE=pucp2
./crear-bucket-estado.sh      # imprime el nombre del bucket; se dicta en el paso 8
./barrido.sh                  # no debe quedar nada de pruebas anteriores
```

3. Comparte las tres credenciales con los alumnos por un canal privado (no en el chat grabado de la clase). Si la sesión se reinicia durante la clase, las credenciales cambian y hay que volver a compartirlas.

## Durante y después de la clase

```bash
./barrido.sh                  # todo lo que sigue vivo
./barrido.sh perez            # solo un alumno
./barrido.sh perez --borrar   # borra lo que quedó de ese alumno
```

Al terminar el curso, borra el bucket de estado: `aws s3 rb s3://m2-tfstate-<cuenta> --force`.

## Costo de referencia

Infracost estima USD 14.45 al mes por alumno **con 10 millones de visitas**; con el tráfico real de una clase, Lambda, DynamoDB, SQS y logs cuestan centavos. El mayor riesgo para el presupuesto de USD 50 no es el lab, sino algo creado a mano y olvidado: revisa la consola de facturación del laboratorio después de cada sesión.

## Secretos del pipeline

El job `plan` usa las credenciales de AWS Educate, que vencen con la sesión (unas 4 horas). Antes de abrir un PR de demostración, inicia la sesión, actualiza el perfil `pucp2` y ejecuta:

```bash
./actualizar-secretos-ci.sh            # copia las credenciales de pucp2 al repositorio
```

Para el job `costo`, crea en `https://dashboard.infracost.io` un token de cuenta de servicio o un token de acceso personal (no el token de MCP) y cárgalo una sola vez:

```bash
gh secret set INFRACOST_CLI_AUTHENTICATION_TOKEN --repo josedelcastillo/PUCP-LAB-M2
```

Los repositorios que los alumnos crean desde la plantilla no heredan secretos: en ellos `plan` y `costo` se omiten con un aviso.
