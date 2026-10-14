# 02.1 Enumeración Web

## Objetivo

Pasar de "hay un servidor web en el 80/443" a un mapa de tecnología, rutas y superficie de ataque concreta, antes de lanzar ningún intento de explotación.

## 1. Fingerprinting de tecnología

```bash
whatweb -a 3 http://$TARGET
curl -sI http://$TARGET                 # cabeceras: servidor, framework, cookies
wappalyzer-cli http://$TARGET 2>/dev/null || true
```

Las cabeceras HTTP (`Server`, `X-Powered-By`, nombres de cookie de sesión) suelen delatar el stack antes de tocar nada más intrusivo.

## 2. Enumeración de contenido y rutas

```bash
# Directorios/ficheros
gobuster dir -u http://$TARGET -w $WORDLIST -x php,txt,bak,zip -t 50 -o enum/gobuster.txt

# Subdominios, si el objetivo es un dominio con vhosts
gobuster vhost -u http://$TARGET -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt

# robots.txt y sitemap — a menudo listan rutas que el propio sitio no quiere indexar
curl -s http://$TARGET/robots.txt
curl -s http://$TARGET/sitemap.xml
```

## 3. Identificación de CMS

```bash
# WordPress
wpscan --url http://$TARGET --enumerate vp,vt,u --api-token $WPSCAN_TOKEN

# Genérico — buscar rutas/firmas conocidas de CMS habituales
curl -s http://$TARGET/wp-login.php -o /dev/null -w "%{http_code}\n"
curl -s http://$TARGET/administrator/ -o /dev/null -w "%{http_code}\n"   # Joomla
```

Un CMS desactualizado identificado aquí es, en la mayoría de auditorías de entorno real, el vector de entrada más probable — ver `audit-shopcloud-cloud-assessment` en el portfolio principal para un caso real de priorización de CVEs sobre WordPress.

## 4. Formularios y superficie de entrada

```bash
# Captura de peticiones para analizar manualmente en Burp/ZAP
# (lanzar el proxy y navegar el sitio con el proxy del navegador apuntando a 127.0.0.1:8080)
```

Puntos a registrar por cada formulario/endpoint encontrado:
- ¿Hay validación de entrada visible (longitud, tipo) o solo del lado cliente?
- ¿El formulario refleja la entrada en la respuesta sin sanitizar (candidato a XSS)?
- ¿Hay parámetros numéricos/IDs en la URL que sugieran IDOR (`?id=104`)?
- ¿Cookies de sesión sin flag `HttpOnly`/`Secure`?

## 5. APIs expuestas

```bash
gobuster dir -u http://$TARGET/api -w /usr/share/seclists/Discovery/Web-Content/api/api-endpoints.txt
curl -s http://$TARGET/api/swagger.json   # documentación de API expuesta por error, frecuente
```

## Checklist OWASP Top 10 aplicada a esta fase

| Riesgo OWASP | Qué buscar en enumeración |
|---|---|
| A01 Broken Access Control | Rutas admin accesibles sin autenticación, IDOR en parámetros |
| A05 Security Misconfiguration | Cabeceras de seguridad ausentes (CSP, HSTS), listados de directorio abiertos |
| A06 Vulnerable Components | Versión de CMS/plugin/librería JS desactualizada y con CVE conocido |
| A09 Logging Failures | No se puede comprobar en esta fase, pero se documenta como pregunta para la entrevista con el cliente |

## Siguiente paso

Con la superficie web mapeada, si el objetivo expone servicios de infraestructura adicionales (SMB, servicios de directorio, etc.), continuar en `02-SMB-y-Servicios-Infraestructura.md`. Si la vía de entrada identificada es web, pasar a `03-Explotacion-y-Shells/`.
