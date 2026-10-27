# Presentación Lab 2 · Infraestructura como Código con Terraform

Especificación de la presentación que acompaña al laboratorio de IaC del repositorio PUCP-LAB-M2. Es la fuente para generar las láminas en Google Slides: cada sección de "Contenido por lámina" es una lámina, con su texto y sus notas del expositor.

> Documento para el instructor. Igual que en el Lab 1, conviene sacarlo de `main` (rama del instructor o repositorio privado) junto con la carpeta `instructor/`.

## Objetivo

- Acompañar una sesión de **2 horas en total**: teoría y conversación (~48 min), laboratorio guiado (57 min), FinOps (9 min) y cierre (2 min). Quedan ~4 min de holgura.
- La teoría prioriza **aplicabilidad en negocio**: qué problema resuelve IaC, qué riesgo trae el state y cuándo Terraform no es la herramienta correcta.
- El laboratorio parte de un proyecto Terraform ya escrito (`lab/`). Cada alumno estima su costo, lo crea, lo modifica, provoca drift, simula la pérdida del state y lo destruye. No se escribe HCL desde cero.
- El laboratorio corre en **una cuenta de AWS Educate compartida** (presupuesto total USD 50, IAM bloqueado). Todos usan las mismas credenciales; los recursos se separan por el prefijo `m2-<alumno>-`. Por eso es serverless: con un `t3.micro` encendido por alumno, 5 alumnos gastarían unos USD 41 al mes, el 82 % del presupuesto.

## Audiencia

Estudiantes de maestría: profesionales de desarrollo, QA, operaciones y gestión. Ya hicieron el Lab 1 (CI con GitHub Actions y Codespaces). No necesariamente han usado AWS ni Terraform. Público mixto técnico y de negocio.

## Reglas

1. **Idioma:** español neutro, sin emojis.
2. **Sin estadísticas inventadas.** Los precios que aparecen son precios de lista de AWS en `us-east-1` y se confirman en vivo con Infracost; no se citan porcentajes de ahorro "de la industria" sin fuente.
3. **Una idea por lámina.** Preferir tablas, diagramas y frases fuertes sobre listas largas.
4. **Cada lámina lleva notas del expositor** con tiempo sugerido, preguntas para el grupo y cómo conducir la discusión.
5. **Coherencia con el repositorio:** nombres de recursos (`m2-<alumno>-...`), variables (`alumno`, `mensaje`, `memoria_mb`, `cola_fifo`, `dynamodb_billing_mode`, `servidor_ec2`), herramientas (Terraform 1.14, Infracost v2.18) y los 9 pasos deben coincidir con `GUIA.md` y `lab/`.

## Diseño

Mismo sistema visual que el Lab 1 para que las dos sesiones se lean como una serie.

- Formato 16:9.
- Tipografías: **IBM Plex Sans** (títulos y texto, 400/600/700) y **JetBrains Mono** (etiquetas, código, nombres de archivos y tiempos).
- Paleta:

| Uso | Color |
|---|---|
| Oscuro (fondos de énfasis, texto principal) | `#14213D` |
| Claro (fondo principal) | `#F7F6F2` |
| Claro alterno (fondo secundario) | `#ECEAE3` |
| Acento naranja (riesgo, "a mano", costo) | `#B34A12` |
| Acento naranja claro sobre oscuro | `#F2A65A` |
| Acento azul ("con IaC", flujo sano) | `#2D6CDF` |
| Acento verde (FinOps, ahorro) | `#2F7D5B` |
| Texto secundario sobre claro / sobre oscuro | `#4A5568` / `#C9D2E3` |

- Nada menor a 24 px en pantalla. Código en bloques de máximo 12 líneas.
- Cada lámina de contenido lleva una etiqueta superior en mono mayúsculas (la sección) y un título que afirma algo.
- La lámina "Perder el state" (8) es la única con fondo naranja (lámina de impacto). Las dos de FinOps usan el acento verde.

## Estructura y tiempos

