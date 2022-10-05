-- Получение правильных ответов на вопросы по тесту
CREATE FUNCTION [GetAssessmentCorrectAnswers] (
  @assessment_id BIGINT
) 
RETURNS TABLE AS RETURN (
SELECT 
  [t0].[id] AS [assessment_id],
  [x0].[section].value('title[1]', 'VARCHAR(255)') AS [section_name],
  [x1].[item].value('id[1]', 'BIGINT') AS [item_id],
  [x1].[item].value('title[1]', 'VARCHAR(255)') AS [item_name],
  [t2].[name] AS [type_name],
  [t1].[question_text],
  ISNULL([t3].[correct_answers], [t4].[correct_answers]) AS [correct_answers]
FROM 
  [assessments] AS [t0]
  INNER JOIN [assessment] AS [d0] ON [d0].[id] = [t0].[id]
  CROSS APPLY [d0].[data].nodes('//sections/section') AS [x0](section)
  CROSS APPLY [x0].[section].nodes('./items/item') AS [x1](item)
  INNER JOIN [items] AS [t1] ON [t1].[id] = [x1].[item].value('id[1]', 'BIGINT')
  INNER JOIN [item] AS [d1] ON [t1].[id] = [d1].[id]
  INNER JOIN [common.item_types] AS [t2] ON [t1].[type_id] = [t2].[id]
  OUTER APPLY (
    SELECT
      STRING_AGG([ix0].[answer].value('text[1]', 'VARCHAR(255)'), ';') AS [correct_answers]
    FROM [d1].[data].nodes('//answers/answer[is_correct_answer = true()]') AS [ix0](answer)
  ) AS [t3]
  OUTER APPLY (
    SELECT
      STRING_AGG([ix0].[data].value('text[1]', 'VARCHAR(255)') + ' - ' + [ix1].[data].value('text[1]', 'VARCHAR(255)'), ';') AS [correct_answers]
    FROM 
      [d1].[data].nodes('//answers/answer') AS [ix0](data)
      CROSS APPLY [ix0].data.nodes('values/value') AS [ix1](data)
  ) AS [t4]
WHERE 
  [t0].[id] = @assessment_id
);