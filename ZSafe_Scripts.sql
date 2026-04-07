IF DB_ID('ZSafeDb') IS NULL
	CREATE DATABASE ZSafeDb;
GO

USE ZSafeDb;
GO

CREATE TABLE dbo.Zombies (
	Id INT IDENTITY(1,1) NOT NULL,
	Tipo VARCHAR(50) NOT NULL,
	TiempoDisparo DECIMAL(5,2) NOT NULL,
	BalasNecesarias SMALLINT NOT NULL,
	NivelAmenaza TINYINT NOT NULL,
	CONSTRAINT PK_Zombies PRIMARY KEY (Id),
	CONSTRAINT UQ_Zombies_Tipo UNIQUE (Tipo),
	CONSTRAINT CK_Zombies_TiempoDisparo CHECK (TiempoDisparo > 0),
	CONSTRAINT CK_Zombies_BalasNecesarias CHECK (BalasNecesarias > 0),
	CONSTRAINT CK_Zombies_NivelAmenaza CHECK (NivelAmenaza BETWEEN 0 AND 255)
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
	CONSTRAINT FK_Eliminados_Zombies FOREIGN KEY (ZombieId) REFERENCES dbo.Zombies(Id),
	CONSTRAINT FK_Eliminados_Simulaciones FOREIGN KEY (SimulacionId) REFERENCES dbo.Simulaciones(Id),
	CONSTRAINT CK_Eliminados_PuntosObtenidos CHECK (PuntosObtenidos >= 0)
);
GO

INSERT INTO dbo.Zombies (Tipo, TiempoDisparo, BalasNecesarias, NivelAmenaza) VALUES
('Walker', 1.50, 1, 2),
('Runner', 0.75, 2, 5),
('Spitter', 2.25, 2, 6),
('Bloater', 4.50, 3, 8),
('Alpha', 5.75, 4, 10);
GO

INSERT INTO dbo.Simulaciones (TiempoDisponible, BalasDisponibles) VALUES
(90, 30),
(60, 18);
GO

IF NOT EXISTS (
	SELECT 1
	FROM sys.indexes
	WHERE name = 'IX_Eliminados_SimulacionId'
	  AND object_id = OBJECT_ID('dbo.Eliminados')
)
	CREATE NONCLUSTERED INDEX IX_Eliminados_SimulacionId ON dbo.Eliminados(SimulacionId);
GO

IF NOT EXISTS (
	SELECT 1
	FROM sys.indexes
	WHERE name = 'IX_Eliminados_ZombieId'
	  AND object_id = OBJECT_ID('dbo.Eliminados')
)
	CREATE NONCLUSTERED INDEX IX_Eliminados_ZombieId ON dbo.Eliminados(ZombieId);
GO

SELECT
	s.Id AS SimulacionId,
	s.Fecha,
	z.Tipo AS TipoZombie,
	COUNT(e.Id) AS TotalZombiesEliminados,
	ISNULL(SUM(e.PuntosObtenidos), 0) AS PuntajeTotal
FROM dbo.Simulaciones s
LEFT JOIN dbo.Eliminados e ON s.Id = e.SimulacionId
LEFT JOIN dbo.Zombies z ON e.ZombieId = z.Id
GROUP BY s.Id, s.Fecha, z.Tipo
ORDER BY s.Id DESC, PuntajeTotal DESC;
GO

IF OBJECT_ID('dbo.Auditoria_Resultados', 'U') IS NULL
BEGIN
	CREATE TABLE dbo.Auditoria_Resultados (
		Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
		EliminadoId BIGINT NULL,
		Accion VARCHAR(20) NOT NULL,
		PuntosAntiguos INT NULL,
		PuntosNuevos INT NULL,
		Usuario VARCHAR(100) NOT NULL,
		Fecha DATETIME2(3) NOT NULL CONSTRAINT DF_Auditoria_Resultados_Fecha DEFAULT SYSDATETIME()
	);
END;
GO

CREATE OR ALTER TRIGGER dbo.TR_Auditoria_Eliminados
ON dbo.Eliminados
AFTER UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
	BEGIN
		INSERT INTO dbo.Auditoria_Resultados (EliminadoId, Accion, PuntosAntiguos, PuntosNuevos, Usuario)
		SELECT d.Id, 'UPDATE', d.PuntosObtenidos, i.PuntosObtenidos, SYSTEM_USER
		FROM deleted d
		INNER JOIN inserted i ON d.Id = i.Id
		WHERE d.PuntosObtenidos <> i.PuntosObtenidos;
	END

	IF NOT EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
	BEGIN
		INSERT INTO dbo.Auditoria_Resultados (EliminadoId, Accion, PuntosAntiguos, PuntosNuevos, Usuario)
		SELECT d.Id, 'DELETE', d.PuntosObtenidos, NULL, SYSTEM_USER
		FROM deleted d;
	END
END;
GO
