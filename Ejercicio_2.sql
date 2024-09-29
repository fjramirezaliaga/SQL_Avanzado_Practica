--2. CREACION BASE DE DATOS
DROP TABLE IF EXISTS bootcamps;
DROP TABLE IF EXISTS alumnos;
DROP TABLE IF EXISTS profesores;
DROP TABLE IF EXISTS modulos;
DROP TABLE IF EXISTS bootcamp_mod;

-- Crear tabla bootcamps
CREATE TABLE bootcamps (
    bootcamp_id SERIAL PRIMARY KEY,
    bootcamp_name VARCHAR(50),
    fecha_inicio DATE,
    horas_requeridas INT
);
ALTER TABLE bootcamps
ADD CONSTRAINT unique_bootcamp_name UNIQUE (bootcamp_name);

-- Crear tabla alumnos
CREATE TABLE alumnos (
    alumno_id SERIAL PRIMARY KEY,
    nombre_alumno VARCHAR(50),
    apellidos_alumno VARCHAR(50),
    bootcamp_id INT,
    fecha_nacimiento date,
    email_alumno VARCHAR(100),
    FOREIGN KEY(bootcamp_id) REFERENCES bootcamps(bootcamp_id)
);
ALTER TABLE alumnos
ADD CONSTRAINT unique_email_alumno UNIQUE (email_alumno);

-- Crear tabla profesores
CREATE TABLE profesores (
    profesor_id SERIAL PRIMARY KEY,
    nombre_profesor VARCHAR(50),
    apellidos_profesor VARCHAR(50),
    email_profesor VARCHAR(100)
);

ALTER TABLE profesores
ADD CONSTRAINT unique_email_profesor UNIQUE (email_profesor);

-- Crear tabla modulos
CREATE TABLE modulos (
    module_id SERIAL PRIMARY KEY,
    module_name VARCHAR(50),
    profesor_id INT,
    inicio_modulo DATE,
    fin_modulo DATE,
    FOREIGN KEY(profesor_id) REFERENCES profesores(profesor_id)
);
ALTER TABLE modulos
ADD CONSTRAINT unique_module_name UNIQUE (module_name);

-- Crear tabla bootcamp_mod
CREATE TABLE bootcamp_mod (
    bootcamp_mod_id SERIAL PRIMARY KEY,
    bootcamp_id INT,
    module_id INT,
    FOREIGN KEY(bootcamp_id) REFERENCES bootcamps(bootcamp_id),    
    FOREIGN KEY(module_id) REFERENCES modulos(module_id)
);

INSERT INTO bootcamps(bootcamp_name, fecha_inicio, horas_requeridas) VALUES
('BigData & AI','2024-09-01',400),
('ML & AI','2024-08-18',450),
('Java','2024-09-30',300),
('Ciber Seguridad','2024-09-01',350),
('Blockchain','2024-09-25',325),
('Desarrollo Web','2024-01-09',250);


INSERT INTO alumnos(nombre_alumno, apellidos_alumno, bootcamp_id, fecha_nacimiento, email_alumno) VALUES
('Miguel','Pérez Santos',2,'1985-06-25','miguel.perez.perez@gmail.com'),
('Alba','Rios Lozano',1,'1994-07-31','alba.rioslozano@gmail.com'),
('Samuel','Rivera Ortiz',4,'1990-05-01','samu.rivera.o@gmail.com'),
('María','Vizcaíno Llamas',5,'2000-01-19','mariavizcaino@hotmail.com'),
('Gabriel','Sánchez Rodríguez',2,'1996-12-19','gabi.sanchez@outlook.com'),
('Filipa','Duarte',2,'1988-11-20','filipa.x.duarte@jpmorgan.com'),
('Valentina','García Pizarro',3,'1993-10-12','valen.gar.piz@hotmail.com'),
('Antonio','Cortés Zamora',3,'1989-03-17','corteszamora.toni@gmail.com'),
('Juan Antonio','Avila García',3,'1991-09-15','juan.avila@outlook.com'),
('Andres','Ramon Garcia',3,'1988-06-24','andreu.ramon@hotmail.com'),
('Marcos','Castillo Cuello',3,'1991-12-17','marc.c.castillo@gmail.com'),
('Cristian','López López',3,'1990-01-28','chris.l.lopez@outlook.com'),
('Eva','Prados Casado',3,'1999-02-12','evita.prados@gmail.com');


INSERT INTO profesores(nombre_profesor, apellidos_profesor, email_profesor) VALUES
('Manuel','Lendoiro Rivera','manuel.x.lendoiro@keepcoding.com'),
('Isabel','Muñiz Arteaga','isabel.x.muniz@keepcoding.com'),
('Alex','Ferguson','alex.ferguson.s@keepcoding.com'),
('José','Sanchez Feijoo','jose.contrad@keepcoding.com');


INSERT INTO modulos(module_name, profesor_id, inicio_modulo, fin_modulo) VALUES
('SQL Avanzado',1,'2024-09-15','2024-10-01'),
('Informática para principantes',3,'2024-07-15','2024-09-01'),
('Protección de datos',4,'2024-09-15','2024-09-22'),
('Visualización de datos',2,'2024-10-02','2024-10-22'),
('Matemáticas 101',3,'2024-10-02','2024-10-22');


INSERT INTO bootcamp_mod(bootcamp_id, module_id) VALUES
(1,1),
(3,2),
(1,3),
(2,3),
(3,4),
(4,3),
(5,3),
(1,4),
(2,4),
(6,2),
(4,5);

--En que módulos está matriculada el alumno_id 2?
SELECT  alumnos.nombre_alumno,
		alumnos.apellidos_alumno,
		bootcamps.bootcamp_name,
		modulos.module_name
FROM alumnos
LEFT 
JOIN bootcamps
	ON alumnos.bootcamp_id = bootcamps.bootcamp_id
LEFT
JOIN bootcamp_mod
	ON bootcamps.bootcamp_id = bootcamp_mod.bootcamp_id
LEFT 
JOIN modulos
	ON bootcamp_mod.module_id = modulos.module_id
WHERE alumnos.alumno_id = 2


--DROP TABLE "public"."alumnos" CASCADE;
--DROP TABLE "public"."bootcamp_mod" CASCADE;
--DROP TABLE "public"."bootcamps" CASCADE;
--DROP TABLE "public"."modulos" CASCADE;
--DROP TABLE "public"."profesores" CASCADE;
