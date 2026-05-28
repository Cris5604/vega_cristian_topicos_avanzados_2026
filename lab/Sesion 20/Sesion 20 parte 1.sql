

-- Detener la ejecución si ocurre un error
WHENEVER SQLERROR EXIT SQL.SQLCODE;

-- Cambiar al PDB XEPDB1
ALTER SESSION SET CONTAINER = XEPDB1;

-- Crear un nuevo usuario (esquema) para el curso en el PDB
CREATE USER curso_topicos IDENTIFIED BY curso2025;

-- Otorgar privilegios necesarios al usuario
GRANT CONNECT, RESOURCE, CREATE SESSION TO curso_topicos;
GRANT CREATE TABLE, CREATE TYPE, CREATE PROCEDURE TO curso_topicos;
GRANT CREATE ANY TRIGGER TO curso_topicos;
GRANT UNLIMITED TABLESPACE TO curso_topicos;

-- Confirmar creación
SELECT username FROM dba_users WHERE username = 'CURSO_TOPICOS';

-- Cambiar al esquema curso_topicos
ALTER SESSION SET CURRENT_SCHEMA = curso_topicos;

-- Habilitar salida de mensajes para PL/SQL
SET SERVEROUTPUT ON;

-- Crear tabla Clientes
BEGIN
    DBMS_OUTPUT.PUT_LINE('Creando tabla Clientes...');
    EXECUTE IMMEDIATE 'CREATE TABLE Clientes (
        ClienteID NUMBER PRIMARY KEY,
        Nombre VARCHAR2(50),
        Ciudad VARCHAR2(50),
        FechaNacimiento DATE
    )';
    DBMS_OUTPUT.PUT_LINE('Tabla Clientes creada.');
END;
/

-- Crear tabla Pedidos
BEGIN
    DBMS_OUTPUT.PUT_LINE('Creando tabla Pedidos...');
    EXECUTE IMMEDIATE 'CREATE TABLE Pedidos (
        PedidoID NUMBER PRIMARY KEY,
        ClienteID NUMBER,
        Total NUMBER,
        FechaPedido DATE,
        CONSTRAINT fk_pedido_cliente FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID)
    )';
    DBMS_OUTPUT.PUT_LINE('Tabla Pedidos creada.');
END;
/

-- Crear tabla Productos
BEGIN
    DBMS_OUTPUT.PUT_LINE('Creando tabla Productos...');
    EXECUTE IMMEDIATE 'CREATE TABLE Productos (
        ProductoID NUMBER PRIMARY KEY,
        Nombre VARCHAR2(50),
        Precio NUMBER
    )';
    DBMS_OUTPUT.PUT_LINE('Tabla Productos creada.');
END;
/

-- Insertar datos en Clientes
BEGIN
    DBMS_OUTPUT.PUT_LINE('Insertando datos en Clientes...');
    INSERT INTO Clientes VALUES (1, 'Juan Perez', 'Santiago', TO_DATE('1990-05-15', 'YYYY-MM-DD'));
    INSERT INTO Clientes VALUES (2, 'María Gomez', 'Valparaiso', TO_DATE('1985-10-20', 'YYYY-MM-DD'));
    INSERT INTO Clientes VALUES (3, 'Ana Lopez', 'Santiago', TO_DATE('1995-03-10', 'YYYY-MM-DD'));
    DBMS_OUTPUT.PUT_LINE('Datos insertados en Clientes.');
END;
/

-- Insertar datos en Pedidos
BEGIN
    DBMS_OUTPUT.PUT_LINE('Insertando datos en Pedidos...');
    INSERT INTO Pedidos VALUES (101, 1, 600, TO_DATE('2025-03-01', 'YYYY-MM-DD'));
    INSERT INTO Pedidos VALUES (102, 1, 300, TO_DATE('2025-03-02', 'YYYY-MM-DD'));
    INSERT INTO Pedidos VALUES (103, 2, 800, TO_DATE('2025-03-03', 'YYYY-MM-DD'));
    DBMS_OUTPUT.PUT_LINE('Datos insertados en Pedidos.');
