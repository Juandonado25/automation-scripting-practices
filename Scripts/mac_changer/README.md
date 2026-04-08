# MAC Address Changer

Herramienta de línea de comandos en Python para cambiar la dirección MAC de una interfaz de red en sistemas Linux/Unix.

---

## Cambio manual de MAC (sin script)

Para cambiar la MAC de forma manual durante la sesión actual, se utiliza la siguiente secuencia de comandos:

```bash
sudo ifconfig eth0 down
sudo ifconfig eth0 hw ether 00:66:22:77:11:88
sudo ifconfig eth0 up
```

> ⚠️ El cambio es **temporal**: se revierte al reiniciar el sistema o la interfaz.

---

## Requisitos

- Python 3.x
- `ifconfig` instalado (`net-tools`)
- Privilegios `sudo`

Instalar dependencias del sistema si es necesario:

```bash
sudo apt install net-tools
```

---

## Uso del script

```bash
python3 mac_changer.py -i <interfaz> -m <nueva_mac>
```

### Argumentos

| Argumento | Alias | Descripción |
|---|---|---|
| `--interface` | `-i` | Nombre de la interfaz de red (ej: `eth0`, `wlan0`) |
| `--mac` | `-m` | Nueva dirección MAC en formato `XX:XX:XX:XX:XX:XX` |

### Ejemplo

```bash
python3 mac_changer.py -i eth0 -m 00:66:22:77:11:88
```

**Salida esperada:**

```
[+] Changing MAC address of interface 'eth0' to '00:66:22:77:11:88'...
[+] MAC address changed successfully.
```

---

## Estructura del código

### Clase `Macchanger`

#### `validate_interface(interface)`

Verifica que la interfaz de red exista en el sistema ejecutando `ip link show`. Si el comando retorna un código distinto de 0, la interfaz no existe.

```python
result = subprocess.run(["ip", "link", "show", interface], capture_output=True)
return result.returncode == 0
```

#### `validate_mac(mac)`

Valida que la dirección MAC tenga el formato correcto `XX:XX:XX:XX:XX:XX`.

```python
pattern = r"^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$"
```

#### `get_arguments()`

Parsea y valida los argumentos de línea de comandos usando `argparse`. Las validaciones se ejecutan en este orden:

1. Que se haya indicado una interfaz (`-i`).
2. Que la interfaz exista en el sistema (`validate_interface`).
3. Que se haya indicado una MAC (`-m`).
4. Que el formato de la MAC sea válido (`validate_mac`).

#### `change_mac(interface, new_mac)`

Ejecuta los tres comandos de sistema necesarios para cambiar la MAC usando `subprocess.call()`:

```python
subprocess.call(["sudo", "ifconfig", interface, "down"])
subprocess.call(["sudo", "ifconfig", interface, "hw", "ether", new_mac])
subprocess.call(["sudo", "ifconfig", interface, "up"])
```

---

## Módulos utilizados

| Módulo | Uso |
|---|---|
| `subprocess` | Ejecutar comandos del sistema operativo y verificar interfaces |
| `argparse` | Parseo y validación de argumentos de CLI |
| `re` | Validación del formato de la dirección MAC |

---

## Notas de seguridad

- El script requiere `sudo`. Asegurate de ejecutarlo en un entorno de confianza.
- Cambiar la MAC puede ser útil para pruebas de red, privacidad o pentesting ético.
- El cambio **no persiste** tras reiniciar la interfaz o el sistema.
