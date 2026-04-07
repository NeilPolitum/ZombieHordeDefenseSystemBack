IF DB_ID('ZSafeDb') IS NULL
BEGIN
    CREATE DATABASE ZSafeDb;
END
GO

USE ZSafeDb;
GO

CREATE TABLE dbo.Zombie (
    Id INT IDENTITY(1,1) NOT NULL,
    Tipo VARCHAR(50) NOT NULL,
    TiempoDisparo DECIMAL(5, 2) NOT NULL,
    BalasNecesarias SMALLINT NOT NULL,
    NivelAmenaza TINYINT NOT NULL,
    CONSTRAINT PK_Zombies PRIMARY KEY (Id),
    CONSTRAINT UQ_Zombies_Tipo UNIQUE (Tipo),
    CONSTRAINT CK_Zombies_TiempoDisparo CHECK (TiempoDisparo > 0),
    CONSTRAINT CK_Zombies_BalasNecesarias CHECK (BalasNecesarias > 0),
    CONSTRAINT CK_Zombies_NivelAmenaza CHECK (NivelAmenaza BETWEEN 1 AND 255)
);
GO

CREATE TABLE dbo.Simulaciones (
    Id INT IDENTITY(1,1) NOT NULL,
    Fecha DATETIME2(3) NOT NULL CONSTRAINT DF_Simulaciones_Fecha DEFAULT SYSDATETIME(),
    TiempoDisponible INT NOT NULL,
    BalasDisponibles INT NOT NULL,
    CONSTRAINT PK_Simulaciones PRIMARY KEY (Id),
    CONSTRAINT CK_Simulaciones_TiempoDisponible CHECK (TiempoDisponible > 0),
    CONSTRAINT CK_Simulaciones_BalasDisponibles CHECK (BalasDisponibles > 0)
);
GO

CREATE TABLE dbo.Eliminados (
    Id BIGINT IDENTITY(1,1) NOT NULL,
    ZombieId INT NOT NULL,
    SimulacionId INT NOT NULL,
    PuntosObtenidos INT NOT NULL,
    [Timestamp] DATETIME2(3) NOT NULL CONSTRAINT DF_Eliminados_Timestamp DEFAULT SYSDATETIME(),
    CONSTRAINT PK_Eliminados PRIMARY KEY (Id),
    CONSTRAINT FK_Eliminados_Zombie FOREIGN KEY (ZombieId) REFERENCES dbo.Zombie(Id),
    CONSTRAINT FK_Eliminados_Simulaciones FOREIGN KEY (SimulacionId) REFERENCES dbo.Simulaciones(Id),
    CONSTRAINT CK_Eliminados_PuntosObtenidos CHECK (PuntosObtenidos >= 0)
)
GO

--Alimentar tablas

IF NOT EXISTS (SELECT 1 FROM dbo.Zombie WHERE Tipo = 'Corredor Alfa')
BEGIN
    INSERT INTO dbo.Zombie (Tipo, TiempoDisparo, BalasNecesarias, NivelAmenaza)
    VALUES ('Corredor Alfa', 1.50, 2, 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Zombie WHERE Tipo = 'Escupeacido')
BEGIN
    INSERT INTO dbo.Zombie (Tipo, TiempoDisparo, BalasNecesarias, NivelAmenaza)
    VALUES ('Escupeacido', 3.25, 3, 4);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Zombie WHERE Tipo = 'Tanque Putrefacto')
BEGIN
    INSERT INTO dbo.Zombie (Tipo, TiempoDisparo, BalasNecesarias, NivelAmenaza)
    VALUES ('Tanque Putrefacto', 6.00, 5, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Zombie WHERE Tipo = 'Rastreador Sombrio')
BEGIN
    INSERT INTO dbo.Zombie (Tipo, TiempoDisparo, BalasNecesarias, NivelAmenaza)
    VALUES ('Rastreador Sombrio', 2.10, 1, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Zombie WHERE Tipo = 'Griton Rabioso')
