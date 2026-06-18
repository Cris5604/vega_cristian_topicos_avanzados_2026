/*
1. Define qué es una transacción en una base de datos y explica cómo las propiedades 
ACID garantizan su integridad. Proporciona un ejemplo de un procedimiento que registre 
un pedido en la tabla Pedidos, usando savepoints para revertir la operación si el cliente no existe.
*/
CREATE OR REPLACE PROCEDURE registrar_pedido (
    p_cliente_id IN NUMBER,
    p_total IN NUMBER,
    p_fecha_pedido IN DATE
) AS
    v_cliente_existe NUMBER;
BEGIN
    SAVEPOINT inicio_pedido;
    -- Validar que el cliente existe
    SELECT COUNT(*) INTO v_cliente_existe
    FROM Clientes
    WHERE ClienteID = p_cliente_id;
    IF v_cliente_existe = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Cliente no existe.');
    END IF;
    -- Insertar pedido
    INSERT INTO Pedidos (PedidoID, ClienteID, Total, FechaPedido)
    VALUES ((SELECT NVL(MAX(PedidoID), 0) + 1 FROM Pedidos), p_cliente_id, p_total, p_fecha_pedido);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO inicio_pedido;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM || '. Operación revertida.');
        ROLLBACK;
END;
/

/*
¿Qué es un Data Warehouse y cómo se diferencia de una base de datos operativa en términos de propósito 
y estructura? Diseña una tabla de hechos Fact_Inventario para analizar el movimiento de productos (entradas y salidas) 
en la base de datos, incluyendo claves foráneas y medidas adecuadas.*/

Un Data Warehouse (DWH) o almacén de datos es un sistema diseñado específicamente para el almacenamiento, integración y 
análisis de grandes volúmenes de datos provenientes de diversas fuentes. A diferencia de las bases de datos tradicionales, 
el DWH está optimizado para la toma de decisiones y la generación de inteligencia de negocios (Business Intelligence), 
permitiendo realizar consultas históricas complejas sin afectar el rendimiento de los sistemas transaccionales.

CREATE TABLE Fact_Inventario (
    FactID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ProductoID NUMBER,
    FechaID NUMBER,
    CantidadMovimiento NUMBER,
    TipoMovimiento VARCHAR2(10),
    CONSTRAINT fk_fact_inventario_producto FOREIGN KEY (ProductoID) REFERENCES Dim_Producto(ProductoID),
    CONSTRAINT fk_fact_inventario_tiempo FOREIGN KEY (FechaID) REFERENCES Dim_Tiempo(FechaID)
);


/*
Explica cómo se implementa la herencia en Oracle utilizando tipos de objetos y la cláusula UNDER. 
Diseña una jerarquía de tipos para modelar clientes (Cliente → ClientePremium) y crea un índice en la 
tabla Clientes para optimizar consultas por Ciudad. Justifica tu elección.
*/

En Oracle, la herencia se implementa mediante el uso de Tipos de Objetos (Object Types) definidos por el usuario, 
aprovechando la orientación a objetos dentro del modelo relacional. La cláusula UNDER permite que un tipo de objeto 
hijo herede los atributos y métodos de un tipo de objeto padre.

La elección de utilizar tipos de objetos y la cláusula UNDER para implementar la herencia en Oracle se 
justifica bajo tres pilares fundamentales del desarrollo de software moderno:
-Polimorfismo en Almacenamiento
-Abstracción y Reutilización de Código
-Mantenibilidad de Modelos de Datos Complejo

CREATE TYPE Tipo_Cliente AS OBJECT (
    ClienteID NUMBER,
    Nombre VARCHAR2(50),
    Ciudad VARCHAR2(50),
    MEMBER FUNCTION getDescuento RETURN NUMBER
) NOT FINAL;
/
CREATE TYPE BODY Tipo_Cliente AS
    MEMBER FUNCTION getDescuento RETURN NUMBER IS
    BEGIN RETURN 0; END;
END;
/
CREATE TYPE Tipo_ClientePremium UNDER Tipo_Cliente (
    DescuentoAdicional NUMBER,
    OVERRIDING MEMBER FUNCTION getDescuento RETURN NUMBER
);
/
CREATE TYPE BODY Tipo_ClientePremium AS
    OVERRIDING MEMBER FUNCTION getDescuento RETURN NUMBER IS
    BEGIN RETURN DescuentoAdicional; END;
END;
/
CREATE TABLE Clientes OF Tipo_Cliente;

CREATE INDEX idx_clientes_ciudad ON Clientes (Ciudad);

ALTER TABLE Pedidos ADD PARTITION BY RANGE (FechaPedido) (
    PARTITION p_q1_2025 VALUES LESS THAN (TO_DATE('2025-04-01', 'YYYY-MM-DD')),
    PARTITION p_q2_2025 VALUES LESS THAN (TO_DATE('2025-07-01', 'YYYY-MM-DD')),
    PARTITION p_q3_2025 VALUES LESS THAN (TO_DATE('2025-10-01', 'YYYY-MM-DD')),
    PARTITION p_q4_2025 VALUES LESS THAN (MAXVALUE)
);

CREATE INDEX idx_pedidos_cliente_total ON Pedidos (ClienteID, Total);

/*Crea un índice compuesto en DetallesPedidos para PedidoID y ProductoID. Particiona 
Pedidos por rango de FechaPedido (mensual para 2025). Escribe una consulta que sume 
Total por ClienteID en enero de 2025. */

-- Índice compuesto
CREATE INDEX idx_detalles_pedido_prod ON DetallesPedidos (PedidoID, ProductoID);
-- Partición por rango mensual
ALTER TABLE Pedidos ADD PARTITION BY RANGE (FechaPedido) (
    PARTITION p_jan_2025 VALUES LESS THAN (TO_DATE('2025-02-01', 'YYYY-MM-DD')),
    PARTITION p_feb_2025 VALUES LESS THAN (TO_DATE('2025-03-01', 'YYYY-MM-DD')),
    PARTITION p_mar_2025 VALUES LESS THAN (TO_DATE('2025-04-01', 'YYYY-MM-DD')),
    PARTITION p_max VALUES LESS THAN (MAXVALUE)
);
-- Consulta
SELECT 
    ClienteID,
    SUM(Total) AS Total_Mensual
FROM Pedidos
WHERE FechaPedido BETWEEN TO_DATE('2025-01-01', 'YYYY-MM-DD') AND TO_DATE('2025-01-31', 'YYYY-MM-DD')
GROUP BY ClienteID;

