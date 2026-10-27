#!/usr/bin/env bash
# Lista los recursos del laboratorio que siguen vivos en la cuenta compartida.
# Uso: ./barrido.sh            -> todos los alumnos
#      ./barrido.sh <alumno>   -> solo ese alumno
#      ./barrido.sh <alumno> --borrar -> borra lo que quedó de ese alumno
set -euo pipefail
export AWS_REGION="${AWS_REGION:-us-east-1}"
P="m2-${1:-}"

echo "Funciones Lambda:"
aws lambda list-functions --query "Functions[?starts_with(FunctionName,'$P')].FunctionName" --output text | tr '\t' '\n'
echo "Tablas DynamoDB:"
aws dynamodb list-tables --query "TableNames[?starts_with(@,'$P')]" --output text | tr '\t' '\n'
echo "Colas SQS:"
aws sqs list-queues --queue-name-prefix "$P" --query 'QueueUrls' --output text 2>/dev/null | tr '\t' '\n' | grep -v '^None$' || true
echo "Grupos de logs:"
aws logs describe-log-groups --log-group-name-prefix "/aws/lambda/$P" --query 'logGroups[].logGroupName' --output text | tr '\t' '\n'

if [[ "${2:-}" == "--borrar" && -n "${1:-}" ]]; then
  echo
  echo "Borrando recursos de ${1}..."
  aws lambda delete-function --function-name "${P}-web" 2>/dev/null || true
  aws dynamodb delete-table --table-name "${P}-pedidos" >/dev/null 2>&1 || true
  for q in $(aws sqs list-queues --queue-name-prefix "$P" --query 'QueueUrls' --output text 2>/dev/null | grep -v '^None$'); do
    aws sqs delete-queue --queue-url "$q"
  done
  aws logs delete-log-group --log-group-name "/aws/lambda/${P}-web" 2>/dev/null || true
  echo "Listo."
fi
