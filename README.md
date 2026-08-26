# Mostrador AU

App de escritorio (Windows) para que los asesores de servicio llamen, atienden, saltan y rellaman turnos del sistema de turnos de Autoconsa. Consume la API de KIOSCO.API.

---

## Ejecutar en desarrollo

```bash
flutter pub get
flutter run -d windows
```

---

## Sistema de actualización automática

La app revisa al arrancar y luego **cada 4 horas** si hay una versión más nueva publicada. Si la hay, muestra un diálogo **obligatorio** (no se puede cerrar ni posponer): el asesor debe presionar "Actualizar ahora", la app descarga el instalador, ejecuta `msiexec /passive` y se cierra sola para completar la instalación.

La versión vigente y la ubicación del instalador se leen desde la tabla `SI_CAMP_REPO_REPU` (mismo patrón que la URL base de la API, tipo `431`):

| RR_NOMBRE | RR_NOMB_REAL | Qué es |
|---|---|---|
| `VERSION MOSTRADOR` | `0.1.2` | Versión que todos deben tener instalada |
| `URL MSI MOSTRADOR` | id de objeto en MinIO, o una URL completa | De dónde se descarga el instalador |

**`URL MSI MOSTRADOR` acepta dos formatos:**

- **Id de objeto de MinIO** (ej. `MostradorAU-0.1.2.msi`, sin `http`): la API genera un link firmado nuevo en cada consulta → nunca expira. **Es el formato recomendado.**
- **URL completa** (empieza con `http`): se usa tal cual, sin regenerar nada. Útil para un link firmado manual (ej. de 12h desde la consola de MinIO), pero si algún mostrador consulta después de que venza, la descarga falla hasta que subas un link nuevo.

### Configuración inicial (una sola vez, ya en desarrollo)

```sql
INSERT INTO SI_CAMP_REPO_REPU (RR_TIPO, RR_NOMBRE, RR_NOMB_REAL, RR_NOMB_REAL_S, RR_TOTALIZAR, RR_CABECERA, RR_FECHA)
VALUES (431, 'VERSION MOSTRADOR', '0.1.1', 'VERSION VIGENTE DE LA APP MOSTRADOR', 0, 0, GETDATE());

INSERT INTO SI_CAMP_REPO_REPU (RR_TIPO, RR_NOMBRE, RR_NOMB_REAL, RR_NOMB_REAL_S, RR_TOTALIZAR, RR_CABECERA, RR_FECHA)
VALUES (431, 'URL MSI MOSTRADOR', 'PENDIENTE', 'ID DE OBJETO EN MINIO O URL DEL INSTALADOR VIGENTE', 0, 0, GETDATE());
```

Repetir en `siac_prod` cuando esto se despliegue a producción.

---

## Publicar una nueva versión (paso a paso)

Ejemplo pasando de `0.1.1` a `0.1.2`.

### 1. Subir el número de versión en el código

Dos archivos, deben quedar coherentes entre sí:

- **`pubspec.yaml`**, línea `version:`
  ```yaml
  version: 0.1.2+3
  ```
  (`X.Y.Z` es la versión visible; el `+N` es el build number de Flutter, súbelo también aunque no lo lea el actualizador.)

- **`installer/Package.wxs`**, atributo `Version` del `<Package>` — mismo número que el pubspec, 3 dígitos alcanzan (Windows Installer solo usa Major.Minor.Build para decidir actualizaciones)
  ```xml
  Version="0.1.2"
  ```

### 2. Compilar el release de Windows

```bash
flutter build windows --release
```

Genera los binarios en `build/windows/x64/runner/Release/`, que es lo que el instalador empaqueta (`installer/Files.wxs` apunta ahí).

### 3. Generar el MSI con WiX

