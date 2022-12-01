SELECT melt_row.EltId melt_id,
       melt_row.EventId,
       melt_row.Frequency,
       melt_row.SeverityModel,
       melt_row.CorrelationModel,
       melt_row.CorrelationParameter,
       melt_row.SeverityParameter1,
       melt_row.SeverityParameter2,
       melt_row.SeverityParameter3,
       melt_row.SeverityParameter4,
       melt_row.SeverityParameter5,
       melt_row.FrequencyGroupId
FROM [GPISystem_Simulation].[dbo].[Elt] melt
    JOIN dbo.EltRow melt_row
        ON melt_row.EltId = melt.Id
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
);