-- Consultas Simple SQL:
SELECT * FROM CURSO_TOPICOS.CLIENTES WHERE CIUDAD = 'Valparaiso';
SELECT * FROM CURSO_TOPICOS.PEDIDOS WHERE total > 300 ORDER BY FechaPedido DESC;

-- Consultas Funciones Agregadas:
SELECT c.Nombre, COUNT(p.ClienteID) FROM CURSO_TOPICOS.CLIENTES c LEFT JOIN CURSO_TOPICOS.PEDIDOS p on c.ClienteID = p.ClienteID group by c.Nombre HAVING COUNT(p.ClienteID)>0;
SELECT c.Nombre, SUM(p.Total) as SumaTotal FROM CURSO_TOPICOS.CLIENTES c LEFT JOIN CURSO_TOPICOS.PEDIDOS p on c.ClienteID = p.ClienteID GROUP BY C.Nombre HAVING SUM(p.Total) > 0 ORDER BY SumaTotal DESC;

-- Consultas con expresiones regulares:
SELECT ClienteID, Nombre, Ciudad FROM CURSO_TOPICOS.CLIENTES WHERE REGEXP_LIKE(Nombre, '^[J]');
SELECT ProductoID, Nombre, Precio FROM CURSO_TOPICOS.Productos WHERE REGEXP_LIKE(Nombre, '^[L]');

-- Consultas con vistas:
CREATE VIEW CURSO_TOPICOS.Vista_PedidosPorCliente AS SELECT c.Nombre AS NombreCliente, po.Nombre AS NombreProducto, p.PedidoID, dp.Cantidad FROM CURSO_TOPICOS.DetallesPedidos dp LEFT JOIN CURSO_TOPICOS.PEDIDOS p ON dp.PedidoID = p.PedidoID LEFT JOIN CURSO_TOPICOS.PRODUCTOS po ON po.ProductoID = dp.ProductoID LEFT JOIN CURSO_TOPICOS.CLIENTES c ON p.ClienteID = c.ClienteID GROUP BY c.Nombre, po.Nombre, p.PedidoID, dp.Cantidad;
SELECT * FROM CURSO_TOPICOS.Vista_PedidosPorCliente;

CREATE VIEW CURSO_TOPICOS.Vista_ProductosVendidos AS SELECT po.ProductoID, po.Nombre, po.precio, dp.Cantidad FROM CURSO_TOPICOS.PEDIDOS p LEFT JOIN CURSO_TOPICOS.DetallesPedidos dp ON dp.PedidoID = p.PedidoID LEFT JOIN CURSO_TOPICOS.PRODUCTOS po ON po.ProductoID = dp.ProductoID LEFT JOIN CURSO_TOPICOS.CLIENTES c ON p.ClienteID = c.ClienteID GROUP BY po.ProductoID, po.Nombre, po.precio, dp.Cantidad;
SELECT * FROM CURSO_TOPICOS.Vista_ProductosVendidos;


