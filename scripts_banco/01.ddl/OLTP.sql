
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Projeto_SAD')
BEGIN
    CREATE DATABASE Projeto_SAD;
END
GO

USE Projeto_SAD;
GO


CREATE TABLE oltp.categoria (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(45) NOT NULL
);
GO

CREATE TABLE oltp.tema (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nome_tema VARCHAR(45) NOT NULL
);
GO

CREATE TABLE oltp.cliente (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf_cnpj VARCHAR(18) NOT NULL UNIQUE,
    email VARCHAR(100) NULL,
    telefone VARCHAR(15) NULL,
    cidade VARCHAR(45) NULL,
    estado VARCHAR(45) NULL
);
GO

CREATE TABLE oltp.insumo (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    unidade_medida VARCHAR(10) NULL DEFAULT 'G', 
    estoque_atual DECIMAL(10,3) NULL DEFAULT 0.000,
    custo_unitario DECIMAL(10,2) NULL,
    data_ultima_compra DATE NULL,
    plataforma_compra VARCHAR(45) NULL
);
GO

CREATE TABLE oltp.maquina (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(45) NOT NULL,
    status_maquina VARCHAR(20) NULL DEFAULT 'Ativa',
    marca VARCHAR(45) NULL,
    modelo VARCHAR(45) NULL,
    valor_aquisicao DECIMAL(10,2) NULL,
    vida_util_meses INT NULL,
    consumo_watts INT NULL
);
GO

CREATE TABLE oltp.produto (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    preco_venda DECIMAL(10,2) NOT NULL,
    estoque_atual INT NOT NULL DEFAULT 0,
    categoria_id INT NOT NULL,
    tema_id INT NOT NULL,
    CONSTRAINT FK_Produto_Categoria FOREIGN KEY (categoria_id) REFERENCES oltp.categoria(id),
    CONSTRAINT FK_Produto_Tema FOREIGN KEY (tema_id) REFERENCES oltp.tema(id)
);
GO

CREATE TABLE oltp.producao (
    id INT IDENTITY(1,1) PRIMARY KEY,
    data_inicio DATETIME NOT NULL DEFAULT GETDATE(),
    data_fim DATETIME NULL,
    maquina_id INT NOT NULL,
    custo_energy_estimado DECIMAL(10,2) NULL,
    desperdicio INT NULL, 
    falhas INT NULL,      
    CONSTRAINT FK_Producao_Maquina FOREIGN KEY (maquina_id) REFERENCES oltp.maquina(id)
);
GO

CREATE TABLE oltp.venda (
    id INT IDENTITY(1,1) PRIMARY KEY,
    data_venda DATETIME NOT NULL DEFAULT GETDATE(),
    cliente_id INT NOT NULL,
    valor_total DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    custo_embalagem DECIMAL(10,2) NULL DEFAULT 0.00,
    custo_plataforma DECIMAL(10,2) NULL DEFAULT 0.00,
    nome_plataforma VARCHAR(45) NULL,
    CONSTRAINT FK_Venda_Cliente FOREIGN KEY (cliente_id) REFERENCES oltp.cliente(id)
);
GO

CREATE TABLE oltp.producao_has_insumo (
    producao_id INT NOT NULL,
    insumo_id INT NOT NULL,
    quantidade_utilizada DECIMAL(10,3) NOT NULL,
    PRIMARY KEY (producao_id, insumo_id),
    CONSTRAINT FK_PHI_Producao FOREIGN KEY (producao_id) REFERENCES oltp.producao(id),
    CONSTRAINT FK_PHI_Insumo FOREIGN KEY (insumo_id) REFERENCES oltp.insumo(id)
);
GO

CREATE TABLE oltp.produto_has_producao (
    producao_id INT NOT NULL,
    produto_id INT NOT NULL,
    quantidade_produzida INT NOT NULL,
    PRIMARY KEY (producao_id, produto_id),
    CONSTRAINT FK_PHP_Producao FOREIGN KEY (producao_id) REFERENCES oltp.producao(id),
    CONSTRAINT FK_PHP_Produto FOREIGN KEY (produto_id) REFERENCES oltp.produto(id)
);
GO

CREATE TABLE oltp.venda_has_produto (
    venda_id INT NOT NULL,
    produto_id INT NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario_historico DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (venda_id, produto_id),
    CONSTRAINT FK_VHP_Venda FOREIGN KEY (venda_id) REFERENCES oltp.venda(id),
    CONSTRAINT FK_VHP_Produto FOREIGN KEY (produto_id) REFERENCES oltp.produto(id)
);
GO

