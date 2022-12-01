SET NOCOUNT ON;



SELECT Type = 'Model',
       m.*
FROM [dbo].[Model] m
    JOIN Elt melt
        ON melt.Id = m.EltId
WHERE m.EltId = 409324486671
      AND melt.Type = 'Market'
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

IF OBJECT_ID(N'tempdb..#model_group_model', N'U') IS NOT NULL
    DROP TABLE #model_group_model;
GO
IF OBJECT_ID(N'tempdb..#model_group', N'U') IS NOT NULL
    DROP TABLE #model_group;
GO
IF OBJECT_ID(N'tempdb..#matching_model_group_model', N'U') IS NOT NULL
    DROP TABLE #matching_model_group_model;
GO

DECLARE @ModelId BIGINT = 409324552207;

-- Select all ModelGroupModel relations for this Model 
SELECT Type = 'ModelGroupModel',
       *
INTO #model_group_model
FROM ModelGroupModel mg
WHERE mg.ModelId = @ModelId;

SELECT *
FROM #model_group_model;


-- Select the ModelGroups the the mgm relations points to
SELECT Type = 'ModelGroup',
       *
INTO #model_group
FROM ModelGroup mg
WHERE EXISTS
(
    SELECT ''
    FROM #model_group_model mgm
    WHERE mgm.ModelGroupId = mg.Id
          AND EXISTS
    (
        SELECT 'dummy'
        FROM dbo.Bet bt
            JOIN dbo.BetByes bb
                ON bb.BetId = bt.Id
        WHERE bb.ByesId = mg.ByesId
              AND bt.Status = 'InProduction'
              AND bt.Classification = 'STD'
    )
);

SELECT *
FROM #model_group;

-- Select all members of the ModelGroups
SELECT Type = 'MatchingModelGroupModel',
       *
INTO #matching_model_group_model
FROM dbo.ModelGroupModel mgm
WHERE EXISTS
(
    SELECT ''
    FROM #model_group tmg
    WHERE tmg.Id = mgm.ModelGroupId
);

SELECT *
FROM #matching_model_group_model mgm
ORDER BY mgm.ModelGroupId,
         mgm.ModelId;

SELECT Type = 'MatchingModelGroup',
       *
FROM dbo.ModelGroup mg
WHERE EXISTS
(
    SELECT ''
    FROM #matching_model_group_model mmgm
    WHERE mmgm.ModelGroupId = mg.Id
)
ORDER BY mg.Id;

SELECT Type = 'MatchingModel',
       *
FROM dbo.Model m
WHERE EXISTS
(
    SELECT '' FROM #matching_model_group_model mmgm WHERE mmgm.ModelId = m.Id
)
ORDER BY m.Id;