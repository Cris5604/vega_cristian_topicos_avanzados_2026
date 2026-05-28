-- PARTE 1:

1.Explica la diferencia entre un procedimiento almacenado y una función almacenada en PL/SQL. 
Da un ejemplo de cuándo usarías cada uno en el contexto de la base de datos de la prueba.

Respuesta:
Un procedimiento almacenado realiza una accion en especifico con la intencion de modificar datos o enseñar un resultado, ademas que los procedimienos
son capaces de usar un cursor, por otro lado una funcion almacenda devuelve un valor y se puede usar dentro de una consulta SQL, para que la funcion
pueda funcionar tiene que ser llamada dentro de una expresion SQL. A las 2 se les pueden pasar parametros, pero en el caso de las funciones, el parametro 
de salida es el valor que devuelve la funcion.

Ejemplo de procedimiento almacenado:
CREATE OR REPLACE PROCEDURE actualizar_horas_asignacion (p_asignacion_id IN NUMBER, p_ajuste_horas IN NUMBER) 
AS
BEGIN
    -- Actualizar las horas de la asignación
    UPDATE Asignaciones
    SET Horas = Horas + p_ajuste_horas
    WHERE AsignacionID = p_asignacion_id
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

Ejemplo de función almacenada:
CREATE OR REPLACE FUNCTION total_horas_incidente(p_incidente_id IN NUMBER) RETURN NUMBER 
AS
    v_total_horas NUMBER;
BEGIN
    SELECT SUM(Horas) INTO v_total_horas FROM Asignaciones
    WHERE IncidenteID = p_incidente_id; 
    RETURN v_total_horas; -- Devolver el total de horas
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        RETURN 0;
END;
/

2.Describe cómo usarías un parámetro IN OUT en un procedimiento almacenado. Escribe un ejemplo de un procedimiento que use 
un parámetro IN OUT para actualizar y devolver las horas de una asignación después de un ajuste.

Respuesta:
Un parámetro IN OUT en un procedimiento almacenado se utiliza para pasar un valor al procedimiento, 
esto permite que el procedimiento lo modifique y luego devolver el valor modificado al que llama el proceso. 
Esto es sirve para que el procedimiento realice una operación sobre un valor y luego devuelva el resultado actualizado.

Ejemplo de procedimiento con IN OUT:
CREATE OR REPLACE PROCEDURE ajustar_horas_asignacion (p_asignacion_id IN NUMBER,p_ajuste_horas IN NUMBER,p_total_horas IN OUT NUMBER) 
AS 
BEGIN
    -- Actualizar las horas de la asignación
    UPDATE Asignaciones
    SET Horas = Horas + p_ajuste_horas
    WHERE AsignacionID = p_asignacion_id;

    SELECT Horas INTO p_total_horas FROM Asignaciones
    WHERE AsignacionID = p_asignacion_id;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

3.¿Cómo se puede usar una función almacenada dentro de una consulta SQL? Escribe un ejemplo de una función que calcule el 
total de horas asignadas a un incidente y úsala en una consulta para listar los incidentes con su total de horas.

Una función almacenada se puede usar dentro de una consulta SQL siempre que la función devuelva un valor, para usar una funcion 
simplemente se llama a la función en la parte de la consulta donde se necesita el valor que devuelve.

Ejemplo de función:
CREATE OR REPLACE FUNCTION total_horas_incidente(p_incidente_id IN NUMBER) RETURN NUMBER
AS
    v_total_horas NUMBER;
BEGIN
    SELECT SUM(Horas) INTO v_total_horas FROM Asignaciones
    WHERE IncidenteID = p_incidente_id; 
    RETURN v_total_horas; -- Devolver el total de horas
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        RETURN 0;
END;
/
-- llamando a la consulta SQL usando la función
SELECT IncidenteID, Descripcion, total_horas_incidente(IncidenteID) AS TotalHoras FROM Incidentes;

4.Explica qué es un trigger y menciona dos tipos de eventos que pueden dispararlo. Da un ejemplo de un trigger que se dispare después 
de insertar una asignación en la tabla Asignaciones y actualice el estado del incidente a 'En Proceso' si estaba en 'Abierto'.

Un trigger es un bloque de codigo en SQL el cual se ejecuta automaticamente cuando una cierta accion ocurre en la base de datos, realizando 
una tarea especifica. Los eventos que pueden disparar un trigger son un INSERT (cuando se ingresa un datos) y un UPDATE (cuando se actualiza un dato).
Estas acciones que puede realizar el trigger pueden realizarse antes (AFTER) o despues (BEFORE) de que ocurra el evento.

Ejemplo de trigger:
CREATE OR REPLACE TRIGGER actualizar_estado_incidente AFTER INSERT ON Asignaciones
FOR EACH ROW
BEGIN
    -- Cambiar el estado a 'En Proceso' a los Estados 'Abierto'
    UPDATE Incidentes
    SET Estado = 'En Proceso' 
    WHERE IncidenteID = :NEW.IncidenteID AND Estado = 'Abierto';
END;
/


-- PARTE 2:

1. Escribe un procedimiento registrar_asignacion que reciba un AgenteID, IncidenteID, Horas y Rol (parámetros IN). El procedimiento debe:
Insertar una nueva asignación en la tabla Asignaciones (usa el próximo AsignacionID disponible).
Actualizar el estado del incidente a 'En Proceso' si estaba en 'Abierto'.
Manejar excepciones si el agente o incidente no existen, o si el agente ya está asignado a ese incidente.

