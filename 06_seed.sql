-- 06_seed.sql
-- Datos de prueba para EduTech Plus

-- Programas
INSERT INTO programas_academicos (codigo, nombre, nivel, duracion_semestres) VALUES
('ING-SIS', 'Ingeniería de Sistemas', 'Pregrado', 10),
('DER', 'Derecho', 'Pregrado', 10),
('MED', 'Medicina', 'Pregrado', 12),
('MBA', 'Maestría en Administración', 'Posgrado', 4),
('DIS', 'Diseño Gráfico', 'Pregrado', 8);

-- Periodos
INSERT INTO periodos_academicos (nombre, fecha_inicio, fecha_fin, activo) VALUES
('2024-1', '2024-02-01', '2024-06-30', FALSE),
('2024-2', '2024-08-01', '2024-12-15', TRUE);

-- Docentes (5)
INSERT INTO docentes (documento, nombre, apellido, correo, especialidad) VALUES
('D001', 'Alan', 'Turing', 'alan@edutech.com', 'Algoritmos'),
('D002', 'Grace', 'Hopper', 'grace@edutech.com', 'Compiladores'),
('D003', 'Ada', 'Lovelace', 'ada@edutech.com', 'Programación'),
('D004', 'Richard', 'Feynman', 'richard@edutech.com', 'Física'),
('D005', 'Marie', 'Curie', 'marie@edutech.com', 'Química');

-- Cursos (10)
INSERT INTO cursos (codigo, nombre, creditos, programa_id) VALUES
('CS101', 'Intro a Programación', 3, 1),
('CS102', 'Estructuras de Datos', 4, 1),
('LW101', 'Derecho Romano', 3, 2),
('LW102', 'Constitucional', 4, 2),
('MD101', 'Anatomía', 5, 3),
('MD102', 'Biología Celular', 4, 3),
('AD201', 'Gerencia Estratégica', 3, 4),
('AD202', 'Finanzas Corporativas', 3, 4),
('DS101', 'Teoría del Color', 2, 5),
('DS102', 'Tipografía', 2, 5);

-- Asignaciones Docentes
INSERT INTO asignaciones_docentes (docente_id, curso_id, periodo_id) VALUES
(1, 1, 2), (1, 2, 2),
(2, 1, 2),
(3, 2, 2),
(4, 7, 2);

-- Estudiantes (20)
INSERT INTO estudiantes (documento, nombre, apellido, correo, programa_id) VALUES
('1001', 'Juan', 'Perez', 'juan.perez@mail.com', 1),
('1002', 'Maria', 'Gomez', 'maria.gomez@mail.com', 1),
('1003', 'Carlos', 'Lopez', 'carlos.lopez@mail.com', 1),
('1004', 'Ana', 'Rodriguez', 'ana.rod@mail.com', 2),
('1005', 'Luis', 'Martinez', 'luis.mar@mail.com', 2),
('1006', 'Laura', 'Hernandez', 'laura.her@mail.com', 3),
('1007', 'Pedro', 'Garcia', 'pedro.gar@mail.com', 3),
('1008', 'Sofia', 'Diaz', 'sofia.diaz@mail.com', 4),
('1009', 'Jorge', 'Torres', 'jorge.tor@mail.com', 5),
('1010', 'Elena', 'Ruiz', 'elena.ruiz@mail.com', 5),
('1011', 'Miguel', 'Vargas', 'miguel.var@mail.com', 1),
('1012', 'Lucia', 'Castro', 'lucia.cas@mail.com', 1),
('1013', 'Diego', 'Rios', 'diego.rios@mail.com', 2),
('1014', 'Paula', 'Mendoza', 'paula.men@mail.com', 3),
('1015', 'Andres', 'Silva', 'andres.sil@mail.com', 4),
('1016', 'Camila', 'Orr', 'camila.orr@mail.com', 5),
('1017', 'Victor', 'Hugo', 'victor.hugo@mail.com', 1),
('1018', 'Isabel', 'Allende', 'isabel.all@mail.com', 2),
('1019', 'Gabriel', 'Marquez', 'gabriel.mar@mail.com', 3),
('1020', 'Julio', 'Cortazar', 'julio.cor@mail.com', 4);

-- Matriculas (Algunos ejemplos)
-- Matricular a Juan (1) en Intro Prog (1) periodo 2
INSERT INTO matriculas (estudiante_id, curso_id, periodo_id) VALUES (1, 1, 2);
-- Matricular a Maria (2) en Estructuras (2) periodo 2
INSERT INTO matriculas (estudiante_id, curso_id, periodo_id) VALUES (2, 2, 2);
-- Matricular a Carlos (3) en Intro Prog (1) periodo 2
INSERT INTO matriculas (estudiante_id, curso_id, periodo_id) VALUES (3, 1, 2);

-- Evaluaciones para Curso 1 periodo 2
INSERT INTO evaluaciones (curso_id, periodo_id, nombre, porcentaje) VALUES 
(1, 2, 'Parcial 1', 30.0),
(1, 2, 'Final', 40.0),
(1, 2, 'Talleres', 30.0);

-- Calificaciones
-- Juan en Curso 1
INSERT INTO calificaciones (matricula_id, evaluacion_id, valor) VALUES 
(1, 1, 4.5), (1, 2, 3.8);

-- Pagos
INSERT INTO pagos (estudiante_id, periodo_id, monto, concepto, metodo_pago) VALUES
(1, 2, 1000.00, 'Matricula Semestre', 'Tarjeta'),
(2, 2, 1000.00, 'Matricula Semestre', 'Efectivo'),
(8, 2, 2500.00, 'Matricula Maestria', 'Transferencia');
