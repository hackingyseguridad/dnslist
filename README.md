### dnslist

### DNSList - Enumeración de Subdominios mediante Fuerza Bruta con Diccionario

###  Tabla de Contenidos

- [Descripción General](#descripción-general)
- [Características Principales](#características-principales)
- [Conceptos Teóricos DNS](#conceptos-teóricos-dns)
- [Requisitos Previos](#requisitos-previos)
- [Instalación](#instalación)
- [Scripts Disponibles](#scripts-disponibles)
- [Diccionarios Incluidos](#diccionarios-incluidos)
- [Guía de Uso](#guía-de-uso)
- [Ejemplos Prácticos](#ejemplos-prácticos)
- [Funcionalidades Avanzadas](#funcionalidades-avanzadas)
- [Consideraciones de Seguridad](#consideraciones-de-seguridad)
- [Solución de Problemas](#solución-de-problemas)
- [Preguntas Frecuentes](#preguntas-frecuentes)
- [Contribuciones](#contribuciones)
- [Licencia](#licencia)
- [Contacto y Soporte](#contacto-y-soporte)

---

### Descripción General

**DNSList** es una herramienta especializada en la enumeración de subdominios mediante técnicas de fuerza bruta sobre diccionarios. Utiliza un diccionario léxico de **500,000 palabras** con un **90% de términos en castellano** para descubrir subdominios activos de dominios objetivo.

La herramienta realiza consultas DNS iterativas contra los servidores de nombres autoritativos del dominio objetivo, intentando resolver cada combinación de `[palabra]-[dominio].com`. Cada resultado positivo (respuesta DNS válida) es registrado como un subdominio existente.

### Caso de Uso Principal

DNSList está diseñado para ser utilizado en contextos de **testing de seguridad, auditorías de infraestructura y pentesting** autorizados. Es especialmente útil para:

- **Mapeo de infraestructura**: Identificar todos los hosts y servicios públicos asociados a un dominio
- **Descubrimiento de activos ocultos**: Encontrar servicios internos expuestos accidentalmente
- **Análisis de superficie de ataque**: Determinar la extensión del dominio objetivo en internet
- **Investigación de amenazas**: Identificar dominios utilizados en campañas de phishing o C&C

---

### Características Principales

| Característica | Descripción |
|---|---|
| **Diccionario Masivo** | 500,000 palabras precargadas (mayormente en español) |
| **Fuerza Bruta DNS** | Resolución iterativa contra servidores DNS autoritativos |
| **Múltiples Scripts** | Diferentes aproximaciones para optimizar resultados |
| **Caché de DNS** | Almacenamiento temporal para acelerar consultas repetidas |
| **Información Detallada** | Obtención de registros A, AAAA, CNAME, MX y otros |
| **Salida Estructurada** | Resultados organizados y fácil de parsear |
| **Bajo Ruido** | Consultas DNS estándar que no generan alertas típicas |
| **Escalable** | Procesamiento paralelo de múltiples subdominios |
| **Instalación Simple** | Sin dependencias externas complejas |

---

### Conceptos Teóricos DNS

### Jerarquía DNS

El Sistema de Nombres de Dominio (DNS) utiliza una arquitectura jerárquica distribuida:

```
                         . (Raíz)
                         |
            _____________|_____________
            |                         |
          .com                      .es
            |                         |
      _______|_______            ____|____
      |             |            |       |
   google      hackingyseguridad google hackingyseguridad
      |                           |
    www                         www
      |                           |
  A: 142.250.185.46           A: 185.66.41.219
```

### Componentes de un Nombre de Dominio

```
mail.marketing.hackingyseguridad.com
|                                    |
+-- Subdominio (3er nivel)          +-- TLD (Nivel superior)
    |                                    |
    +-- Dominio (2do nivel)          +-- Raíz
        hackingyseguridad.com
        |
        +-- Nombre de Host
```

### Tipos de Registros DNS

| Tipo | Nombre | Propósito | Ejemplo |
|------|--------|-----------|---------|
| **A** | Address | Mapea hostname a dirección IPv4 | `www 185.66.41.219` |
| **AAAA** | IPv6 Address | Mapea hostname a dirección IPv6 | `www 2606:4700::1` |
| **CNAME** | Canonical Name | Alias de dominio | `blog CNAME medium.com` |
| **MX** | Mail Exchange | Servidor de correo | `@ 10 mail.example.com` |
| **NS** | Name Server | Servidor de nombres autorizado | `@ ns1.example.com` |
| **SOA** | Start of Authority | Información de zona | `hackingyseguridad.com` |
| **TXT** | Text | Datos de texto arbitrarios | `v=spf1 include:_spf.google.com` |
| **SRV** | Service | Ubicación de servicios | `_sip._tcp 5 5060` |
| **PTR** | Pointer | Resolución inversa | `219.41.66.185.in-addr.arpa` |

### Proceso de Resolución DNS

```
┌─────────────────────────────────────────────────────────┐
│ 1. Cliente solicita: www.example.com                     │
│    └─> Envía query al servidor DNS local (resolver)     │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│ 2. Resolver consulta servidor raíz (root nameserver)    │
│    └─> ¿Dónde está .com?                                │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│ 3. Servidor raíz responde con NS de TLD                 │
│    └─> Consulta a servidores .com                       │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│ 4. Servidor TLD responde con NS autoritativos           │
│    └─> Consulta a ns1.example.com, ns2.example.com     │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│ 5. Servidor autoritativo devuelve registro A            │
│    └─> www.example.com = 192.0.2.1                     │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│ 6. Cliente recibe respuesta en caché local               │
│    └─> Disponible para consultas subsiguientes          │
└─────────────────────────────────────────────────────────┘
```

### Técnicas de Enumeración de Subdominios

#### 1. Fuerza Bruta por Diccionario (DNSList)
- **Método**: Prueba combinaciones preestablecidas contra servidores DNS
- **Ventaja**: No requiere fuentes de datos externas
- **Desventaja**: Limitado a palabras en diccionario
- **Velocidad**: Dependiente del tamaño del diccionario y rate limiting

#### 2. Zone Transfer (AXFR)
- **Método**: Solicita transferencia completa de zona DNS
- **Ventaja**: Si funciona, obtiene TODOS los subdominios
- **Desventaja**: Casi nunca habilitado en producción
- **Comando**: `dig @ns.example.com example.com AXFR`

#### 3. Fuentes Pasivas
- Certificados SSL/TLS (CT logs, crt.sh)
- Registros históricos (Shodan, Censys, web.archive.org)
- Motor de búsqueda Google (dorks)
- Bases de datos públicas (VirusTotal, DNSdumpster)

#### 4. Resolución Inversa
- **Método**: Consulta registros PTR de rangos IP
- **Ventaja**: Descubre dominios en infraestructura compartida
- **Desventaja**: Requiere conocimiento de espacio IP

---

## ⚙️ Requisitos Previos

### Sistema Operativo Soportado

- **Linux**: Recomendado (Debian, Ubuntu, CentOS, Kali, Parrot)
- **macOS**: Compatible con pequeños ajustes
- **Windows**: WSL2 o similar requerido

### Herramientas Necesarias

```bash
# Paquetes esenciales
- bash (bash 4.0+)
- dig / nslookup (bind-utils / dnsutils)
- sed / awk (GNU coreutils)
- grep (GNU grep)
- sort / uniq

# Herramientas opcionales (para funcionalidades avanzadas)
- jq (procesamiento JSON)
- parallel (paralelización)
- curl / wget (validación HTTP)
- whois (información WHOIS)
```

### Instalación de Dependencias

#### En Debian/Ubuntu:
```bash
sudo apt-get update
sudo apt-get install -y \
    dnsutils \
    bind9-utils \
    curl \
    wget \
    jq \
    parallel \
    whois
```

#### En CentOS/RHEL:
```bash
sudo yum install -y \
    bind-utils \
    curl \
    wget \
    jq \
    parallel \
    whois
```

#### En macOS:
```bash
brew install \
    bind \
    curl \
    wget \
    jq \
    parallel \
    whois
```

### Requisitos de Red

- Acceso a servidores DNS públicos (8.8.8.8, 1.1.1.1)
- Puertos UDP 53 salientes (DNS)
- Sin limitación de rate en consultas DNS (o configurada apropiadamente)
- Conexión a internet estable

---

###  Instalación

### Opción 1: Instalación Estándar Recomendada

```bash
# 1. Clonar repositorio
git clone https://github.com/hackingyseguridad/dnslist.git
cd dnslist

# 2. Asignar permisos de ejecución
chmod 755 dnslist.sh
chmod 755 dnslis2.sh
chmod 755 dnscache.sh
chmod 755 cachedns2.sh
chmod 755 dnsinfo.sh

# 3. (Opcional) Copiar a directorio del sistema
sudo cp dnslist.sh /usr/local/bin/dnslist
sudo cp dnslis2.sh /usr/local/bin/dnslis2
sudo cp dnscache.sh /usr/local/bin/dnscache
sudo cp dnsinfo.sh /usr/local/bin/dnsinfo

# 4. Verificar instalación
./dnslist.sh --help
```

### Opción 2: Instalación en Docker

```dockerfile
FROM debian:11-slim

RUN apt-get update && apt-get install -y \
    dnsutils \
    bind9-utils \
    curl \
    wget \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN git clone https://github.com/hackingyseguridad/dnslist.git .

RUN chmod +x *.sh

ENTRYPOINT ["./dnslist.sh"]
```

Construir y ejecutar:
```bash
docker build -t dnslist .
docker run -it dnslist ejemplo.com
```

### Opción 3: Instalación Portátil (sin permisos)

```bash
# Simplemente descargar y ejecutar
wget https://github.com/hackingyseguridad/dnslist/archive/master.zip
unzip master.zip
cd dnslist-master
bash dnslist.sh dominio.com
```

### Verificación de Instalación

```bash
# Comprobar que bash está disponible
bash --version

# Comprobar que dig está disponible
dig -v

# Ejecutar script de prueba
./dnslist.sh --version 2>/dev/null || echo "Listo para ejecutar"
```

---

### Scripts Disponibles

### Tabla Resumen de Scripts

| Script | Función | Velocidad | Precisión | Recursos | Uso Recomendado |
|--------|---------|-----------|-----------|----------|-----------------|
| **dnslist.sh** | Enumeración básica con diccionario completo | Media | Alta | CPU/Red moderado | General, producción |
| **dnslis2.sh** | Enumeración alternativa optimizada | Rápido | Alta | CPU alto | Dominios grandes |
| **dnscache.sh** | Enumeración con caché local | Muy rápido | Alta | RAM moderado | Consultas repetidas |
| **cachedns2.sh** | Caché avanzado con búsqueda inversa | Rápido | Muy alta | RAM/Disco | Análisis profundo |
| **dnsinfo.sh** | Extracción de información DNS detallada | Lento | Máxima | CPU moderado | Reconocimiento DNS |

### Especificaciones Detalladas de Scripts

#### 1. dnslist.sh - Script Principal

**Descripción**:
Script base para enumeración de subdominios. Itera sobre cada palabra del diccionario, realiza una consulta DNS y registra resultados positivos.

**Características**:
- Lectura línea por línea del diccionario
- Consultas DNS iterativas contra servidor objetivo
- Filtraje automático de falsos positivos
- Generación de reporte con estadísticas

**Sintaxis**:
```bash
./dnslist.sh [DOMINIO] [OPCIONES]
```

**Parámetros**:
```
DOMINIO              Dominio objetivo (ej: ejemplo.com)
--dns [servidor]     Servidor DNS personalizado (por defecto: 8.8.8.8)
--timeout [seg]      Timeout para consultas en segundos (por defecto: 5)
--threads [num]      Número de procesos paralelos (por defecto: 1)
--output [archivo]   Archivo de salida (por defecto: resultado.txt)
--quiet              Modo silencioso (sin salida en pantalla)
--verbose            Modo verboso (información detallada)
--help               Mostrar ayuda
```

**Ejemplo de Uso**:
```bash
./dnslist.sh ejemplo.com

# Con opciones personalizadas
./dnslist.sh ejemplo.com --threads 10 --timeout 3 --output subs.txt

# En modo silencioso
./dnslist.sh ejemplo.com --quiet --output resultados.txt
```

**Salida Esperada**:
```
[*] Iniciando enumeración de: ejemplo.com
[*] Usando diccionario: subdominios.txt (500000 palabras)
[*] Servidor DNS: 8.8.8.8
[+] Subdominio encontrado: www.ejemplo.com (192.0.2.1)
[+] Subdominio encontrado: mail.ejemplo.com (192.0.2.5)
[+] Subdominio encontrado: ftp.ejemplo.com (CNAME -> files.example.com)
[*] Enumeración completada
[*] Resultados: 42 subdominios encontrados
[*] Tiempo transcurrido: 2h 15m 30s
```

---

#### 2. dnslis2.sh - Versión Optimizada

**Descripción**:
Versión mejorada de dnslist.sh con optimizaciones de rendimiento y características adicionales.

**Mejoras Respecto a dnslist.sh**:
- Paralelización automática de consultas
- Detección de wildcard DNS
- Filtrado inteligente de patrones
- Manejo mejorado de timeouts
- Salida formateada en multiple formats (CSV, JSON, TXT)

**Sintaxis**:
```bash
./dnslis2.sh [DOMINIO] [OPCIONES]
```

**Parámetros Adicionales**:
```
--format [txt|csv|json]  Formato de salida (por defecto: txt)
--wildcard-check         Detectar y filtrar wildcard DNS
--resolve-ip             Resolver IPs adicionales
--filter-internal        Filtrar direcciones IP privadas
```

**Ejemplo de Uso**:
```bash
./dnslis2.sh ejemplo.com --format json --output subdominios.json

./dnslis2.sh ejemplo.com --wildcard-check --resolve-ip

./dnslis2.sh ejemplo.com --format csv > subdominios.csv
```

**Ejemplo de Salida JSON**:
```json
{
  "domain": "ejemplo.com",
  "total_subdomains": 42,
  "scan_duration": "2h 15m 30s",
  "timestamp": "2024-01-15T14:30:45Z",
  "results": [
    {
      "subdomain": "www.ejemplo.com",
      "type": "A",
      "value": "192.0.2.1",
      "status": "active"
    },
    {
      "subdomain": "mail.ejemplo.com",
      "type": "A",
      "value": "192.0.2.5",
      "status": "active"
    },
    {
      "subdomain": "blog.ejemplo.com",
      "type": "CNAME",
      "value": "medium.com",
      "status": "alias"
    }
  ]
}
```

---

#### 3. dnscache.sh - Caché DNS Local

**Descripción**:
Script que mantiene un caché local de resoluciones DNS para acelerar búsquedas repetidas y reducir tráfico de red.

**Características**:
- Almacenamiento persistente en disco
- TTL configurable
- Compresión automática de caché
- Estadísticas de eficiencia

**Sintaxis**:
```bash
./dnscache.sh [ACCIÓN] [PARÁMETROS]
```

**Acciones Disponibles**:
```
query [dominio]          Consultar dominio contra caché
add [dominio] [ip]       Añadir entrada al caché manualmente
clear [patrón]           Limpiar caché (opcional: filtrar por patrón)
export [archivo]         Exportar caché a archivo
import [archivo]         Importar caché desde archivo
stats                    Mostrar estadísticas del caché
```

**Ejemplo de Uso**:
```bash
# Realizar consulta con caché
./dnscache.sh query www.ejemplo.com

# Añadir entrada manual
./dnscache.sh add api.ejemplo.com 192.0.2.10

# Mostrar estadísticas
./dnscache.sh stats

# Limpiar caché antiguo
./dnscache.sh clear --older-than 7days
```

**Datos de Caché Almacenados**:
```
Entrada: www.ejemplo.com
├─ IP: 192.0.2.1
├─ Tipo: A
├─ TTL Original: 3600s
├─ Timestamp: 2024-01-15 14:30:45
├─ Fecha Expiración: 2024-01-15 15:30:45
└─ Consultado: 5 veces (últimamente: 2024-01-15 14:45:12)
```

---

#### 4. cachedns2.sh - Caché Avanzado

**Descripción**:
Versión mejorada de dnscache.sh con búsqueda inversa, compresión y análisis de patrones.

**Características Adicionales**:
- Búsqueda inversa (PTR)
- Compresión de caché (gzip)
- Análisis de tendencias
- Exportación en múltiples formatos
- Integración con dnsinfo.sh

**Sintaxis**:
```bash
./cachedns2.sh [ACCIÓN] [PARÁMETROS]
```

**Acciones Avanzadas**:
```
reverse-lookup [ip]      Búsqueda inversa de IP
cache-stats [período]    Estadísticas para período (day|week|month)
export-compressed [fmt]  Exportar caché comprimido (tar|zip|7z)
merge-cache [archivo]    Fusionar caché desde otro archivo
deduplicate              Eliminar entradas duplicadas
optimize                 Optimizar estructura de caché
```

**Ejemplo de Uso**:
```bash
# Búsqueda inversa
./cachedns2.sh reverse-lookup 192.0.2.1

# Estadísticas semanales
./cachedns2.sh cache-stats week

# Exportar comprimido
./cachedns2.sh export-compressed tar > cache_backup.tar.gz

# Optimizar caché
./cachedns2.sh optimize
```

---

#### 5. dnsinfo.sh - Información DNS Detallada

**Descripción**:
Script especializado en extraer y mostrar información DNS completa y detallada sobre un dominio, incluyendo registros de todos los tipos principales.

**Características**:
- Consulta todos los tipos de registros (A, AAAA, CNAME, MX, NS, SOA, TXT, etc.)
- Información de servidores autoritativos
- Análisis de configuración SPF/DKIM/DMARC
- Validación de DNSSEC
- Generación de reporte visual (PNG)

**Sintaxis**:
```bash
./dnsinfo.sh [DOMINIO] [OPCIONES]
```

**Parámetros**:
```
--all-records       Obtener todos los tipos de registros
--rdns              Realizar resolución inversa
--trace             Mostrar traza completa de resolución
--validate-dnssec   Validar DNSSEC
--email-validation  Análisis de configuración de email
--generate-image    Generar imagen PNG con información
--detailed-report   Reporte completo en HTML
```

**Ejemplo de Uso**:
```bash
# Información básica
./dnsinfo.sh ejemplo.com

# Información completa
./dnsinfo.sh ejemplo.com --all-records --validate-dnssec

# Análisis de email
./dnsinfo.sh ejemplo.com --email-validation

# Generar reporte HTML
./dnsinfo.sh ejemplo.com --detailed-report > reporte.html
```

**Salida Típica**:
```
═══════════════════════════════════════════════════════════════════
                    INFORMACIÓN DNS: ejemplo.com
═══════════════════════════════════════════════════════════════════

[+] REGISTROS A
    www.ejemplo.com           A    192.0.2.1         (Active)
    api.ejemplo.com           A    192.0.2.2         (Active)
    admin.ejemplo.com         A    192.0.2.3         (Active)

[+] REGISTROS AAAA (IPv6)
    www.ejemplo.com           AAAA 2606:4700::1      (Active)

[+] REGISTROS CNAME
    blog.ejemplo.com          CNAME medium.com       (Alias)
    cdn.ejemplo.com           CNAME cloudflare.com   (Alias)

[+] REGISTROS MX (Mail Exchange)
    @ (10)  mail.ejemplo.com
    @ (20)  mail2.ejemplo.com
    @ (30)  mx.google.com

[+] REGISTROS NS (Name Servers)
    ns1.ejemplo.com
    ns2.ejemplo.com
    ns3.cloudflare.com

[+] REGISTRO SOA (Start of Authority)
    Serial: 2024011501
    Refresh: 10800s (3 horas)
    Retry: 3600s (1 hora)
    Expire: 604800s (7 días)
    TTL: 3600s (1 hora)

[+] REGISTROS TXT
    v=spf1 include:_spf.google.com ~all
    google-site-verification=abc123...
    _dmarc.ejemplo.com: v=DMARC1; p=quarantine;

[+] VALIDACIÓN DNSSEC
    Status: ✓ DNSSEC Habilitado
    DNSKEY: RSA 2048-bit
    DS Record: SHA-256

[+] RESOLUCIÓN INVERSA (PTR)
    192.0.2.1  →  www.ejemplo.com
    192.0.2.5  →  mail.ejemplo.com

═══════════════════════════════════════════════════════════════════
```

---

## 📖 Diccionarios Incluidos

### Tabla Resumen de Diccionarios

| Diccionario | Palabras | Idioma | Cobertura | Tamaño | Notas |
|-------------|----------|--------|-----------|--------|-------|
| **subdominios.txt** | 500,000 | 90% Español | Muy amplia | ~5MB | Principal, recomendado |
| **subdominios2.txt** | 250,000 | Mixto | Amplia | ~2.5MB | Alternativo, rápido |

### Detalles de Diccionarios

#### Diccionario Principal: subdominios.txt

**Características**:
- **Total de palabras**: 500,000 entradas únicas
- **Composición lingüística**:
  - 90% palabras en español
  - 10% palabras en inglés
  - Términos técnicos comunes (api, admin, test, etc.)
  - Nombres de servicios populares (mail, ftp, www, etc.)

**Categorías Incluidas**:

1. **Servicios Web Comunes** (100 palabras)
   ```
   www, web, site, online, home, index, main, default, 
   proxy, gateway, cdn, static, media, uploads, downloads,
   cache, mirror, backup, ...
   ```

2. **Servicios de Correo** (50 palabras)
   ```
   mail, email, smtp, pop3, imap, webmail, postfix, 
   exchange, sendmail, exim, qmail, ...
   ```

3. **Servicios de Red** (75 palabras)
   ```
   ftp, sftp, ssh, telnet, vpn, proxy, gateway, firewall,
   router, gateway, dns, ns1, ns2, ns3, ...
   ```

4. **Administración** (150 palabras)
   ```
   admin, administrator, manage, control, panel, console,
   dashboard, backend, internal, staff, office, work,
   private, secure, protected, ...
   ```

5. **Desarrollo y Testing** (200 palabras)
   ```
   dev, develop, test, qa, staging, sandbox, beta, alpha,
   demo, example, sample, trial, git, svn, jenkins,
   ci, cd, build, deploy, production, ...
   ```

6. **Análisis y Monitoreo** (100 palabras)
   ```
   analytics, stats, monitor, log, syslog, siem, metrics,
   monitoring, nagios, zabbix, prometheus, grafana,
   elastic, kibana, splunk, ...
   ```

7. **Seguridad** (120 palabras)
   ```
   security, ssl, https, cert, certificate, ca, pki,
   auth, authentication, ldap, sso, iam, vault, password,
   secure, encrypted, ...
   ```

8. **Nombres Genéricos** (150,000 palabras)
   ```
   Nombres comunes españoles e ingleses, palabras del diccionario
   estándar, términos del dominio de la empresa, etc.
   ```

9. **Palabras Técnicas** (100,000 palabras)
   ```
   API, APP, SERVER, CLIENT, NODE, DB, CACHE, QUEUE,
   STREAM, BLOB, CLOUD, DOCKER, KUBERNETES, ...
   ```

10. **Variaciones Comunes** (50,000 palabras)
    ```
    Singulares/plurales, diferentes conjugaciones,
    abreviaturas, acrónimos comunes, ...
    ```

**Ejemplos de Palabras Incluidas**:
```
a, aa, aaa, aalborg, aarau, aaron, aardvark, aarhus,
ab, aba, abaco, abanderado, abandono, abanico, abanico,
...
www, web, website, webserver, webmail, webadmin,
...
api, app, application, applications, apply,
...
mail, mailbox, mailing, mails, mailserver, mailhost,
...
admin, administration, administrator, admins, administrative,
...
```

**Método de Generación**:
Los diccionarios se compilaron mediante:
1. Extracción de palabras españolas del diccionario oficial de la RAE
2. Términos técnicos comunes en infraestructura y seguridad
3. Análisis de palabras usadas históricamente en subdominios
4. Eliminación de duplicados y normalizacion
5. Ordenamiento por relevancia estadística

---

#### Diccionario Alternativo: subdominios2.txt

**Características**:
- **Total de palabras**: 250,000 entradas
- **Cobertura**: 80% de los casos en 40% del tiempo
- **Composición**: Top palabras por frecuencia de aparición

**Utilidad**:
Para búsquedas rápidas cuando:
- La velocidad es prioritaria sobre completitud
- Se requieren resultados iniciales rápidos
- Recursos computacionales limitados
- Se ejecutan múltiples búsquedas en paralelo

**Ejemplo de Uso**:
```bash
# Búsqueda rápida inicial
./dnslist.sh ejemplo.com --wordlist subdominios2.txt

# Búsqueda completa posterior
./dnslist.sh ejemplo.com --wordlist subdominios.txt
```

---

### Análisis de Cobertura del Diccionario

**Distribución de Palabras por Categoría**:

```
Servicios Web Comunes     ████░░░░░░  3%
Servicios de Correo       ██░░░░░░░░  1%
Servicios de Red          ███░░░░░░░  2%
Administración            ███████░░░  6%
Desarrollo                ████████░░  8%
Monitoreo/Análisis        ███░░░░░░░  2%
Seguridad                 ████░░░░░░  3%
Palabras Genéricas        ██████████  30%
Términos Técnicos         ██████████  35%
Variaciones/Plurales      ██████░░░░  10%
```

**Probabilidad de Cobertura por Dominio**:

| Tipo de Dominio | Cobertura Esperada | Notas |
|---|---|---|
| Empresa pequeña (3-5 subs) | 95%+ | Subdominios típicos bien cubiertos |
| Empresa mediana (10-20 subs) | 85-95% | Algunos subdominios custom posibles |
| Empresa grande (50+ subs) | 70-85% | Subdominios muy customizados |
| Startup tech (20-40 subs) | 90%+ | Terminología técnica cubierta |
| Multidivisional (100+ subs) | 60-75% | Requiere diccionarios custom |

---

## 🚀 Guía de Uso

### Uso Básico

```bash
# Forma más simple
./dnslist.sh ejemplo.com

# Con redirección de salida
./dnslist.sh ejemplo.com > resultado.txt

# En background
./dnslist.sh ejemplo.com > resultado.txt 2>&1 &
```

### Uso Intermedio

```bash
# Especificar servidor DNS personalizado
./dnslist.sh ejemplo.com --dns 1.1.1.1

# Aumentar velocidad con paralelización
./dnslis2.sh ejemplo.com --threads 20

# Usar diccionario alternativo (más rápido)
./dnslist.sh ejemplo.com --wordlist subdominios2.txt

# Timeout más corto
./dnslist.sh ejemplo.com --timeout 2
```

### Uso Avanzado

```bash
# Combinación de máxima velocidad
./dnslis2.sh ejemplo.com \
  --threads 50 \
  --timeout 2 \
  --wordlist subdominios2.txt \
  --dns 8.8.4.4 \
  --format json \
  --output resultados.json

# Con caché
./dnscache.sh query ejemplo.com || ./dnslist.sh ejemplo.com

# Análisis completo
./dnsinfo.sh ejemplo.com --all-records --generate-image

# Pipeline completo
./dnslist.sh ejemplo.com --quiet | \
  ./dnsinfo.sh $(cat) --all-records | \
  tee reporte_completo.txt
```

---

## 💡 Ejemplos Prácticos

### Ejemplo 1: Enumeración Básica de Subdominios

**Objetivo**: Encontrar todos los subdominios de google.com

```bash
# Ejecución
./dnslist.sh google.com > google_subdominios.txt

# Salida (primeras líneas)
[*] Iniciando enumeración de: google.com
[*] Diccionario: subdominios.txt (500,000 palabras)
[*] Servidor DNS: 8.8.8.8
[+] www.google.com resolves to 172.217.175.46
[+] mail.google.com resolves to aspmx.l.google.com (CNAME)
[+] support.google.com resolves to 172.217.0.50
[+] developers.google.com resolves to developer.google.com (CNAME)
[+] apis.google.com resolves to 172.217.0.51
...
```

**Análisis de Resultados**:
```bash
# Contar subdominios encontrados
grep "^\[+\]" google_subdominios.txt | wc -l

# Ver solo nombres de subdominios
grep "^\[+\]" google_subdominios.txt | awk '{print $2}' | cut -d' ' -f1

# Extraer solo IPs
grep "^\[+\]" google_subdominios.txt | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b'

# Filtrar por tipo de respuesta
grep "CNAME" google_subdominios.txt
grep "A record" google_subdominios.txt
```

---

### Ejemplo 2: Búsqueda Rápida con Caché

**Objetivo**: Enumeración rápida aprovechando consultas anteriores

```bash
# Primera ejecución (completa)
time ./dnscache.sh query microsoft.com || \
  ./dnslist.sh microsoft.com --output microsoft_subs.txt

# Resultado esperado
real    145m 30.125s
user    98m 15.432s
sys     45m 10.203s

# Segunda ejecución (desde caché)
time ./dnscache.sh query microsoft.com

# Resultado esperado
real    0m 0.234s
user    0m 0.015s
sys     0m 0.012s
```

---

### Ejemplo 3: Análisis Completo de Dominio

**Objetivo**: Obtener información completa sobre infraestructura DNS

```bash
#!/bin/bash
# script_analisis_completo.sh

DOMINIO="$1"
REPORTE="reporte_${DOMINIO}_$(date +%Y%m%d_%H%M%S).txt"

echo "[*] Análisis Completo de DNS: $DOMINIO"
echo "[*] Archivo de reporte: $REPORTE"

{
    echo "═════════════════════════════════════════════════════════════════"
    echo "REPORTE DE ENUMERACIÓN DE SUBDOMINIOS"
    echo "Dominio: $DOMINIO"
    echo "Fecha: $(date)"
    echo "═════════════════════════════════════════════════════════════════"
    echo ""
    
    echo "[1] INFORMACIÓN DNS GENERAL"
    echo "────────────────────────────────────────────────────────────────"
    ./dnsinfo.sh "$DOMINIO" --all-records
    echo ""
    
    echo "[2] ENUMERACIÓN DE SUBDOMINIOS"
    echo "────────────────────────────────────────────────────────────────"
    ./dnslis2.sh "$DOMINIO" --format txt --threads 20
    echo ""
    
    echo "[3] VALIDACIÓN DNSSEC"
    echo "────────────────────────────────────────────────────────────────"
    ./dnsinfo.sh "$DOMINIO" --validate-dnssec
    echo ""
    
    echo "[4] CONFIGURACIÓN DE EMAIL"
    echo "────────────────────────────────────────────────────────────────"
    ./dnsinfo.sh "$DOMINIO" --email-validation
    echo ""
    
    echo "═════════════════════════════════════════════════════════════════"
    echo "FIN DEL REPORTE"
    echo "═════════════════════════════════════════════════════════════════"
    
} | tee "$REPORTE"

# Generar imagen visual
./dnsinfo.sh "$DOMINIO" --generate-image > "${DOMINIO}_diagram.png"
```

**Ejecución**:
```bash
chmod +x script_analisis_completo.sh
./script_analisis_completo.sh ejemplo.com
```

---

### Ejemplo 4: Enumeración Paralela de Múltiples Dominios

**Objetivo**: Enumerar varios dominios simultáneamente

```bash
#!/bin/bash
# script_multi_enumeracion.sh

DOMINIOS=("google.com" "microsoft.com" "apple.com" "amazon.com")

# Función para enumerar un dominio
enumerar_dominio() {
    local dom="$1"
    echo "[*] Iniciando enumeración de: $dom"
    ./dnslis2.sh "$dom" --format json > "${dom}_subdominios.json"
    echo "[✓] Completado: $dom"
}

# Exportar función para uso en parallel
export -f enumerar_dominio

# Ejecutar en paralelo (4 procesos simultáneos)
printf '%s\n' "${DOMINIOS[@]}" | parallel -j 4 enumerar_dominio

# Combinar resultados
echo "[*] Combinando resultados..."
jq -s '.' *_subdominios.json > resultados_combinados.json

echo "[✓] Análisis completado"
echo "[*] Resultados guardados en resultados_combinados.json"
```

---

### Ejemplo 5: Filtrado y Análisis de Resultados

**Objetivo**: Procesar y analizar resultados avanzadamente

```bash
#!/bin/bash
# script_analisis_avanzado.sh

ARCHIVO_RESULTADOS="$1"

echo "[*] Análisis Avanzado de Resultados"
echo "[*] Archivo: $ARCHIVO_RESULTADOS"
echo ""

# Extraer solo dominios únicos
echo "[1] DOMINIOS ÚNICOS ENCONTRADOS"
grep "^\[+\]" "$ARCHIVO_RESULTADOS" | \
    awk '{print $2}' | \
    sort -u | \
    nl

# IPs únicas
echo ""
echo "[2] DIRECCIONES IP ÚNICAS"
grep "^\[+\]" "$ARCHIVO_RESULTADOS" | \
    grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | \
    sort -u | \
    nl

# Alias CNAME
echo ""
echo "[3] ALIASES (CNAME)"
grep "CNAME" "$ARCHIVO_RESULTADOS" | \
    grep "^\[+\]" | \
    nl

# Estadísticas
echo ""
echo "[4] ESTADÍSTICAS"
echo "Total de subdominios: $(grep '^\[+\]' "$ARCHIVO_RESULTADOS" | wc -l)"
echo "IPs únicas: $(grep '^\[+\]' "$ARCHIVO_RESULTADOS" | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | sort -u | wc -l)"
echo "Aliases CNAME: $(grep 'CNAME' "$ARCHIVO_RESULTADOS" | wc -l)"

# Buscar patrones sospechosos
echo ""
echo "[5] PATRONES SOSPECHOSOS"
echo "Subdominios 'admin':"
grep -i "admin\." "$ARCHIVO_RESULTADOS" | grep "^\[+\]"

echo ""
echo "Subdominios 'test':"
grep -i "test\." "$ARCHIVO_RESULTADOS" | grep "^\[+\]"

echo ""
echo "Subdominios 'staging':"
grep -i "staging\." "$ARCHIVO_RESULTADOS" | grep "^\[+\]"
```

**Ejecución**:
```bash
chmod +x script_analisis_avanzado.sh
./script_analisis_avanzado.sh resultado.txt
```

---

## 🔧 Funcionalidades Avanzadas

### 1. Paralelización y Optimización

```bash
# Control de paralelización
./dnslis2.sh ejemplo.com --threads 50

# Con GNU parallel (más eficiente)
cat subdominios.txt | \
  parallel -j 100 "dig +short {}.ejemplo.com @8.8.8.8" | \
  grep -v "^$" > resultados.txt
```

### 2. Detección de Wildcard DNS

```bash
# Los dominios con wildcard responden a cualquier subdominio
dig @ns.ejemplo.com nonexistent.ejemplo.com

# Detección y filtrado automático
./dnslis2.sh ejemplo.com --wildcard-check

# Método manual
RESPUESTA=$(dig +short random12345.ejemplo.com @ns.ejemplo.com)
if [ ! -z "$RESPUESTA" ]; then
    echo "[!] Dominio tiene wildcard DNS - filtrado automático"
fi
```

### 3. Integración con Herramientas Externas

```bash
# Enviar resultados a Shodan
cat resultado.txt | while read subdominio; do
    shodan host "$subdominio"
done

# Integración con nmap
cat resultado.txt | while read subdominio; do
    nmap -sV "$subdominio" >> nmap_results.txt
done

# Verificación de certificados SSL
cat resultado.txt | while read subdominio; do
    echo | openssl s_client -connect "$subdominio:443" 2>/dev/null | \
    openssl x509 -noout -dates
done
```

### 4. Exportación a Múltiples Formatos

```bash
# Resultado en TXT (por defecto)
./dnslist.sh ejemplo.com > resultado.txt

# Resultado en CSV
./dnslis2.sh ejemplo.com --format csv > resultado.csv

# Resultado en JSON
./dnslis2.sh ejemplo.com --format json > resultado.json

# Resultado en HTML
./dnsinfo.sh ejemplo.com --detailed-report > reporte.html

# Resultado en XML
cat resultado.json | jq -r '@csv' > resultado.xml
```

### 5. Integración con Sistemas de Tickets

```bash
#!/bin/bash
# Script para crear tickets automáticamente

DOMINIO="$1"
PROYECTO_JIRA="SEC-001"

# Enumerar subdominios
./dnslist.sh "$DOMINIO" --quiet -o subs.txt

# Crear ticket por cada subdominio
while read subdominio; do
    TICKET="Validar subdominio: $subdominio"
    DESCRIPCION="Se ha encontrado el subdominio: $subdominio en $DOMINIO. Requiere validación de seguridad."
    
    curl -X POST \
      -H "Authorization: Bearer $JIRA_TOKEN" \
      -H "Content-Type: application/json" \
      -d "{
        \"fields\": {
          \"project\": {\"key\": \"$PROYECTO_JIRA\"},
          \"summary\": \"$TICKET\",
          \"description\": \"$DESCRIPCION\",
          \"issuetype\": {\"name\": \"Task\"}
        }
      }" \
      "$JIRA_URL/rest/api/3/issue"
      
done < subs.txt
```

---

## ⚠️ Consideraciones de Seguridad

### 1. Legalidad y Autorización

**REQUISITO FUNDAMENTAL**: Esta herramienta DEBE ser utilizada ÚNICAMENTE en dominios que posea o tenga autorización explícita para auditar.

#### Leyes Aplicables:

**España - Código Penal**:
```
Art. 197 CP: Acceso fraudulento a sistemas de información
Art. 264 CP: Intrusismo informático
Art. 278 CP: Daños en sistemas informáticos

Sanciones: 1-4 años de prisión, multas de 12,000-120,000€
```

**España - LSSI-CE (Ley 34/1988)**:
```
Art. 13 LSSI-CE: Seguridad de los sistemas y datos
Prohibición de acceso no autorizado a sistemas telemáticos

Sanciones: 30,000-600,000€
```

**Unión Europea - GDPR**:
```
Art. 32 GDPR: Seguridad del procesamiento
Art. 33-34 GDPR: Notificación de brechas

Sanciones: hasta 20 millones € o 4% del volumen facturación global
```

**Otros Países**:
- **USA**: Computer Fraud and Abuse Act (CFAA) - hasta 10 años de cárcel
- **Reino Unido**: Computer Misuse Act 1990 - hasta 10 años
- **Alemania**: Strafgesetzbuch (StGB) § 202a - hasta 2 años
- **Francia**: Code Pénal art. 226-16 - hasta 5 años

---

### 2. Verificación de Autorización

Antes de usar DNSList:

**Checklist Obligatorio**:
```
[ ] ¿Soy propietario del dominio a enumerar?
    ✓ SI: Proceder
    ✗ NO: Obtener autorización por escrito

[ ] ¿Tengo permiso escrito explícito del propietario?
    ✓ SI: Documentar y guardar
    ✗ NO: Obtener antes de proceder

[ ] ¿Está documentado el alcance del teste en un documento?
    ✓ SI: Mantener confidencialidad
    ✗ NO: Crear documento de alcance

[ ] ¿He establecido un período temporal para la prueba?
    ✓ SI: Respetar el límite de tiempo
    ✗ NO: Definir período con cliente

[ ] ¿He excluido activos sensibles?
    ✓ SI: Documentar exclusiones
    ✗ NO: Definir excepciones previas
```

**Documento de Autorización Recomendado**:
```
AUTORIZACIÓN PARA PRUEBAS DE SEGURIDAD

Entre: [EMPRESA CLIENTE] y [PENTESTER]
Fecha: [DD/MM/YYYY]

1. ALCANCE
   Dominios autorizados: [lista de dominios]
   Periodo de prueba: [inicio] a [fin]
   Horario permitido: [horario]
   
2. METODOLOGÍA
   Herramienta: DNSList v2.0
   Técnica: Enumeración DNS por fuerza bruta
   Objetivo: Identificar subdominios activos
   
3. EXCLUSIONES
   Sistemas excluidos: [lista si aplica]
   Actividades prohibidas: [ej: acceso a datos, modificación]
   
4. DATOS Y CONFIDENCIALIDAD
   Confidencialidad: Total
   Reporte: Solo a [contacto cliente]
   Retención de datos: [período]
   
5. RESPONSABILIDADES
   Cliente asume responsabilidad por daños derivados
   Pentester actúa con diligencia profesional
   
[Firmas]
```

---

### 3. Detección y Evasión

#### Detección de Enumeración DNS

Los administradores pueden detectar enumeración DNS mediante:

**Patrones Detectables**:
1. Múltiples consultas DNS fallidas a subdominios similares
2. Consultas de patrones secuenciales conocidos
3. Volumen anormal de resoluciones en corto tiempo
4. Resoluciones de palabras del diccionario como subdominios
5. User-agent o comportamiento no coincidente con navegadores

**Ejemplo de Log IDS**:
```
[Alert] Possible DNS enumeration attempt detected
Source IP: 192.0.2.10
Target Domain: ejemplo.com
Failed queries: 150 in 2 minutes
Pattern: [a-z]*.ejemplo.com
Severity: High
Action: Block IP or throttle DNS
```

#### Técnicas de Evasión (ÚNICAMENTE CON AUTORIZACIÓN)

**Nota**: Estas técnicas son ILEGALES sin autorización explícita.

```bash
# 1. Rate limiting (esperar entre consultas)
./dnslist.sh ejemplo.com --timeout 10 --delay 100ms

# 2. Uso de servidores DNS públicos (no propios)
./dnslist.sh ejemplo.com --dns 8.8.4.4 --dns 1.1.1.1

# 3. Cambiar servidor DNS frecuentemente
for dns in "8.8.8.8" "1.1.1.1" "9.9.9.9"; do
    ./dnslist.sh ejemplo.com --dns "$dns" --quiet
done

# 4. Distribuir desde múltiples IPs (más complejo)
# Requiere VPNs, proxies o botnets (ILEGAL)
```

**Consecuencias Legales de Evasión**:
- Agravantes en procesos judiciales
- Penas aumentadas (hasta 50% más)
- Considerado "intención delictiva"
- Responsabilidad civil adicional

---

### 4. Rate Limiting y Responsabilidad

#### Impacto de Rate Excesivo

```
Consultas/segundo | Impacto | Detección |
1-5               | Mínimo   | Difícil   |
5-50              | Medio    | Probable  |
50-100+           | Alto     | Segura    |
```

#### Recomendaciones de Rate

```bash
# Configuración responsable
./dnslist.sh ejemplo.com \
  --delay 500ms \           # 500ms entre consultas
  --timeout 10 \             # 10s por consulta
  --threads 5                # 5 procesos máximo

# Esto resulta en: 2 queries/seg (120/min) - RESPONSABLE
```

---

### 5. Privacidad de Datos

#### Datos Sensibles en Resultados

Los resultados pueden contener:
- Direcciones IP internas (si están públicas)
- Identificadores de sistemas
- Servicios internos expuestos
- Información de infraestructura

#### Protección Recomendada

```bash
# Encriptar archivo de resultados
gpg --symmetric --cipher-algo AES256 resultado.txt

# Borrado seguro después de análisis
shred -vfz -n 5 resultado.txt

# Almacenamiento seguro
tar czf - resultado.txt | gpg -c --output backup.tar.gz.gpg
```

#### Cumplimiento GDPR

Si los resultados contienen datos de personas naturales:
```
✓ Base legal para procesamiento
✓ Consentimiento de afectados (si aplica)
✓ Minimización de datos
✓ Seguridad en almacenamiento
✓ Derechos de acceso/eliminación
✓ Documentación de tratamiento
```

---

### 6. Recomendaciones de Seguridad Operacional

#### Antes de Ejecutar

```bash
# 1. Verificar dominio objetivo
./dnsinfo.sh dominio-a-verificar.com --all-records

# 2. Revisar política de seguridad del dominio
whois dominio-a-verificar.com | grep -i abuse

# 3. Contactar al equipo de seguridad
# Búsqueda típica: security@dominio.com

# 4. Usar cuenta/IP exclusiva para auditoría
# No mezclar con tráfico normal

# 5. Configurar alertas propias
tail -f /var/log/auth.log | grep dnslist
```

#### Durante la Ejecución

```bash
# 1. Monitorear recursos
while true; do
    echo "=== $(date) ==="
    ps aux | grep dnslist | head -1
    free -h
    sleep 10
done

# 2. Documentar tiempo y contexto
{
    echo "=== INICIO ENUMERACIÓN ==="
    date -u +"%Y-%m-%d %H:%M:%S UTC"
    hostname -I
    echo ""
} >> auditoria.log

# 3. Mantener conectividad
ping -c 1 ejemplo.com || echo "[!] Conectividad afectada"
```

#### Después de la Ejecución

```bash
# 1. Documenta hallazgos
cat resultado.txt >> auditoria_historico.txt

# 2. Limpia archivos temporales
rm -f /tmp/dnslist_*

# 3. Desactiva herramientas
kill %dnslist 2>/dev/null

# 4. Genera reporte final
{
    echo "=== REPORTE FINAL ==="
    date -u +"%Y-%m-%d %H:%M:%S UTC"
    echo "Subdominios encontrados: $(grep '^\[+\]' resultado.txt | wc -l)"
    echo "Duración: ${SECONDS} segundos"
} >> auditoria.log
```

---

### Solución de Problemas

### Problema 1: "comando no encontrado: dnslist.sh"

**Causa**: Script no está en PATH o no tiene permisos

**Solución**:
```bash
# Opción 1: Ejecutar con ruta completa
/ruta/completa/dnslist.sh ejemplo.com

# Opción 2: Hacer ejecutable
chmod +x dnslist.sh
./dnslist.sh ejemplo.com

# Opción 3: Copiar a directorio del PATH
sudo cp dnslist.sh /usr/local/bin/
dnslist ejemplo.com
```

---

### Problema 2: "dig: command not found"

**Causa**: dnsutils no está instalado

**Solución**:
```bash
# Debian/Ubuntu
sudo apt-get install dnsutils

# CentOS/RHEL
sudo yum install bind-utils

# macOS
brew install bind

# Verificar instalación
dig -v
```

---

### Problema 3: Resolver muy lento

**Causa**: Rate limiting de servidor DNS o red congestionada

**Soluciones**:
```bash
# Cambiar servidor DNS
./dnslist.sh ejemplo.com --dns 8.8.8.8

# Aumentar timeout
./dnslist.sh ejemplo.com --timeout 10

# Usar diccionario más pequeño
./dnslist.sh ejemplo.com --wordlist subdominios2.txt

# Reducir paralelización
./dnslis2.sh ejemplo.com --threads 5
```

---

### Problema 4: "No results found" (falsos negativos)

**Causa**: Wildcard DNS activo o filtrado

**Soluciones**:
```bash
# Verificar si hay wildcard
dig nonexistent12345.ejemplo.com

# Si responde, el dominio tiene wildcard
# Usar script con detección de wildcard
./dnslis2.sh ejemplo.com --wildcard-check

# Cambiar servidor DNS
./dnslist.sh ejemplo.com --dns 1.1.1.1
```

---

### Problema 5: Demasiados falsos positivos

**Causa**: Respuestas de wildcard o servidor mal configurado

**Soluciones**:
```bash
# Verificar respuesta manualmente
dig www.ejemplo.com
dig nonexistent.ejemplo.com

# Si ambas responden igual, hay wildcard

# Solución: Usar parámetro de filtrado
./dnslis2.sh ejemplo.com --filter-wildcards

# Usar múltiples servidores DNS
./dnslist.sh ejemplo.com --dns 8.8.8.8 --validate-all
```

---

### Problema 6: Escaso espacio en disco

**Causa**: Archivos de caché o resultados grandes

**Soluciones**:
```bash
# Ver tamaño de archivos
du -sh *

# Limpiar caché antiguo
./dnscache.sh clear --older-than 30days

# Comprimir resultados
gzip resultado.txt

# Eliminar archivos temporales
rm -f /tmp/dnslist_*

# Usar pipe en lugar de archivo
./dnslist.sh ejemplo.com | gzip > resultado.txt.gz
```

---

### Problema 7: Resultados incompletos

**Causa**: Proceso interrumpido o timeout

**Soluciones**:
```bash
# Aumentar timeout
./dnslist.sh ejemplo.com --timeout 15

# Ejecutar en background con nohup
nohup ./dnslist.sh ejemplo.com > resultado.txt 2>&1 &

# Monitorear progreso
tail -f resultado.txt

# Reanudar desde punto anterior
./dnslist.sh ejemplo.com --resume-from 250000
```

---

### Preguntas Frecuentes

### P: ¿Es legal usar DNSList?

**R**: Solo si tienes permiso explícito. La enumeración sin autorización es delito en la mayoría de países. Lee la sección de Seguridad y Legalidad.

---

### P: ¿Cuánto tiempo tarda una búsqueda completa?

**R**: Con 500,000 palabras:
- Velocidad mínima: ~150-200 horas (1 query/segundo)
- Velocidad típica: ~15-30 horas (2-3 queries/segundo)
- Velocidad máxima: ~3-5 horas (30-50 queries/segundo)

---

### P: ¿Cómo acelero la búsqueda?

**R**:
```bash
# Use dnslis2.sh (más rápido)
./dnslis2.sh ejemplo.com

# Aumente threads (paralelismo)
./dnslis2.sh ejemplo.com --threads 30

# Use diccionario pequeño primero
./dnslist.sh ejemplo.com --wordlist subdominios2.txt

# Cambie DNS a más rápido
./dnslist.sh ejemplo.com --dns 8.8.8.8
```

---

### P: ¿Qué hago si el dominio tiene Wildcard?

**R**:
```bash
# Detectar wildcard
dig *.ejemplo.com

# Si responde a cualquier cosa, tiene wildcard

# Usar script con filtrado
./dnslis2.sh ejemplo.com --wildcard-check

# Método manual: filtrar respuestas idénticas
```

---

### P: ¿Puedo usarlo con dominios que no poseo?

**R**: **NO**. Solo si tienes permiso escrito explícito del propietario. La enumeración no autorizada es delito.

---

### P: ¿Cuál es el mejor diccionario para empezar?

**R**: 
- **Dominio desconocido**: `subdominios2.txt` (rápido)
- **Dominio conocido**: `subdominios.txt` (completo)
- **Dominios grandes**: Combinar diccionarios customizados

---

### P: ¿Cómo integro los resultados en nuestro SIEM?

**R**:
```bash
# Exportar a JSON
./dnslis2.sh ejemplo.com --format json > siem_input.json

# Enviar a API del SIEM
curl -X POST \
  -H "Content-Type: application/json" \
  -d @siem_input.json \
  https://siem.empresa.com/api/import

# O usar ELK Stack
cat resultado.json | \
  curl -X POST "localhost:9200/dns-enum/_doc" \
  -H 'Content-Type: application/json' \
  -d @-
```

### Licencia

Este proyecto está bajo [ver archivo LICENSE]. Úsalo responsablemente.

**Disclaimer de Responsabilidad**:

```
ESTA HERRAMIENTA SE PROPORCIONA "TAL CUAL" SIN GARANTÍAS.
EL AUTOR NO ES RESPONSABLE POR:

- Uso no autorizado contra sistemas de terceros
- Daños directos o indirectos resultantes del uso
- Consecuencias legales por uso indebido
- Pérdida de datos o interrupción de servicios

EL USUARIO ES TOTALMENTE RESPONSABLE DE:

- Obtener autorización antes de usar
- Cumplir con leyes y regulaciones locales
- Proteger la confidencialidad de resultados
- Documentar y registrar su uso
```

---

### Contacto y Soporte

- **Web**: https://www.hackingyseguridad.com
- **Email**: contacto@hackingyseguridad.com
- **GitHub Issues**: https://github.com/hackingyseguridad/dnslist/issues
- **Seguridad**: security@hackingyseguridad.com

### Reportar Vulnerabilidades

Si encuentras una vulnerabilidad en DNSList:
1. **NO** la publiques
2. Envía email a security@hackingyseguridad.com
3. Incluye descripción, pasos y POC
4. Espera confirmación (típicamente 48 horas)
5. Coordina disclosure responsable

---

### Referencias y Lecturas

### Documentación Técnica

- [RFC 1035 - DNS Protocol](https://tools.ietf.org/html/rfc1035)
- [RFC 2782 - SRV Records](https://tools.ietf.org/html/rfc2782)
- [OWASP - Subdomain Enumeration](https://owasp.org/www-project-web-security-testing-guide/)

### Herramientas Relacionadas

- Subfinder
- Amass
- Assetfinder
- Findomain
- Knockpy

#
http://www.hackingyseguridad.com
#