| # | Id | Lámina | Bloque | Tiempo |
|---|---|---|---|---|
| 1 | `cover` | Portada | Apertura | 1 min |
| 2 | `agenda` | Agenda de las 2 horas | Apertura | 1 min |
| 3 | `problema` | El servidor que nadie sabe cómo se creó | Por qué IaC | 4 min |
| 4 | `que-es` | Qué es Infraestructura como Código | Por qué IaC | 4 min |
| 5 | `tipos` | No toda la IaC es igual | Tipos | 6 min |
| 6 | `ciclo` | Cómo trabaja Terraform: init, plan, apply, destroy | Terraform | 5 min |
| 7 | `state` | El state: la memoria de Terraform | State | 6 min |
| 8 | `state-riesgo` | Perder el state no borra nada, y ese es el problema | State | 4 min |
| 9 | `drift` | Drift: cuando la nube y el código dejan de coincidir | State | 3 min |
| 10 | `cuando` | Cuándo sí usar Terraform y cuándo no | Decidir | 6 min |
| 11 | `costo` | Saber el costo antes de crear | Costo | 5 min |
| 12 | `conversar` | Preguntas antes del laboratorio | Conversar | 3 min |
| 13 | `lab-objetivo` | Crear, cambiar y destruir en una cuenta compartida | Laboratorio | 2 min |
| 14 | `lab-pasos` | Nueve pasos en 55 minutos | Laboratorio | 55 min |
| 15 | `finops` | FinOps: el costo es una métrica de ingeniería | FinOps | 4 min |
| 16 | `ahorro` | Siete palancas para bajar la factura | FinOps | 5 min |
| 17 | `cierre` | Lo que nos llevamos | Cierre | 2 min |

Total: 116 min.

## Contenido por lámina

### 1. Portada (`cover`)
- Etiqueta: "PUCP · Laboratorio 2".
- Título: "Infraestructura como Código con Terraform".
- Subtítulo: "Crear, estimar, cambiar y destruir infraestructura desde un repositorio".
- Pie: "2 horas · Repositorio PUCP-LAB-M2".
- Notas (1 min): conectar con el Lab 1. Allí el pipeline revisaba el código de la aplicación; hoy la infraestructura también es código y pasa por el mismo proceso: revisión, plan, aprobación.

### 2. Agenda (`agenda`)
Cuatro bloques con horario:
- 0:00–0:20 · Qué es IaC, tipos de herramientas y cómo funciona Terraform.
- 0:20–0:48 · El state, cuándo usar Terraform y cómo saber el costo antes de crear.
- 0:48–1:45 · Laboratorio: estimar, crear, modificar, romper el state y destruir.
- 1:45–2:00 · FinOps, estrategias de ahorro y cierre.
- Notas (1 min): pedir que abran ya el Codespace (paso 1 de la guía) porque tarda 2–3 minutos en construirse; así llegan listos al laboratorio.

### 3. El problema (`problema`)
- Título: "El servidor que nadie sabe cómo se creó".
- Una historia en tres tarjetas, de izquierda a derecha:
  1. **Lunes:** alguien crea un servidor desde la consola web. Funciona.
  2. **Seis meses después:** hay que crear el mismo ambiente para un cliente nuevo. Nadie recuerda qué casillas se marcaron.
  3. **Auditoría:** "¿Quién abrió el puerto 22 a internet y cuándo?" No hay registro.
- Frase al pie: "Lo que se hace con clics no se revisa, no se repite y no se audita".
- Notas (4 min): preguntar al grupo: "¿Cuántos tienen en su empresa un servidor, una base de datos o una regla de firewall que nadie se atreve a tocar?". Recoger 2–3 casos. A este modo de trabajo se le llama *ClickOps*. El problema no es la consola en sí, sino que el conocimiento queda en la cabeza de una persona.

### 4. Qué es IaC (`que-es`)
- Título: "Infraestructura como Código: la infraestructura se describe en archivos de texto versionados".
- Tres columnas "Con clics" vs "Con código":

| | Con clics | Con código |
|---|---|---|
| Repetir un ambiente | Rehacer de memoria | Ejecutar el mismo archivo |
| Revisar un cambio | Imposible antes de hacerlo | Pull request con diff y plan |
| Saber quién cambió qué | Logs dispersos, si existen | Historial de git |
| Deshacer | A mano | Revertir el commit y aplicar |