Requiere el [WiX Toolset v7](https://wixtoolset.org/) como herramienta de `dotnet` y la extensión de UI. **Solo la primera vez en una máquina/clon nuevo:**

```bash
dotnet tool install --global wix
wix eula accept wix7
wix extension add WixToolset.UI.wixext
```

Luego, para generar el instalador (cada versión, desde la raíz del proyecto):

```bash
wix build installer/Package.wxs installer/Files.wxs installer/Shortcut.wxs -ext WixToolset.UI.wixext -out installer/MostradorAU-0.1.2.msi
```

Verifica que el `MSI` quedó en `installer/MostradorAU-0.1.2.msi`.

> ⚠️ **Nunca cambies `UpgradeCode`** en `Package.wxs` — es lo que le permite a Windows reconocer que un MSI nuevo es una actualización del mismo producto (gracias al `<MajorUpgrade>`) y reemplazar la instalación anterior en vez de crear una segunda entrada en "Aplicaciones instaladas".

### 4. Subir el MSI a MinIO (manual)

Sube `installer/MostradorAU-0.1.2.msi` al bucket que uses para instaladores, con el método que ya manejas (consola web de MinIO, `mc`, etc.). Anota el **nombre/key del objeto** que le pusiste (ej. `MostradorAU-0.1.2.msi`).

### 5. Actualizar la base de datos

```sql
UPDATE SI_CAMP_REPO_REPU SET RR_NOMB_REAL = '0.1.2'
WHERE RR_TIPO = 431 AND RR_NOMBRE = 'VERSION MOSTRADOR';

UPDATE SI_CAMP_REPO_REPU SET RR_NOMB_REAL = 'MostradorAU-0.1.2.msi'
WHERE RR_TIPO = 431 AND RR_NOMBRE = 'URL MSI MOSTRADOR';
```

(Si en vez del id de objeto guardas una URL firmada manual, pon la URL completa en el segundo `UPDATE` — ver la tabla de arriba.)

### 6. Listo

En máximo 4 horas (o antes, si algún asesor reinicia su mostrador) todos reciben el diálogo obligatorio y quedan en `0.1.2` sin que nadie visite las agencias.

---

## Probar el flujo de actualización sin publicar una versión real

Útil para validar que todo funciona antes de un release real:

1. Compila y sube a MinIO el MSI que ya tienes (ej. `MostradorAU-0.1.1.msi`, la versión actual).
2. Marca en base una versión "nueva" apuntando a ese mismo archivo:
   ```sql
   UPDATE SI_CAMP_REPO_REPU SET RR_NOMB_REAL = '9.9.9'
   WHERE RR_TIPO = 431 AND RR_NOMBRE = 'VERSION MOSTRADOR';

   UPDATE SI_CAMP_REPO_REPU SET RR_NOMB_REAL = 'MostradorAU-0.1.1.msi'
   WHERE RR_TIPO = 431 AND RR_NOMBRE = 'URL MSI MOSTRADOR';
   ```
3. Abre el mostrador (o espera hasta 4h si ya estaba abierto) — debe salir el diálogo obligatorio, descargar, instalar y reabrir.
4. Verifica en "Aplicaciones instaladas" de Windows que siga habiendo **una sola entrada** "Mostrador AU" (confirma que el `MajorUpgrade` funcionó, no una instalación duplicada).
5. Vuelve a dejar la base en la versión real para no confundir a nadie:
   ```sql
   UPDATE SI_CAMP_REPO_REPU SET RR_NOMB_REAL = '0.1.1'
   WHERE RR_TIPO = 431 AND RR_NOMBRE = 'VERSION MOSTRADOR';
   ```

---

## Estructura del instalador (`installer/`)

| Archivo | Qué define |
|---|---|
| `Package.wxs` | Metadatos del producto: nombre, fabricante, **versión**, `UpgradeCode` (fijo, no tocar), lógica de actualización mayor (`MajorUpgrade`) |
| `Files.wxs` | Qué archivos empaqueta — todo `build/windows/x64/runner/Release/**` |
| `Shortcut.wxs` | Accesos directos (menú inicio / escritorio) |
| `License.rtf` | Texto mostrado en el asistente de instalación |
