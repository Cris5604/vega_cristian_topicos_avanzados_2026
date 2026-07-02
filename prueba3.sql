-- Script para crear y poblar la base de datos para la Prueba 3
-- Ejecutar en Oracle SQL Developer en el esquema del estudiante

SET SERVEROUTPUT ON;

-- Eliminar tablas si ya existen
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Asignaciones CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Incidentes CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Agentes CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- Crear tabla Agentes
CREATE TABLE Agentes (
    AgenteID     NUMBER PRIMARY KEY,
    Nombre       VARCHAR2(50),
    Especialidad VARCHAR2(50),
    FechaIngreso DATE
);

-- Crear tabla Incidentes
CREATE TABLE Incidentes (
    IncidenteID    NUMBER PRIMARY KEY,
    Descripcion    VARCHAR2(100),
    Severidad      VARCHAR2(20),
    Estado         VARCHAR2(20),
    FechaDeteccion DATE
);

-- Crear tabla Asignaciones
CREATE TABLE Asignaciones (
    AsignacionID NUMBER PRIMARY KEY,
    AgenteID     NUMBER,
    IncidenteID  NUMBER,
    Horas        NUMBER,
    Rol          VARCHAR2(30),
    CONSTRAINT fk_asig_agente    FOREIGN KEY (AgenteID)    REFERENCES Agentes(AgenteID),
    CONSTRAINT fk_asig_incidente FOREIGN KEY (IncidenteID) REFERENCES Incidentes(IncidenteID)
);

-- Insertar datos en Agentes
INSERT INTO Agentes VALUES (101, 'Camila Reyes',     'Pentester',       TO_DATE('2023-03-15','YYYY-MM-DD'));
INSERT INTO Agentes VALUES (102, 'Diego Muñoz',      'Analista SOC',    TO_DATE('2022-07-01','YYYY-MM-DD'));
INSERT INTO Agentes VALUES (103, 'Valentina Soto',   'Analista SOC',    TO_DATE('2024-01-10','YYYY-MM-DD'));
INSERT INTO Agentes VALUES (104, 'Matías Fernández', 'Forense Digital', TO_DATE('2021-11-20','YYYY-MM-DD'));
INSERT INTO Agentes VALUES (105, 'Francisca López',  'Pentester',       TO_DATE('2023-08-05','YYYY-MM-DD'));

-- Insertar datos en Incidentes
INSERT INTO Incidentes VALUES (201, 'Ransomware LockBit en servidor de archivos', 'Critical', 'Abierto',  TO_DATE('2026-03-01','YYYY-MM-DD'));
INSERT INTO Incidentes VALUES (202, 'Campaña de Phishing dirigida a RRHH',        'High',     'Abierto',  TO_DATE('2026-03-03','YYYY-MM-DD'));
INSERT INTO Incidentes VALUES (203, 'DDoS en portal web institucional',            'High',     'Cerrado',  TO_DATE('2026-03-20','YYYY-MM-DD'));
INSERT INTO Incidentes VALUES (204, 'SQL Injection en API de pagos',               'Critical', 'Abierto',  TO_DATE('2026-04-05','YYYY-MM-DD'));
INSERT INTO Incidentes VALUES (205, 'Exfiltración de datos via DNS tunneling',     'Medium',   'Cerrado',  TO_DATE('2026-04-10','YYYY-MM-DD'));
INSERT INTO Incidentes VALUES (206, 'Acceso no autorizado a base de datos',        'Critical', 'Abierto',  TO_DATE('2026-05-02','YYYY-MM-DD'));
INSERT INTO Incidentes VALUES (207, 'Malware en estaciones de trabajo',            'Medium',   'Cerrado',  TO_DATE('2026-05-15','YYYY-MM-DD'));

-- Insertar datos en Asignaciones
INSERT INTO Asignaciones VALUES (1,  101, 201, 40, 'Lider');
INSERT INTO Asignaciones VALUES (2,  102, 201, 35, 'Apoyo');
INSERT INTO Asignaciones VALUES (3,  102, 202, 20, 'Lider');
INSERT INTO Asignaciones VALUES (4,  103, 202, 25, 'Apoyo');
INSERT INTO Asignaciones VALUES (5,  103, 203, 30, 'Lider');
INSERT INTO Asignaciones VALUES (6,  104, 204, 45, 'Lider');
INSERT INTO Asignaciones VALUES (7,  101, 204, 35, 'Apoyo');
INSERT INTO Asignaciones VALUES (8,  105, 205, 25, 'Lider');
INSERT INTO Asignaciones VALUES (9,  104, 201, 20, 'Apoyo');
INSERT INTO Asignaciones VALUES (10, 102, 206, 50, 'Lider');
INSERT INTO Asignaciones VALUES (11, 105, 206, 30, 'Apoyo');
INSERT INTO Asignaciones VALUES (12, 103, 207, 15, 'Lider');

