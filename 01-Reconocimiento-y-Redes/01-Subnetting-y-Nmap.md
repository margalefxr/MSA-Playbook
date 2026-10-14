# 01. Reconocimiento de Red: Subnetting y Nmap

## Objetivo

Pasar de un rango/IP autorizado a un mapa de hosts vivos y puertos abiertos, sin generar más ruido del necesario y sin saltarse el cálculo de subred cuando el objetivo es un segmento completo.

## Subnetting rápido

Antes de escanear un rango entero a ciegas, calcular cuántos hosts caben y qué solapa con qué:

```bash
# Dado 10.10.20.0/24 → 254 hosts usables, máscara 255.255.255.0
ipcalc 10.10.20.0/24

# Para segmentar un rango grande en bloques manejables de escaneo:
python3 -c "import ipaddress; [print(s) for s in ipaddress.ip_network('10.10.0.0/16').subnets(new_prefix=24)]" | head
```

| CIDR | Máscara | Hosts usables | Uso típico |
|---|---|---|---|
| /30 | 255.255.255.252 | 2 | Enlace punto a punto |
| /24 | 255.255.255.0 | 254 | Segmento de LAN típico |
| /16 | 255.255.0.0 | 65.534 | Red corporativa grande / varias VLANs |

## Descubrimiento de hosts (barrido de ping)

```bash
nmap -sn 10.10.20.0/24 -oA recon/host-discovery
# Si ICMP está filtrado (habitual en redes endurecidas):
nmap -sn -PS22,80,443 -PA80,443 10.10.20.0/24 -oA recon/host-discovery-tcp
```

## Escaneo de puertos: de rápido a exhaustivo

El orden importa — no se lanza un `-p-` completo como primer comando contra un /24 entero:

```bash
# 1. Barrido rápido TCP top-1000 sobre todos los hosts vivos
nmap -T4 -iL recon/hosts-vivos.txt -oA recon/fast-scan

# 2. Full TCP (todos los puertos) solo sobre los hosts relevantes
nmap -p- -T4 --min-rate 1000 $TARGET -oA recon/full-tcp

# 3. Detección de servicio/versión y scripts por defecto SOLO sobre los puertos abiertos encontrados
nmap -sCV -p$(cat recon/full-tcp.nmap | grep open | cut -d'/' -f1 | paste -sd,) $TARGET -oA recon/service-scan

# 4. UDP — más lento, se acota a los puertos top habituales salvo que el contexto justifique más
nmap -sU --top-ports 100 $TARGET -oA recon/udp-scan
```

## Por qué este orden y no `-A` directo

| Enfoque | Problema |
|---|---|
| `nmap -A -p- objetivo` de entrada | Lento, ruidoso, y mezcla fases — dificulta separar qué comando generó qué hallazgo en el informe |
| Fases separadas (arriba) | Cada `.nmap`/`.xml` queda como evidencia independiente, trazable a una pregunta concreta ("¿qué puertos?", "¿qué versión?") |

## Timing y sigilo

| Flag | Cuándo usarlo |
|---|---|
| `-T4` | Red estable, sin IDS que preocupe evadir (lab, o auditoría con alcance autorizado para ruido) |
| `-T2` / `--scan-delay` | Entorno con IDS/IPS activo donde el cliente pide minimizar alertas, o enlaces inestables |
| `-D RND:10` | Decoy scan — solo con autorización explícita, y entendiendo que puede generar falsos positivos que compliquen el SOC del cliente |

## Salida y trazabilidad

Siempre `-oA` (los tres formatos: `.nmap` legible, `.xml` parseable, `.gnmap` grep-able). El `.xml` es el que se importa luego a herramientas de correlación o se referencia directamente como evidencia en el informe técnico (ver `06-Plantillas-y-Reportes/01-Plantilla-PoC-Vulnerabilidad.md`).

## Siguiente paso

Con los puertos y servicios identificados, la enumeración profunda por tipo de servicio se documenta en `02-Enumeracion-de-Servicios/`.