CREATE OR REPLACE PROCEDURE registrar_asignacion (p_agente_id IN NUMBER, p_incidente_id IN NUMBER, p_horas IN NUMBER, p_rol IN VARCHAR2)
AS
    v_asignacion_id NUMBER := 0;
    v_agente_existe NUMBER := 0;
    v_incidente_existe NUMBER := 0;
BEGIN
    -- Verificar si el agente existe
    SELECT 1 INTO v_agente_existe FROM Agentes -- Se le asigna el valor 1 a v_agente_existe si el agente existe en la tabla Agentes
    WHERE AgenteID = p_agente_id; -- en caso de que el agente no exista, v_agente_existe se quedara con su valor inicial de 0
    IF p_agente_id IS NULL OR v_agente_existe = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Error, agente no encontrado: ' || SQLERRM);
    END IF;

    -- Verificar si el incidente existe
    SELECT 1 INTO v_incidente_existe FROM Incidentes -- Se le asigna el valor 1 a v_incidente_existe si el incidente existe en la tabla Incidentes
    WHERE IncidenteID = p_incidente_id; -- en caso de que el incidente no exista, v_incidente_existe se quedara con su valor inicial de 0
    IF p_incidente_id IS NULL OR v_incidente_existe = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Error, incidente no encontrado: ' || SQLERRM);
    END IF;

    -- Verificar si el agente ya está asignado al incidente
    SELECT 1 INTO v_asignacion_id FROM Asignaciones -- Se le asigna el valor 1 a v_asignacion_id si el agente ya está asignado al incidente en la tabla Asignaciones
    WHERE AgenteID = p_agente_id AND IncidenteID = p_incidente_id; -- en caso de que el agente no esté asignado al incidente, v_asignacion_id se quedara con su valor inicial de 0
    IF v_asignacion_id > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Error, agente ya está asignado al incidente: ' || SQLERRM);
    END IF;

    -- Insertar la nueva asignación
    INSERT INTO Asignaciones (AsignacionID, AgenteID, IncidenteID, Horas, Rol)
    VALUES (Asignacion_seq.NEXTVAL, p_agente_id, p_incidente_id, p_horas, p_rol);

    -- Actualizar el estado del incidente a 'En Proceso' si estaba en 'Abierto'
    UPDATE Incidentes
    SET Estado = 'En Proceso'
    WHERE IncidenteID = p_incidente_id AND Estado = 'Abierto';

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

2. Escribe una función calcular_horas_agente que reciba un AgenteID (parámetro IN) y devuelva el total de horas asignadas a ese agente 
en todos los incidentes. Luego, usa la función en un procedimiento mostrar_carga_agentes que muestre el total de horas por agente 
para todos los agentes, indicando su nombre y especialidad.

CREATE OR REPLACE FUNCTION calcular_horas_agente(p_agente_id IN NUMBER) RETURN NUMBER
AS
    v_total_horas NUMBER;
BEGIN
    SELECT SUM(Horas) INTO v_total_horas FROM Asignaciones
    WHERE AgenteID = p_agente_id;
    RETURN v_total_horas; -- Devolver el total de horas de asignaciones para el agente
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        RETURN 0;
END;
/

CREATE OR REPLACE PROCEDURE mostrar_carga_agentes 
AS
    -- Declarar un cursor para obtener los agentes
    CURSOR agente_cursor IS
        SELECT AgenteID, Nombre, Especialidad FROM Agentes;
BEGIN
    -- Iterar sobre los agentes y mostrar su carga de horas
    FOR agente IN agente_cursor LOOP
        DBMS_OUTPUT.PUT_LINE('Nombre Agente: ' || agente.Nombre || ', Especialidad: ' || agente.Especialidad || ', Total Horas: ' || calcular_horas_agente(agente.AgenteID));
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

3. Implementa un sistema de auditoría manual usando un trigger. Para esto, primero crea una tabla llamada AuditoriaAsignaciones con 
las columnas necesarias. Luego, crea un trigger auditar_asignaciones que se dispare después de insertar o eliminar una asignación en 
la tabla Asignaciones. El trigger debe registrar en la tabla de auditoría el AsignacionID, AgenteID, IncidenteID, Horas, la acción 
realizada ('INSERT' o 'DELETE') y la fecha del registro. 

CREATE TABLE AuditoriaAsignaciones (
    AuditoriaID NUMBER PRIMARY KEY,
    AsignacionID NUMBER,
    AgenteID NUMBER,
    IncidenteID NUMBER,
    Horas NUMBER,
    Accion VARCHAR2(10),
    FechaRegistro DATE
);

CREATE OR REPLACE TRIGGER auditar_asignaciones AFTER INSERT OR DELETE ON Asignaciones
FOR EACH ROW
BEGIN 
    IF INSERTING THEN
        INSERT INTO AuditoriaAsignaciones (AuditoriaID, AsignacionID, AgenteID, IncidenteID, Horas, Accion, FechaRegistro)
        VALUES ( Auditoria_seq.NEXTVAL, :NEW.AsignacionID, :NEW.AgenteID, :NEW.IncidenteID, :NEW.Horas, 'INSERT', SYSDATE);
    ELSIF DELETING THEN
        INSERT INTO AuditoriaAsignaciones (AuditoriaID, AsignacionID, AgenteID, IncidenteID, Horas, Accion, FechaRegistro)
        VALUES ( Auditoria_seq.NEXTVAL, :OLD.AsignacionID, :OLD.AgenteID, :OLD.IncidenteID, :OLD.Horas, 'DELETE', SYSDATE);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/