COMMIT;

SELECT 'Tablas creadas y datos insertados correctamente.' AS mensaje FROM dual;

SELECT * FROM Agentes;
SELECT * FROM Incidentes;
SELECT * FROM Asignaciones;


================================================================================
PRUEBA 3 - TÓPICOS AVANZADOS DE BASES DE DATOS
================================================================================


================================================================================
PARTE 1 - PREGUNTAS TEÓRICAS (40 puntos, 10 puntos cada una)
================================================================================

-- PREGUNTA 1 (10 puntos)
Explica qué es una transacción en una base de datos y describe las propiedades
ACID. Luego, muestra a través de un ejemplo cómo usarías múltiples savepoints
para manejar errores parciales en un procedimiento que asigna un agente a un
incidente y actualiza simultáneamente el estado del incidente. ¿Qué ocurre si
falla solo la actualización del estado?

Una transaccion en una base de datos es una unidad que se ejecuta de manera completa o no se ejecuta ninguna. 
Las propiedades ACID son:
1. Atomicidad:  Garantiza que todas las operaciones dentro de una trasaccion se completen exitosamente o ninguna se ejecute, asegurando que la base de datos permanezca preparada para cualquier fallo.
2. Consistencia: Asegura que una transaccion pueda llevar a la base de datos de un estado que esta valido a otro estado valido, manteniendo la integridad de los datos de la base.
3. Aislamiento: Garantiza que las operaciones de una transaccion sean invisibles para otras transacciones hasta que se complete, evitando interferencias y asegurando los resultados.
4. Durabilidad: Se asegura que una vez que una transaccion se ha completado, sus cambios se mantendran en la base de datos incluso en casos que presente fallos un sistema.

Ejemplo completo de uso de múltiples savepoints en un procedimiento:
CREATE OR REPLACE PROCEDURE asignar_agente_a_incidente (
    p_agente_id IN NUMBER,
    p_incidente_id IN NUMBER
) AS
    v_savepoint1 VARCHAR2(20);
    v_savepoint2 VARCHAR2(20);
BEGIN
    -- Crear un savepoint antes de asignar el agente
    v_savepoint1 := 'SAVEPOINT_ASIGNACION';
    SAVEPOINT v_savepoint1;

    -- Asignar el agente al incidente
    INSERT INTO Asignaciones (AgenteID, IncidenteID, Horas, Rol)
    VALUES (p_agente_id, p_incidente_id, 0, 'Apoyo');

    -- Crear un savepoint antes de actualizar el estado del incidente
    v_savepoint2 := 'SAVEPOINT_ESTADO';
    SAVEPOINT v_savepoint2;

    -- Actualizar el estado del incidente
    UPDATE Incidentes
    SET Estado = 'En Progreso'
    WHERE IncidenteID = p_incidente_id;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO v_savepoint2; -- Deshacer solo la actualización del estado
        DBMS_OUTPUT.PUT_LINE('Error al actualizar el estado del incidente. Se ha revertido solo esa operación.');
END;



¿Qué ocurre si falla solo la actualización del estado?
Si falla la actualizacion del estado, el procedimiento detectara el error y ejecutara el ROLLBACK al savepoint que se creo, 
lo que significa que la asignacion del agente al incidente se mantendra, pero el estado del incidente no se actualizara. 
El ejemplo muestra cómo manejar errores parciales en una transaccion, permitiendo que las operaciones exitosas se mantengan mientras se revierten solo las operaciones fallidas.



-- PREGUNTA 2 (10 puntos)
¿Qué es un Data Warehouse y cómo se diferencia de una base de datos
transaccional? Describe cómo diseñarías un modelo dimensional (tabla de hechos
y al menos dos dimensiones) para analizar las horas trabajadas por agente y
por severidad de incidente. ¿Qué ventajas tiene este modelo para consultas
analíticas versus consultar directamente las tablas transaccionales?

