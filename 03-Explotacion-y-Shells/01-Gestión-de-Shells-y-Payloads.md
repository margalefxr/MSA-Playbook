# 03.1 Gestión Avanzada de Shells, Payloads y Explotación

## 1. CheatSheet & Comandos de Explotación Directa

### Tratamiento de TTY (Estabilización Completa de Shell)
```bash
# Paso 1: Spawn de PTY con Python
python3 -c 'import pty; pty.spawn("/bin/bash")'

# Paso 2: Suspender la shell con Ctrl+Z y configurar terminal local
stty raw -echo; fg

# Paso 3: Ajustar variables de entorno y dimensiones
export TERM=xterm-256color
stty rows 38 columns 116