# 00. Setup de Entorno, Git y Automatización

## Objetivo

Antes de tocar el objetivo, el entorno de trabajo tiene que ser reproducible y la evidencia tiene que quedar versionada desde el primer comando. Un informe que no se puede reconstruir a partir de las notas no sirve como evidencia.

## Estructura de carpetas por auditoría

```bash
AUDIT="cliente-fecha"
mkdir -p ~/audits/$AUDIT/{recon,enum,exploit,postexploit,loot,screenshots,report}
cd ~/audits/$AUDIT
git init -q
echo "loot/\n*.pcap\n*.cap" > .gitignore   # loot y capturas nunca van al repo del informe
git add .gitignore && git commit -qm "init: estructura de auditoría"
```

Separar `loot/` (credenciales, hashes, ficheros extraídos del objetivo) del resto es la salvaguarda mínima de confidencialidad: ese contenido no debe acabar nunca en un repositorio, ni siquiera privado, sin anonimizar.

## Captura de comandos con `script`

Todo lo que se ejecuta contra el objetivo queda registrado para la sección de evidencia del informe, no solo lo que "sale bien":

```bash
script -a ~/audits/$AUDIT/recon/session.log
# ... trabajo normal ...
exit   # cierra la grabación
```

## Automatización mínima: autosave

Un hook sencillo que evita perder horas de notas si la sesión se interrumpe (VPN caída, snapshot de VM revertido):

```bash
#!/bin/bash
# autosave.sh — commit + push automático de las notas de auditoría
MESSAGE=${1:-"auto: update audit notes"}
git add .
if git diff-index --quiet HEAD --; then
    echo "Sin cambios pendientes."
else
    git commit -m "$MESSAGE"
    git push origin main 2>/dev/null || true
    echo "Notas sincronizadas."
fi
```

Se lanza con un `watch -n 300 ./autosave.sh` durante la fase activa de la auditoría, o manualmente al cerrar cada hito (recon completo, acceso inicial, post-explotación).

## Variables de entorno estándar

Fijar las mismas variables en cada auditoría reduce errores de copia/pega entre herramientas:

```bash
export TARGET="10.10.X.X"
export IFACE="tun0"
export WORDLIST="/usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt"
export AUDIT_DIR=~/audits/$AUDIT
```

## Relación con GRC

Esta fase, aunque parezca puramente operativa, es la que sostiene después la **cadena de custodia** del informe: un hallazgo sin timestamp, sin comando exacto y sin snapshot del entorno no es defendible ante un cliente que lo cuestione, y tampoco cumple el nivel de trazabilidad que pide ISO 27001 (A.5.28, recogida de evidencias) para una auditoría formal.
