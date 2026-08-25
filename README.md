# Control Maquina Hiladora (Flutter)

App para controlar la maquina hiladora vía Bluetooth clásico (HC-05 + ESP32).

## Como generar el .apk SIN instalar nada (usando GitHub Actions)

### 1. Crear un repositorio en GitHub
1. Entra a https://github.com y crea una cuenta si no tenes.
2. Toca el boton verde **"New"** (o "Nuevo repositorio").
3. Ponele un nombre, por ejemplo `mh-control-app`.
4. Dejalo en **Public** o **Private**, cualquiera funciona.
5. NO marques "Add a README" (ya tenemos uno). Toca **Create repository**.

### 2. Subir estos archivos
La forma mas facil sin usar la terminal:
1. En la pagina del repositorio recien creado, toca **"uploading an existing file"** (o "Add file" > "Upload files").
2. Arrastra **TODA** la carpeta descomprimida del zip (o todos los archivos y carpetas: `lib/`, `.github/`, `pubspec.yaml`, `README.md`).
   - Importante: la carpeta `.github` es invisible en algunos exploradores de archivos porque empieza con punto. Si tu explorador no la muestra, activa "mostrar archivos ocultos", o subi el zip completo y GitHub lo descomprime al arrastrarlo en la web (recomendado: arrastra el ZIP directo a la pagina de upload, GitHub lo desarma solo si lo soltas ahi... si no funciona, descomprimilo antes en tu compu y arrastra las carpetas).
3. Escribi cualquier mensaje abajo (ej: "primera version") y toca **Commit changes**.

### 3. Ver como se compila solo
1. Arriba en el repositorio, toca la pestaña **Actions**.
2. Vas a ver un proceso llamado "Build APK" corriendo (circulo amarillo girando). Tarda entre 3 y 6 minutos.
3. Cuando el circulo se pone verde con un tilde ✅, tocalo para entrar.

### 4. Descargar el APK
1. Dentro de esa ejecucion ya terminada, bajá hasta la seccion **Artifacts**.
2. Vas a ver **mh-control-apk** — tocalo para descargarlo (baja un .zip que contiene el .apk adentro).
3. Descomprimi ese .zip, vas a encontrar `app-release.apk`.

### 5. Instalar en el celular
1. Pasa el `app-release.apk` a tu celular (por cable, Drive, WhatsApp a vos mismo, etc.).
2. Abrilo desde el celular. Te va a pedir permiso para "instalar apps de origenes desconocidos" — aceptalo solo para esta instalacion.
3. Instala y listo.

## Notas
- Cada vez que modifiques el codigo y vuelvas a subir cambios (commit) al repositorio, se genera un nuevo APK automaticamente en la pestaña Actions.
- Si el compilado falla (circulo rojo ❌), toca la ejecucion fallida y fijate el mensaje de error — normalmente es algun archivo faltante o mal subido.
