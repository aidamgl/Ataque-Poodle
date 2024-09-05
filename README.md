# Ataque Poodle

Este repositorio contiene la implementación de un ataque Poodle, utilizando un servidor web nginx vulnerable y un exploit desarrollado en Python. A continuación se detalla cómo ejecutar el ataque, configurar el entorno y lanzar los comandos necesarios para su correcta implementación.

## Contenidos del Repositorio

- **Imagen de Docker:** Se ha creado una imagen de Docker con un servidor web nginx vulnerable a Poodle. Esta imagen está disponible en Docker Hub para su descarga y uso.
- **Archivo `docker-compose.yml`:** Permite la implementación rápida del servidor vulnerable a través del comando `docker-compose up`.
- **Exploit en Python:** El archivo `poodle-exploit.py` monta un proxy que facilita la redirección y manipulación del tráfico entre el cliente y el servidor.
- **Código de Inyección:** El archivo `poodle.js` contiene el código necesario para realizar la inyección en el servidor web.

## Requisitos

- Docker y Docker Compose instalados en el sistema.
- Python 3.x con las dependencias necesarias para ejecutar el exploit.
- Acceso a Docker Hub para descargar la imagen del servidor vulnerable.

## Instrucciones de Uso

### 1. Descargar e Iniciar la Imagen Docker

Para lanzar el servidor vulnerable, se ha configurado un archivo `docker-compose.yml`. El archivo incluye todos los parámetros necesarios para ejecutar la imagen de Docker. 

```bash
docker-compose up
```
Este comando levanta el servidor vulnerable a Poodle y expone los puertos 80 y 443. El comando que se ejecuta dentro del archivo docker-compose es:
```bash
docker run --rm -it -p 32080:80 -p 32443:443 --security-opt=no-new-privileges --name servidor servidor_nginx_ssl3
```
Nota: La opción --security-opt=no-new-privileges evita que los procesos dentro del contenedor obtengan nuevos privilegios.
### 2. Iniciar el Servidor Web

Una vez que el contenedor esté en ejecución, es necesario iniciar manualmente el servidor nginx dentro del contenedor con el siguiente comando:

```bash
/usr/local/nginx/sbin/./nginx
```
### 3. Ejecutar el Exploit

#### Paso 1: Configurar el Proxy

Para configurar el proxy que interceptará y manipulará el tráfico entre el cliente y el servidor, ejecuta el archivo `poodle-exploit.py` con el siguiente comando:

```bash
python3 poodle-exploit.py --simpleProxy 1 --start-block 52 --stop-block 54 127.0.0.1 4443 127.0.0.1 32443
```
- **--simpleProxy 1**: Indica que el exploit actuará como proxy, redirigiendo el tráfico de vuelta al cliente.
- **--strat-block** y **--stop-block**: Definen los bloques que se quieren descifrar. En este caso, del bloque 52 al 54, para agilizar el ataque
- **--127.0.0.1 4443**: Es la dirección y el puerto del proxy.
- **127.0.0.1 32443**: Es la dirección y el puerto del servidor vulnerable.
#### 2. Configuración Final del Navegador

Para que el proxy funcione adecuadamente y redirija el tráfico de la víctima, es necesario configurar manualmente el navegador de la máquina víctima:

1. Abre la configuración del navegador en la máquina víctima.
2. Configura un proxy manual, especificando la dirección `127.0.0.1` y el puerto `4443`.
3. Esta configuración permitirá que todo el tráfico del navegador pase a través del proxy que has configurado con el exploit.

Con esta configuración en su lugar, el proxy podrá interceptar y manipular el tráfico, permitiendo que el ataque Poodle funcione correctamente.
#### Paso 3: Inyección de Código y Ejecución del Ataque

1. Copia el contenido del archivo `poodle.js` en la consola del navegador de la máquina víctima. Este script es responsable de generar las peticiones necesarias para el ataque.

2. En la terminal del proxy, ejecuta el siguiente comando:

```bash
search
```
Este comando pone al proxy en modo escucha, permitiendo observar el tráfico generado por el script poodle.js que ha sido inyectado en el servidor web.
3. En la consola del servidor web, ejecuta la función findlengthblock():
```bash
findlengthblock()
```
Esta función envía varias solicitudes al servidor web, modificando pequeñas porciones de datos en cada una para identificar la longitud del bloque de cifrado utilizado. El servidor responde con datos que ayudan a deducir el tamaño del bloque de relleno (padding).

4. Después de identificar el tamaño del bloque, en la terminal del proxy, ejecuta el comando:
```bash
active
```
Esto activa el modo de manipulación en el proxy, permitiendo que no solo escuche, sino también altere el tráfico cifrado que pasa a través de él.
5. En la consola del servidor web, ejecuta la función sendAttack():
```bash
sendAttack()
```
La función sendAttack() manipula los bloques cifrados, enviando múltiples solicitudes al servidor y analizando las respuestas. Este proceso busca encontrar la combinación correcta que permita descifrar los bloques de datos seleccionados.
#### Paso 4: Descifrado de Información

El exploit seguirá enviando solicitudes manipuladas hasta que se descifren completamente los bloques de datos indicados. Durante este proceso, el proxy observará y ajustará las solicitudes hasta obtener una respuesta correcta del servidor.

Una vez que el ataque se haya completado con éxito, la información descifrada se mostrará en la terminal del proxy, lo que indica que el exploit ha funcionado correctamente y se ha descifrado el bloque de datos especificado.

## Resultados Esperados
- Al completar el ataque, se mostrará en la terminal del proxy la información descifrada desde el servidor vulnerable.
- El ataque será exitoso si se descifra correctamente la información esperada.
## Referencias

Este trabajo se basa en el código original del repositorio [Beast-PoC](https://github.com/mpgn/poodle-PoC).
