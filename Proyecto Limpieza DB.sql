-- CREO CONSULTA DE COMPROBACIÓN -- 

DELIMITER //
create procedure limp()
begin
	select * from limpieza limit 10;
end //
DELIMITER ;

-- LLAMO A LA CONSULTA PARA COMPROBAR LA CONSUTA -- 

CALL limp();


-- RENOMBRO COLUMNAS CON CARACTERES ESPECIALES--

ALTER TABLE limpieza CHANGE COLUMN `genero` Gender varchar(50) null;
ALTER TABLE limpieza CHANGE COLUMN `Id_empleado` Id_emp varchar(50) null;
ALTER TABLE limpieza CHANGE COLUMN `Apellido` Last_Name varchar(50) null;
ALTER TABLE limpieza CHANGE COLUMN star_date start_date varchar(50) null;


-- CONFIRMO LOS META DATOS DE LA TABLA --

DESCRIBE limpieza;

-- MOSTRAR DUPLICADOS --

SELECT 
    id_emp, COUNT(*) AS cantidad_duplicados
FROM
    limpieza
GROUP BY id_emp
HAVING COUNT(*) > 1;


-- SUBCONSULTA CONTAR DUPLICADOS --

SELECT 
    COUNT(*) AS cantidad_duplicados
FROM
    (SELECT 
        id_emp, COUNT(*) AS cantidad_duplicados
    FROM
        limpieza
    GROUP BY id_emp
    HAVING COUNT(*) > 1) AS Subquery;

-------------- ELIMINAR DUPLICADOS --------------
-- RENOMBRAR TABLA CON DUPLICADOS --

rename table limpieza to tabla_duplicados;


-- NUEVA TABLA SIN DUPLICADOS EN TABLA TEMPORAL--

create temporary table Temp_limpieza as
select distinct * from tabla_duplicados;


-- CONFIRMO QUE NO ESTÁN LOS DUPLICADOS --

SELECT 
    COUNT(*) AS conteo
FROM
    tabla_duplicados;
SELECT 
    COUNT(*) AS conteo2
FROM
    Temp_limpieza;


-- NUEVA TABLA SIN DUPLICADOS EN NUEVA TABLA--

CREATE TABLE limpieza AS SELECT * FROM
    Temp_limpieza;

call limp();


-- ELIMINO TABLA CON DUPLICADOS --

drop table tabla_duplicados;


-- ELIMINO ESPACIOS INECESARIOS DE LOS DATOS --
-- Reviso los nombres que tienen espacios extra--

SELECT 
    name
FROM
    limpieza
WHERE
    LENGTH(name) - LENGTH(TRIM(name)) > 0;

-- Comparo con la función TRIM --

SELECT 
    name, TRIM(name) AS new_name
FROM
    limpieza
WHERE
    LENGTH(name) - LENGTH(TRIM(name)) > 0;

-- Modifico los nombres con espacios extra antes o después del texto--

UPDATE limpieza 
SET 
    name = TRIM(name)
WHERE
    LENGTH(name) - LENGTH(TRIM(name)) > 0;
    
 -- Repito para Last_name -- 
 
SELECT 
    name
FROM
    limpieza
WHERE
    LENGTH(last_name) - LENGTH(TRIM(last_name)) > 0;
 
    UPDATE limpieza 
SET 
    Last_name = TRIM(Last_name)
WHERE
    LENGTH(Last_name) - LENGTH(TRIM(Last_name)) > 0;
    
    
    -- Modifico los nombres con espacios extra dentro del texto en columna area--
    
UPDATE limpieza 
SET 
    area = (REGEXP_REPLACE(area, '\s+', ' '));



    -- REEMPLAZAR DATOS--
    -- Columna Gender -- 
    
    UPDATE LIMPIEZA 
