-- +++++++++++ Actividad 1 ++++++++++++++

-- Clase Vehiculo
CREATE OR REPLACE TYPE Vehiculo AS OBJECT (
	marca VARCHAR2(50),
	ano NUMBER,
	MEMBER FUNCTION obtener_antiguedad RETURN NUMBER
) NOT FINAL;
/
-- Funcion de obtener antiguedad de vehiculo
CREATE OR REPLACE TYPE BODY Vehiculo AS
	MEMBER FUNCTION obtener_antiguedad RETURN NUMBER IS
	BEGIN
    	RETURN 2025-ano;
	END;
END;
/

-- SubClase Automovil,. hereda de Vehiculo
CREATE OR REPLACE TYPE Automovil UNDER Vehiculo (
	NumeroPuertas NUMBER,
	MEMBER FUNCTION descripcion RETURN VARCHAR2
);
/
-- Cadena de muestra para Automoviles
CREATE OR REPLACE TYPE BODY Automovil AS
	MEMBER FUNCTION descripcion RETURN VARCHAR2 IS
	BEGIN
    	RETURN 'Automóvil: ' || Marca || ', Año: ' || Año || ', Puertas: ' || NumeroPuertas;
	END;
END;
/
-- Insertar datos
Create TABLE Vehiculos OF Vehiculo
INSERT INTO Vehiculos
VALUES (Automovil('***', TO_DATE('1985-06-20', 'YYYY-MM-DD'), 10));
-- Mostrar datos especificos de los Automoviles
SELECT * from Vehiculo v 
WHERE VALUE(v) is OF (Automovil)

-- +++++++++++ Actividad 2 ++++++++++++++

-- SubClase Camion
CREATE OR REPLACE TYPE Camion UNDER Vehiculo (
	capacidadCarga NUMBER,
	OVERRIDING MEMBER FUNCTION obtener_antiguedad RETURN NUMBER
);
/
-- Funcion de sobre escrita de calcular antiguedad
CREATE OR REPLACE TYPE BODY Gerente AS
	OVERRIDING MEMBER FUNCTION obtener_antiguedad RETURN NUMBER IS
	BEGIN
    	RETURN (2025-ano)+2;
	END;
END;
/
INSERT INTO Vehiculos VALUES (Camion('Volvo', 2018, 10));
SELECT v.Marca, v.obtener_antiguedad() AS Antiguedad
FROM Vehiculos v
WHERE VALUE(v) IS OF (Camion);
