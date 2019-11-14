# Paycapp

Aplicación de Pagos

## Inicialización Automática
1. Ejecutar el archivo `install.sh` con la consola de git al iniciar ingresar la dirección ip del servidor
 * Se creara un archivo `run.bat` que contiene el comando
    para ejecutar el servidor
    * Se creará el archivo `lib/env.dart` con la dirección ip del servidor
    , si este archivo no existe, se lanzará un error.

## Inicialización Manual
1. Ejecutar el siguiente código, remplazando su ip del servidor
    ```bash
    echo "const server = '192.168.0.1';" >> lib/env.dart
    ```
2. Iniciar el servidor con el siguiente comando, nuevamente remplace por su ip, el puerto dejar tal cual
    ````bash
    php artisan serve --port=80 --host=192.168.0.1
    `````