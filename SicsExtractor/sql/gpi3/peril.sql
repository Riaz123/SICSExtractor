SELECT Id = CAST(Id AS BIGINT),
       [Type] = CAST([Type] AS NVARCHAR(255)),
       [version] = CAST([version] AS INT),
       Name = CAST(Name AS NVARCHAR(255)),
       Description = CAST(Description AS NVARCHAR(255)),
       Comment = CAST(Comment AS NVARCHAR(255)),
       Active = CAST(Active AS BIT),
       LevelId = CAST(LevelId AS BIGINT),
       NaturalKey = CAST(NaturalKey AS NVARCHAR(255)),
       [Path] = CAST([Path] AS NVARCHAR(255)),
       ParentId = CAST(ParentId AS BIGINT),
       Classification = CAST(Classification AS NVARCHAR(255)),
       PerilCategory = CAST(PerilCategory AS NVARCHAR(255))
FROM [dbo].Peril;