-Respuesta pregunta 2:
Un Data Warehouse es un sistema de almacenamiento de datos diseñado para la consulta y el análisis de grandes 
volumenes de datos. Se diferencia de una base de datos transaccional, ya que en está se optimiza para consultas complejas 
y analisis de datos historicos, mientras que las bases de datos transaccionales están diseñadas para manejar 
operaciones diarias y mantener la integridad de los datos en tiempo real.

Para el modelo dimensional, diseñaría un modelo dimensional con una tabla de hechos llamada 
Fact_Asignaciones y dos dimensiones: Dim_Agente y Dim_Incidente. Despues, la tabla de hechos Fact_Asignaciones contendria las métricas de horas trabajadas y 
el numero de incidentes atendidos, mientras que las dimensiones Dim_Agente y Dim_Incidente contendrian informacion detallada sobre los agentes y los incidentes, respectivamente. 
Con esto se podria realizar un analisis eficiente de las horas trabajadas por agente y por severidad de incidente.

Las ventajas de este modelo para consultas analiticas incluyen un rendimiento mejorado para las consultas analiticas, asi se ejecutan más rápido debido al modelo dimensional.
su facilidad de uso para los usuarios logra que pueden realizar consultas complejas y la escalabilidad del modelo dimensional permite agregar nuevas dimensiones 
y métricas sin afectar la estructura existente, facilitando el crecimiento del Data Warehouse.

-- PREGUNTA 3 (10 puntos)
Explica cómo se implementa la herencia en Oracle usando tipos de objetos.
Da un ejemplo de una jerarquía de dos niveles: Agente → AgenteEspecialista →
AgentePentester, donde cada nivel agrega atributos y sobreescribe un método
calcular_costo(). ¿Qué implicancias tiene declarar un tipo como NOT
INSTANTIABLE?

- Respuesta pregunta 3:
En Oracle, la herencia se implementa mediante tipos de objetos. Un tipo de objeto puede heredar atributos y metodos de otro tipo de objeto, como
un dato especefico o un comportamiento. Los tipos de objetos que heredan de otros tipos pueden sobrescribir metodos y agregar nuevos atributos, permitiendo la creación de jerarquias de objetos.
Ejemplo de jerarquía de dos niveles:
CREATE OR REPLACE TYPE Agente AS OBJECT (
    AgenteID NUMBER,
    Nombre VARCHAR2(50),
    MEMBER FUNCTION calcular_costo RETURN NUMBER
) NOT INSTANTIABLE;
CREATE OR REPLACE TYPE AgenteEspecialista UNDER Agente (
    Especialidad VARCHAR2(50),
    OVERRIDING MEMBER FUNCTION calcular_costo RETURN NUMBER
    function calcular_costo RETURN NUMBER IS
    BEGIN
        -- Implementación específica para AgenteEspecialista
        RETURN 1000; -- Ejemplo de costo fijo para especialistas
    END;
);
CREATE OR REPLACE TYPE AgentePentester UNDER AgenteEspecialista (
    Certificacion VARCHAR2(50),
    OVERRIDING MEMBER FUNCTION calcular_costo RETURN NUMBER
    function calcular_costo RETURN NUMBER IS
    BEGIN
        -- Implementación específica para AgentePentester
        RETURN 1500; -- Ejemplo de costo fijo para pentesters
    END;
);

Lo que implica declarar un tipo como NOT INSTANTIABLE es que no se pueden crear instancias de ese tipo directamente. 
Esto significa que solo se pueden crear instancias de los tipos derivados, lo que permite definir una estructura base común para todos 
los tipos derivados y garantizar que ciertos métodos o atributos sean implementados en las subclases.

-- PREGUNTA 4 (10 puntos)
Describe las ventajas y desventajas de usar índices y particiones en una base
de datos. ¿Cómo usarías un índice compuesto y una partición por rango para
mejorar el rendimiento de consultas en la tabla Incidentes filtradas por
Severidad y FechaDeteccion? Explica qué es el partition pruning y cómo
impacta en el plan de ejecución.

- Respuesta pregunta 4:
Las ventajas de usar los indeteces y particiones en una base de datos son que los indices permiten el acceso rapido a los datos
y las particiones permiten dividir grandes tablas de datos en partes mas pequeñas, estas ventajas permiten mejorar el rendmiento de las consultas y la gestion de los datos.
Por otra parte, las desventajas de usar los indices y las partciones de datos son que lo que los indices pueden aumentar el tiempo de ingreso, eliminacion y la actualizacion de datos,
mientras que las particiones pueden aumentar la complejidad de la gestion de la base de datos.

