-- 1. Vista de estudiantes con su programa académico
CREATE OR REPLACE VIEW vista_estudiantes_programa AS
SELECT 
    e.id AS estudiante_id,
    e.nombre,
    e.apellido,
    e.correo,
    p.nombre AS programa,
    e.estado
FROM estudiantes e
JOIN programas_academicos p ON e.programa_id = p.id;

-- 2. Vista de cursos con docentes asignados (por periodo activo, asumiendo activo=true en periodos o último periodo)
CREATE OR REPLACE VIEW vista_cursos_docentes AS
SELECT 
    c.codigo AS codigo_curso,
    c.nombre AS nombre_curso,
    d.nombre AS nombre_docente,
    d.apellido AS apellido_docente,
    pa.nombre AS periodo,
    ad.grupo
FROM asignaciones_docentes ad
JOIN cursos c ON ad.curso_id = c.id
JOIN docentes d ON ad.docente_id = d.id
JOIN periodos_academicos pa ON ad.periodo_id = pa.id;

-- 3. Vista de historial académico detallado
CREATE OR REPLACE VIEW vista_historial_academico AS
SELECT 
    e.documento,
    e.nombre || ' ' || e.apellido AS estudiante,
    p.nombre AS programa,
    c.nombre AS curso,
    pa.nombre AS periodo,
    m.estado AS estado_matricula,
    -- Promedio de notas de ese curso en esa matricula
    (SELECT AVG(cal.valor) FROM calificaciones cal WHERE cal.matricula_id = m.id) AS nota_final_calculada
FROM matriculas m
JOIN estudiantes e ON m.estudiante_id = e.id
JOIN programas_academicos p ON e.programa_id = p.id
JOIN cursos c ON m.curso_id = c.id
JOIN periodos_academicos pa ON m.periodo_id = pa.id;

-- 4. Vista de pagos (General)
CREATE OR REPLACE VIEW vista_resumen_pagos AS
SELECT 
    e.documento,
    e.nombre || ' ' || e.apellido AS estudiante,
    pa.nombre AS periodo,
    SUM(p.monto) AS total_pagado
FROM pagos p
JOIN estudiantes e ON p.estudiante_id = e.id
JOIN periodos_academicos pa ON p.periodo_id = pa.id
GROUP BY e.id, e.nombre, e.apellido, pa.nombre;

