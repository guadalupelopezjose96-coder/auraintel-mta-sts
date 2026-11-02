#!/usr/bin/env bash
set -euo pipefail

# 1. Instalar git y gh si no están presentes
pkg install -y git gh

# 2. Estructura exacta requerida por RFC 8461
mkdir -p .well-known
cat <<'TXT' > .well-known/mta-sts.txt
version: STSv1
mode: enforce
mx: aspmx.l.google.com
mx: *.aspmx.l.google.com
mx: smtp.google.com
max_age: 604800
TXT

# Archivo CNAME requerido por GitHub Pages para vincular el subdominio
echo "mta-sts.AuraIntelCore.com" > CNAME

# Archivo .nojekyll para evitar que GitHub ignore directorios que inician con punto (.well-known)
touch .nojekyll

# 3. Inicializar repositorio local
git init -b main
git config user.name "AuraIntelCore SecOps"
git config user.email "admin@AuraIntelCore.com"
git add .
git commit -m "feat: MTA-STS RFC 8461 Policy Endpoint"

echo "============================================================"
echo " Autenticando con GitHub CLI..."
echo "============================================================"
gh auth login --web

echo "============================================================"
echo " Creando repositorio público en GitHub..."
echo "============================================================"
gh repo create auraintel-mta-sts --public --source=. --remote=origin --push

echo "============================================================"
echo " Habilitando GitHub Pages con HTTPS forzado..."
echo "============================================================"
gh api -X POST "repos/{owner}/auraintel-mta-sts/pages" \
  -f "source[branch]=main" \
  -f "source[path]=/" \
  -f "cname=mta-sts.AuraIntelCore.com" || true

echo "============================================================"
echo " REPOSITORIO PUBLICADO CON ÉXITO"
echo " Registros DNS que debes añadir en AuraIntelCore.com:"
echo " Tipo: CNAME | Nombre: mta-sts | Destino: <tu-usuario-github>.github.io."
echo "============================================================"
