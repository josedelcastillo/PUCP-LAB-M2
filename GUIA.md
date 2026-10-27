# Guía del alumno — Lab 2: Infraestructura como Código con Terraform

## Antes de empezar

**Qué vas a construir.** Una página web servida por una función Lambda, una tabla DynamoDB y una cola SQS en AWS, descritas en código. Antes de crearlas vas a saber cuánto costarían al mes con tráfico real, y cuánto costaría lo mismo con un servidor tradicional. Después las vas a modificar, vas a ver cómo Terraform recuerda lo que creó (el *state*) y qué pasa cuando alguien cambia algo a mano. Al final las destruyes con un solo comando.

**Requisitos.**

- Cuenta de GitHub con sesión iniciada en el navegador (la misma del Lab 1).
- Credenciales de AWS. Una de estas dos:
  - **Cuenta del curso**: el profesor comparte las credenciales de su laboratorio de AWS Educate (`aws_access_key_id`, `aws_secret_access_key` y `aws_session_token`).
  - **Tu propio laboratorio de AWS Educate / Academy**: `AWS Details → AWS CLI → Show`.
- Cuenta gratuita de Infracost (se crea en el paso 3; puedes registrarte con GitHub).

**Convenciones de esta guía.**

- `texto en código` es algo que se escribe o se hace clic tal cual.
- `<apellido>` se reemplaza por tu usuario del curso: tu apellido en minúsculas, sin tildes. Si dos personas tienen el mismo apellido, agreguen la inicial del nombre (`perezj`). **Revisa en el chat que nadie más use el tuyo**: todos trabajan en la misma cuenta y lo único que separa tus recursos de los de otro es ese prefijo.
- Cada paso termina con una verificación. No avances si no se cumple: escribe en el chat de Zoom el número del paso y qué ves.
- Todos los comandos se escriben en la terminal, dentro de la carpeta `lab/`.

**Reglas del lab en la cuenta compartida.**

1. Solo tocas recursos que empiezan con `m2-<apellido>-`. Las credenciales permiten borrar los de otros: no lo hagas.
2. No creas nada desde la consola web ni fuera de este proyecto.
3. Todo lo que crees, lo destruyes en el paso 9. Si tienes que irte antes, ejecuta el paso 9 primero.

## Paso 1 — Crear tu repositorio y cargar credenciales (5 min)

1. Abre `https://github.com/josedelcastillo/PUCP-LAB-M2` → `Use this template` → `Create a new repository`. Nombre: `PUCP-LAB-M2-<apellido>`. Visibilidad: `Private`.
2. Guarda las credenciales como secretos de Codespaces, **no** en un archivo del repositorio: en GitHub, tu foto → `Settings` → `Codespaces` → `Secrets` → `New secret`. Crea los tres, cada uno con `Repository access` = `PUCP-LAB-M2-<apellido>`:

| Nombre | Valor |
|---|---|
| `AWS_ACCESS_KEY_ID` | el valor de `aws_access_key_id` |
| `AWS_SECRET_ACCESS_KEY` | el valor de `aws_secret_access_key` |
| `AWS_SESSION_TOKEN` | el valor de `aws_session_token` (es largo: cópialo completo) |

3. En tu repositorio: `Code` → `Codespaces` → `Create codespace on main`. Espera 2–3 minutos (instala Terraform, AWS CLI e Infracost).
4. En la terminal:

```bash
cd lab
aws sts get-caller-identity
terraform version
infracost --version
```

**Verificación.** `get-caller-identity` muestra un `Arn` con `assumed-role/voclabs/`. `terraform version` muestra `v1.14` e `infracost --version` muestra `v2.18`.

> En la pestaña `Actions` de tu repositorio verás correr el pipeline `CI` al crearlo. Es normal: valida el código y construye el mismo entorno que tu Codespace. Los jobs `plan` y `costo` terminan con un aviso de que faltan secretos; en este lab no los necesitas.

> Si dice `Unable to locate credentials`, los secretos se crearon después de abrir el Codespace: `Ctrl+Shift+P` → `Codespaces: Rebuild Container`.
>
> Las credenciales de AWS Educate vencen cuando termina la sesión del laboratorio del profesor (unas 4 horas) o si la reinicia. Si ves `ExpiredToken` durante la clase, no reconstruyas el Codespace: pega en la terminal las tres líneas nuevas que comparta el profesor y sigue trabajando:
>
> ```bash
> export AWS_ACCESS_KEY_ID=...
> export AWS_SECRET_ACCESS_KEY=...
> export AWS_SESSION_TOKEN=...
> ```
>
> Valen solo para esa terminal. Después de la clase, actualiza también los secretos.

## Paso 2 — Leer el código e inicializar (5 min)

1. Abre los archivos de `lab/` en este orden:

