# 00.1 Punto Zero: Setup de Auditoría y Scope

## Protocolo de inicio

1. **Confirmar interfaz VPN** (`tun0` en la mayoría de labs de práctica; en una auditoría real, confirmar también la IP de salida autorizada con el cliente).
   ```bash
   ip a show tun0
   ```
2. **Declarar el objetivo como variable** — nunca pegar la IP a mano en cada comando, es la fuente más común de errores en campo:
   ```bash
   export TARGET="10.10.X.X"
   ```
3. **Crear el árbol de evidencia local** (ver `00-Setup-y-Git-Automation.md`) antes del primer `nmap`.
4. **Verificar el Rules of Engagement (RoE)** antes de lanzar nada activo: alcance exacto (IPs/dominios autorizados), ventana horaria, contactos de escalado si algo rompe producción, y qué queda explícitamente fuera (DoS, ingeniería social, etc.). En un entorno de práctica esto se simplifica, pero mantener el hábito es lo que distingue una prueba autorizada de un acceso no autorizado — la diferencia legal entre ambas es exactamente el papel firmado antes de empezar.

## Checklist de scope

| Pregunta | Por qué importa |
|---|---|
| ¿IPs/dominios exactos autorizados? | Tocar fuera de alcance es la forma más rápida de convertir una auditoría en un incidente |
| ¿Se permite explotación activa o solo detección? | Cambia todo el plan: un escaneo de vulnerabilidades no es lo mismo que un pentest |
| ¿Hay sistemas frágiles (ICS/OT, legacy) a excluir? | Un escáner agresivo puede tumbar un PLC o un sistema sin parchear desde hace años |
| ¿Ventana horaria? | Evita que un escaneo ruidoso coincida con el pico de tráfico de producción del cliente |
| ¿A quién se escala un hallazgo crítico in situ? | Una vulnerabilidad explotable en caliente (RCE sin autenticación) puede justificar parar y avisar antes de continuar |

## Primer reconocimiento pasivo

Antes de cualquier escaneo activo, registrar qué se sabe del objetivo sin tocarlo:

```bash
whois $TARGET
dig any $TARGET
```

Esto separa claramente, en el informe final, qué se obtuvo por OSINT/pasivo (sin dejar huella en los logs del objetivo) de qué se obtuvo por interacción activa — una distinción que importa tanto para el informe técnico como para el marco legal bajo el que se operó.

## Siguiente paso

Con el scope confirmado y el entorno listo, el reconocimiento activo (subnetting, descubrimiento de hosts y Nmap) se documenta en `01-Reconocimiento-y-Redes/01-Subnetting-y-Nmap.md`.
