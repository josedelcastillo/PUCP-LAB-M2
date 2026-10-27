#!/usr/bin/env bash
# Copia las credenciales actuales del perfil de AWS Educate a los secretos de
# GitHub Actions del repositorio, para que el job `plan` del pipeline funcione.
# Uso: ./actualizar-secretos-ci.sh [perfil] [repositorio]
set -euo pipefail
PERFIL="${1:-pucp2}"
REPO="${2:-josedelcastillo/PUCP-LAB-M2}"

aws sts get-caller-identity --profile "$PERFIL" --query Arn --output text
eval "$(aws configure export-credentials --profile "$PERFIL" --format env)"

printf '%s' "$AWS_ACCESS_KEY_ID"     | gh secret set AWS_ACCESS_KEY_ID     --repo "$REPO"
printf '%s' "$AWS_SECRET_ACCESS_KEY" | gh secret set AWS_SECRET_ACCESS_KEY --repo "$REPO"
printf '%s' "$AWS_SESSION_TOKEN"     | gh secret set AWS_SESSION_TOKEN     --repo "$REPO"
echo "Secretos actualizados en $REPO."
