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
		PRINT 'Categoria ' + @Nome + ' não cadastrado' ;
	END
END;
GO

CREATE PROCEDURE oltp.CadastrarTema
	@Nome VARCHAR(45)
AS
BEGIN
	IF NOT EXISTS(SELECT 1 FROM oltp.tema WHERE nome_tema = @Nome)
	BEGIN
		INSERT INTO oltp.tema(nome_tema) VALUES (@Nome);
		PRINT 'Tema ' + @Nome + ' cadastrada com sucesso.';
	END
	ELSE
	BEGIN
		PRINT 'Tema ' + @Nome + 'não cadastrado';
	END
END;
GO

CREATE PROCEDURE oltp.cadastrarInsumo
	@Nome VARCHAR(100),
	@unidade_medida VARCHAR(10),
	@estoque_atual DECIMAL(10,3),
	@custo_unitario DECIMAL(10,2),
	@data_ultima_compra DATE,
	@plataforma_compra VARCHAR(45)
AS
BEGIN
	INSERT INTO oltp.insumo(nome, unidade_medida, estoque_atual, custo_unitario, data_ultima_compra, plataforma_compra) 
    VALUES (@Nome, @unidade_medida, @estoque_atual, @custo_unitario, @data_ultima_compra, @plataforma_compra);
	PRINT 'Insumo ' + @Nome + ' cadastrado com sucesso.';
END;
GO

CREATE PROCEDURE oltp.cadastrarCliente
	@Nome VARCHAR(100),
	@cpf_cnpj VARCHAR(15),
	@email VARCHAR(100),
	@telefone VARCHAR(15)
AS
BEGIN
	INSERT INTO oltp.cliente(nome, cpf_cnpj, email, telefone) VALUES (@Nome, @cpf_cnpj, @email, @telefone);
	PRINT 'Cliente ' + @Nome + ' cadastrado com sucesso.';
END;
GO

CREATE PROCEDURE oltp.cadastrarMaquina
	@Nome VARCHAR(45),
    @status_maquina VARCHAR(20),
    @marca VARCHAR(45),
    @modelo VARCHAR(45),
    @valor_aqusicao DECIMAL (10,2),
    @vida_util_meses INT,
    @consumo_watts INT
AS
BEGIN
	INSERT INTO oltp.maquina(nome, status_maquina, marca, modelo, valor_aqusicao,vida_util_meses,consumo_watts) VALUES (@Nome,@status_maquina, @marca, @modelo, @valor_aqusicao,@vida_util_meses,@consumo_watts);
	PRINT 'Maquina ' + @Nome + ' cadastrada com sucesso.';
END;
GO

CREATE PROCEDURE oltp.cadastrarProduto
    @nome VARCHAR(100) ,
    @preco_venda DECIMAL(10,2),
    @estoque_atual INT,
    @categoria_id INT,
    @tema_id INT
AS
BEGIN
	INSERT INTO oltp.produto(nome,preco_venda,estoque_atual,categoria_id, tema_id) VALUES (@nome,@preco_venda,@estoque_atual,@categoria_id, @tema_id);
	PRINT 'Produto ' + @nome + ' cadastrado com sucesso.';
END;
GO

CREATE PROCEDURE oltp.cadastrarProducao
    @data_inicio DATETIME,
    @data_fim DATETIME,
    @maquina_id INT,
    @custo_energy_estimado DECIMAL (10,2),
    @falhas VARCHAR(45)
AS
BEGIN
	INSERT INTO oltp.producao(data_inicio,data_fim,maquina_id,custo_energy_estimado, falhas) VALUES (@data_inicio,@data_fim,@maquina_id,@custo_energy_estimado, @falhas);
	PRINT 'Produção cadastrada com sucesso.';
END;
GO

CREATE PROCEDURE oltp.cadastrarVenda
    @cliente_id INT,
    @data_venda DATETIME,
    @valor_total DECIMAL(10,2),
    @custo_embalagem DECIMAL(10,2),
    @custo_plataforma DECIMAL(10,2),
    @nome_plataforma VARCHAR(45)
AS
BEGIN
    INSERT INTO oltp.venda (cliente_id, data_venda, valor_total, custo_embalagem, custo_plataforma, nome_plataforma)
    VALUES (@cliente_id, @data_venda, @valor_total, @custo_embalagem, @custo_plataforma, @nome_plataforma);
    
    PRINT 'Venda registrada com sucesso.';
END;
GO

CREATE PROCEDURE oltp.cadastrarProducaoInsumo
    @producao_id INT,
    @insumo_id INT,
    @quantidade_utilizada DECIMAL(10,3)
AS
BEGIN
    IF EXISTS(SELECT 1 FROM oltp.producao WHERE id = @producao_id) AND 
       EXISTS(SELECT 1 FROM oltp.insumo WHERE id = @insumo_id)
    BEGIN
        INSERT INTO oltp.producao_has_insumo (producao_id, insumo_id, quantidade_utilizada)
        VALUES (@producao_id, @insumo_id, @quantidade_utilizada);
    END
    ELSE
    BEGIN
        PRINT 'Erro: Produção ou Insumo não encontrados.';
    END
