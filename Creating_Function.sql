---ASSIGNMENT 4----

--Create a scalar-valued function that returns the factorial of a number you gave it.

CREATE FUNCTION dbo.Factorial (@Number INT )
RETURNS BIGINT
AS
BEGIN
DECLARE @x  int

    IF @Number <= 1
        SET @x = 1
    ELSE
        SET @x = @Number * dbo.Factorial(@Number - 1 )
RETURN (@x)
END

SELECT dbo.Factorial(5)
