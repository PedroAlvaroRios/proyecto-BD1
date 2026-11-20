-- Preparar y verificar el inventario
USE mini_mundo_almacen;

-- Preparar el inventario
INSERT IGNORE INTO inventario (id_almacen, id_producto, cantidad)
SELECT alma.id_almacen, prod.id_producto, 0
FROM almacen AS alma
CROSS JOIN producto AS prod;

-- Verificar
SELECT COUNT(*) AS total_productos
FROM producto;

SELECT COUNT(*) AS filas_de_inventario
FROM inventario;
-- Consultar el catálogo de productos
SELECT
    prod.id_producto,
    prod.nombre AS nombre_producto,
    cate.nombre AS nombre_categoria,
    prov.nombre AS nombre_proveedor,
    prov.telefono AS telefono_proveedor,
    prod.precio_unitario,
    prod.stock_minimo
FROM producto AS prod
INNER JOIN categoria AS cate
    ON cate.id_categoria = prod.id_categoria
INNER JOIN proveedor AS prov
    ON prov.id_proveedor = prod.id_proveedor
ORDER BY cate.nombre, prod.nombre;

-- Ver qué empleados trabajan en cada almacén

SELECT
    alma.nombre AS nombre_almacen,
    empl.id_empleado,
    CONCAT(empl.nombre, ' ', empl.apellido) AS nombre_empleado,
    empl.cargo,
    empl.telefono
FROM almacen AS alma
LEFT JOIN empleado AS empl
    ON empl.id_almacen = alma.id_almacen
ORDER BY alma.id_almacen, empl.id_empleado;

-- Revisar las existencias de un almacén

SELECT
    alma.nombre AS nombre_almacen,
    prod.id_producto,
    prod.nombre AS nombre_producto,
    inve.cantidad AS unidades_disponibles,
    prod.stock_minimo
FROM inventario AS inve
INNER JOIN almacen AS alma
    ON alma.id_almacen = inve.id_almacen
INNER JOIN producto AS prod
    ON prod.id_producto = inve.id_producto
WHERE alma.id_almacen = 1
ORDER BY prod.nombre;

-- Detectar productos que hay que reponer

SELECT
    prod.id_producto,
    prod.nombre AS nombre_producto,
    prod.stock_minimo,
    COALESCE(SUM(inve.cantidad), 0) AS existencias_totales,
    GREATEST(
        prod.stock_minimo - COALESCE(SUM(inve.cantidad), 0),
        0
    ) AS unidades_para_llegar_al_minimo
FROM producto AS prod
LEFT JOIN inventario AS inve
    ON inve.id_producto = prod.id_producto
GROUP BY
    prod.id_producto,
    prod.nombre,
    prod.stock_minimo
HAVING COALESCE(SUM(inve.cantidad), 0) <= prod.stock_minimo
ORDER BY prod.nombre;

-- Consultar los movimientos y sus productos

SELECT
    movi.id_movimiento,
    movi.fecha,
    movi.tipo,
    alma.nombre AS nombre_almacen,
    CONCAT(empl.nombre, ' ', empl.apellido) AS empleado_responsable,
    prod.id_producto,
    prod.nombre AS nombre_producto,
    deta.cantidad
FROM movimiento AS movi
INNER JOIN almacen AS alma
    ON alma.id_almacen = movi.id_almacen
INNER JOIN empleado AS empl
    ON empl.id_empleado = movi.id_empleado
   AND empl.id_almacen = movi.id_almacen
INNER JOIN detalle_movimiento AS deta
    ON deta.id_movimiento = movi.id_movimiento
INNER JOIN producto AS prod
    ON prod.id_producto = deta.id_producto
ORDER BY movi.fecha DESC, movi.id_movimiento DESC;

-- Resumir los movimientos por mes

SELECT
    DATE_FORMAT(movi.fecha, '%Y-%m') AS periodo,
    SUM(CASE WHEN movi.tipo = 'ENTRADA' THEN 1 ELSE 0 END) AS cantidad_entradas,
    SUM(CASE WHEN movi.tipo = 'SALIDA' THEN 1 ELSE 0 END) AS cantidad_salidas,
    COUNT(*) AS total_movimientos
FROM movimiento AS movi
GROUP BY DATE_FORMAT(movi.fecha, '%Y-%m')
ORDER BY periodo;

-- Registrar una entrada de productos

START TRANSACTION;

INSERT INTO movimiento
    (tipo, fecha, observacion, id_almacen, id_empleado)
VALUES
    ('ENTRADA', CURDATE(), 'Compra de prueba', 1, 1);

SET @id_movimiento = LAST_INSERT_ID();

INSERT INTO detalle_movimiento
    (id_movimiento, id_producto, cantidad)
VALUES
    (@id_movimiento, 1, 50),
    (@id_movimiento, 2, 30);

UPDATE inventario
SET cantidad = cantidad + CASE id_producto
    WHEN 1 THEN 50
    WHEN 2 THEN 30
END
WHERE id_almacen = 1
  AND id_producto IN (1, 2);

COMMIT;

-- Registrar una salida comprobando existencias

START TRANSACTION;

SELECT
    prod.id_producto,
    prod.nombre AS producto,
    inve.cantidad AS unidades_disponibles
FROM inventario AS inve
INNER JOIN producto AS prod
    ON prod.id_producto = inve.id_producto
WHERE inve.id_almacen = 1
  AND inve.id_producto IN (1, 2)
FOR UPDATE;



-- revision y verificacion de transaccion

INSERT INTO movimiento
    (tipo, fecha, observacion, id_almacen, id_empleado)
VALUES
    ('SALIDA', CURDATE(), 'Despacho de prueba', 1, 2);

SET @id_salida = LAST_INSERT_ID();

INSERT INTO detalle_movimiento
    (id_movimiento, id_producto, cantidad)
VALUES
    (@id_salida, 1, 5),
    (@id_salida, 2, 3);

UPDATE inventario
SET cantidad = cantidad - 5
WHERE id_almacen = 1
  AND id_producto = 1;

UPDATE inventario
SET cantidad = cantidad - 3
WHERE id_almacen = 1
  AND id_producto = 2;

COMMIT;

-- si no funciona ejecutar
-- ROLLBACK;
