#!/usr/bin/env bash
# Crea el bucket compartido para el paso 8 (state remoto) e imprime su nombre.
# Se crea con la AWS CLI y no con Terraform: en AWS Educate una política de la
# organización bloquea s3:GetBucketObjectLockConfiguration, y el provider de AWS
# no puede leer buckets. El backend "s3" de Terraform sí funciona: solo lee y
# escribe objetos.
set -euo pipefail
REGION="${AWS_REGION:-us-east-1}"
CUENTA=$(aws sts get-caller-identity --query Account --output text)
BUCKET="m2-tfstate-${CUENTA}"

aws s3api create-bucket --bucket "$BUCKET" --region "$REGION" >/dev/null
aws s3api put-bucket-versioning --bucket "$BUCKET" --versioning-configuration Status=Enabled
aws s3api put-public-access-block --bucket "$BUCKET" --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
aws s3api put-bucket-tagging --bucket "$BUCKET" --tagging 'TagSet=[{Key=Curso,Value=pucp-m2},{Key=Rol,Value=instructor}]'
echo "$BUCKET"
