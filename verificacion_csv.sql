USE mini_mundo_almacen;

SELECT
    COUNT(*) AS total_productos,
    MIN(id_producto) AS id_menor,
    MAX(id_producto) AS id_mayor
FROM producto;

SELECT COUNT(*) AS productos_con_id_del_csv
FROM producto
WHERE id_producto BETWEEN 1 AND 100;

-- Relaciones de productos: no deben devolver filas
SELECT 'productos sin categoría' AS verificacion, COUNT(*) AS cantidad_invalida
FROM producto AS p
LEFT JOIN categoria AS c ON c.id_categoria = p.id_categoria
WHERE c.id_categoria IS NULL
UNION ALL
SELECT 'productos sin proveedor', COUNT(*)
FROM producto AS p
LEFT JOIN proveedor AS pr ON pr.id_proveedor = p.id_proveedor
WHERE pr.id_proveedor IS NULL
UNION ALL
SELECT 'empleados sin almacén', COUNT(*)
FROM empleado AS e
LEFT JOIN almacen AS a ON a.id_almacen = e.id_almacen
WHERE a.id_almacen IS NULL
UNION ALL
SELECT 'movimientos sin almacén', COUNT(*)
FROM movimiento AS m
LEFT JOIN almacen AS a ON a.id_almacen = m.id_almacen
WHERE a.id_almacen IS NULL
UNION ALL
SELECT 'movimientos con empleado de otro almacén', COUNT(*)
FROM movimiento AS m
LEFT JOIN empleado AS e
  ON e.id_empleado = m.id_empleado
 AND e.id_almacen = m.id_almacen
WHERE e.id_empleado IS NULL
UNION ALL
SELECT 'detalles sin movimiento', COUNT(*)
FROM detalle_movimiento AS d
LEFT JOIN movimiento AS m ON m.id_movimiento = d.id_movimiento
WHERE m.id_movimiento IS NULL
UNION ALL
SELECT 'detalles sin producto', COUNT(*)
FROM detalle_movimiento AS d
LEFT JOIN producto AS p ON p.id_producto = d.id_producto
WHERE p.id_producto IS NULL
UNION ALL
SELECT 'inventario sin almacén', COUNT(*)
FROM inventario AS i
LEFT JOIN almacen AS a ON a.id_almacen = i.id_almacen
WHERE a.id_almacen IS NULL
UNION ALL
SELECT 'inventario sin producto', COUNT(*)
FROM inventario AS i
LEFT JOIN producto AS p ON p.id_producto = i.id_producto
WHERE p.id_producto IS NULL;

SELECT id_producto, nombre, precio_unitario, stock_minimo,
       id_categoria, id_proveedor
FROM producto
ORDER BY id_producto
LIMIT 100;