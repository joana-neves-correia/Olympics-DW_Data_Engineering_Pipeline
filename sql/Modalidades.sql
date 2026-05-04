/*
==============================================
Object:  TABELA DIMENSÃO MODALIDADES   
============================================== */
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE Dim_Modalidades(
	ID_Mod INT IDENTITY(1,1) PRIMARY KEY,
    SubMod VARCHAR(150) NOT NULL,
    Modalidade VARCHAR(150) NULL,
	[DW_row_checksum] [varchar](200) NULL,
	[DW_run_id] [varchar](50) NULL,
	[DW_updated_on] [datetime] NULL,
	[DW_source_system] [varchar](50) NULL,
);

/*
============================================== 
Object:  TABELA STAGING MODALIDADES
============================================== */
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE Dim_Staging_Modalidades(
    SubMod VARCHAR(150) NOT NULL,
    Modalidade VARCHAR(150) NULL,
	[DW_row_checksum] [varchar](200) NULL,
	[DW_run_id] [varchar](50) NULL,
	[DW_updated_on] [datetime] NULL,
	[DW_source_system] [varchar](50) NULL,
);

/*
============================================== 
Object:  TRIGGER STAGING MODALIDADES
============================================== */
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[trg_Insert_Dim_Staging_Modalidades_Checksum]
ON Dim_Staging_Modalidades
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Dim_Staging_Modalidades
    SET Dim_Staging_Modalidades.DW_row_checksum = CONVERT(
                            VARCHAR(64),
                            HASHBYTES('MD5',
                                CONCAT(
                                    ISNULL(Dim_Staging_Modalidades.SubMod, ''),
                                    ISNULL(Dim_Staging_Modalidades.Modalidade, '')
                                )
                            ), 2
                        )
END;


/*
============================================== 
Object:  MERGE TABLE MODALIDADES
============================================== */
MERGE dbo.Dim_Modalidades AS T

USING dbo.Dim_Staging_Modalidades AS S

ON T.DW_row_checksum <> S.DW_row_checksum AND T.SubMod = S.SubMod

WHEN MATCHED THEN 
   UPDATE SET T.SubMod = S.SubMod, T.Modalidade = S.Modalidade, T.DW_row_checksum = S.DW_row_checksum, T.DW_run_id = S.DW_run_id, T.DW_updated_on = S.DW_updated_on, T.DW_source_system = S.DW_source_system;

---

MERGE dbo.Dim_Modalidades AS T

USING dbo.Dim_Staging_Modalidades AS S

ON T.SubMod = S.SubMod

WHEN NOT MATCHED THEN
   INSERT (SubMod, Modalidade, DW_row_checksum, DW_run_id, DW_updated_on, DW_source_system) VALUES (S.SubMod, S.Modalidade, S.DW_row_checksum, S.DW_run_id, S.DW_updated_on, S.DW_source_system);