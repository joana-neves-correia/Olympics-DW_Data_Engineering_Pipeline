/*
==============================================
Object:  TABELA FACT OLIMPIADAS
==============================================
*/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE Fact_Olimpiadas(
    ID_column INT IDENTITY(1,1) PRIMARY KEY,
    ID_Atleta INT NOT NULL,
    NOC VARCHAR(50) NOT NULL,
    Games VARCHAR(50) NOT NULL,
    ID_Mod INT NOT NULL,
    Medal VARCHAR(50) NULL,
    [DW_row_checksum] [varchar](200) NULL,
	[DW_run_id] [varchar](50) NULL,
	[DW_updated_on] [datetime] NULL,
	[DW_source_system] [varchar](50) NULL,
);
GO

/*
==============================================
Object:  FOREIGN KEYS FACT OLIMPIADAS
==============================================
*/
ALTER TABLE Fact_Olimpiadas
ADD CONSTRAINT FK_Fact_Olimpiadas_Dim_Atleta
FOREIGN KEY (ID_Atleta) REFERENCES Dim_Atleta(ID_Atleta);
GO

ALTER TABLE Fact_Olimpiadas
ADD CONSTRAINT FK_Fact_Olimpiadas_Dim_Comites
FOREIGN KEY (NOC) REFERENCES Dim_Comites(NOC);
GO

ALTER TABLE Fact_Olimpiadas
ADD CONSTRAINT FK_Fact_Olimpiadas_Dim_Olimpiadas
FOREIGN KEY (Games) REFERENCES Dim_Olimpiadas(Games);
GO

ALTER TABLE Fact_Olimpiadas
ADD CONSTRAINT FK_Fact_Olimpiadas_Dim_Modalidades
FOREIGN KEY (ID_Mod) REFERENCES Dim_Modalidades(ID_Mod);
GO

/*
==============================================
Object:  TABELA STAGING FACT OLIMPIADAS
==============================================
*/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE Fact_Staging_Olimpiadas(
    ID_Atleta INT NOT NULL,
    NOC CHAR(50) NOT NULL,
    Games VARCHAR(50) NOT NULL,
    ID_Mod INT NOT NULL,
    Medal VARCHAR(50) NULL,
    [DW_row_checksum] [varchar](200) NULL,
	[DW_run_id] [varchar](50) NULL,
	[DW_updated_on] [datetime] NULL,
	[DW_source_system] [varchar](50) NULL,
);
GO

/*
==============================================
Object:  TRIGGER STAGING FACT OLIMPIADAS
==============================================
*/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[trg_Insert_Fact_Staging_Olimpiadas_Checksum]
ON Fact_Staging_Olimpiadas
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE S
    SET S.DW_row_checksum = CONVERT(
                                VARCHAR(64),
                                HASHBYTES(
                                    'MD5',
                                    CONCAT(
                                        ISNULL(CAST(S.ID_Atleta AS VARCHAR(50)), ''),
                                        ISNULL(S.NOC, ''),
                                        ISNULL(S.Games, ''),
                                        ISNULL(CAST(S.ID_Mod AS VARCHAR(50)), ''),
                                        ISNULL(S.Medal, '')
                                    )
                                ),
                                2
                            )
    FROM Fact_Staging_Olimpiadas S
    INNER JOIN inserted I
        ON S.ID_Atleta = I.ID_Atleta
       AND S.NOC = I.NOC
       AND S.Games = I.Games
       AND S.ID_Mod = I.ID_Mod
       AND ISNULL(S.Medal, '') = ISNULL(I.Medal, '');
END;
GO

/*
==============================================
Object:  MERGE TABLE FACT OLIMPIADAS - UPDATE
==============================================
*/
MERGE dbo.Fact_Olimpiadas AS T

USING (
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY ID_Atleta, NOC, Games, ID_Mod, Medal
                   ORDER BY ID_Atleta
               ) AS rn
        FROM dbo.Fact_Staging_Olimpiadas
    ) X
    WHERE rn = 1
) AS S

ON T.ID_Atleta = S.ID_Atleta
AND T.NOC = S.NOC
AND T.Games = S.Games
AND T.ID_Mod = S.ID_Mod
AND T.DW_row_checksum <> S.DW_row_checksum

WHEN MATCHED THEN
    UPDATE SET
        T.ID_Atleta = S.ID_Atleta,
        T.NOC = S.NOC,
        T.Games = S.Games,
        T.ID_Mod = S.ID_Mod,
        T.Medal = S.Medal,
        T.DW_row_checksum = S.DW_row_checksum,
        T.DW_run_id = S.DW_run_id,
        T.DW_updated_on = S.DW_updated_on,
        T.DW_source_system = S.DW_source_system;

MERGE dbo.Fact_Olimpiadas AS T

USING (
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY ID_Atleta, NOC, Games, ID_Mod, Medal
                   ORDER BY ID_Atleta
               ) AS rn
        FROM dbo.Fact_Staging_Olimpiadas
    ) X
    WHERE rn = 1
) AS S

ON T.ID_Atleta = S.ID_Atleta
AND T.NOC = S.NOC
AND T.Games = S.Games
AND T.ID_Mod = S.ID_Mod

WHEN NOT MATCHED THEN
    INSERT (
        ID_Atleta,
        NOC,
        Games,
        ID_Mod,
        Medal,
        DW_row_checksum,
        DW_run_id,
        DW_updated_on,
        DW_source_system
    )
    VALUES (
        S.ID_Atleta,
        S.NOC,
        S.Games,
        S.ID_Mod,
        S.Medal,
        S.DW_row_checksum,
        S.DW_run_id,
        S.DW_updated_on,
        S.DW_source_system
    );
GO