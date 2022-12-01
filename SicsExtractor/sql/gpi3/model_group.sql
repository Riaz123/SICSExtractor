SELECT ModelGroupId = CAST(mg.Id AS BIGINT),
       Name = CAST(mg.Name AS NVARCHAR(255)),
       StartYear = CAST(mg.StartYear AS INT),
       EndYear = CAST(mg.EndYear AS INT),
       ByesId = CAST(mg.ByesId AS BIGINT),
       RootModelId = CAST(mg.RootModelId AS BIGINT),
       RootModelName = CAST(m.Name AS NVARCHAR(255)),
       ThirdPartyEventSet = UPPER(CAST(md.ThirdPartyEventSet AS NVARCHAR(255)))
FROM [dbo].ModelGroup mg
    LEFT JOIN [dbo].[Model] m
        ON mg.RootModelId = m.Id
    LEFT JOIN [dbo].[Elt] Melt
        ON m.EltId = Melt.Id
    LEFT JOIN [dbo].[ModelDetail] md
        ON md.Id = Melt.ModelDetailId
WHERE Melt.Type = 'Market'
      AND EXISTS
(
    SELECT 'dummy'
    FROM dbo.Bet bt
        JOIN dbo.BetByes bb
            ON bb.BetId = bt.Id
    WHERE bb.ByesId = mg.ByesId
          AND bt.Status = 'InProduction'
          AND bt.Classification = 'STD'
);