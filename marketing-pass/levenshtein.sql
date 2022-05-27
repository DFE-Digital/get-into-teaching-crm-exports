-- Levensthein disstance, sourced from TAD
CREATE FUNCTION [fuzzy].[lev](@s nvarchar(4000), @t nvarchar(4000), @d int)
RETURNS int
AS
BEGIN
  DECLARE @sl int, @tl int, @i int, @j int, @sc nchar, @c int, @c1 int,
    @cv0 nvarchar(4000), @cv1 nvarchar(4000), @cmin int
  SELECT @sl = LEN(@s), @tl = LEN(@t), @cv1 = '', @j = 1, @i = 1, @c = 0
  WHILE @j <= @tl
    SELECT @cv1 = @cv1 + NCHAR(@j), @j = @j + 1
  WHILE @i <= @sl
  BEGIN
    SELECT @sc = SUBSTRING(@s, @i, 1), @c1 = @i, @c = @i, @cv0 = '', @j = 1, @cmin = 4000
    WHILE @j <= @tl
    BEGIN
      SET @c = @c + 1
      SET @c1 = @c1 - CASE WHEN @sc = SUBSTRING(@t, @j, 1) THEN 1 ELSE 0 END
      IF @c > @c1 SET @c = @c1
      SET @c1 = UNICODE(SUBSTRING(@cv1, @j, 1)) + 1
      IF @c > @c1 SET @c = @c1
      IF @c < @cmin SET @cmin = @c
      SELECT @cv0 = @cv0 + NCHAR(@c), @j = @j + 1
    END
    IF @cmin > @d BREAK
    SELECT @cv1 = @cv0, @i = @i + 1
  END
  RETURN CASE WHEN @cmin <= @d AND @c <= @d THEN @c ELSE 999 END
END