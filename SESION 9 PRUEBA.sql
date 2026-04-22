-- PARTE 1:

-- 1. Relación Muchos a Muchos (10 pts): Explica qué es una relación muchos a muchos y cómo se implementa en una base de datos relacional. Usa un ejemplo basado en las tablas del esquema creado para la prueba.

Para implemnetar una relacion entre las tablas de muchos a muchos hayq ue crear una tabla intermediaria la cual tiene que almacenar 2 PRIMARY KEY de las tablas las cuales
se quiere almacenar los datos. Esta tecnica se usa principalmente debido a la gran cantidad de datos que pueden llegar a manejar estas tablas de datos.
Un ejemplo seria la tabla de "Asignaciones" que se encuentra dentro de la base de datos enviada en la prueba, la cual hace la conectividad entre los
"Agentes" y los "Incidentes", mediante sus PRIMARY KEY(AgenteID, IncidenteID), teniando en la tabla "Asignaciones" FOREIGN KEY de las PRIMARY key mencionadas.

-- 2. Describe qué es una vista y cómo la usarías para mostrar el total de horas dedicadas por incidente, incluyendo la descripción del incidente y su severidad. 
-- Escribe la consulta SQL para crear la vista (no es necesario ejecutarla).

Una vista es una forma de enseñar datos de tablas de manera mas eficiente y especifica, ya que no seria necesario generar la consulta para cada vez que se quiera visualizar los datos, se podria decir
que es una forma de "resumir consultas en SQL" a la hora de pedir ciertos datos. Para crear una vista del "total de horas por incidente" enseñaria el ID del incidente con los demas 
datos solicitados, aca esta la consulta:

CREATE VIEW vista_incidentes AS
    SELECT i.IncidenteID, SUM(a.Horas), i.Descripcion, i.Severidad FROM Incidentes
    inner join Asignaciones a on a.IncidenteID = i.IncidenteID
    group by i.IncidenteID, i.descripción, i.severidad;
SELECT * from vista_incidentes;

--3. ¿Qué es una excepción predefinida en PL/SQL y cómo se maneja? Da un ejemplo de cómo manejarías la excepción NO_DATA_FOUND en un bloque PL/SQL.

Una excepción en SQL sirve para definir casos de errores que puede tener el programa al ejecutar una accion, por ejemplo si el programa no encuentra un dato especifico,
la excepción se puede encargar de hacerle saber al usuario que paso realmente, o si el cursor esta Abierto tambien puede ser cerrado por una excepción

EXCEPTION
    WHEN OTHERS THEN 
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    IF incidente_cursor%ISOPEN THEN
        CLOSE incidente_cursor;
    END IF;
END;
/

--4.: Explica qué es un cursor explícito y cómo se usa en PL/SQL. Menciona al menos dos atributos de cursor (como %NOTFOUND) y su propósito.

Un cursor explícito sirve principalmente para enseñar datos de una tabla sin alterar los anteriores mencionados (aun que se pueden modifciar)
dependiendo de lo que quieras hacer. El NOTFOUND sirve principalmente para casos en los que no se cuentren mas variables dentro de la tabla,
se podria decir que es la condicional para cerrar el LOOP

DECLARE
	CURSOR incidente_cursor IS
    	SELECT incidente_id, descripción FROM Incidentes;
	v_incidentes_id Incidentes.incidente_id%TYPE;
	v_descripcion Incidentes.descripción%TYPE;
BEGIN
	OPEN incidente_cursor;
	LOOP
    	FETCH incidente_cursor INTO v_incidentes_id, v_descripcion;
    	EXIT WHEN incidente_cursor%NOTFOUND;
    	DBMS_OUTPUT.PUT_LINE('Incidente ' || v_incidentes_id || ' Descripcion: ' || v_descripcion);
	END LOOP;
	CLOSE incidente_cursor;
EXCEPTION
    WHEN OTHERS THEN 
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    IF incidente_cursor%ISOPEN THEN
        CLOSE incidente_cursor;
    END IF;
END;
/


-- PARTE 2:

-- Escribe un bloque PL/SQL con un cursor explícito que liste las especialidades de agentes cuyo promedio de horas asignadas a incidentes sea mayor a 30, 
-- mostrando la especialidad y el promedio de horas. Usa un JOIN entre Agentes y Asignaciones.
DECLARE
	CURSOR agentes_cursor IS
    	SELECT a.Nombre, a.Especialidad, AVG(asi.Horas) FROM Agentes a
        inner join Asignaciones asi on asi.AgenteID=a.AgenteID
        group BY a.AgenteID, a.Nombre, a.Especialidad
        HAVING AVG(ASI.HORAS)>30
	v_nombre_agentes Agentes.Nombre%TYPE;
	v_especialidad Agentes.Especialidad%TYPE;
    v_promedio_horas NUMBER;
BEGIN
	OPEN agentes_cursor;
	LOOP
    	FETCH agentes_cursor INTO v_nombre_agentes, v_especialidad, v_promedio_horas;
    	EXIT WHEN agentes_cursor%NOTFOUND;
    	DBMS_OUTPUT.PUT_LINE('Nombre Agente ' || v_nombre_agentes || ' Especialidad Agente: ' || v_especialidad || 'Promedio Horas Agente:' || v_promedio_horas);
	END LOOP;
	CLOSE agentes_cursor;
EXCEPTION
    WHEN OTHERS THEN 
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    IF agentes_cursor%ISOPEN THEN
        CLOSE agentes_cursor;
    END IF;
END;
/

-- Escribe un bloque PL/SQL con un cursor explícito que aumente en 10 las horas de todas las asignaciones 
-- asociadas a incidentes con severidad 'Critical'. Usa FOR UPDATE y maneja excepciones.
DECLARE
	CURSOR asignaciones_cursor IS
    	SELECT i.IncidenteID, i.Severidad, a.HORAS FROM Incidentes
    	INNER JOIN Asignaciones a on a.IncidenteID = i.IncidenteID
        WHERE i.severidad = 'Critical'
    	FOR UPDATE;
	v_incidentes_id Incidentes.IncidenteID%TYPE;
	v_incidentes_severidad Incidentes.Severidad%type;
    v_horas_asignadas NUMBER;
BEGIN
	OPEN asignaciones_cursor;
	LOOP
    	FETCH asignaciones_cursor INTO v_incidentes_id, v_incidentes_severidad, v_horas_asignadas;
    	EXIT WHEN asignaciones_cursor%NOTFOUND;
    	UPDATE Asignaciones
    	SET Horas = v_horas_asignadas + 10
    	WHERE CURRENT OF asignaciones;
    	DBMS_OUTPUT.PUT_LINE('ID INCIDENTE ' || v_incidentes_id || ' SEVERIDAD INCIDENTE: ' || v_incidentes_severidad || 'HORAS AUMENTADAS: ' || (v_horas_asignadas+10));
	END LOOP;
	CLOSE asignaciones_cursor;
EXCEPTION
	WHEN OTHERS THEN
    	DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    	IF asignaciones_cursor%ISOPEN THEN
        	CLOSE asignaciones_cursor;
    	END IF;
END;
/

-- Tipo de Objeto (20 pts) Crea un tipo de objeto incidente_obj con atributos incidente_id, descripcion, y un método get_reporte. 
-- Luego, crea una tabla basada en ese tipo y transfiere los datos de Incidentes a esa tabla. 
-- Finalmente, escribe un cursor explícito que liste la información de los incidentes usando el método get_reporte.