END;
/

-- Insertar datos en Productos
BEGIN
    DBMS_OUTPUT.PUT_LINE('Insertando datos en Productos...');
    INSERT INTO Productos VALUES (1, 'Laptop', 1200);
    INSERT INTO Productos VALUES (2, 'Mouse', 25);
    DBMS_OUTPUT.PUT_LINE('Datos insertados en Productos.');
END;
/

-- Confirmar los datos insertados antes de continuar
COMMIT;

-- Confirmar creación e inserción de datos
BEGIN
    DBMS_OUTPUT.PUT_LINE('Tablas creadas y datos insertados correctamente.');
END;
/

-- Verificar datos
SELECT * FROM Clientes;
SELECT * FROM Pedidos;
SELECT * FROM Productos;

-- Crear tabla DetallesPedidos
BEGIN
    DBMS_OUTPUT.PUT_LINE('Creando tabla DetallesPedidos...');
    EXECUTE IMMEDIATE 'CREATE TABLE DetallesPedidos (
        DetalleID NUMBER PRIMARY KEY,
        PedidoID NUMBER,
        ProductoID NUMBER,
        Cantidad NUMBER,
        CONSTRAINT fk_detalle_pedido FOREIGN KEY (PedidoID) REFERENCES Pedidos(PedidoID),
        CONSTRAINT fk_detalle_producto FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID)
    )';
    DBMS_OUTPUT.PUT_LINE('Tabla DetallesPedidos creada.');
END;
/

-- Insertar datos en DetallesPedidos
BEGIN
    DBMS_OUTPUT.PUT_LINE('Insertando datos en DetallesPedidos...');
    INSERT INTO DetallesPedidos VALUES (1, 101, 1, 2); -- Pedido 101: 2 Laptops
    INSERT INTO DetallesPedidos VALUES (2, 101, 2, 5); -- Pedido 101: 5 Mouse
    DBMS_OUTPUT.PUT_LINE('Datos insertados en DetallesPedidos.');
END;
/

-- Verificar datos
SELECT * FROM DetallesPedidos;

-- Commit final
COMMIT;

/*
Crea un procedimiento actualizar_precios_por_categoria que reciba un porcentaje de aumento (parámetro IN) y 
aplique el aumento solo a productos cuyo precio promedio por pedido (calculado con una función) sea mayor a 500. 
Usa un cursor para iterar sobre los productos.
*/

-- Función para calcular el precio promedio por pedido
CREATE OR REPLACE FUNCTION precio_promedio_por_pedido(p_producto_id IN NUMBER) RETURN NUMBER AS
	v_promedio NUMBER;
BEGIN
	SELECT AVG(p.Precio * d.Cantidad) INTO v_promedio FROM DetallesPedidos d JOIN Productos p ON d.ProductoID = p.ProductoID
	WHERE d.ProductoID = p_producto_id;
	RETURN NVL(v_promedio, 0);
END;
/
-- Procedimiento
CREATE OR REPLACE PROCEDURE actualizar_precios_por_categoria(p_porcentaje IN NUMBER) AS
	CURSOR producto_cursor IS
    	SELECT ProductoID, Precio
    	FROM Productos;
BEGIN
	FOR producto IN producto_cursor LOOP
    	IF precio_promedio_por_pedido(producto.ProductoID) > 500 THEN
        	UPDATE Productos
        	SET Precio = producto.Precio * (1 + p_porcentaje / 100)
        	WHERE ProductoID = producto.ProductoID;
        	DBMS_OUTPUT.PUT_LINE('Producto ' || producto.ProductoID || ' actualizado.');
    	END IF;
	END LOOP;
	COMMIT;
EXCEPTION
	WHEN OTHERS THEN
    	DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    	ROLLBACK;
END;
/
-- Prueba
EXEC actualizar_precios_por_categoria(10);
