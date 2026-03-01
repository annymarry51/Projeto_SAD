USE Projeto_SAD;
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'dw')
    EXEC('CREATE SCHEMA dw');
GO

CREATE TABLE dw.Dim_Tempo (
    id_tempo INT IDENTITY(1,1) PRIMARY KEY,
    data DATE NOT NULL,
    dia INT NOT NULL,
    mes INT NOT NULL,
    ano INT NOT NULL,
    trimestre INT NOT NULL,
    dia_semana VARCHAR(20) NOT NULL
);
GO

CREATE TABLE dw.Dim_Cliente (
    id_cliente INT IDENTITY(1,1) PRIMARY KEY,
    id_cliente_oltp INT NOT NULL, 
    nome VARCHAR(100) NOT NULL,
    cidade VARCHAR(45) NULL,
    estado VARCHAR(45) NULL
);
GO

CREATE TABLE dw.Dim_Produto (
    id_produto INT IDENTITY(1,1) PRIMARY KEY,
    id_produto_oltp INT NOT NULL, 
    nome VARCHAR(100) NOT NULL,
    categoria VARCHAR(45) NULL,
    tema VARCHAR(45) NULL
);
GO

CREATE TABLE dw.Dim_Maquina (
    id_maquina INT IDENTITY(1,1) PRIMARY KEY,
    id_maquina_oltp INT NOT NULL, 
    nome VARCHAR(45) NOT NULL,
    marca VARCHAR(45) NULL,
    modelo VARCHAR(45) NULL
);
GO

CREATE TABLE dw.Dim_Insumo (
    id_insumo INT IDENTITY(1,1) PRIMARY KEY,
    id_insumo_oltp INT NOT NULL, 
    nome VARCHAR(100) NOT NULL,
    tipo_material VARCHAR(45) NULL 
);
GO

CREATE TABLE dw.Dim_Plataforma (
    id_plataforma INT IDENTITY(1,1) PRIMARY KEY,
    nome_plataforma VARCHAR(45) NOT NULL
);
GO

CREATE TABLE dw.Fato_Venda (
    id_tempo INT NOT NULL,
    id_cliente INT NOT NULL,
    id_produto INT NOT NULL,
    id_plataforma INT NOT NULL,
    
    quantidade_vendida INT NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    valor_venda_bruto DECIMAL(10,2) NOT NULL,
    custo_embalagem_rateado DECIMAL(10,2) NOT NULL,
    custo_plataforma_rateado DECIMAL(10,2) NOT NULL,
    valor_venda_liquido DECIMAL(10,2) NOT NULL,
    
    PRIMARY KEY (id_tempo, id_cliente, id_produto, id_plataforma),
    CONSTRAINT FK_FV_Tempo FOREIGN KEY (id_tempo) REFERENCES dw.Dim_Tempo(id_tempo),
    CONSTRAINT FK_FV_Cliente FOREIGN KEY (id_cliente) REFERENCES dw.Dim_Cliente(id_cliente),
    CONSTRAINT FK_FV_Produto FOREIGN KEY (id_produto) REFERENCES dw.Dim_Produto(id_produto),
    CONSTRAINT FK_FV_Plataforma FOREIGN KEY (id_plataforma) REFERENCES dw.Dim_Plataforma(id_plataforma)
);
GO

CREATE TABLE dw.Fato_Producao (
    id_tempo INT NOT NULL,
    id_maquina INT NOT NULL,
    id_produto INT NOT NULL,
    id_insumo INT NOT NULL,
    
    quantidade_produzida INT NOT NULL,
    quantidade_insumo_utilizada DECIMAL(10,3) NOT NULL,
    custo_energia_estimado DECIMAL(10,2) NOT NULL,
    qtd_desperdicio INT NOT NULL,
    qtd_falhas_peca INT NOT NULL,
    tempo_impressao_minutos INT NOT NULL,
    
    PRIMARY KEY (id_tempo, id_maquina, id_produto, id_insumo),
    CONSTRAINT FK_FP_Tempo FOREIGN KEY (id_tempo) REFERENCES dw.Dim_Tempo(id_tempo),
    CONSTRAINT FK_FP_Maquina FOREIGN KEY (id_maquina) REFERENCES dw.Dim_Maquina(id_maquina),
    CONSTRAINT FK_FP_Produto FOREIGN KEY (id_produto) REFERENCES dw.Dim_Produto(id_produto),
    CONSTRAINT FK_FP_Insumo FOREIGN KEY (id_insumo) REFERENCES dw.Dim_Insumo(id_insumo)
);
GO

