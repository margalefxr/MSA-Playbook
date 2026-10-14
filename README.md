# MSA — Metodología Simplificada de Auditoría

Playbook propio de pentesting/auditoría técnica, construido como referencia operativa reutilizable en cada compromiso: desde el setup del entorno hasta la plantilla de informe final. Es la metodología citada como **MSA-Recon** / **MSA-Interno** en las auditorías reales del [portfolio principal](https://github.com/margalefxr/CyberOps-Portfolio) (`audit-axezone-external-recon`, `audit-moldtek-internal-network`).

No es una colección de comandos sueltos: cada módulo enlaza con el siguiente (recon → enumeración → explotación → post-explotación → pivoting → informe) y, donde aplica, con el control normativo que el hallazgo correspondiente activa (ISO 27001, ENS, OWASP), siguiendo el mismo enfoque GRC-first del portfolio principal.

## Índice

| Fase | Módulo | Contenido |
|---|---|---|
| 00 · Operativa | [Setup, Git y Automatización](./00-Operativa-y-Entorno/00-Setup-y-Git-Automation.md) | Estructura de carpetas, captura de evidencia, autosave |
| 00 · Operativa | [Punto Zero: Setup de Auditoría](./00-Operativa-y-Entorno/01-Punto-Zero-Setup-de-Auditoria.md) | Scope, Rules of Engagement, reconocimiento pasivo |
| 01 · Reconocimiento | [Subnetting y Nmap](./01-Reconocimiento-y-Redes/01-Subnetting-y-Nmap.md) | Cálculo de red, descubrimiento de hosts, escaneo por fases |
| 02 · Enumeración | [Enumeración Web](./02-Enumeracion-de-Servicios/01-Enumeracion-Web.md) | Fingerprinting, CMS, APIs, checklist OWASP Top 10 |
| 02 · Enumeración | [SMB y Servicios de Infraestructura](./02-Enumeracion-de-Servicios/02-SMB-y-Servicios-Infraestructura.md) | SMB, Active Directory, Kerberoasting, SNMP/FTP |
| 03 · Explotación | [Gestión de Shells y Payloads](./03-Explotacion-y-Shells/01-Gestión-de-Shells-y-Payloads.md) | Estabilización de TTY, listeners, one-liners, transferencia de ficheros |
| 03 · Explotación | [Manual vs. Metasploit](./03-Explotacion-y-Shells/02-Explotacion-Manual-vs-Metasploit.md) | Criterio de elección, flujo de cada enfoque |
| 04 · Post-Explotación | [Linux PrivEsc](./04-Post-Explotacion-y-Privilegios/01-Linux-PrivEsc.md) | SUID, sudo, cron, capabilities, kernel |
| 04 · Post-Explotación | [Windows PrivEsc](./04-Post-Explotacion-y-Privilegios/02-Windows-PrivEsc.md) | Servicios, tokens, Potato, Active Directory |
| 05 · Pivoting | [Ligolo-ng y Enrutamiento](./05-Pivoting-y-Redes-Internas/01-Ligolo-ng-y-Enrutamiento.md) | Pivoting con TUN, doble salto, port forwarding |
| 06 · Reporte | [Plantilla PoC de Vulnerabilidad](./06-Plantillas-y-Reportes/01-Plantilla-PoC-Vulnerabilidad.md) | Formato de hallazgo, CVSS, resumen ejecutivo |

## Principios del framework

1. **Trazabilidad primero.** Todo comando ejecutado contra un objetivo queda registrado (`script`, `-oA` en Nmap, logs de sesión) antes de que cuente como evidencia.
2. **Scope explícito antes de acción.** Ningún módulo de explotación se ejecuta sin confirmar el Rules of Engagement del punto 00.
3. **Manual antes que caja negra.** Metasploit y las herramientas automatizadas (LinPEAS, WinPEAS) aceleran, pero el criterio de qué perseguir y por qué sigue siendo del auditor — ver la comparativa en el módulo 03.2.
4. **Cada hallazgo técnico se traduce a impacto de negocio y control normativo.** Es lo que separa un listado de CVEs de un informe que un comité de dirección puede usar para priorizar presupuesto.

## Stack de herramientas de referencia

Nmap · Gobuster/WhatWeb/WPScan · Burp Suite/OWASP ZAP · Enum4linux/rpcclient/Impacket · Metasploit · LinPEAS/WinPEAS/PowerUp · Ligolo-ng · GTFOBins/LOLBAS como referencia de vectores.

## Relación con el resto del trabajo

- **[CyberOps-Portfolio](https://github.com/margalefxr/CyberOps-Portfolio)** — auditorías reales y laboratorios donde se aplica esta metodología.
- **[OpsMatrix Lab](https://github.com/margalefxr/opsmatrix-lab)** — el entorno defensivo (Blue Team) que, en espejo, implementa los controles que neutralizan los vectores documentados aquí.

## Automatización

`.autosave.sh` sincroniza las notas con el repositorio remoto tras cada hito de la auditoría (ver `00-Setup-y-Git-Automation.md`).
