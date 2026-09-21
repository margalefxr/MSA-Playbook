#!/bin/bash
MESSAGE=${1:-"auto: update playbook notes"}
git add .
if git diff-index --quiet HEAD --; then
    echo "ℹ️ No hay cambios locales pendientes."
else
    git commit -m "$MESSAGE"
    git push origin master
    echo "✅ Cambios guardados y sincronizados con GitHub."
fi
