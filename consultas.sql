USE universidad;

SHOW TABLES;
-- Devuelve un listado con los nombres de todos los profesores y los departamentos que tienen vinculados. El listado también debe mostrar aquellos profesores que no tienen ningún departamento asociado. El listado debe devolver cuatro columnas, nombre del departamento, primer apellido, segundo apellido y nombre del profesor. El resultado estará ordenado alfabéticamente de menor a mayor por el nombre del departamento, apellidos y el nombre.

# Se hace un left join con la tabla depto para sacar todos los profesores y relacionarlos con aquellos que tengan un depto asociado
SELECT D.nombre AS Depto, P.apellido1 AS Apellido1Profesor, P.apellido2 AS Apellido2Profesor, P.nombre AS NombreProfesor
FROM profesor P
LEFT JOIN departamento AS D ON P.id_departamento = D.id
ORDER BY D.nombre, P.apellido1, P.apellido2, P.nombre;

-- Devuelve un listado con los profesores que no están asociados a un departamento.

# hacemos la comparacion para que nos devuelva todos los profesores cuyo id_depto no esté en esa tabla. Como no hay profesores que no tengan deptos, no devuelve registros sino una tabla vacia
# No hay profesores que no esten asociados a un departamento porque es un dato nOT NULL
SELECT P.*
FROM profesor P
WHERE id_departamento NOT IN (SELECT id FROM departamento);





-- Devuelve un listado con los departamentos que no tienen profesores asociados

# Se hace una subconsulta para obtener los id_departamento de cada profesor y luego se devuelve los nombres de los deptos que no estén relacionados con la subconsulta
SELECT D.nombre
FROM departamento D
WHERE D.id NOT IN 
(SELECT P.id_departamento
FROM profesor P
INNER JOIN departamento D ON P.id_departamento = D.id);


-- Devuelve un listado con los profesores que no imparten ninguna asignatura.


# Se hace una subconsulta para tener los profesores que imparten asignaturas y luego se compara con el total de profesores
SELECT P.nombre
FROM profesor P
WHERE P.id NOT IN(
    SELECT P2.id
    FROM asignatura A
    INNER JOIN profesor P2 ON A.id_profesor = P2.id
);

-- Devuelve un listado con las asignaturas que no tienen un profesor asignado.

# Devuelve las asignaturas donde no haya un profesor registrado
SELECT nombre
FROM asignatura
WHERE id_profesor IS NULL;


-- Devuelve un listado con todos los departamentos que tienen alguna asignatura que no se haya impartido en ningún curso escolar. El resultado debe mostrar el nombre del departamento y el nombre de la asignatura que no se haya impartido nunca.


#Se hace una subconsulta con los id de las asignaturas relacionadas con curso y alumno y se compara con el total de las asignaturas con el fin de obtener las que no se hayan impartido

SELECT D.nombre AS Departamento, A.nombre AS Asignatura
FROM departamento D
INNER JOIN profesor P ON D.id = P.id_departamento
INNER JOIN asignatura A ON P.id = A.id_profesor
WHERE A.id NOT IN (
    SELECT id_asignatura
    FROM alumno_se_matricula_asignatura
);

-- 7. Devuelve el número total de **alumnas** que hay.

# Se usa COUNT en el indice de la tabla para contar todas las ocurrencias donde el sexo sea M
SELECT COUNT(id) AS TotalAlumnas
FROM alumno 
WHERE sexo = "M";

-- Cuantos alumnos nacieron en 1999

# Se cuentan las ocurrencias de todos los estudiantes que su fecha de nacimiento inicie en 1999

SELECT COUNT(id)
FROM alumno 
WHERE fecha_nacimiento LIKE "1999%";

-- Calcula cuántos profesores hay en cada departamento. El resultado sólo debe mostrar dos columnas, una con el nombre del departamento y otra con el número de profesores que hay en ese departamento. El resultado sólo debe incluir los departamentos que tienen profesores asociados y deberá estar ordenado de mayor a menor por el número de profesores.


# Se hace un inner join para relacionar las tablas y se cuenta con count y group by para determinar cuantos profesores hay

SELECT D.nombre, COUNT(P.id) AS NumeroProfesores
FROM departamento D
INNER JOIN profesor P ON D.id = P.id_departamento
GROUP BY D.nombre
ORDER BY COUNT(P.id) DESC;

-- Devuelve un listado con todos los departamentos y el número de profesores que hay en cada uno de ellos. Tenga en cuenta que pueden existir departamentos que no tienen profesores asociados. Estos departamentos también tienen que aparecer en el listado.

# Misma consulta de la anterior, en esta hacemos un left join en vez de inner para incluir todos los deptos
SELECT D.nombre, COUNT(P.id) AS NumeroProfesores
FROM departamento D
LEFT JOIN profesor P ON D.id = P.id_departamento
GROUP BY D.nombre;