Para mejorar el rendimiento de consultas de la tabla incidentes filtradas, se puede crear un indice compuesto en las columnas, Severidad y FechaDeteccion, lo que
permite que las consultas que filtren para acceder a los datos de manera mas eficiente. Por otra parte, la particion por rango de FechaDeteccion 
que permite dividir la tabla en particiones, permitiendo que la informacion se pueda acceder de manera mas rapida y eficiente.

El "partition pruning" es una tecnica que permite que la base de datos determine que particiones son relevantes para la consulta y acceda solo a unas particones especificas,
evitando el escaneo de varias partciones. Esto impacta en el plan de ejecucion al reducir la cantidad de datos, mejorando el rendimiento de la consulta
y optimizando el uso de recursos del sistema.


================================================================================
PARTE 2 - EJERCICIOS PRÁCTICOS (60 puntos)
================================================================================

-- EJERCICIO 1 (20 puntos)
Escribe un procedimiento registrar_asignacion que reciba un AgenteID,
IncidenteID, Horas y Rol (parámetros IN). El procedimiento debe:
  a) Insertar una nueva asignación en Asignaciones (usa el próximo
     AsignacionID disponible).
  b) Validar que el agente no supere 100 horas totales asignadas en
     incidentes con Estado 'Abierto'.
  c) Validar que el incidente no tenga ya 3 o más agentes asignados.
  d) Usar savepoints independientes para cada validación, de modo que un
     fallo en una no deshaga operaciones previas válidas.
  e) Manejar todas las excepciones con mensajes descriptivos.

respuesta Ejercicio 1:
CREATE OR REPLACE PROCEDURE registrar_asignacion (
    p_AgenteID    IN NUMBER,
    p_IncidenteID IN NUMBER,
    p_Horas       IN NUMBER,
    p_Rol         IN VARCHAR2
) AS
    v_savepoint1 VARCHAR2(20);
    v_savepoint2 VARCHAR2(20);
    v_total_horas NUMBER;
    v_total_agentes NUMBER;
Begin 
    -- Crear un savepoint antes de validar las horas del agente
    v_savepoint1 := 'SAVEPOINT_VALIDAR_HORAS';
    SAVEPOINT v_savepoint1;

    -- Validar que el agente no supere 100 horas totales asignadas en incidentes con Estado 'Abierto'
    SELECT SUM(Horas) INTO v_total_horas FROM Asignaciones a
    JOIN Incidentes i ON a.IncidenteID = i.IncidenteID
    WHERE a.AgenteID = p_AgenteID AND i.Estado = 'Abierto';
    -- Manejar el caso en que el agente no tenga asignaciones previas
    IF NVL(v_total_horas, 0) + p_Horas > 100 THEN
        ROLLBACK TO v_savepoint1;
        RAISE_APPLICATION_ERROR(-20001, 'El agente supera las 100 horas totales asignadas en incidentes abiertos.');
    END IF;

    -- Crear un savepoint antes de validar el número de agentes asignados al incidente
    v_savepoint2 := 'SAVEPOINT_VALIDAR_AGENTES';
    SAVEPOINT v_savepoint2;

    -- Validar que el incidente no tenga ya 3 o más agentes asignados
    SELECT COUNT(*) INTO v_total_agentesFROM Asignaciones
    WHERE IncidenteID = p_IncidenteID;
    -- Manejar el caso en que el incidente no tenga asignaciones previas
    IF NVL(v_total_agentes, 0) >= 3 THEN
        ROLLBACK TO v_savepoint2;
        RAISE_APPLICATION_ERROR(-20002, 'El incidente ya tiene 3 o más agentes asignados.');
    END IF;

    -- Insertar la nueva asignación
    INSERT INTO Asignaciones (AsignacionID, AgenteID, IncidenteID, Horas, Rol)
    VALUES (Asignaciones_SEQ.NEXTVAL, p_AgenteID, p_IncidenteID, p_Horas, p_Rol);
    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error al registrar la asignación: ' || SQLERRM);
END;



EJERCICIO 2 (20 puntos)
Diseña las tablas Fact_Asignaciones, Dim_Agente y Dim_Incidente para un
Data Warehouse basado en la base de datos de la prueba. Luego, escribe una
consulta analítica sobre las tablas transaccionales que muestre, para cada
agente, el total de horas trabajadas y el número de incidentes atendidos,
ordenado de mayor a menor por total de horas.

