CREATE OR ALTER PROCEDURE dbo.PivotTable (
  @result NVARCHAR (100),   -- table or view object name for result
  @source NVARCHAR (100),   -- table or view object name
  @pivotCol NVARCHAR (100),   -- the column to pivot
  @pivotAggCol NVARCHAR (100),   -- the column with the values for the pivot
  @pivotAggFunc NVARCHAR (20),   -- the aggregate function to apply to those values
  @leadCols NVARCHAR (100) -- comma seprated list of other columns to keep and order by
  ) AS 
BEGIN 
  DECLARE @pivotedColumns NVARCHAR(MAX);
  DECLARE @tsql NVARCHAR(MAX);
  DECLARE @alterSql NVARCHAR(MAX);
  DECLARE @insertSql NVARCHAR(MAX);

  SET @tsql = CONCAT(
      'SELECT @pivotedColumns = STRING_AGG(qname, '','') FROM (SELECT DISTINCT QUOTENAME(', 
      @pivotCol, ') AS qname FROM ', @source, 
      ') AS qnames'
    );

  EXEC sp_executesql @tsql, N'@pivotedColumns nvarchar(max) out', @pivotedColumns out 

  SET @tsql = CONCAT (
      'SELECT ', @leadCols, ',', @pivotedColumns, 
      ' FROM ', ' ( SELECT ', @leadCols, 
      ',', @pivotAggCol, ',', @pivotCol, 
      ' FROM ', @source, ') AS t ', ' PIVOT (', 
      @pivotAggFunc, '(', @pivotAggCol, 
      ')', ' FOR ', @pivotCol, '   IN (', 
      @pivotedColumns, ')) AS pvt ', ' ORDER BY ', 
      @leadCols
    );

  SET @alterSql = (
      SELECT 
        CONCAT(
          'ALTER TABLE ', 
          @result, 
          ' ADD ', 
          CONCAT(
            STRING_AGG([value], ' NVARCHAR(MAX), '), 
            ' NVARCHAR(MAX)'
          )
        ) 
      FROM 
        string_split(@pivotedColumns, ',')
    );

  EXEC (@alterSql);

  SET  @insertSql = (
      SELECT 
        CONCAT(
          'INSERT INTO ', @result, ' EXEC (@tsql)'
        )
    );

  EXEC sp_executesql @insertSql, N'@tsql NVARCHAR(MAX)', @tsql = @tsql;

END;