END;
GO

CREATE PROCEDURE oltp.cadastrarProdutoProducao
    @producao_id INT,
    @produto_id INT,
    @quantidade_produzida DECIMAL(10,3)
AS
BEGIN
    IF EXISTS(SELECT 1 FROM oltp.producao WHERE id = @producao_id) AND 
       EXISTS(SELECT 1 FROM oltp.produto WHERE id = @produto_id)
    BEGIN
        INSERT INTO oltp.produto_has_producao (producao_id, produto_id, quantidade_produzida)
        VALUES (@producao_id, @produto_id, @quantidade_produzida);
    END
    ELSE
    BEGIN
        PRINT 'Erro: Produção ou Produto não encontrados.';
    END
END;
GO

CREATE PROCEDURE oltp.cadastrarVendaProduto
    @venda_id INT,
    @produto_id INT,
    @quantidade INT,
    @preco_unitario_historico DECIMAL(10,3)
AS
BEGIN
    IF EXISTS(SELECT 1 FROM oltp.venda WHERE id = @venda_id) AND 
       EXISTS(SELECT 1 FROM oltp.produto WHERE id = @produto_id)
    BEGIN
        INSERT INTO oltp.venda_has_produto (venda_id, produto_id, quantidade, preco_unitario_historico)
        VALUES (@venda_id, @produto_id, @quantidade, @preco_unitario_historico);
    END
    ELSE
    BEGIN
        PRINT 'Erro: Venda ou Produto não encontrados.';
    END
END;
GO


EXEC oltp.CadastrarCategoria @Nome = 'Papelaria';
EXEC oltp.CadastrarCategoria @Nome = 'Decoração';
EXEC oltp.CadastrarCategoria @Nome = 'Lembrancinhas';

EXEC oltp.CadastrarTema @Nome = 'Aniversário Infantil';
EXEC oltp.CadastrarTema @Nome = 'Casamento';
EXEC oltp.CadastrarTema @Nome = 'Corporativo';

EXEC oltp.cadastrarInsumo 
    @Nome = 'Papel Fotográfico A4 180g', 
    @unidade_medida = 'Folha', 
    @estoque_atual = 500.000, 
    @custo_unitario = 0.50, 
    @data_ultima_compra = '2026-02-01', 
    @plataforma_compra = 'Fornecedor Papel Total';

EXEC oltp.cadastrarInsumo 
    @Nome = 'Tinta Epson Magenta', 
    @unidade_medida = 'ML', 
    @estoque_atual = 100.000, 
    @custo_unitario = 0.15, 
    @data_ultima_compra = '2026-02-10', 
    @plataforma_compra = 'Mercado Livre';


EXEC oltp.cadastrarCliente 
    @Nome = 'Ana Souza', 
    @cpf_cnpj = '12345678901', 
    @email = 'ana.souza@email.com', 
    @telefone = '11999990000';

EXEC oltp.cadastrarCliente 
    @Nome = 'Empresa Tech Soluções', 
    @cpf_cnpj = '12345678000199', 
    @email = 'contato@tech.com', 
    @telefone = '1133334444';


EXEC oltp.cadastrarMaquina 
    @Nome = 'Impressora Plotter', 
    @status_maquina = 'Ativa', 
    @marca = 'Epson', 
    @modelo = 'SureColor', 
    @valor_aqusicao = 5000.00, 
    @vida_util_meses = 60, 
    @consumo_watts = 200;


EXEC oltp.cadastrarProduto 
    @nome = 'Convite de Casamento Rústico', 
    @preco_venda = 8.50, 
    @estoque_atual = 0, 
    @categoria_id = 1, 
    @tema_id = 2;


EXEC oltp.cadastrarProducao 
    @data_inicio = '2026-02-20 08:00', 
    @data_fim = '2026-02-20 12:00', 
    @maquina_id = 1, 
    @custo_energy_estimado = 15.50, 
    @falhas = NULL;



EXEC oltp.cadastrarProducaoInsumo 
    @producao_id = 1, 
    @insumo_id = 1, 
    @quantidade_utilizada = 55.000;

EXEC oltp.cadastrarProducaoInsumo 
    @producao_id = 1, 
    @insumo_id = 2,
    @quantidade_utilizada = 20.000; 

EXEC oltp.cadastrarProdutoProducao 
    @producao_id = 1, 
    @produto_id = 1,
    @quantidade_produzida = 50.000;


EXEC oltp.cadastrarVenda 
    @cliente_id = 1, 
    @data_venda = '2026-02-25 14:00', 
    @valor_total = 425.00, 
    @custo_embalagem = 10.00, 
    @custo_plataforma = 50.00, 
    @nome_plataforma = 'Site Próprio';

EXEC oltp.cadastrarVendaProduto 
    @venda_id = 1, 
    @produto_id = 1,
    @quantidade = 50, 
    @preco_unitario_historico = 8.50;
GO