# 06.1 Plantilla de PoC de Vulnerabilidad

## Por qué una plantilla fija

Un hallazgo sin estructura consistente obliga al lector (técnico o no) a buscar la información relevante cada vez de forma distinta. Esta plantilla es la que se usa en los informes reales del portfolio (`audit-axezone-external-recon`, `audit-moldtek-internal-network`) para que cada hallazgo sea comparable y priorizable entre sí.

---

## [ID-XXX] Título del hallazgo

| Campo | Valor |
|---|---|
| **Severidad (CVSS 3.1)** | `X.X` (`AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:N`) |
| **Clasificación (CWE)** | CWE-XXX — Nombre de la categoría |
| **Activo afectado** | Host / URL / servicio exacto |
| **Estado** | Confirmado / Potencial (requiere validación adicional) |
| **Fecha de detección** | AAAA-MM-DD |
| **Fase de la metodología** | Recon / Enumeración / Explotación / Post-explotación |

### Descripción

Explicación en una o dos frases de qué es la vulnerabilidad y por qué existe, sin jerga innecesaria — esta sección la lee también el responsable no técnico del cliente.

### Evidencia técnica (PoC)

```bash
# Comando exacto ejecutado, con marcas de tiempo si aplica
```

```text
Salida relevante (recortada si es muy larga, indicando que se recortó)
```

Capturas de pantalla, si aplica, referenciadas como `![descripción](../assets/evidencia-XXX.png)`.

### Impacto

Qué puede hacer un atacante que explote esto, en términos de negocio, no solo técnicos: ¿acceso a datos de qué tipo? ¿disponibilidad de qué servicio? ¿pivote hacia qué otro activo?

### Causa raíz

La causa técnica concreta (versión sin parchear, configuración por defecto, falta de segmentación, credencial reutilizada) — distinguir siempre causa raíz de síntoma: un XSS reflejado es el síntoma, la ausencia de sanitización de entrada en el framework es la causa raíz, y es la que hay que corregir para que no reaparezca en otro endpoint.

### Recomendación de corrección

Acción concreta, priorizada y realista para el equipo del cliente — no "aplicar buenas prácticas de seguridad" sino el paso exacto ("actualizar `paquete-x` de la versión 2.1 a la 2.4", "añadir el flag `internal: true` a la red backend", "forzar MFA en la cuenta de servicio X").

### Referencias normativas

| Marco | Control relacionado |
|---|---|
| ISO/IEC 27001:2022 | A.X.X |
| ENS (RD 311/2022) | mp.xxx |
| OWASP | A0X:2021 (si aplica a vulnerabilidad web) |
| CWE / CVE | Si aplica |

---

## Matriz de severidad CVSS de referencia rápida

| Rango CVSS | Severidad | SLA de corrección recomendado |
|---|---|---|
| 9.0 – 10.0 | Crítica | Inmediato / 24-72h |
| 7.0 – 8.9 | Alta | 7-15 días |
| 4.0 – 6.9 | Media | 30-60 días |
| 0.1 – 3.9 | Baja | Siguiente ciclo de mantenimiento |

## Resumen ejecutivo (una página, para dirección)

Formato separado del informe técnico completo, con:
- Alcance de la auditoría en 2-3 líneas.
- Tabla de hallazgos por severidad (conteo, no detalle técnico).
- Top 3 riesgos priorizados por impacto de negocio, no por CVSS bruto.
- Una recomendación estratégica de fondo (ej. "la causa raíz repetida en 4 de los 7 hallazgos es ausencia de gestión de parches — se recomienda un proceso formal de vulnerability management", enlazando con `sec-vulnerability-management-assessment`).

## Siguiente paso

Esta plantilla cierra el ciclo de la metodología MSA: cada hallazgo documentado así es el que alimenta tanto el informe técnico completo como el resumen ejecutivo que recibe el cliente.
