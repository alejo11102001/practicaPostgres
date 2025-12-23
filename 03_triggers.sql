-- 03_triggers.sql
-- Triggers para EduTech Plus

-- 1. Trigger de Auditoría de Matrículas
CREATE OR REPLACE FUNCTION auditar_matricula_func() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, usuario, datos_antiguos, datos_nuevos, descripcion)
    VALUES (
        'matriculas',
        TG_OP,
        CURRENT_USER,
        CASE WHEN TG_OP = 'DELETE' THEN row_to_json(OLD) ELSE NULL END,
        CASE WHEN TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN row_to_json(NEW) ELSE NULL END,
        'Acción sobre matrícula. Estudiante: ' || COALESCE(NEW.estudiante_id, OLD.estudiante_id) || ' Curso: ' || COALESCE(NEW.curso_id, OLD.curso_id)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_audto_matriculas
AFTER INSERT OR UPDATE OR DELETE ON matriculas
FOR EACH ROW EXECUTE FUNCTION auditar_matricula_func();

-- 2. Trigger Validación Calificación (Aunque ya tenemos constraint CHECK, el usuario pidió trigger explícito)
CREATE OR REPLACE FUNCTION validar_calificacion_func() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.valor < 0 OR NEW.valor > 5 THEN
        RAISE EXCEPTION 'La calificación no puede ser menor a 0 ni mayor a 5.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_nota
BEFORE INSERT OR UPDATE ON calificaciones
FOR EACH ROW EXECUTE FUNCTION validar_calificacion_func();

-- 3. Trigger Actualizar estado financiero (Simulación)
-- Supongamos que si paga completo un monto X, se marca algo o simplemente se loguea.
-- Vamos a hacer algo útil: Si el pago es recibido, registrar en auditoría financiera específica.
CREATE OR REPLACE FUNCTION auditar_pago_func() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, descripcion, datos_nuevos)
    VALUES ('pagos', 'INSERT', 'Pago recibido por valor de ' || NEW.monto, row_to_json(NEW));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_pago_recibido
AFTER INSERT ON pagos
FOR EACH ROW EXECUTE FUNCTION auditar_pago_func();