-- Creacion de Dimensiones y tabla de hechos para el Data Warehouse segun los datos de las tablas transaccionales:
-- Crear tabla Dim_Agente   
CREATE TABLE Dim_Agente (
    AgenteID     NUMBER PRIMARY KEY,
    Nombre       VARCHAR2(50),
    Especialidad VARCHAR2(50),
    FechaIngreso DATE
);
CREATE TABLE Dim_Incidente (
    IncidenteID    NUMBER PRIMARY KEY,
    Descripcion    VARCHAR2(100),
    Severidad      VARCHAR2(20),
    Estado         VARCHAR2(20),
    FechaDeteccion DATE
);
CREATE TABLE Fact_Asignaciones (
    AsignacionID NUMBER PRIMARY KEY,
    AgenteID     NUMBER,
    IncidenteID  NUMBER,
    Horas        NUMBER,
    Rol          VARCHAR2(30),
    CONSTRAINT fk_fact_agente    FOREIGN KEY (AgenteID)    REFERENCES Dim_Agente(AgenteID),
    CONSTRAINT fk_fact_incidente FOREIGN KEY (IncidenteID) REFERENCES Dim_Incidente(IncidenteID)
);
-- Consulta analitica que muestra
SELECT a.AgenteID, a.Nombre, SUM(f.Horas) AS total_horas, COUNT(DISTINCT f.IncidenteID) AS total_incidentes FROM Dim_Agente a
JOIN Fact_Asignaciones f ON a.AgenteID = f.AgenteID
GROUP BY a.AgenteID, a.Nombre
ORDER BY total_horas DESC;


EJERCICIO 3 (20 puntos)
Crea un índice compuesto en Incidentes para las columnas Severidad y
FechaDeteccion. Luego, crea la tabla Incidentes particionada por rango de
FechaDeteccion (trimestral para 2026). Escribe una consulta que muestre el
total de horas asignadas por incidente para incidentes 'Critical' detectados
en el primer trimestre de 2026. Finalmente, muestra el plan de ejecución
con EXPLAIN PLAN e indica qué ventaja aporta la partición para esta consulta.

--Crear indice compuesto:
CREATE INDEX idx_severidad_fecha ON Incidentes (Severidad, FechaDeteccion);

--Crear tabla particionada por rango de FechaDeteccion:
CREATE TABLE Incidentes_Part (
    IncidenteID    NUMBER PRIMARY KEY,
    Descripcion    VARCHAR2(100),
    Severidad      VARCHAR2(20),
    Estado         VARCHAR2(20),
    FechaDeteccion DATE
)
-- Particion trimestral para 2026
PARTITION BY RANGE (FechaDeteccion) (
    -- Son 4 particiones para cada trimestre del año 2026.
    Partition Q1_2026 VALUES LESS THAN (TO_DATE('2026-04-01','YYYY-MM-DD')),
    Partition Q2_2026 VALUES LESS THAN (TO_DATE('2026-07-01','YYYY-MM-DD')),
    Partition Q3_2026 VALUES LESS THAN (TO_DATE('2026-10-01','YYYY-MM-DD')),
    Partition Q4_2026 VALUES LESS THAN (TO_DATE('2027-01-01','YYYY-MM-DD'))
);

-- Consulta que muestra el total de horas asignadas por incidente para incidentes 'Critical' detectados en el primer trimestre de 2026:
SELECT i.IncidenteID, SUM(a.horas) AS total_horas FROM Incidentes_Part i
JOIN Asignaciones a ON i.IncidenteID = a.IncidenteID
WHERE i.Severidad = 'Critical' AND i.FechaDeteccion >= TO_DATE('2026-01-01','YYYY-MM-DD') AND i.FechaDeteccion < TO_DATE('2026-04-01','YYYY-MM-DD')
GROUP BY i.IncidenteID;

-- Mostrar plan de ejecucion con Explain Plan:
EXPLAIN PLAN FOR
SELECT i.IncidenteID, SUM(a.horas) AS total_horas FROM Incidentes_Part i
JOIN Asignaciones a ON i.IncidenteID = a.IncidenteID
WHERE i.Severidad = 'Critical' AND i.FechaDeteccion >= TO_DATE('2026-01-01','YYYY-MM-DD') AND i.FechaDeteccion < TO_DATE('2026-04-01','YYYY-MM-DD')
GROUP BY i.IncidenteID;

La ventaja de la particion para esta consulta es que permite que la base de datos acceda solo a la particion relevante,
evitando el escaneo de todas las particiones mejorando el rendimiento de la consulta y optimizando los recursos del sistema.

================================================================================