- Pie: "El repositorio pasa a ser la fuente de verdad de la infraestructura".
- Notas (4 min): enfatizar el beneficio de negocio, no el técnico: repetibilidad (ambientes iguales de dev a producción), trazabilidad (auditoría, cumplimiento) y velocidad (un ambiente nuevo en minutos). Conectar con el Lab 1: el mismo `pull request` que protegía la rama `main` ahora protege la infraestructura.

### 5. Tipos de IaC (`tipos`)
- Título: "No toda la IaC es igual".
- Fila superior, dos ejes en tarjetas:
  - **Declarativo vs imperativo.** Declarativo: describes el resultado final ("quiero 3 servidores") y la herramienta calcula los pasos. Imperativo: escribes los pasos ("crea un servidor, repite tres veces"). Si ya existen 3, el declarativo no hace nada; el imperativo crea 3 más.
  - **Aprovisionar vs configurar.** Aprovisionar: crear la infraestructura (red, máquinas, bases de datos). Configurar: instalar y ajustar el software dentro de las máquinas ya creadas.
- Tabla de herramientas:

| Herramienta | Estilo | Lenguaje | Alcance | ¿Quién guarda el estado? |
|---|---|---|---|---|
| Terraform / OpenTofu | Declarativo, aprovisiona | HCL | Multi-nube y SaaS | Archivo de state propio |
| AWS CloudFormation | Declarativo, aprovisiona | YAML / JSON | Solo AWS | AWS (stack) |
| AWS CDK | Código que genera CloudFormation | TypeScript, Python, Java… | Solo AWS | AWS (stack) |
| Pulumi | Declarativo con lenguaje general | TypeScript, Python, Go… | Multi-nube | Servicio Pulumi o backend propio |
| Ansible | Mayormente procedimental, configura | YAML | Servidores, redes | No guarda estado |
| Scripts (Bash + AWS CLI) | Imperativo | Bash | Lo que se programe | Nadie |

- Notas (6 min): la columna importante es la última; lleva directo a la lámina del state. Mencionar que en 2023 HashiCorp cambió la licencia de Terraform a BSL y la comunidad creó **OpenTofu** (Linux Foundation, licencia MPL), compatible con el mismo código; IBM completó la compra de HashiCorp en 2025. Para una empresa que solo usa Terraform internamente la licencia no cambia nada práctico; sí importa a quien ofrece Terraform como servicio a terceros. Preguntar: "¿Alguien usa Ansible o scripts hoy? ¿Qué pasa si los corres dos veces?".

### 6. Ciclo de Terraform (`ciclo`)
- Título: "Cómo trabaja Terraform: escribes el estado deseado y él calcula la diferencia".
- Diagrama horizontal de cinco pasos:
  `escribir .tf` → `terraform init` (descarga providers) → `terraform plan` (calcula la diferencia) → `terraform apply` (la ejecuta) → `terraform destroy` (borra todo).
- Debajo, un fragmento de código del lab:

```hcl
resource "aws_dynamodb_table" "pedidos" {
  name         = "m2-${var.alumno}-pedidos"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  attribute {
    name = "id"
    type = "S"
  }
}
```

- Tres conceptos en tarjetas pequeñas: **provider** (el traductor hacia la API de AWS, GitHub, Cloudflare…), **resource** (algo que Terraform crea y administra), **data source** (algo que solo lee, como la VPC por defecto).
- Notas (5 min): el `plan` es el corazón: es lo que se revisa en un pull request, igual que un diff de código. Terraform arma un grafo de dependencias: si el servidor necesita el security group, crea primero el security group. El orden en el archivo no importa.

### 7. El state (`state`)
- Título: "El state: la memoria de Terraform".
- Diagrama de tres vértices (triángulo):
  - **Código** (`.tf`): lo que quieres.
  - **State** (`terraform.tfstate`): lo que Terraform cree que creó, con el ID real de cada recurso.
  - **Nube** (AWS): lo que existe de verdad.
  - Flecha central: `plan` = comparar los tres.
- Ejemplo de lo que guarda (resumido):

