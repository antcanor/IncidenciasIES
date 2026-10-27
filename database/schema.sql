-- ==============================================================
-- Esquema de Base de Datos SQLite: IncidenciasIES
-- ==============================================================
-- Activar soporte para claves foráneas en SQLite
PRAGMA foreign_keys = ON;

-- --------------------------------------------------------------
-- Tabla: aula
-- --------------------------------------------------------------
CREATE TABLE IF NOT EXISTS aula (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL UNIQUE,
    planta INTEGER NOT NULL
);

-- --------------------------------------------------------------
-- Tabla: equipo
-- --------------------------------------------------------------
CREATE TABLE IF NOT EXISTS equipo (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    aula_id INTEGER NOT NULL,
    tipo TEXT NOT NULL,
    codigo TEXT NOT NULL UNIQUE,
    FOREIGN KEY (aula_id) REFERENCES aula(id) 
        ON UPDATE CASCADE 
        ON DELETE RESTRICT
);

-- --------------------------------------------------------------
-- Tabla: incidencia
-- --------------------------------------------------------------
CREATE TABLE IF NOT EXISTS incidencia (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    equipo_id INTEGER NOT NULL,
    descripcion TEXT NOT NULL,
    prioridad TEXT NOT NULL CHECK(prioridad IN ('BAJA', 'MEDIA', 'ALTA', 'URGENTE')),
    estado TEXT NOT NULL CHECK(estado IN ('ABIERTA', 'EN_PROCESO', 'RESUELTA', 'CERRADA')),
    fecha TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
    FOREIGN KEY (equipo_id) REFERENCES equipo(id) 
        ON UPDATE CASCADE 
        ON DELETE CASCADE
);

-- --------------------------------------------------------------
-- Tabla: comentario
-- --------------------------------------------------------------
CREATE TABLE IF NOT EXISTS comentario (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    incidencia_id INTEGER NOT NULL,
    fecha TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
    texto TEXT NOT NULL,
    FOREIGN KEY (incidencia_id) REFERENCES incidencia(id) 
        ON UPDATE CASCADE 
        ON DELETE CASCADE
);

-- --------------------------------------------------------------
-- Índices para optimizar búsquedas y navegación por FK
-- --------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_equipo_aula_id ON equipo(aula_id);
CREATE INDEX IF NOT EXISTS idx_incidencia_equipo_id ON incidencia(equipo_id);
CREATE INDEX IF NOT EXISTS idx_incidencia_estado ON incidencia(estado);
CREATE INDEX IF NOT EXISTS idx_comentario_incidencia_id ON comentario(incidencia_id);
