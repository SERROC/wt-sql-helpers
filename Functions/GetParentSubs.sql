/*
  Get parents for subdivision
*/
CREATE FUNCTION [GetParentSubs](@subdivision_id BIGINT) RETURNS @result TABLE (
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
    INNER JOIN [cte0] AS [t1] ON [t0].[id] = [t1].[parent_object_id]
) 

INSERT INTO @result 
SELECT 
  [t0].[id], 
  [t0].[parent_object_id], 
  [t0].[name], 
  ROW_NUMBER() OVER(
    ORDER BY 
      [t0].[level] DESC
  ) - 1 AS [level] 
FROM 
  [cte0] AS [t0] 
RETURN;
END;
