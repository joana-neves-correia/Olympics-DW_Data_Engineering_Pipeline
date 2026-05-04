/*
==============================================
Object:  TABELA DIMENSÃO ATLETA   
============================================== */
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE Dim_Atleta(
    ID_column INT IDENTITY(1,1) PRIMARY KEY,
	ID_Atleta INT UNIQUE NOT NULL,
    Name VARCHAR(500) NOT NULL,
    Sex CHAR(15) NULL,
    Age VARCHAR(50) NULL,
    Height VARCHAR(50) NULL,
    Weight VARCHAR(50) NULL,
    Team VARCHAR(150) NULL,
	[DW_row_checksum] [varchar](200) NULL,
	[DW_run_id] [varchar](50) NULL,
	[DW_updated_on] [datetime] NULL,
	[DW_source_system] [varchar](50) NULL,
);

/*
============================================== 
Object:  TABELA STAGING ATLETA
============================================== */
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE Dim_Staging_Atleta(
    ID_Atleta INT NOT NULL,
    Name VARCHAR(500) NOT NULL,
    Sex CHAR(15) NULL,
    Age VARCHAR(50) NULL,
    Height VARCHAR(50) NULL,
    Weight VARCHAR(50) NULL,
    Team VARCHAR(150) NULL,
	[DW_row_checksum] [varchar](200) NULL,
	[DW_run_id] [varchar](50) NULL,
	[DW_updated_on] [datetime] NULL,
	[DW_source_system] [varchar](50) NULL,
);

/*
============================================== 
Object:  TRIGGER STAGING ATLETA
============================================== */
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[trg_Insert_Dim_Staging_Atleta_Checksum]
ON Dim_Staging_Atleta
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Dim_Staging_Atleta
    SET Dim_Staging_Atleta.DW_row_checksum = CONVERT(
                            VARCHAR(64),
                            HASHBYTES('MD5',
                                CONCAT(
                                    ISNULL(Dim_Staging_Atleta.ID_Atleta, ''),
                                    ISNULL(Dim_Staging_Atleta.Name, ''),
                                    ISNULL(Dim_Staging_Atleta.Sex, ''),
                                    ISNULL(Dim_Staging_Atleta.Age, ''),
                                    ISNULL(Dim_Staging_Atleta.Height, ''),
                                    ISNULL(Dim_Staging_Atleta.Weight, ''),
                                    ISNULL(Dim_Staging_Atleta.Team, '')
                                )
                            ), 2
                        )
END;


/*
============================================== 
Object:  MERGE TABLE ATLETA
============================================== */
MERGE dbo.Dim_Atleta AS T

USING dbo.Dim_Staging_Atleta AS S

ON T.DW_row_checksum <> S.DW_row_checksum AND T.ID_Atleta = S.ID_Atleta

WHEN MATCHED THEN 
   UPDATE SET T.ID_Atleta = S.ID_Atleta, T.Name = S.Name, T.Sex = S.Sex, T.Age = S.Age, T.Height = S.Height, T.Weight = S.Weight, T.Team = S.Team, T.DW_row_checksum = S.DW_row_checksum, T.DW_run_id = S.DW_run_id, T.DW_updated_on = S.DW_updated_on, T.DW_source_system = S.DW_source_system;

---

MERGE dbo.Dim_Atleta AS T

USING dbo.Dim_Staging_Atleta AS S

ON T.ID_Atleta = S.ID_Atleta

WHEN NOT MATCHED THEN
   INSERT (ID_Atleta, Name, Sex, Age, Height, Weight, Team, DW_row_checksum, DW_run_id, DW_updated_on, DW_source_system) VALUES (S.ID_Atleta, S.Name, S.Sex, S.Age, S.Height, S.Weight, S.Team, S.DW_row_checksum, S.DW_run_id, S.DW_updated_on, S.DW_source_system);
