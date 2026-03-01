USE Projeto_SAD;
GO

SET NOCOUNT ON;


DECLARE @DataInicio DATE = '2023-01-01';
DECLARE @DataFim DATE = '2030-12-31';
DECLARE @DataAtual DATE = @DataInicio;

PRINT 'A iniciar o povoamento da Dimensão Tempo...';

WHILE @DataAtual <= @DataFim
BEGIN

    IF NOT EXISTS (SELECT 1 FROM dw.Dim_Tempo WHERE data = @DataAtual)
    BEGIN
        INSERT INTO dw.Dim_Tempo (
            data, 
            dia, 
            mes, 
            ano, 
            trimestre, 
            dia_semana
        )
        VALUES (
            @DataAtual,
            DAY(@DataAtual),
            MONTH(@DataAtual),
            YEAR(@DataAtual),
            DATEPART(QUARTER, @DataAtual),
            DATENAME(WEEKDAY, @DataAtual) 
        );
    END
    
    SET @DataAtual = DATEADD(DAY, 1, @DataAtual);
END

PRINT 'Povoamento da Dimensão Tempo concluído com sucesso!';
GO