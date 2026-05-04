/*
==============================================
Object:  TABELA DIMENSÃO OLIMPIADAS   
============================================== */
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE Dim_Olimpiadas(
	ID_Olimpiadas INT IDENTITY(1,1) PRIMARY KEY,
    Games VARCHAR(50) UNIQUE NOT NULL,
    Year VARCHAR(50) NULL,
    Season VARCHAR(50) NULL,
    City VARCHAR(100) NULL,
	[DW_row_checksum] [varchar](200) NULL,
	[DW_run_id] [varchar](50) NULL,
	[DW_updated_on] [datetime] NULL,
	[DW_source_system] [varchar](50) NULL,
);

/*
============================================== 
Object:  TABELA STAGING OLIMPIADAS
============================================== */
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE Dim_Staging_Olimpiadas(
    Games VARCHAR(50) NOT NULL,
    Year VARCHAR(50) NULL,
    Season VARCHAR(50) NULL,
    City VARCHAR(100) NULL,
	[DW_row_checksum] [varchar](200) NULL,
	[DW_run_id] [varchar](50) NULL,
	[DW_updated_on] [datetime] NULL,
	[DW_source_system] [varchar](50) NULL,
);

/*
============================================== 
Object:  TRIGGER STAGING OLIMPIADAS
============================================== */
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[trg_Insert_Dim_Staging_Olimpiadas_Checksum]
ON Dim_Staging_Olimpiadas
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Dim_Staging_Olimpiadas
    SET Dim_Staging_Olimpiadas.DW_row_checksum = CONVERT(
                            VARCHAR(64),
                            HASHBYTES('MD5',
                                CONCAT(
                                    ISNULL(Dim_Staging_Olimpiadas.Games, ''),
                                    ISNULL(Dim_Staging_Olimpiadas.Year, ''),
                                    ISNULL(Dim_Staging_Olimpiadas.Season, ''),
                                    ISNULL(Dim_Staging_Olimpiadas.City, '')
                                )
                            ), 2
                        )
END;


/*
============================================== 
Object:  MERGE TABLE OLIMPIADAS
============================================== */
MERGE dbo.Dim_Olimpiadas AS T

USING dbo.Dim_Staging_Olimpiadas AS S

ON T.DW_row_checksum <> S.DW_row_checksum AND T.Games = S.Games

WHEN MATCHED THEN 
   UPDATE SET T.Games = S.Games, T.Year = S.Year, T.Season = S.Season, T.City = S.City, T.DW_row_checksum = S.DW_row_checksum, T.DW_run_id = S.DW_run_id, T.DW_updated_on = S.DW_updated_on, T.DW_source_system = S.DW_source_system;

---

MERGE dbo.Dim_Olimpiadas AS T

USING dbo.Dim_Staging_Olimpiadas AS S

ON T.Games = S.Games

WHEN NOT MATCHED THEN
   INSERT (Games, Year, Season, City, DW_row_checksum, DW_run_id, DW_updated_on, DW_source_system) VALUES (S.Games, S.Year, S.Season, S.City, S.DW_row_checksum, S.DW_run_id, S.DW_updated_on, S.DW_source_system);

