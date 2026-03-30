# nmapsk.sh

Script de Bash para Kali Linux que automatiza escaneos con Nmap. Admite dos modos de operación pasados por parámetro y guarda los resultados en un archivo de texto con nombre basado en la fecha y hora de ejecución.

---

## Uso

```bash
sudo ./nmapsk.sh <modo> <ip/host>
```

|Parámetro|Descripción|
|---|---|
|`-l`|Modo ruidoso (Loud): rápido y agresivo|
|`-q`|Modo silencioso (Quiet): furtivo y exhaustivo|
|`<ip/host>`|Dirección IP, hostname o rango CIDR objetivo|

### Ejemplos

```bash
sudo ./nmapsk.sh -l 192.168.1.1
sudo ./nmapsk.sh -q 10.0.0.0/24
```

---

## Modos de escaneo

### Modo Loud `-l`

Orientado a velocidad y cobertura máxima. Recomendado para entornos controlados como CTFs o laboratorios donde la detección no es una preocupación.

Opciones de Nmap utilizadas:

|Opción|Descripción|
|---|---|
|`-sS`|SYN scan (half-open)|
|`-sV`|Detección de versiones de servicios|
|`-sC`|Scripts por defecto de Nmap|
|`-O`|Detección de sistema operativo|
|`-A`|Detección agresiva (OS, versiones, scripts, traceroute)|
|`-p-`|Escaneo de los 65535 puertos|
|`-T5`|Velocidad máxima (insane)|
|`--version-intensity 9`|Detección de versiones al máximo nivel|
|`--script=default,vuln,auth,discovery,exploit`|Conjunto amplio de scripts NSE|
|`--open`|Muestra solo puertos abiertos|

### Modo Quiet `-q`

Orientado a la evasión de sistemas de detección (IDS/IPS). Más lento, pero con menor huella en la red. Recomendado para auditorías donde se requiere discreción.

Opciones adicionales respecto al modo Loud:

|Opción|Descripción|
|---|---|
|`-T1`|Velocidad mínima (sneaky)|
|`-D RND:10`|Genera 10 direcciones IP señuelo aleatorias|
|`--data-length 25`|Agrega padding a los paquetes para imitar tráfico legítimo|
|`--randomize-hosts`|Aleatoriza el orden de escaneo de hosts|
|`--spoof-mac 0`|Genera una dirección MAC aleatoria|
|`--ttl 64`|Establece un TTL estándar para evitar fingerprinting|
|`--scan-delay 2s`|Pausa entre sondas para no activar alertas|
|`--max-retries 3`|Límite de reintentos por puerto|
|`-f`|Fragmentación de paquetes para evadir firewalls|

---

## Archivos de salida

Cada ejecución genera un archivo `.txt` único con el modo, fecha y hora:

```
nmap_loud_scan_20260328_143507.txt
nmap_quiet_scan_20260328_150012.txt
```

El archivo incluye un encabezado con el objetivo, la fecha y el comando ejecutado, seguido de la salida completa de Nmap.

---

## Requisitos

- Kali Linux (o cualquier distribución con Nmap instalado)
- Nmap: `sudo apt install nmap`
- Privilegios root para escaneos SYN, detección de OS y spoofing de MAC

---

## Notas

- El script advierte si se ejecuta sin `sudo`, ya que varias opciones requieren permisos de administrador.
- Usar este script contra sistemas sin autorización expresa es ilegal. Debe utilizarse únicamente en entornos propios o con permiso documentado.