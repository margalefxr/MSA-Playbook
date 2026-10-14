# 02.2 SMB y Servicios de Infraestructura

## Objetivo

Enumerar los servicios que típicamente delatan una red interna mal segmentada: SMB/NetBIOS, servicios de directorio (LDAP/Kerberos en entornos Active Directory), y otros servicios de infraestructura (FTP, SNMP, RPC).

## 1. SMB — descubrimiento inicial

```bash
nmap -p139,445 --script smb-os-discovery,smb-enum-shares,smb-enum-users $TARGET -oA enum/smb-nmap

# Enumeración de shares sin credenciales (sesión nula — sigue funcionando en entornos mal configurados)
smbclient -L //$TARGET -N
smbmap -H $TARGET -u null

# Con credenciales (si ya se obtuvieron en una fase anterior)
smbmap -H $TARGET -u usuario -p 'contraseña'
```

## 2. Enumeración de usuarios y política de contraseñas

```bash
enum4linux -a $TARGET > enum/enum4linux.txt
rpcclient -U "" -N $TARGET -c "enumdomusers"
```

Esto da, en un entorno mal endurecido: lista de usuarios válidos, política de bloqueo de cuenta y, a veces, descripción de cuentas con pistas de contraseña ("Password: Verano2026!" en el campo de descripción es más habitual de lo que debería).

## 3. Active Directory (si el objetivo es un controlador de dominio)

```bash
# Enumeración no autenticada vía LDAP anónimo
ldapsearch -x -H ldap://$TARGET -b "dc=dominio,dc=local"

# Kerberoasting — solicitar tickets de servicio para crackear offline (requiere un usuario válido)
GetUserSPNs.py dominio.local/usuario:contraseña -dc-ip $TARGET -request

# AS-REP Roasting — cuentas sin preautenticación Kerberos
GetNPUsers.py dominio.local/ -usersfile usuarios.txt -dc-ip $TARGET -no-pass
```

| Técnica | Requiere credenciales | Qué obtiene |
|---|---|---|
| LDAP anónimo | No | Estructura del dominio, a veces usuarios/grupos |
| AS-REP Roasting | No (solo lista de usuarios) | Hash crackeable offline de cuentas mal configuradas |
| Kerberoasting | Sí (una cuenta válida) | Hashes de cuentas de servicio, a menudo con privilegios altos |

## 4. Otros servicios de infraestructura habituales

```bash
# FTP — comprobar acceso anónimo
ftp $TARGET   # usuario: anonymous

# SNMP — community strings por defecto filtran topología y configuración
snmpwalk -c public -v1 $TARGET

# RPC / portmapper
rpcinfo -p $TARGET
```

## Matriz rápida de impacto

| Hallazgo | Severidad típica | Por qué |
|---|---|---|
| Sesión nula SMB con listado de shares | Alta | Fuga de información sin autenticar; a veces shares con datos sensibles directamente legibles |
| AS-REP Roasting posible | Alta | Permite crackear contraseñas offline sin tocar al usuario, sin generar bloqueo de cuenta |
| Community string SNMP por defecto | Media-Alta | Expone topología de red completa a un atacante no autenticado |
| FTP anónimo con escritura | Crítica | Vector directo de subida de shell si el FTP comparte raíz con un servicio web |

## Relación con segmentación y Zero Trust

Que estos servicios sean alcanzables y enumerables desde fuera del segmento donde deberían vivir es, en sí mismo, el hallazgo de arquitectura más repetido en redes internas mal diseñadas — exactamente el patrón analizado en `sec-infrastructure-evaluation` y `audit-moldtek-internal-network` del portfolio principal. La enumeración técnica de aquí alimenta directamente esa conclusión de nivel GRC.

## Siguiente paso

Con credenciales o un vector de acceso identificado, continuar en `03-Explotacion-y-Shells/`.
