-- 1. Registrar un nuevo estudiante
CREATE OR REPLACE PROCEDURE registrar_estudiante(
    p_documento VARCHAR,
    p_nombre VARCHAR,
    p_apellido VARCHAR,
    p_correo VARCHAR,
    p_programa_id INT,
    p_fecha_nacimiento DATE
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validar duplicados
    IF EXISTS (SELECT 1 FROM estudiantes WHERE documento = p_documento OR correo = p_correo) THEN
        RAISE EXCEPTION 'El estudiante con documento % o correo % ya existe.', p_documento, p_correo;
    END IF;

    -- Validar programa
    IF NOT EXISTS (SELECT 1 FROM programas_academicos WHERE id = p_programa_id) THEN
        RAISE EXCEPTION 'El programa académico con ID % no existe.', p_programa_id;
    END IF;

    INSERT INTO estudiantes (documento, nombre, apellido, correo, programa_id, fecha_nacimiento)
    VALUES (p_documento, p_nombre, p_apellido, p_correo, p_programa_id, p_fecha_nacimiento);
    
    RAISE NOTICE 'Estudiante % % registrado exitosamente.', p_nombre, p_apellido;
END;
$$;

-- 2. Matricular un estudiante en un curso
CREATE OR REPLACE PROCEDURE matricular_estudiante(
    p_estudiante_id INT,
    p_curso_id INT,
    p_periodo_id INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_cupo_actual INT;
    v_cupo_max INT;
BEGIN
    -- Validar estudiante activo
    IF NOT EXISTS (SELECT 1 FROM estudiantes WHERE id = p_estudiante_id AND estado = 'Activo') THEN
        RAISE EXCEPTION 'Estudiante ID % no existe o no está activo.', p_estudiante_id;
    END IF;

    -- Validar periodo activo (Opcional, depende de lógca, asumimos que periodo debe existir)
    IF NOT EXISTS (SELECT 1 FROM periodos_academicos WHERE id = p_periodo_id) THEN
        RAISE EXCEPTION 'Periodo ID % no existe.', p_periodo_id;
    END IF;

    -- Validar si ya está matriculado
    IF EXISTS (SELECT 1 FROM matriculas WHERE estudiante_id = p_estudiante_id AND curso_id = p_curso_id AND periodo_id = p_periodo_id) THEN
        RAISE EXCEPTION 'El estudiante ya está matriculado en este curso para el periodo indicado.';
    END IF;

    -- Validar cupo (Opcional simplificado)
    SELECT cupo_maximo INTO v_cupo_max FROM cursos WHERE id = p_curso_id;
    SELECT COUNT(*) INTO v_cupo_actual FROM matriculas WHERE curso_id = p_curso_id AND periodo_id = p_periodo_id;

    IF v_cupo_actual >= v_cupo_max THEN
        RAISE EXCEPTION 'No hay cupo disponible en el curso ID %.', p_curso_id;
    END IF;

    INSERT INTO matriculas (estudiante_id, curso_id, periodo_id, estado)
    VALUES (p_estudiante_id, p_curso_id, p_periodo_id, 'Inscrito');

    RAISE NOTICE 'Matrícula exitosa para estudiante ID % en curso ID %.', p_estudiante_id, p_curso_id;
END;
$$;

-- 3. Registrar una calificación
CREATE OR REPLACE PROCEDURE registrar_calificacion(
    p_matricula_id INT,
    p_evaluacion_id INT,
    p_valor DECIMAL
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validar rango nota
    IF p_valor < 0.0 OR p_valor > 5.0 THEN
        RAISE EXCEPTION 'La calificación debe estar entre 0.0 y 5.0';
    END IF;

    -- Validar existencia de matrícula y evaluación
    IF NOT EXISTS (SELECT 1 FROM matriculas WHERE id = p_matricula_id) THEN
        RAISE EXCEPTION 'Matrícula ID % no encontrada.', p_matricula_id;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM evaluaciones WHERE id = p_evaluacion_id) THEN
        RAISE EXCEPTION 'Evaluación ID % no encontrada.', p_evaluacion_id;
    END IF;

    -- Insertar o Actualizar (Upsert)
    INSERT INTO calificaciones (matricula_id, evaluacion_id, valor)
    VALUES (p_matricula_id, p_evaluacion_id, p_valor)
    ON CONFLICT (matricula_id, evaluacion_id) 
    DO UPDATE SET valor = EXCLUDED.valor, fecha_registro = CURRENT_TIMESTAMP;

    RAISE NOTICE 'Calificación registrada: %', p_valor;
END;
$$;

-- 4. Calcular promedio académico
CREATE OR REPLACE PROCEDURE calcular_promedio_estudiante(
    IN p_estudiante_id INT,
    INOUT p_promedio DECIMAL
)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT COALESCE(AVG(c.valor), 0.0)
    INTO p_promedio
    FROM calificaciones c
    JOIN matriculas m ON c.matricula_id = m.id
    WHERE m.estudiante_id = p_estudiante_id;
END;
$$;

-- 5. Generar certificación académica
CREATE OR REPLACE PROCEDURE generar_certificacion(
    p_estudiante_id INT,
    p_periodo_id INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_cursos_aprobados INT;
BEGIN
    -- Validar que no exista cert previa
    IF EXISTS (SELECT 1 FROM certificaciones WHERE estudiante_id = p_estudiante_id AND periodo_id = p_periodo_id AND tipo = 'Certificado Notas') THEN
        RAISE EXCEPTION 'Ya existe un certificado de notas para este estudiante en el periodo %.', p_periodo_id;
    END IF;

    -- Contar cursos aprobados
    SELECT COUNT(*) INTO v_cursos_aprobados
    FROM matriculas m
    JOIN calificaciones c ON m.id = c.matricula_id
    WHERE m.estudiante_id = p_estudiante_id 
      AND m.periodo_id = p_periodo_id
      AND c.valor >= 3.0; -- Lógica simplificada de aprobación por nota individual

    IF v_cursos_aprobados = 0 THEN
       RAISE NOTICE 'Advertencia: El estudiante no tiene cursos aprobados, se generará certificado pero vacío o con reprobados.';
    END IF;

    INSERT INTO certificaciones (estudiante_id, periodo_id, tipo, contenido)
    VALUES (p_estudiante_id, p_periodo_id, 'Certificado Notas', 'Certificado generado automáticamente por el sistema.');

    RAISE NOTICE 'Certificación generada para estudiante ID %.', p_estudiante_id;
END;
$$;

