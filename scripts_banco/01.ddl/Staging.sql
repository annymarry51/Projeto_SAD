USE Projeto_SAD;
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'staging')
    EXEC('CREATE SCHEMA staging');
GO

CREATE TABLE staging.stg_cliente (
    id_cliente_oltp INT,
    nome VARCHAR(100),
    cidade VARCHAR(45),
    estado VARCHAR(45)
);
GO

CREATE TABLE staging.stg_produto (
    id_produto_oltp INT,
    nome VARCHAR(100),
    categoria VARCHAR(45),
    tema VARCHAR(45)
);
GO

CREATE TABLE staging.stg_maquina (
    id_maquina_oltp INT,
    nome VARCHAR(45),
    marca VARCHAR(45),
    modelo VARCHAR(45)
);
GO

CREATE TABLE staging.stg_insumo (
    id_insumo_oltp INT,
    nome VARCHAR(100),
    tipo_material VARCHAR(45)
);
GO

CREATE TABLE staging.stg_plataforma (
    nome_plataforma VARCHAR(45)
);
GO

CREATE TABLE staging.stg_fato_venda (
    data_venda DATETIME,
    id_cliente_oltp INT,
    id_produto_oltp INT,
    nome_plataforma VARCHAR(45),
    quantidade INT,
    preco_unitario DECIMAL(10,2),
    custo_embalagem_rateado DECIMAL(10,2),
    custo_plataforma_rateado DECIMAL(10,2)
);
GO

CREATE TABLE staging.violacao_fato_venda (
    data_venda DATETIME,
    id_cliente_oltp INT,
    id_produto_oltp INT,
    quantidade INT,
    preco_unitario DECIMAL(10,2),
    motivo_violacao VARCHAR(255),
    data_registo DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE staging.stg_fato_producao (
    data_inicio DATETIME,
    data_fim DATETIME,
    id_maquina_oltp INT,
    id_produto_oltp INT,
    id_insumo_oltp INT,
    quantidade_produzida INT,
    quantidade_insumo DECIMAL(10,3),
    custo_energia DECIMAL(10,2),
    desperdicio INT,
    falhas INT,
    tempo_impressao_minutos INT
);
GO

CREATE TABLE staging.violacao_fato_producao (
    data_inicio DATETIME,
    data_fim DATETIME,
    id_maquina_oltp INT,
    id_produto_oltp INT,
    id_insumo_oltp INT,
    quantidade_produzida INT,
    motivo_violacao VARCHAR(255),
    data_registo DATETIME DEFAULT GETDATE()
);
GO

EXEC staging.CarregarStagingDimensoes;
EXEC staging.CarregarStagingFatos;
GO