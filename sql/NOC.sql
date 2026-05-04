/*
==============================================
Object:  TABELA DIMENSÃO COMITÉS   
============================================== */
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE Dim_Comites(
	NOC VARCHAR(50) PRIMARY KEY,
    Region VARCHAR(150) NULL,
    Notes VARCHAR(255) NULL,
	[DW_row_checksum] [varchar](200) NULL,
	[DW_run_id] [varchar](50) NULL,
	[DW_updated_on] [datetime] NULL,
	[DW_source_system] [varchar](50) NULL,
);

/*
============================================== 
Object:  TABELA STAGING COMITÉS
============================================== */
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE Dim_Staging_Comites(
    NOC VARCHAR(50) NOT NULL,
    Region VARCHAR(150) NULL,
    Notes VARCHAR(255) NULL,
	[DW_row_checksum] [varchar](200) NULL,
	[DW_run_id] [varchar](50) NULL,
	[DW_updated_on] [datetime] NULL,
	[DW_source_system] [varchar](50) NULL,
);

/*
============================================== 
Object:  TRIGGER STAGING COMITÉS
============================================== */
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[trg_Insert_Dim_Staging_Comites_Checksum]
ON Dim_Staging_Comites
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Dim_Staging_Comites
    SET Dim_Staging_Comites.DW_row_checksum = CONVERT(
                            VARCHAR(64),
                            HASHBYTES('MD5',
                                CONCAT(
                                    ISNULL(Dim_Staging_Comites.NOC, ''),
                                    ISNULL(Dim_Staging_Comites.Region, ''),
                                    ISNULL(Dim_Staging_Comites.Notes, '')
                                )
                            ), 2
                        )
END;


/*
============================================== 
Object:  MERGE TABLE COMITÉS
============================================== */
MERGE dbo.Dim_Comites AS T

USING dbo.Dim_Staging_Comites AS S

ON T.DW_row_checksum <> S.DW_row_checksum AND T.NOC = S.NOC

WHEN MATCHED THEN 
   UPDATE SET T.NOC = S.NOC, T.Region = S.Region, T.Notes = S.Notes, T.DW_row_checksum = S.DW_row_checksum, T.DW_run_id = S.DW_run_id, T.DW_updated_on = S.DW_updated_on, T.DW_source_system = S.DW_source_system;

---

MERGE dbo.Dim_Comites AS T

USING dbo.Dim_Staging_Comites AS S

ON T.NOC = S.NOC

WHEN NOT MATCHED THEN
   INSERT (NOC, Region, Notes, DW_row_checksum, DW_run_id, DW_updated_on, DW_source_system) VALUES (S.NOC, S.Region, S.Notes, S.DW_row_checksum, S.DW_run_id, S.DW_updated_on, S.DW_source_system);