```json
"type": "aws_lambda_function", "name": "web",
"instances": [{ "attributes": {
  "function_name": "m2-perez-web",
  "memory_size": 128,
  "role": "arn:aws:iam::...:role/LabRole" } }]
```

- Tres reglas en el pie: "Nunca se edita a mano" · "Puede contener secretos: se trata como una credencial" · "En equipo vive en un backend remoto con bloqueo".
- Notas (6 min): sin el state Terraform no sabe que `aws_lambda_function.web` es la función `m2-perez-web` de esta cuenta. Local vs remoto: en el lab empieza local, en el Codespace; el paso 8 opcional lo mueve a S3 con `use_lockfile`, que desde Terraform 1.10 hace el bloqueo en el propio S3, sin DynamoDB. Comandos que se ven en el lab: `state list`, `state show`. Mencionar que existen `import` (traer al state algo creado a mano) y `moved` (renombrar sin recrear), sin entrar en detalle.

### 8. Perder el state (`state-riesgo`) — fondo naranja
- Título: "Perder el state no borra nada, y ese es el problema".
- Frase central: "Sin state, Terraform cree que no existe nada y propone crearlo todo otra vez".
- Tres consecuencias en una línea: recursos duplicados que se siguen cobrando · errores por nombres repetidos · recursos huérfanos que nadie destruye.
- Notas (4 min): no adelantar el resultado exacto del paso 7 del lab; solo plantear la pregunta: "¿Qué hace Terraform si mañana borro el archivo?". Los alumnos lo verán en vivo. Casos reales del grupo: ¿dónde guardan hoy los archivos importantes del equipo de infraestructura?

### 9. Drift (`drift`)
- Título: "Drift: cuando la nube y el código dejan de coincidir".
- Dos columnas: "Cómo aparece" (alguien cambia algo en la consola por una urgencia; otro script toca el mismo recurso; AWS cambia un valor por defecto) y "Qué hace Terraform" (`plan` lo detecta y propone volver al código; `plan -refresh-only` lo muestra sin corregir).
- Pie: "Regla de equipo: si se gestiona con Terraform, se cambia con Terraform".
- Notas (3 min): pregunta para el grupo: "Son las 2 a. m., producción está caída y la solución es abrir un puerto desde la consola. ¿Está bien?". Respuesta razonable: sí, y al día siguiente ese cambio entra al código o se revierte; de lo contrario, el siguiente `apply` lo deshace sin avisar.

### 10. Cuándo sí y cuándo no (`cuando`)
- Título: "Cuándo sí usar Terraform y cuándo no".

| Úsalo cuando… | Evítalo o compleméntalo cuando… |
|---|---|
| Los ambientes deben ser iguales (dev, QA, producción, clientes) | Necesitas configurar software dentro del servidor → Ansible, imágenes, contenedores |
| Varias personas cambian la infraestructura y necesitas revisión | Despliegas versiones de la aplicación varias veces al día → pipeline de CI/CD, Helm, ECS |
| Usas varios proveedores (AWS + GitHub + Cloudflare + Datadog) | Los "recursos" son datos del negocio (usuarios de la app, filas, archivos subidos) |
| Necesitas auditoría y trazabilidad de cada cambio | Es un experimento de una tarde que se borrará hoy mismo |
| La infraestructura vive meses o años | El equipo es 100 % AWS, ya domina CloudFormation/CDK y no tiene otros proveedores |
| Quieres estimar costo y seguridad antes de crear | Necesitas lógica compleja (bucles, pruebas unitarias en el lenguaje del equipo) → CDK o Pulumi |

- Notas (6 min): el punto clave es la frontera. Terraform crea la máquina; no debería instalar la aplicación ni desplegar cada versión. Un antipatrón común: usar `user_data` o `provisioner` para todo. Preguntar: "En tu organización, ¿qué parte de la infraestructura cambia cada semana y qué parte cada año?". Lo que cambia cada año es candidato ideal para IaC.

### 11. Costo antes de crear (`costo`)
- Título: "Saber el costo antes de crear".
- Comparativa:

