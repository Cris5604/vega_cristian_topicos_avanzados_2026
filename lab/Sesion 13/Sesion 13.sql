
-- 1. Crea un procedimiento actualizar_inventario_pedido que reciba un PedidoID (parámetro IN) y reduzca la cantidad de productos en una 
-- tabla Inventario (crea la tabla si no existe) según los detalles del pedido. Usa savepoints para manejar errores si no hay suficiente inventario.

-- Crear tabla Inventario
CREATE TABLE Inventario (
	ProductoID NUMBER PRIMARY KEY,
	Cantidad NUMBER
);
INSERT INTO Inventario VALUES (1, 10);
INSERT INTO Inventario VALUES (2, 30);

CREATE OR REPLACE PROCEDURE actualizar_inventario_pedido(solicitud_pedido_id IN NUMBER) AS
	CURSOR detalle_cursor IS
    	SELECT ProductoID, Cantidad FROM DetallesPedidos
    	WHERE PedidoID = solicitud_pedido_id;
	v_actual_cantidad NUMBER;

BEGIN
	FOR detalle IN detalle_cursor LOOP
    	SELECT Cantidad INTO v_actual_cantidad FROM Inventario
    	WHERE ProductoID = detalle.ProductoID;
   	 
    	SAVEPOINT antes_reducir;
   	 
    	IF v_actual_cantidad < detalle.Cantidad THEN
        	RAISE_APPLICATION_ERROR(-20001, 'No hay inventario del producto ' || detalle.ProductoID);
    	END IF;
   	 
    	UPDATE Inventario
    	SET Cantidad = Cantidad - detalle.Cantidad
    	WHERE ProductoID = detalle.ProductoID;
   	 
    	DBMS_OUTPUT.PUT_LINE('Inventario actualizado del producto: ' || detalle.ProductoID);
	END LOOP;
	COMMIT; 
EXCEPTION
	WHEN NO_DATA_FOUND THEN
    	DBMS_OUTPUT.PUT_LINE('Error, el producto no esta en el inventario.');
    	ROLLBACK;
	WHEN OTHERS THEN
    	DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    	ROLLBACK TO antes_reducir;
    	COMMIT;
END;
/
EXEC actualizar_inventario_pedido(108);

-- 2.
-- Diseña una tabla de hechos Fact_Pedidos y una dimensión Dim_Ciudad para un Data Warehouse basado en curso_topicos. 
-- Escribe una consulta analítica que muestre el total de ventas por ciudad y año.

-- Dimencion de Cliente
CREATE TABLE Dim_Cliente (
	ClienteID NUMBER PRIMARY KEY,
	Nombre VARCHAR2(50),
	Ciudad VARCHAR2(50)
);
INSERT INTO Dim_Cliente
SELECT ClienteID, Nombre, Ciudad FROM Clientes;

-- Dimencion de Ciudad
CREATE TABLE Dim_Ciudad (
	CiudadID NUMBER PRIMARY KEY,
	Ciudad VARCHAR2(50)
);
INSERT INTO Dim_Ciudad (CiudadID, Ciudad)
SELECT ROWNUM, Ciudad FROM (SELECT DISTINCT Ciudad FROM Clientes);

-- Dimension de tiempo
CREATE TABLE Dim_Tiempo (
	FechaID NUMBER PRIMARY KEY,
	Fecha DATE,
	Año NUMBER,
	Mes NUMBER,
	Día NUMBER
);
INSERT INTO Dim_Tiempo (FechaID, Fecha, Año, Mes, Día)
SELECT ROWNUM, FechaPedido, EXTRACT(YEAR FROM FechaPedido), EXTRACT(MONTH FROM FechaPedido), EXTRACT(DAY FROM FechaPedido)
FROM (SELECT DISTINCT FechaPedido FROM Pedidos);


-- Tabla de hechos
CREATE TABLE Fact_Pedidos (
	PedidoID NUMBER,
	ClienteID NUMBER,
	CiudadID NUMBER,
	FechaID NUMBER,
	Total NUMBER,
	CONSTRAINT fk_pedido_cliente FOREIGN KEY (ClienteID) REFERENCES Dim_Cliente(ClienteID),
	CONSTRAINT fk_pedido_ciudad FOREIGN KEY (CiudadID) REFERENCES Dim_Ciudad(CiudadID),
	CONSTRAINT fk_pedido_tiempo FOREIGN KEY (FechaID) REFERENCES Dim_Tiempo(FechaID)
);
INSERT INTO Fact_Pedidos (PedidoID, ClienteID, CiudadID, FechaID, Total)
SELECT p.PedidoID, p.ClienteID, dc.CiudadID, dt.FechaID, p.Total FROM Pedidos p
JOIN Clientes c ON p.ClienteID = c.ClienteID
JOIN Dim_Ciudad dc ON c.Ciudad = dc.Ciudad
JOIN Dim_Tiempo dt ON p.FechaPedido = dt.Fecha;

-- Consulta analítica
SELECT dc.Ciudad, dt.Año, SUM(fp.Total) AS TotalVentas
FROM Fact_Pedidos fp
JOIN Dim_Ciudad dc ON fp.CiudadID = dc.CiudadID
JOIN Dim_Tiempo dt ON fp.FechaID = dt.FechaID
GROUP BY dc.Ciudad, dt.Año;