| Archivo | Qué contiene |
|---|---|
| `versions.tf` | Versión de Terraform y de los providers (`aws` y `archive`) |
| `providers.tf` | Región y etiquetas que llevan todos los recursos (`Curso`, `Alumno`) |
| `variables.tf` | Lo que se puede cambiar sin tocar el código: `alumno`, `mensaje`, `memoria_mb`… |
| `main.tf` | Los recursos: función Lambda con URL pública, grupo de logs, tabla DynamoDB y cola SQS |
| `outputs.tf` | Lo que Terraform imprime al final: la URL de la página, el nombre de la tabla… |

En `main.tf`, el bloque 4 (`aws_instance.comparacion`) es un servidor EC2 que **nunca se crea**: sirve para comparar costos en el paso 6.

2. Crea tu archivo de variables:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Ábrelo y reemplaza `<apellido>` por tu usuario. Guarda.

3. Inicializa:

```bash
terraform init
```

**Verificación.** La salida termina con `Terraform has been successfully initialized!` y aparece la carpeta `.terraform/` (los providers descargados).

## Paso 3 — Estimar el costo antes de crear (8 min)

Infracost lee el código y calcula el costo mensual con la lista de precios pública de AWS. **No necesita credenciales de AWS ni crea nada.**

1. Conecta Infracost con tu cuenta:

```bash
infracost auth login --oauth-use-device-flow
```

Abre el enlace que aparece, escribe el código que muestra la terminal y autoriza.

2. Estima el costo y míralo por recurso:

```bash
infracost scan
infracost inspect --group-by resource
```

`infracost.yml` le indica a Infracost que lea tus variables (`terraform.tfvars`) y el uso estimado (`infracost-usage.yml`). Todo lo que creas hoy se cobra **por uso**: sin visitas, cuesta casi cero. Abre `infracost-usage.yml` para ver qué tráfico supone la estimación (por ejemplo, 10 millones de visitas al mes).

3. Mira qué recomienda Infracost para gastar menos:

```bash
infracost inspect --failing
infracost inspect --total-savings
```

4. Guarda el resultado como línea base para comparar cambios en el paso 6:

```bash
infracost scan --json > infracost-base.json
```

**Verificación.** Anota en el chat el `Monthly cost` total y el recurso más caro. Elige una recomendación de `--failing` y explica en una línea si la aplicarías en tu trabajo.

## Paso 4 — Planificar y crear (8 min)

1. Pide el plan:

```bash
terraform plan
```

Lee la salida: cada recurso con `+` se va a crear. Al final: `Plan: 5 to add, 0 to change, 0 to destroy.`

2. Créalos:

```bash
terraform apply
```

Escribe `yes` cuando lo pida. Tarda menos de un minuto.

3. Comprueba:

```bash
terraform output
curl "$(terraform output -raw url)"
```

Abre la `url` del output en el navegador.

**Verificación.** La página muestra `Hola desde Terraform` y tu usuario. Pega tu URL en el chat y abre la de un compañero.

## Paso 5 — Modificar: cambio en sitio y reemplazo (7 min)

1. En `terraform.tfvars` cambia `mensaje` por otro texto. Guarda y planifica:

```bash
terraform plan
```

2. Ahora agrega al final de `terraform.tfvars` la línea `cola_fifo = true`. Guarda y vuelve a planificar.

Compara los dos planes. Busca los símbolos al lado de cada recurso:

| Símbolo | Significa |
|---|---|
| `~` | Se modifica en sitio: el recurso sigue siendo el mismo |
| `-/+` | Se destruye y se crea de nuevo: los mensajes que había en la cola se pierden |

¿Qué cambio produjo `~` y cuál `-/+`? En el segundo, busca la línea con `# forces replacement` para saber qué atributo obliga al reemplazo.

3. Aplica con `terraform apply` y recarga la página.

**Verificación.** La página muestra el nuevo mensaje. En `terraform output`, la `cola` ahora termina en `.fifo`; la `url` no cambió.

## Paso 6 — ¿Cuánto cuesta el cambio? (7 min)

Antes de cambiar la memoria de una función o el modo de cobro de una base de datos, mide la diferencia contra una línea base. Aquí **no** ejecutas `terraform apply`: nada cambia en AWS.

1. Vuelve a generar la línea base: en el paso 5 cambiaste `terraform.tfvars` y la del paso 3 ya no corresponde a lo que tienes creado.

```bash
infracost scan --json > infracost-base.json
```

2. Para cada caso: agrega la línea al final de `terraform.tfvars`, guarda, ejecuta el `diff` y **borra la línea** antes del siguiente caso.

```bash
infracost diff --compare-to infracost-base.json
```

| Caso | Línea a agregar en `terraform.tfvars` |
|---|---|
| 1. Función con más memoria | `memoria_mb = 1024` |
| 2. DynamoDB con capacidad reservada en vez de pago por uso | `dynamodb_billing_mode = "PROVISIONED"` |
| 3. La misma página en un servidor EC2 encendido todo el mes | `servidor_ec2 = true` |

> El caso 3 es solo para estimar: si intentas `terraform plan` con `servidor_ec2 = true`, Terraform se niega con un error que lo explica.

