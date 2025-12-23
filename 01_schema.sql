CREATE TABLE programas_academicos (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    nivel VARCHAR(50) CHECK (nivel IN ('Pregrado', 'Posgrado', 'Educación Continua')),
    duracion_semestres INT CHECK (duracion_semestres > 0),
    estado BOOLEAN DEFAULT TRUE
);

CREATE TABLE docentes (
    id SERIAL PRIMARY KEY,
    documento VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    correo VARCHAR(100) UNIQUE NOT NULL,
    especialidad VARCHAR(100),
    telefono VARCHAR(20)
);

CREATE TABLE estudiantes (
    id SERIAL PRIMARY KEY,
    documento VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    correo VARCHAR(100) UNIQUE NOT NULL,
    fecha_nacimiento DATE,
    direccion VARCHAR(200),
    programa_id INT REFERENCES programas_academicos(id),
    fecha_ingreso DATE DEFAULT CURRENT_DATE,
    estado VARCHAR(20) DEFAULT 'Activo' CHECK (estado IN ('Activo', 'Inactivo', 'Graduado', 'Suspendido'))
);

CREATE TABLE periodos_academicos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(20) NOT NULL UNIQUE, -- Ej: 2024-1
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    activo BOOLEAN DEFAULT FALSE,
    CONSTRAINT chk_fechas CHECK (fecha_fin >= fecha_inicio)
);

CREATE TABLE cursos (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    creditos INT CHECK (creditos > 0),
    programa_id INT REFERENCES programas_academicos(id),
    cupo_maximo INT DEFAULT 30
);

CREATE TABLE asignaciones_docentes (
    id SERIAL PRIMARY KEY,
    docente_id INT REFERENCES docentes(id),
    curso_id INT REFERENCES cursos(id),
    periodo_id INT REFERENCES periodos_academicos(id),
    grupo VARCHAR(10) DEFAULT 'A',
    UNIQUE(docente_id, curso_id, periodo_id, grupo)
);

CREATE TABLE matriculas (
    id SERIAL PRIMARY KEY,
    estudiante_id INT REFERENCES estudiantes(id),
    curso_id INT REFERENCES cursos(id),
    periodo_id INT REFERENCES periodos_academicos(id),
    fecha_matricula TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(20) DEFAULT 'Inscrito' CHECK (estado IN ('Inscrito', 'Cancelado', 'Aprobado', 'Reprobado')),
    UNIQUE(estudiante_id, curso_id, periodo_id)
);

CREATE TABLE evaluaciones (
    id SERIAL PRIMARY KEY,
    curso_id INT REFERENCES cursos(id),
    periodo_id INT REFERENCES periodos_academicos(id), -- Para variar evaluaciones por semestre si es necesario
    nombre VARCHAR(50) NOT NULL, -- Ej: Parcial 1, Final
    porcentaje DECIMAL(5,2) CHECK (porcentaje > 0 AND porcentaje <= 100),
    fecha_programada DATE
);

CREATE TABLE calificaciones (
    id SERIAL PRIMARY KEY,
    matricula_id INT REFERENCES matriculas(id),
    evaluacion_id INT REFERENCES evaluaciones(id),
    valor DECIMAL(4,2) CHECK (valor >= 0 AND valor <= 5.0), -- Escala 0.0 a 5.0
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(matricula_id, evaluacion_id)
);

CREATE TABLE pagos (
    id SERIAL PRIMARY KEY,
    estudiante_id INT REFERENCES estudiantes(id),
    periodo_id INT REFERENCES periodos_academicos(id),
    monto DECIMAL(12,2) CHECK (monto >= 0),
    fecha_pago TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    concepto VARCHAR(100) NOT NULL,
    metodo_pago VARCHAR(50) -- Efectivo, Tarjeta, Transferencia
);

CREATE TABLE certificaciones (
    id SERIAL PRIMARY KEY,
    estudiante_id INT REFERENCES estudiantes(id),
    periodo_id INT REFERENCES periodos_academicos(id),
    fecha_emision DATE DEFAULT CURRENT_DATE,
    codigo_verificacion UUID DEFAULT gen_random_uuid(),
    tipo VARCHAR(50) NOT NULL, -- Certificado Notas, Diploma, Constancia
    contenido TEXT -- Resumen o detalle textual si se requiere
);

CREATE TABLE auditoria (
    id SERIAL PRIMARY KEY,
    tabla_afectada VARCHAR(50),
    accion VARCHAR(20), -- INSERT, UPDATE, DELETE
    usuario VARCHAR(50) DEFAULT CURRENT_USER,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_origen VARCHAR(50),
    datos_antiguos JSONB,
    datos_nuevos JSONB,
    descripcion TEXT
);