| Herramienta | Cómo funciona | A favor | En contra |
|---|---|---|---|
| **Infracost** (elegida) | Lee el código Terraform y consulta precios públicos | CLI de código abierto, sin credenciales de AWS, `diff` en cada PR, recomendaciones FinOps | Requiere una cuenta de Infracost; el uso variable se supone en un archivo; algunas políticas son de la versión de pago |
| AWS Pricing Calculator | Formulario web | Oficial, todos los servicios | Manual: no lee código, se desactualiza |
| Estimación de HCP Terraform | Integrada en el plan de la plataforma de HashiCorp | Sin herramientas extra | Solo en HCP Terraform; cubre menos recursos |
| env0, Spacelift, Scalr | Plataformas que corren Terraform | Integrada al flujo | De pago; requieren adoptar la plataforma |
| AWS Cost Explorer / Budgets | Mira lo ya gastado | Datos reales | Llega tarde: el recurso ya existe |

- Salida real del proyecto del lab (`infracost scan` + `infracost inspect --group-by resource`, 27/10/2026):

```
Resource                        Monthly Cost
aws_lambda_function.web               $6.17   10 M visitas, 200 ms, 128 MB
aws_dynamodb_table.pedidos            $3.75   10 M lecturas, 2 M escrituras, 5 GB
aws_cloudwatch_log_group.web          $2.53   5 GB de logs al mes
aws_sqs_queue.pedidos                 $2.00   5 M mensajes
Total                                $14.45
```

- Y el mismo cambio, medido antes de hacerlo (`infracost diff`):

| Cambio | Antes | Después | Variación |
|---|---|---|---|
| `memoria_mb = 1024` | $14 | $44 | +$29 (+202 %) |
| `dynamodb_billing_mode = "PROVISIONED"` | $14 | $15 | +$0 (+2 %) |
| `servidor_ec2 = true` (la misma página en un `t3.micro`) | $14 | $23 | +$8 (+57 %) |

- Notas (5 min): por qué Infracost: es la única de la lista que lee el mismo código que se revisa en el pull request y no necesita credenciales de la nube; por eso cabe en el pipeline del Lab 1. Se evaluó OpenInfraQuote (alternativa sin API key), pero su repositorio fue archivado en julio de 2026. Se usa la CLI v2 (`scan`, `inspect`, `diff`); la v0.10 (`breakdown`) sigue publicada pero ya no es la principal. Además del costo, `inspect --failing` lista recomendaciones FinOps sobre el código del lab (Graviton en Lambda, capacidad reservada y TTL en DynamoDB): se retoman en la lámina 16. Las políticas de etiquetado que aparecen marcadas como prueba de 14 días son de Infracost Cloud; no son parte del lab. Distinguir costo fijo (el servidor EC2 se cobra por hora aunque nadie lo visite) de costo por uso (Lambda, DynamoDB, SQS y logs: sin tráfico cuestan casi cero). Para el segundo hay que suponer volúmenes, y esa suposición es una decisión de negocio. La comparación Lambda vs EC2 depende del tráfico: el alumno la explora en el paso 6.

### 12. Para conversar (`conversar`)
1. ¿Quién debería aprobar un `terraform apply` a producción: quien escribió el código, otro ingeniero o alguien de negocio?
2. Un cambio aumenta la factura mensual en 30 %. ¿Debe bloquear el pull request o solo avisar?

Notas (3 min): para la 2, usar el +202 % de la memoria de la lámina anterior como caso. Conectar con la lámina de gates del Lab 1: los mismos criterios de "bloquear o advertir" aplican al costo.

### 13. Objetivo del laboratorio (`lab-objetivo`)
- Título: "Crear, cambiar y destruir en una cuenta compartida".
- Lo que cada alumno crea (todo con prefijo `m2-<alumno>-`):
  - Una página web: función Lambda con URL pública y su grupo de logs.
  - Tabla DynamoDB `m2-<alumno>-pedidos`.
  - Cola SQS `m2-<alumno>-pedidos`.
