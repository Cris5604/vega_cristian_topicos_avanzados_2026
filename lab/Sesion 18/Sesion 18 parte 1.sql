

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
Crea un paquete gestion_clientes con:
Un procedimiento registrar_cliente que reciba ClienteID, Nombre, Ciudad y FechaNacimiento, y valide que la fecha de nacimiento sea anterior a la fecha actual.
Una función obtener_edad que reciba un ClienteID y devuelva la edad del cliente.
Usa una variable global para contar los clientes registrados. */

-- Especificación
CREATE OR REPLACE PACKAGE gestion_clientes AS
	g_contador_clientes NUMBER := 0;
	PROCEDURE registrar_cliente(
    	p_cliente_id IN NUMBER,
    	p_nombre IN VARCHAR2,
    	p_ciudad IN VARCHAR2,
    	p_fecha_nacimiento IN DATE
	);
	FUNCTION obtener_edad(
    	p_cliente_id IN NUMBER
	) RETURN NUMBER;
END gestion_clientes;
/

-- Cuerpo
CREATE OR REPLACE PACKAGE BODY gestion_clientes AS
	PROCEDURE registrar_cliente(
    	p_cliente_id IN NUMBER,
    	p_nombre IN VARCHAR2,
    	p_ciudad IN VARCHAR2,
    	p_fecha_nacimiento IN DATE
	) IS
	BEGIN
    	IF p_fecha_nacimiento >= SYSDATE THEN
        	RAISE_APPLICATION_ERROR(-20001, 'La fecha de nacimiento debe ser anterior a la fecha actual.');
    	END IF;
   	 
    	INSERT INTO Clientes (ClienteID, Nombre, Ciudad, FechaNacimiento)
    	VALUES (p_cliente_id, p_nombre, p_ciudad, p_fecha_nacimiento);
	 
    	g_contador_clientes := g_contador_clientes + 1;
    	DBMS_OUTPUT.PUT_LINE('Cliente registrado. Total clientes: ' || g_contador_clientes);
	EXCEPTION
    	WHEN OTHERS THEN
        	DBMS_OUTPUT.PUT_LINE('Error al registrar cliente: ' || SQLERRM);
        	RAISE;
	END registrar_cliente;
    
	FUNCTION obtener_edad(
    	p_cliente_id IN NUMBER
	) RETURN NUMBER IS
    	v_fecha_nacimiento DATE;
    	v_edad NUMBER;
	BEGIN
    	SELECT FechaNacimiento INTO v_fecha_nacimiento
    	FROM Clientes
    	WHERE ClienteID = p_cliente_id;
   	 
    	v_edad := FLOOR(MONTHS_BETWEEN(SYSDATE, v_fecha_nacimiento) / 12);
    	RETURN v_edad;
	EXCEPTION
    	WHEN NO_DATA_FOUND THEN
        	RAISE_APPLICATION_ERROR(-20002, 'Cliente no encontrado.');
    	WHEN OTHERS THEN
        	DBMS_OUTPUT.PUT_LINE('Error al calcular edad: ' || SQLERRM);
        	RAISE;
	END obtener_edad;
END gestion_clientes;
/

-- Prueba
EXEC gestion_clientes.registrar_cliente(4, 'Carlos Díaz', 'Santiago', TO_DATE('1980-01-01', 'YYYY-MM-DD'));
DECLARE
	v_edad NUMBER;
BEGIN
	v_edad := gestion_clientes.obtener_edad(4);
	DBMS_OUTPUT.PUT_LINE('Edad del cliente 4: ' || v_edad);
END;
/