BEGIN
    INSERT INTO dbo.Zombie (Tipo, TiempoDisparo, BalasNecesarias, NivelAmenaza)
    VALUES ('Griton Rabioso', 4.40, 4, 4);
END
GO

DECLARE @Simulacion1Id INT;

INSERT INTO dbo.Simulaciones (TiempoDisponible, BalasDisponibles)
VALUES (8, 10);

SET @Simulacion1Id = SCOPE_IDENTITY();

INSERT INTO dbo.Eliminados (ZombieId, SimulacionId, PuntosObtenidos)
SELECT Id, @Simulacion1Id, 20
FROM dbo.Zombie
WHERE Tipo = 'Corredor Alfa';

INSERT INTO dbo.Eliminados (ZombieId, SimulacionId, PuntosObtenidos)
SELECT Id, @Simulacion1Id, 35
FROM dbo.Zombie
WHERE Tipo = 'Rastreador Sombrio';

INSERT INTO dbo.Eliminados (ZombieId, SimulacionId, PuntosObtenidos)
SELECT Id, @Simulacion1Id, 45
FROM dbo.Zombie
WHERE Tipo = 'Escupeacido';
GO

DECLARE @Simulacion2Id INT;

INSERT INTO dbo.Simulaciones (TiempoDisponible, BalasDisponibles)
VALUES (12, 14);

SET @Simulacion2Id = SCOPE_IDENTITY();

INSERT INTO dbo.Eliminados (ZombieId, SimulacionId, PuntosObtenidos)
SELECT Id, @Simulacion2Id, 55
FROM dbo.Zombie
WHERE Tipo = 'Tanque Putrefacto';

INSERT INTO dbo.Eliminados (ZombieId, SimulacionId, PuntosObtenidos)
SELECT Id, @Simulacion2Id, 40
FROM dbo.Zombie
WHERE Tipo = 'Griton Rabioso';

INSERT INTO dbo.Eliminados (ZombieId, SimulacionId, PuntosObtenidos)
SELECT Id, @Simulacion2Id, 20
FROM dbo.Zombie
WHERE Tipo = 'Corredor Alfa';
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_Eliminados_SimulacionId'
    AND object_id = OBJECT_ID('dbo.Eliminados')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_Eliminados_SimulacionId ON dbo.Eliminados (SimulacionId);
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_Eliminados_ZombieId'
    AND object_id = OBJECT_ID('dbo.Eliminados')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_Eliminados_ZombieId ON dbo.Eliminados (ZombieId);
END
GO

-- Consulta con LEFT JOIN agrupada por simulacion y tipo de zombie
SELECT
    s.Id AS SimulacionId,
    s.Fecha,
    z.Tipo AS TipoZombie,
    COUNT(e.Id) AS totalZombiesEliminados,
    ISNULL(SUM(e.PuntosObtenidos), 0) AS PuntosTotales
FROM dbo.Simulaciones AS s
LEFT JOIN dbo.Eliminados AS e
    ON s.Id = e.SimulacionId
LEFT JOIN dbo.Zombie AS z
    ON e.ZombieId = z.Id
GROUP BY
    s.Id,
    s.Fecha,
    z.Tipo
ORDER BY
    s.Id DESC,
    PuntosTotales DESC;
GO

-- Validacion del LEFT JOIN:
-- Si existe una simulacion sin registros en Eliminados, debe aparecer igual en el resultado.
SELECT
    s.Id AS SimulacionId,
    s.Fecha,
    ISNULL(z.Tipo, 'SIN ELIMINADOS') AS TipoZombie,
    COUNT(e.Id) AS TotalZombiesEliminados,
    ISNULL(SUM(e.PuntosObtenidos), 0) AS PuntosTotales
FROM dbo.Simulaciones AS s
LEFT JOIN dbo.Eliminados AS e
    ON s.Id = e.SimulacionId
LEFT JOIN dbo.Zombie AS z
    ON e.ZombieId = z.Id
GROUP BY
    s.Id,
    s.Fecha,
    ISNULL(z.Tipo, 'SIN ELIMINADOS')
ORDER BY
    s.Id,
    TipoZombie;
GO

