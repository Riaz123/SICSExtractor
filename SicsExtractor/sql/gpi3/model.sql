SELECT ModelId = CAST(m.Id AS BIGINT),
       ModelName = CAST(m.Name AS NVARCHAR(255)),
       ModelType = CAST(m.[Type] AS NVARCHAR(255)),
       MeltId = CAST(m.EltId AS BIGINT),
       MeltName = CAST(Melt.Name AS NVARCHAR(255)),
       MeltImportDate = CAST(Melt.ImportDate AS DATETIME),
       FinancialPerspective = CAST(Melt.FinancialPerspective AS NVARCHAR(255)),
       LossBasisType = CAST(Melt.LossBasisType AS NVARCHAR(255)),
       MeltSource = CAST(Melt.[Source] AS NVARCHAR(255)),
       ModelDetailId = CAST(Melt.ModelDetailId AS BIGINT),
       ModelServerName = CAST(md.ServerName AS NVARCHAR(255)),
       ModelDatabaseName = CAST(md.DatabaseName AS NVARCHAR(255)),
       ModelVersion = CAST(md.ModelVersion AS NVARCHAR(255)),
       ThirdPartyEventSet = CAST(md.ThirdPartyEventSet AS NVARCHAR(255))
FROM [dbo].[Model] m
    LEFT JOIN
    (
        -- All in production with classification STD
        SELECT Id,
               melt.Name,
               melt.ImportDate,
               melt.FinancialPerspective,
               melt.LossBasisType,
               melt.Source,
               melt.ModelDetailId
        FROM [GPISystem_Simulation].[dbo].[Elt] melt
        WHERE melt.Type = 'Market'
              AND EXISTS
        (
            SELECT 'dummy'
            FROM dbo.Bet bt
                JOIN dbo.BetByes bb
                    ON bb.BetId = bt.Id
                JOIN dbo.Byes b
                    ON b.Id = bb.ByesId
            WHERE b.MeltId = melt.Id
                  AND bt.Status = 'InProduction'
                  AND bt.Classification = 'STD'
        )
    ) Melt
        ON m.EltId = Melt.Id
    LEFT JOIN [dbo].[ModelDetail] md
        ON md.Id = Melt.ModelDetailId    