SET 
    GENDER = CASE
        WHEN GENDER = 'HOMBRE' THEN 'MALE'
        WHEN GENDER = 'MUJER' THEN 'FEMALE'
        ELSE 'OTHER'
    END;
    
  
   -- Columna Type -- 
   -- Modifico el type de la columna --
   
   describe limpieza;
   
   alter table limpieza modify column type text;
   
       UPDATE LIMPIEZA 
SET 
    type = CASE
        WHEN type = 1 THEN 'Remote'
        WHEN type = 0 THEN 'Hybrid'
        ELSE 'OTHER'
    END;
   

   -- REEMPLAZAR FORMATO TEXTO A NÚMERO--
   
   UPDATE Limpieza 
SET 
    salary = CAST(TRIM(REPLACE(REPLACE(salary, '$', ''),
                ',',
                ''))
        AS DECIMAL (15 , 2 ));
	ALTER TABLE Limpieza MODIFY COLUMN salary decimal(10,2) null;

call limp();


  -- REEMPLAZAR FORMATO TEXTO A FECHA CON NUEVO FORMATO--
  -- Para columna birth_date --
  
  UPDATE Limpieza SET birth_date = CASE
	WHEN birth_date like '%/%' THEN date_format(str_to_date(birth_date, '%m/%d/%Y'), '%Y-%m-%d')
	WHEN birth_date like '%-%' THEN date_format(str_to_date(birth_date, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE null
END;

  -- Para columna birth_date --
  
  UPDATE Limpieza SET start_date = CASE
	WHEN start_date like '%/%' THEN date_format(str_to_date(start_date, '%m/%d/%Y'), '%Y-%m-%d')
	WHEN start_date like '%-%' THEN date_format(str_to_date(start_date, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE null
END;

ALTER TABLE  Limpieza MODIFY COLUMN birth_date date;
ALTER TABLE  Limpieza MODIFY COLUMN start_date date;

 -- Para modificar columna finish_date --
 
 ALTER TABLE limpieza ADD COLUMN finish_date_backup text;  -- Genero una copia de seguridad de la columna a modificar--
SET SQL_SAFE_UPDATES = 0;
UPDATE limpieza SET finish_date_backup = finish_date;

UPDATE limpieza SET finish_date = str_to_date(finish_date, '%Y-%m-%d %H:%i:%s UTC')
WHERE finish_date <> '';


 -- Separar valores de finish_date en nueva columna--
 
 ALTER TABLE limpieza
	ADD COLUMN 	fecha date,
    ADD COLUMN hora time;
 
 UPDATE limpieza SET finish_date = null 
	WHERE finish_date = '';
    
UPDATE limpieza
	SET fecha = date(finish_date),
		hora = time (finish_date)
	WHERE finish_date is not null and finish_date <> '';
    
ALTER TABLE limpieza MODIFY COLUMN finish_date datetime;
Describe limpieza;


-- CALCULAR EDAD DE LOS EMPLEADOS --

ALTER TABLE limpieza 
	ADD COLUMN age int;

UPDATE limpieza SET age =  timestampdiff(year,birth_date,curdate());
call limp();


-- CREAR CORREOS ELECTRÓNICOS - CONCADENANDO COLUMNAS --7

ALTER TABLE limpieza
	ADD COLUMN email varchar(100);

UPDATE limpieza 
SET 
    email = CONCAT(SUBSTRING_INDEX(name, ' ', 1),
            '_',
            SUBSTRING(last_name, 1, 2),
            '.',
            SUBSTRING(type, 1, 1),
            '@consulting.com');
            
            
-- SELECION Y GRUPACIÓN DE DATOS PARA CREAR UNA NUEVAS TABLAS DE CONSULTA --

-- Lista de empleados e información personal ordenados alfabéticamente --
SELECT Id_emp, name, last_name, age, gender, area, salary, email, finish_date FROM limpieza
WHERE finish_date <= curdate() or finish_date is null
ORDER BY area, Name ;


-- Cantidad de empleados por área de más a menos empleados --
SELECT area, count(*) as cantidad_empleados from limpieza
GROUP BY area
ORDER BY cantidad_empleados DESC;