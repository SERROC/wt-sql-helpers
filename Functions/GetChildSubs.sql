CREATE FUNCTION [GetChildSubs](@subdivision_id BIGINT) RETURNS @result TABLE (
  [id] BIGINT, 
  [parent_object_id] BIGINT, 
  [name] VARCHAR(255), 
  [level] INT
) AS BEGIN 
WITH [cte0] AS (
  SELECT 
    [id], 
    [parent_object_id], 
    [name], 
    0 AS [level] 
  FROM 
    [subdivisions] 
  WHERE 
    [id] = @subdivision_id 
  UNION ALL 
  SELECT 
    [t0].[id], 
    [t0].[parent_object_id], 
    [t0].[name], 
    [t1].[level] + 1 AS [level] 
  FROM 
    [subdivisions] AS [t0] 
    INNER JOIN [cte0] AS [t1] ON [t0].[parent_object_id] = [t1].[id]
) 

INSERT INTO @result 
SELECT 
  [id], 
  [parent_object_id], 
  [name], 
  [level] 
FROM 
  [cte0] 

RETURN;
END;
GO;
