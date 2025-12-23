-- 05_queries.sql
-- Consultas Complejas para EduTech Plus

-- 1. Obtener el listado de estudiantes cuyo promedio general sea superior al promedio general de TODOS los estudiantes.
WITH PromediosPorEstudiante AS (
    SELECT 
        m.estudiante_id,
        AVG(c.valor) as promedio_individual
    FROM matriculas m
    JOIN calificaciones c ON m.id = c.matricula_id
    GROUP BY m.estudiante_id
),
PromedioGlobal AS (
    SELECT AVG(promedio_individual) as promedio_todos FROM PromediosPorEstudiante
)
SELECT 
    e.nombre,
    e.apellido,
    ppe.promedio_individual
FROM enlaces e
JOIN PromediosPorEstudiante ppe ON e.id = ppe.estudiante_id
cross join PromedioGlobal pg
WHERE ppe.promedio_individual > pg.promedio_todos;
-- Corrección: "enlaces" no existe, es "estudiantes".

-- CORREGIDO CONSULTA 1:
WITH PromediosPorEstudiante AS (
    SELECT 
        m.estudiante_id,
        AVG(c.valor) as promedio_individual
    FROM matriculas m
    JOIN calificaciones c ON m.id = c.matricula_id
    GROUP BY m.estudiante_id
)
SELECT 
    e.nombre,
    e.apellido,
    ppe.promedio_individual
FROM estudiantes e
JOIN PromediosPorEstudiante ppe ON e.id = ppe.estudiante_id
WHERE ppe.promedio_individual > (SELECT AVG(promedio_individual) FROM PromediosPorEstudiante);


-- 2. Listar los cursos con mayor cantidad de estudiantes matriculados (Top 5 desc).
SELECT 
    c.nombre AS curso,
    COUNT(m.id) AS total_estudiantes
FROM cursos c
JOIN matriculas m ON c.id = m.curso_id
GROUP BY c.id, c.nombre
ORDER BY total_estudiantes DESC
LIMIT 5;


-- 3. Calcular ingresos totales por periodo académico.
SELECT 
    pa.nombre AS periodo,
    COALESCE(SUM(p.monto), 0) AS total_ingresos
FROM periodos_academicos pa
LEFT JOIN pagos p ON pa.id = p.periodo_id
GROUP BY pa.id, pa.nombre
ORDER BY pa.fecha_inicio;


-- 4. Identificar estudiantes SIN pagos registrados.
SELECT 
    e.id,
    e.nombre,
    e.apellido,
    e.documento
FROM estudiantes e
LEFT JOIN pagos p ON e.id = p.estudiante_id
WHERE p.id IS NULL;


-- 5. Docentes con más cursos asignados.
SELECT 
    d.nombre,
    d.apellido,
    COUNT(ad.curso_id) AS total_cursos_asignados
FROM docentes d
JOIN asignaciones_docentes ad ON d.id = ad.docente_id
GROUP BY d.id, d.nombre, d.apellido
ORDER BY total_cursos_asignados DESC;


-- 6. Historial académico completo (Similar a la vista pero en consulta directa).
SELECT 
    e.nombre || ' ' || e.apellido AS estudiante,
    c.nombre AS curso,
    pa.nombre AS periodo,
    m.estado,
    AVG(cal.valor) as nota_final
FROM estudiantes e
JOIN matriculas m ON e.id = m.estudiante_id
JOIN cursos c ON m.curso_id = c.id
JOIN periodos_academicos pa ON m.periodo_id = pa.id
LEFT JOIN calificaciones cal ON m.id = cal.matricula_id
GROUP BY e.id, c.id, pa.id, m.estado, m.id;


-- 7. Estudiantes que han aprobado TODOS los cursos matriculados.
-- (Asumiendo aprobación si promedio notas > 3.0 por matricula)
SELECT 
    e.nombre,
    e.apellido
FROM estudiantes e
WHERE NOT EXISTS (
    -- Subconsulta busca si existe ALGUNA matrícula reprobada
    -- Para este ejemplo, reprobado es nota < 3.0 o estado 'Reprobado'
    SELECT 1 
    FROM matriculas m
    LEFT JOIN calificaciones cal ON m.id = cal.matricula_id -- simplificando: tomamos notas individuales promedio
    WHERE m.estudiante_id = e.id
    GROUP BY m.id
    HAVING AVG(COALESCE(cal.valor, 0)) < 3.0
);


-- 8. Programas académicos con mayor número de estudiantes activos.
SELECT 
    p.nombre AS programa,
    COUNT(e.id) AS estudiantes_activos
FROM programas_academicos p
JOIN estudiantes e ON p.id = e.programa_id
WHERE e.estado = 'Activo'
GROUP BY p.id, p.nombre
ORDER BY estudiantes_activos DESC;


-- 9. Reporte clasificado por rendimiento (CASE WHEN).
SELECT 
    e.nombre,
    e.apellido,
    AVG(c.valor) AS promedio,
    CASE 
        WHEN AVG(c.valor) >= 4.5 THEN 'Alto Rendimiento'
        WHEN AVG(c.valor) >= 3.0 THEN 'Rendimiento Medio'
        ELSE 'Rendimiento Bajo'
    END AS clasificacion
FROM estudiantes e
JOIN matriculas m ON e.id = m.estudiante_id
JOIN calificaciones c ON m.id = c.matricula_id
GROUP BY e.id, e.nombre, e.apellido;


-- 10. Periodos donde el ingreso superó el promedio histórico.
WITH IngresosPorPeriodo AS (
    SELECT periodo_id, SUM(monto) as total FROM pagos GROUP BY periodo_id
),
PromedioIngresos AS (
    SELECT AVG(total) as media_historica FROM IngresosPorPeriodo
)
SELECT 
    pa.nombre,
    ipp.total
FROM periodos_academicos pa
JOIN IngresosPorPeriodo ipp ON pa.id = ipp.periodo_id
WHERE ipp.total > (SELECT media_historica FROM PromedioIngresos);