- Cómo conviven 4 o 5 personas en una cuenta: todos con las mismas credenciales; lo único que los separa es el prefijo. Si dos usan el mismo, chocan.
- Reglas del lab: solo se tocan recursos propios, nada desde la consola, y todo se destruye en el paso 9.
- Notas (2 min): esto es exactamente lo que **no** se hace en una empresa: en producción cada persona o pipeline tiene su propia identidad con permisos mínimos. Aquí la convención reemplaza a los permisos, y por eso la regla 1 es de honor. Antes de empezar, que cada uno escriba su `alumno` en el chat para detectar duplicados. Quienes usen su propio laboratorio de AWS Educate tienen los mismos recursos y comandos.

### 14. Pasos del laboratorio (`lab-pasos`)

| # | Paso | Tiempo |
|---|---|---|
| 1 | Crear el repositorio, cargar credenciales y abrir Codespaces | 5 min |
| 2 | Leer el código e inicializar | 5 min |
| 3 | Estimar el costo con Infracost | 8 min |
| 4 | `plan` y `apply`: ver la página propia y la de un compañero | 8 min |
| 5 | Modificar: cambio en sitio vs reemplazo | 7 min |
| 6 | ¿Cuánto cuesta el cambio? `infracost diff` | 7 min |
| 7 | State: listar, provocar drift y simular su pérdida | 10 min |
| 8 | (Opcional) Mover el state a S3 con bloqueo | 5 min |
| 9 | Destruir y verificar que no queda nada | 5 min |

Notas: punto de control a los 25 minutos: todos con la página web abierta (fin del paso 4). Si alguien está atrasado, que se salte el paso 6 (no cambia nada en AWS) y llegue al 7. En el paso 7, recorrer en pantalla el resumen del plan sin state y preguntar qué pasaría con `apply` antes de que lo lean ellos. Respuesta para conducir la discusión (probado en vivo el 27/10/2026): Lambda, DynamoDB y el grupo de logs fallan con "ya existe", pero **SQS adopta la cola existente sin avisar**: `CreateQueue` con el mismo nombre devuelve la cola que ya estaba. El resultado es que dos states administran la misma cola, y un `destroy` en cualquiera de los dos la borra para el otro. Antes de cerrar el bloque, el instructor ejecuta `instructor/barrido.sh` en pantalla y muestra quién todavía tiene recursos vivos; con `./barrido.sh <alumno> --borrar` limpia lo de quien ya se fue.

### 15. FinOps (`finops`) — acento verde
- Título: "FinOps: el costo es una métrica de ingeniería".
- Definición (FinOps Foundation): práctica que une a ingeniería, finanzas y negocio para que cada equipo se haga responsable de su gasto en la nube y lo use para decidir.
- Tres fases en ciclo: **Informar** (saber quién gasta cuánto: etiquetas, presupuestos) → **Optimizar** (dimensionar, apagar, comprar mejor) → **Operar** (hacerlo continuo: alertas, revisión en cada PR).
- Tabla "Qué hicimos hoy en cada fase":

| Fase | En el lab |
|---|---|
| Informar | Etiquetas `Curso` y `Alumno` en todo; un presupuesto fijo (USD 50 de AWS Educate para todo el curso) |
| Optimizar | `infracost diff` antes de cambiar el tamaño del servidor o el modo de DynamoDB; `infracost inspect --failing` con recomendaciones |
| Operar | Destruir al terminar; barrido de recursos huérfanos |

- Notas (4 min): la nube cambió el modelo de compra. Antes, comprar un servidor pasaba por finanzas; hoy cualquier ingeniero con permisos gasta con un `apply`. FinOps no es "gastar menos", es gastar a propósito. La sesión de hoy completa del grupo cuesta centavos porque todo es por uso y casi no hay tráfico. Si el lab hubiera sido con un `t3.micro` por alumno, 5 servidores encendidos todo el mes serían unos USD 41 ($8.23 × 5, según Infracost): el 82 % del presupuesto del curso, por olvidar un `destroy`. Preguntar: "¿Y si nadie hubiera ejecutado el paso 9?".

### 16. Estrategias de ahorro (`ahorro`) — acento verde
- Título: "Siete palancas para bajar la factura".

