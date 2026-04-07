-- sesion1.sql: Script para la Sesión 1

-- Detener la ejecución si ocurre un error
WHENEVER SQLERROR EXIT SQL.SQLCODE;


--- EL BLOQUE ANONIMO SE ENCUENTRA AL FINAL



-- Cambiar al PDB XEPDB1
ALTER SESSION SET CONTAINER = XEPDB1;

-- Crear un nuevo usuario (esquema) para el curso en el PDB
CREATE USER curso_topicos IDENTIFIED BY curso2025;

-- Otorgar privilegios necesarios al usuario
GRANT CONNECT, RESOURCE, CREATE SESSION TO curso_topicos;
GRANT CREATE TABLE, CREATE TYPE, CREATE PROCEDURE TO curso_topicos;
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

--- Bloque Anonimo 
BEGIN
    FOR TotalPrecio IN (SELECT Total FROM Precio) 
    LOOP
        IF TotalPrecio.Total > 700 THEN
    	    DBMS_OUTPUT.PUT_LINE('Pedido grande: ' || TotalPrecio.Total);
	    ELSE IF TotalPrecio.Total > 400 THEN
    	    DBMS_OUTPUT.PUT_LINE('Pedido mediano: ' || TotalPrecio.Total);
	    ELSE
    	    DBMS_OUTPUT.PUT_LINE('Pedido pequeño: ' || TotalPrecio.Total);
	    END IF;
    END LOOP;
END;
/
 --- SESION 4
--- Manejo de bloques 1
--- -> Error en el precio de un producto

DECLARE
    precio_producto NUMBER
    error_precio_producto EXCEPTION
BEGIN 
    SELECT  precio INTO precio_producto FROM producto;
    
    if precio_producto < 30 THEN
    RAISE error_precio_producto;
    END IF;

    DBMS_OUTPUT.PUT_LINE('Precio válido: ' || precio_producto);
EXCEPTION
    WHEN precio_bajo THEN
    	DBMS_OUTPUT.PUT_LINE('Error: El precio es demasiado bajo (' || v_precio || ').');
END;
/

--- SESION 5
DECLARE
    CURSOR producto_cursor IS SELECT ProductoID, Precio FROM Productos;
    v_id NUMBER;
    v_precio NUMBER;
BEGIN 
    OPEN producto_cursor;
    LOOP
        FETCH producto_cursor into v_id, v_precio;
        EXIT WHEN producto_cursor%notfound;
        DBMS_OUTPUT.PUT_LINE('ID PRODCUTO: ' || v_id || ', PRECIO: ' || v_precio || );
        --- Agregar como ordernarlo de mayor a menor
    END LOOP;

END;
/
--- Sesion 5, requisito 2
DECLARE
    CURSOR c_producto(p_id NUMBER) IS
        SELECT ProductoID, Nombre, Precio
        FROM Productos
        WHERE ProductoID = p_id
        FOR UPDATE OF Precio;
    v_id              Productos.ProductoID%TYPE;
    v_precio_original Productos.Precio%TYPE;
    v_precio_nuevo    Productos.Precio%TYPE;
BEGIN
    OPEN c_producto(v_id);   
    LOOP
        FETCH c_producto INTO v_id, v_precio_original;
        EXIT WHEN c_producto%NOTFOUND;
      
        v_precio_nuevo := v_precio_original * 1.10;
        
        UPDATE Productos
        SET Precio = v_precio_nuevo
        WHERE CURRENT OF c_producto;
        
        DBMS_OUTPUT.PUT_LINE('Actualización de Producto');
        DBMS_OUTPUT.PUT_LINE('ID del Producto:' || v_id);
        DBMS_OUTPUT.PUT_LINE('Precio Original:' || v_precio_original);
        DBMS_OUTPUT.PUT_LINE('Nuevo Precio:' || v_precio_nuevo);
    END LOOP;
    CLOSE c_producto;
END;
/
