CREATE DATABASE IF NOT EXISTS mini_mundo_almacen
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE mini_mundo_almacen;

-- 1. ALMACENES
CREATE TABLE IF NOT EXISTS almacen (
    id_almacen INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(200) NOT NULL,
    capacidad_m2 DECIMAL(10,2) NOT NULL,

    PRIMARY KEY (id_almacen),
    CONSTRAINT chk_almacen_capacidad CHECK (capacidad_m2 > 0)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;


-- 2. EMPLEADOS
CREATE TABLE IF NOT EXISTS empleado (
    id_empleado INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(80) NOT NULL,
    apellido VARCHAR(80) NOT NULL,
    cargo VARCHAR(60) NOT NULL,
    telefono VARCHAR(25) NOT NULL,
    id_almacen INT UNSIGNED NOT NULL,

    PRIMARY KEY (id_empleado),

    -- Esta clave permite verificar que el empleado y el movimiento
    -- pertenezcan al mismo almacén.
    UNIQUE KEY uq_empleado_almacen (id_empleado, id_almacen),

    CONSTRAINT fk_empleado_almacen
        FOREIGN KEY (id_almacen)
        REFERENCES almacen (id_almacen)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;


-- 3. CATEGORÍAS
CREATE TABLE IF NOT EXISTS categoria (
    id_categoria INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(60) NOT NULL,
    descripcion VARCHAR(255),

    PRIMARY KEY (id_categoria),
    UNIQUE KEY uq_categoria_nombre (nombre)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;


-- 4. PROVEEDORES
CREATE TABLE IF NOT EXISTS proveedor (
    id_proveedor INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    nit VARCHAR(20) NOT NULL,
    telefono VARCHAR(25) NOT NULL,
    direccion VARCHAR(200) NOT NULL,

    PRIMARY KEY (id_proveedor),
    UNIQUE KEY uq_proveedor_nit (nit)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;


-- 5. PRODUCTOS
CREATE TABLE IF NOT EXISTS producto (
    id_producto INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(120) NOT NULL,
    precio_unitario DECIMAL(12,2) NOT NULL,
    stock_minimo INT UNSIGNED NOT NULL DEFAULT 0,
    id_categoria INT UNSIGNED NOT NULL,
    id_proveedor INT UNSIGNED NOT NULL,

    PRIMARY KEY (id_producto),
    KEY idx_producto_categoria (id_categoria),
    KEY idx_producto_proveedor (id_proveedor),

    CONSTRAINT chk_producto_precio CHECK (precio_unitario >= 0),

    CONSTRAINT fk_producto_categoria
        FOREIGN KEY (id_categoria)
        REFERENCES categoria (id_categoria)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_producto_proveedor
        FOREIGN KEY (id_proveedor)
        REFERENCES proveedor (id_proveedor)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;


-- 6. MOVIMIENTOS DE ENTRADA Y SALIDA
CREATE TABLE IF NOT EXISTS movimiento (
    id_movimiento INT UNSIGNED NOT NULL AUTO_INCREMENT,
    tipo VARCHAR(10) NOT NULL,
    fecha DATE NOT NULL,
    observacion VARCHAR(255),
    id_almacen INT UNSIGNED NOT NULL,
    id_empleado INT UNSIGNED NOT NULL,

    PRIMARY KEY (id_movimiento),
    KEY idx_movimiento_almacen_fecha (id_almacen, fecha),
    KEY idx_movimiento_empleado_almacen (id_empleado, id_almacen),

    CONSTRAINT chk_movimiento_tipo
        CHECK (tipo IN ('ENTRADA', 'SALIDA')),

    CONSTRAINT fk_movimiento_almacen
        FOREIGN KEY (id_almacen)
        REFERENCES almacen (id_almacen)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    -- Además de comprobar que existe el empleado, esta relación
    -- comprueba que trabaja en el almacén del movimiento.
    CONSTRAINT fk_movimiento_empleado_almacen
        FOREIGN KEY (id_empleado, id_almacen)
        REFERENCES empleado (id_empleado, id_almacen)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;


-- 7. DETALLE DE CADA MOVIMIENTO
CREATE TABLE IF NOT EXISTS detalle_movimiento (
    id_movimiento INT UNSIGNED NOT NULL,
    id_producto INT UNSIGNED NOT NULL,
    cantidad INT UNSIGNED NOT NULL,

    PRIMARY KEY (id_movimiento, id_producto),
    KEY idx_detalle_producto (id_producto),

    CONSTRAINT chk_detalle_cantidad CHECK (cantidad > 0),

    CONSTRAINT fk_detalle_movimiento
        FOREIGN KEY (id_movimiento)
        REFERENCES movimiento (id_movimiento)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_detalle_producto
        FOREIGN KEY (id_producto)
        REFERENCES producto (id_producto)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;


-- 8. INVENTARIO ACTUAL POR ALMACÉN Y PRODUCTO
CREATE TABLE IF NOT EXISTS inventario (
    id_almacen INT UNSIGNED NOT NULL,
    id_producto INT UNSIGNED NOT NULL,
    cantidad INT UNSIGNED NOT NULL DEFAULT 0,

    PRIMARY KEY (id_almacen, id_producto),
    KEY idx_inventario_producto (id_producto),

    CONSTRAINT fk_inventario_almacen
        FOREIGN KEY (id_almacen)
        REFERENCES almacen (id_almacen)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_inventario_producto
        FOREIGN KEY (id_producto)
        REFERENCES producto (id_producto)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;


-- DATOS DE REFERENCIA PARA PODER IMPORTAR LOS PRODUCTOS

INSERT IGNORE INTO almacen
    (id_almacen, nombre, direccion, capacidad_m2)
VALUES
    (1, 'Almacén Central', 'Avenida Principal 123', 1200.00),
    (2, 'Almacén Norte', 'Calle Norte 45', 750.00),
    (3, 'Almacén Sur', 'Carretera Sur km 8', 900.00);


INSERT IGNORE INTO empleado
    (id_empleado, nombre, apellido, cargo, telefono, id_almacen)
VALUES
    (1, 'Ana', 'Pérez', 'Administradora', '555-0101', 1),
    (2, 'Luis', 'García', 'Almacenista', '555-0102', 1),
    (3, 'María', 'López', 'Supervisora', '555-0103', 2),
    (4, 'Carlos', 'Rojas', 'Almacenista', '555-0104', 2),
    (5, 'Elena', 'Mendoza', 'Encargada', '555-0105', 3),
    (6, 'Jorge', 'Díaz', 'Almacenista', '555-0106', 3);


INSERT IGNORE INTO categoria
    (id_categoria, nombre, descripcion)
VALUES
    (1, 'Bebidas', 'Aguas, jugos y otras bebidas'),
    (2, 'Limpieza', 'Productos para limpieza e higiene'),
    (3, 'Abarrotes', 'Alimentos y productos de despensa');


INSERT IGNORE INTO proveedor
    (id_proveedor, nombre, nit, telefono, direccion)
VALUES
    (1, 'Distribuidora Andina', 'NIT-100001', '555-1001', 'Avenida Industrial 100'),
    (2, 'Bebidas del Valle', 'NIT-100002', '555-1002', 'Calle de las Bebidas 200'),
    (3, 'Limpieza Total', 'NIT-100003', '555-1003', 'Parque Industrial 300'),
    (4, 'Abarrotes Central', 'NIT-100004', '555-1004', 'Avenida del Mercado 400'),
    (5, 'Proveedora Universal', 'NIT-100005', '555-1005', 'Calle Comercio 500');

-- Importar los datos maestros después de crear las tablas y sus datos relacionados
LOAD DATA LOCAL INFILE 'C:/Users/Administrator/Desktop/docs uni/semestre 2/Base de Datos I/notas/practicas/proyecto-BD1/productos.csv'
INTO TABLE producto
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(id_producto, nombre, precio_unitario, stock_minimo, id_categoria, id_proveedor);