-- Devuelve un listado con el nombre de todos los grados existentes en la base de datos y el número de asignaturas que tiene cada uno. Tenga en cuenta que pueden existir grados que no tienen asignaturas asociadas. Estos grados también tienen que aparecer en el listado. El resultado deberá estar ordenado de mayor a menor por el número de asignaturas.

# Se hace un left join desde grado para tener todos los grados y se cuentan las ocurrencias de asignaturas que aparezcan relacionadas
SELECT G.nombre, COUNT(A.id) AS NumAsignaturas
FROM grado G
LEFT JOIN asignatura A ON G.id = A.id_grado
GROUP BY G.nombre
ORDER BY COUNT(A.id) DESC;

-- 12. Devuelve un listado con el nombre de todos los grados existentes en la base de datos y el número de asignaturas que tiene cada uno de los grados que tengan más de `40` asignaturas asociadas.

# Es la misma consulta anterior, se le añade la condicion con un having
SELECT G.nombre, COUNT(A.id) AS NumAsignaturas
FROM grado G
LEFT JOIN asignatura A ON G.id = A.id_grado
GROUP BY G.nombre
HAVING COUNT(A.id) > 40
ORDER BY COUNT(A.id) DESC;

-- Devuelve un listado que muestre el nombre de los grados y la suma del número total de créditos que hay para cada tipo de asignatura. El resultado debe tener tres columnas: nombre del grado, tipo de asignatura y la suma de los créditos de todas las asignaturas que hay de ese tipo. Ordene el resultado de mayor a menor por el número total de crédidos.

# Se usa group by para agrupar los grados y tipos de asignaturas con el fin de poder usar la funcion sum de creditos que es lo que nos pide el problema
SELECT G.nombre, A.tipo, SUM(A.creditos) AS SumaCreditos
FROM grado AS G
INNER JOIN asignatura A ON G.id = A.id_grado
GROUP BY G.nombre, A.tipo
ORDER BY SUM(A.creditos) DESC
;

-- Devuelve un listado que muestre cuántos alumnos se han matriculado de alguna asignatura en cada uno de los cursos escolares. El resultado deberá mostrar dos columnas, una columna con el año de inicio del curso escolar y otra con el número de alumnos matriculados.

# Contamos los ids de alumnos que aparezcan en la tabla que relaciona alumno, asignatura y curso, con el fin de obtener los alumnos que se hayan matriculado en alguna asignatura
SELECT C.anyo_inicio, COUNT(AMA.id_alumno) AS AlumnosMatriculados
FROM alumno_se_matricula_asignatura AMA
INNER JOIN curso_escolar AS C ON AMA.id_curso_escolar = C.id
GROUP BY AMA.id_alumno, C.anyo_inicio;

-- Devuelve un listado con el número de asignaturas que imparte cada profesor. El listado debe tener en cuenta aquellos profesores que no imparten ninguna asignatura. El resultado mostrará cinco columnas: id, nombre, primer apellido, segundo apellido y número de asignaturas. El resultado estará ordenado de mayor a menor por el número de asignaturas.

SELECT P.id, P.nombre, P.apellido1, P.apellido2, COUNT(A.id) AS NumAsignaturas
FROM profesor P
LEFT JOIN asignatura A ON P.id = A.id_profesor
GROUP BY P.id
ORDER BY COUNT(A.id) DESC
;

-- Devuelve todos los datos del alumno más joven.
# Se hace un ordenamiento por fecha y se limita a uno solo para obtener el mas joven
SELECT * 
FROM alumno
ORDER BY fecha_nacimiento DESC LIMIT 1;

-- Devuelve un listado con los profesores que no están asociados a un departamento.

# No hay profesores que no esten asociados a un departamento porque es un dato nOT NULL
SELECT P.*
FROM profesor P
WHERE id_departamento NOT IN (SELECT id FROM departamento);

-- Devuelve un listado con los departamentos que no tienen profesores asociados.

# Se hace una subconsulta para obtener los id_departamento de cada profesor y luego se devuelve los nombres de los deptos que no estén relacionados con la subconsulta
SELECT D.nombre
FROM departamento D
WHERE D.id NOT IN 
(SELECT P.id_departamento
FROM profesor P
INNER JOIN departamento D ON P.id_departamento = D.id);


-- Devuelve un listado con los profesores que tienen un departamento asociado y que no imparten ninguna asignatura.

# Se hace una subconsulta para tener los profesores que imparten asignaturas y luego se compara con el total de profesores
SELECT P.nombre
FROM profesor P
INNER JOIN departamento AS D ON P.id_departamento = D.id
WHERE P.id NOT IN(
    SELECT P2.id
    FROM asignatura A
    INNER JOIN profesor P2 ON A.id_profesor = P2.id
);

-- Devuelve un listado con las asignaturas que no tienen un profesor asignado.

# Devuelve las asignaturas donde no haya un profesor registrado
SELECT nombre
FROM asignatura
WHERE id_profesor IS NULL;
