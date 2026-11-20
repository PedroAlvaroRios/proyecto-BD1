# Guía para contribuidores

## Requisitos

- MySQL 8.0.16 o posterior. El esquema utiliza restricciones `CHECK`.
- Una cuenta de MySQL con permisos para crear la base de datos y sus tablas.
- Para importar `productos.csv`, el cliente y el servidor MySQL deben permitir `LOAD DATA LOCAL INFILE`.
- Visual Studio Code es opcional; también se pueden ejecutar los scripts desde el cliente de MySQL.

## Extensiones de Visual Studio Code

Para conectarse a MySQL desde VS Code, se recomienda instalar:

- **SQLTools**.
- **SQLTools MySQL/MariaDB** (driver de SQLTools).

El proyecto también contiene `mini_mundo_almacen/mini_mundo_almacen.sqlproj`, que utiliza el SDK `Microsoft.Build.Sql`. Si se desea trabajar con ese proyecto de SQL Server, instalar las extensiones de VS Code **SQL Server (mssql)** y **SQL Database Projects**. Este flujo es distinto del esquema principal: los scripts de la raíz usan sintaxis de MySQL, por lo que el `.sqlproj` no debe considerarse una forma validada de compilar esos scripts.

La extensión **PowerShell** es opcional y solo mejora la experiencia al usar PowerShell en VS Code.

## Preparar y ejecutar la base de datos MySQL

1. Clonar el repositorio y abrir su carpeta raíz en VS Code o en una terminal.
2. Abrir `almacen.sql` y cambiar la ruta absoluta de `LOAD DATA LOCAL INFILE` para que apunte al archivo `productos.csv` en la copia local del contribuidor. La ruta que contiene el script corresponde a la computadora donde se preparó y no funcionará automáticamente en otros equipos.
3. Ejecutar `almacen.sql` conectado a MySQL. Por ejemplo, desde PowerShell, en la carpeta raíz:

   ```powershell
   mysql --local-infile=1 -u root -p < almacen.sql
   ```

   Cambiar `root` por el usuario local si corresponde. Si MySQL rechaza `LOCAL INFILE`, comprobar que `local_infile` esté habilitado en el servidor y en el cliente.
4. Conectarse a la base `mini_mundo_almacen` y ejecutar `verificacion_csv.sql` para revisar los datos importados y las relaciones.
5. Ejecutar `consultas.sql` para probar las consultas de ejemplo. **Este archivo también inserta movimientos de prueba y modifica cantidades del inventario**; no ejecutarlo repetidamente sobre datos que se quieran conservar.

`productos.csv` es el archivo importado por el script. `productos.txt` es una copia legible de los datos, no el archivo que carga `almacen.sql`. `Mini Mundo.txt` describe los requisitos del dominio. `prueba.sql` crea una base de datos separada llamada `crud_python` y es independiente del inventario.

## Conexión desde SQLTools

Crear una conexión local con los datos propios del equipo:

- Driver: MySQL/MariaDB.
- Servidor: `localhost` si MySQL está instalado localmente.
- Puerto: `3306`, salvo que la instalación use otro.
- Usuario y contraseña: los configurados localmente.
- Base de datos: `mini_mundo_almacen` después de ejecutar `almacen.sql`.

No compartir contraseñas ni subir una conexión local al repositorio. Los archivos actuales de `.vscode` contienen ajustes propios del equipo (conexión local y una ruta absoluta); no son necesarios para ejecutar la base de datos y deben mantenerse fuera de los commits salvo que se vuelvan portables y se revisen antes.

## Git y GitHub

Al clonar el repositorio, Git configura el remoto `origin` automáticamente. Revisarlo con:

```powershell
git remote -v
```

Si `origin` existe pero apunta a otra URL, cambiarlo con:

```powershell
git remote set-url origin https://github.com/PedroAlvaroRios/proyecto-BD1.git
```

No usar `git remote add origin` si ya existe un remoto con ese nombre. Antes de subir cambios, actualizar la rama de trabajo y resolver cualquier conflicto. No usar `git push --force` para resolver rechazos sin coordinarlo con los demás contribuidores.