**Verificación.** Escribe en el chat el `Amount` y el `Percent` de cada caso. Para el 3: ¿con cuántas visitas al mes el servidor saldría más barato que la Lambda? Cambia `monthly_requests` en `infracost-usage.yml`, vuelve a generar la línea base y repite. Al terminar, `terraform.tfvars` debe quedar sin las líneas de prueba (`terraform plan` → `No changes`).

## Paso 7 — El state: lo que Terraform recuerda (10 min)

1. Mira qué tiene registrado Terraform:

```bash
terraform state list
terraform state show aws_lambda_function.web
```

Abre `terraform.tfstate`: es un JSON con el identificador real de cada recurso en AWS.

2. **Drift: alguien cambia algo a mano.** Sube la memoria de tu función desde fuera de Terraform:

```bash
aws lambda update-function-configuration --function-name "$(terraform output -raw funcion)" --memory-size 256
terraform plan
```

Terraform compara el código con lo que hay en AWS y propone volver a `128`: el código manda. Ejecuta `terraform apply` para corregirlo.

3. **¿Qué pasa si se pierde el state?** Muévelo fuera de la carpeta (no lo borres):

```bash
mv terraform.tfstate ../tfstate.respaldo
terraform plan
```

Lee el resumen del plan. **No ejecutes `apply`.** Responde en el chat: si alguien hiciera `apply` ahora, ¿qué pasaría con cada recurso? Luego devuélvelo a su lugar:

```bash
mv ../tfstate.respaldo terraform.tfstate
terraform plan
```

**Verificación.** Con el state de vuelta, `terraform plan` dice `No changes. Your infrastructure matches the configuration.`

## Paso 8 (opcional) — Mover el state a S3 (5 min)

El state en tu Codespace se pierde si borras el Codespace; en equipo, además, dos personas no pueden compartirlo. El profesor dicta el nombre del bucket de estado.

1. `cp backend.tf.example backend.tf` y reemplaza el nombre del bucket.
2. Migra:

```bash
terraform init -migrate-state -backend-config="key=alumnos/<apellido>/terraform.tfstate"
```

Responde `yes`.

3. Comprueba: `terraform plan` dice `No changes` y `aws s3 ls s3://<bucket-de-estado>/alumnos/<apellido>/` muestra tu `terraform.tfstate`.

**Verificación.** Abre una segunda terminal (`+` en el panel de terminal), entra a `lab/` y ejecuta `terraform plan` en las dos casi a la vez: una falla con `Error acquiring the state lock`. Ese es el bloqueo que evita que dos personas apliquen al mismo tiempo.

## Paso 9 — Destruir (5 min)

1. Mira primero qué se va a borrar:

```bash
terraform plan -destroy
```

2. Destruye:

```bash
terraform destroy
```

Escribe `yes`.

3. Comprueba que no queda nada tuyo:

```bash
aws lambda list-functions --query "Functions[?starts_with(FunctionName,'m2-<apellido>-')].FunctionName"
aws dynamodb list-tables --query "TableNames[?starts_with(@,'m2-<apellido>-')]"
aws sqs list-queues --queue-name-prefix m2-<apellido>-
```

**Verificación.** `Destroy complete! Resources: 5 destroyed.`, las dos primeras consultas devuelven `[]` y la tercera no imprime nada. Si hiciste el paso 8, el state sigue en S3 pero vacío: eso es normal.

## Si algo falla

| Mensaje | Causa probable | Qué hacer |
|---|---|---|
| `ResourceConflictException` / `ResourceInUseException` / `ResourceAlreadyExistsException` | Otra persona usa tu mismo `alumno`, o quedó algo de un `apply` sin state | Cambia `alumno` a uno único y avisa al profesor; no borres a mano |
| `ExpiredToken` | Venció o se reinició la sesión de AWS Educate | Pega en la terminal los tres `export` con las credenciales nuevas (ver paso 1) |
| `Resource precondition failed` | Quedó `servidor_ec2 = true` en `terraform.tfvars` | Borra esa línea |
| `Invalid value for variable` en `alumno` | Tu usuario tiene menos de 3 o más de 20 caracteres, mayúsculas o tildes | Usa solo minúsculas, números y guiones (`perez`, `perezj`) |
| `Unauthorized` en Infracost | No iniciaste sesión o venció | Repite `infracost auth login --oauth-use-device-flow` |
| `Error acquiring the state lock` | Otro `plan`/`apply` en curso con el mismo state | Espera a que termine; no uses `force-unlock` salvo que sepas que nadie más está aplicando |
| La página da `Forbidden` | La URL se creó hace segundos | Espera 30 segundos y recarga |

## Preguntas de cierre

1. En el paso 7, ¿qué habría pasado si hacías `apply` sin state? ¿Cómo lo evitarías en un equipo de diez personas?
2. En el paso 6, ¿desde cuántas visitas al mes conviene un servidor encendido frente a la Lambda? ¿Quién en tu organización debería ver ese número antes de elegir la arquitectura?
3. Nombra un recurso de tu trabajo actual que fue creado a mano y que no podrías recrear igual mañana.