| Palanca | Ejemplo | Cómo se hace con IaC |
|---|---|---|
| Apagar lo que no se usa | Ambientes de dev y QA apagados de noche y fines de semana; serverless cuando el tráfico es bajo o irregular | `terraform destroy` del ambiente; horarios con EventBridge Scheduler |
| Dimensionar bien | Una máquina al 5 % de CPU puede bajar uno o dos tamaños; una Lambda con más memoria de la que usa | Cambiar `instance_type` o `memoria_mb` y medir con `infracost diff` |
| Comprar mejor | Savings Plans o instancias reservadas para la carga estable; Spot para trabajos que toleran interrupciones | Se compran en la consola o en la API; el código define qué carga es estable |
| Elegir el modelo de cobro | DynamoDB por solicitud vs capacidad reservada; serverless para tráfico irregular | Una variable, como `dynamodb_billing_mode` |
| Arquitectura eficiente | Procesadores Graviton (ARM); gp3 en vez de gp2 | Cambiar el tipo en el código y revisar el plan |
| Limpiar huérfanos | IPs públicas, discos, snapshots y logs que quedaron sin dueño | Si todo nace de Terraform, `destroy` lo borra todo |
| Ciclo de vida de datos | Retención de logs; TTL en tablas; mover objetos viejos a clases más baratas | `retention_in_days`, `ttl`, `aws_s3_bucket_lifecycle_configuration` |

- Pie: "Lo que no está etiquetado no se puede asignar; lo que no se mide no se optimiza".
- Notas (5 min): no dar porcentajes de ahorro genéricos (regla 2): mostrar en vivo uno de los `infracost diff` del paso 6 como ejemplo concreto. Varias filas de esta tabla (Graviton, TTL en DynamoDB, modelo de cobro) son las mismas recomendaciones que `infracost inspect --failing` dio en el paso 3 sobre el código del lab: `inspect --total-savings` estima unos $40 al año. Caso real de huérfano encontrado al preparar el lab: cuando una Lambda se ejecuta, AWS crea su grupo de logs por su cuenta; si Terraform no lo administra, `destroy` borra la función y deja los logs, que se siguen cobrando. Por eso el lab declara `aws_cloudwatch_log_group` con `retention_in_days = 1`. Desde febrero de 2024 AWS cobra cada IPv4 pública (USD 0.005 por hora): es un costo pequeño por recurso que sorprende en cuentas con cientos de IPs. Preguntar: "¿Quién en tu organización recibe hoy la factura de la nube y quién la puede reducir? ¿Son la misma persona?".

### 17. Cierre (`cierre`)
- La infraestructura es código: se revisa, se versiona y se destruye igual que la aplicación.
- El state es el activo más delicado del proyecto: remoto, bloqueado y tratado como una credencial.
- El costo se conoce antes del `apply`, no en la factura del mes siguiente.
- Pie: "Siguiente: Lab 3".
- Notas (2 min): recordar el paso 9. Nadie se va sin `Destroy complete!`.

## Preparación del instructor

Ver `README.md` → "Para el instructor". Resumen de lo que debe estar listo **antes de la clase**:

1. Sesión del laboratorio de AWS Educate iniciada (las credenciales duran unas 4 horas) y credenciales listas para compartir.
2. Bucket de estado creado con `instructor/crear-bucket-estado.sh` (paso 8).
3. `./instructor/barrido.sh` sin recursos de pruebas anteriores.

## Pendientes conocidos

1. **Infracost en Codespaces.** `scan`, `inspect` y los tres `diff` se ejecutaron en macOS con la CLI v2.18.2 (resultados en la lámina 11). Falta confirmar `infracost auth login --oauth-use-device-flow` dentro de un Codespace.
2. **Credenciales compartidas.** Todos usan las mismas credenciales de AWS Educate: cualquiera puede borrar recursos ajenos y todos consumen el mismo presupuesto de USD 50. La separación es solo por convención de nombres.
3. **Prueba en vivo (27/10/2026, cuenta pucp2).** Pasos 4, 5, 7, 8 (backend S3 con bloqueo) y 9 ejecutados de punta a punta: sin errores, sin recursos sobrantes. No probado con 4 o 5 personas aplicando a la vez; no se espera problema (cada una tiene nombres y state propios).
