USE Projeto_SAD;
GO

CREATE PROCEDURE oltp.CadastrarCategoria
	@Nome VARCHAR(45)
AS
BEGIN
	IF NOT EXISTS(SELECT 1 FROM oltp.categoria WHERE nome = @Nome)
	BEGIN
		INSERT INTO oltp.categoria(nome) VALUES (@Nome);
		PRINT 'Categoria ' + @Nome + ' cadastrada com sucesso.';
	END
	ELSE
	BEGIN
		PRINT 'Categoria ' + @Nome + ' cdastrada com sucesso.';
	END
END;
GO