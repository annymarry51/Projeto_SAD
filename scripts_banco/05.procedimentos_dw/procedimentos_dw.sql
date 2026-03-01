USE Projeto_SAD;
GO


CREATE OR ALTER PROCEDURE dw.CarregarDimensoes
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dw.Dim_Cliente (id_cliente_oltp, nome, cidade, estado)
    SELECT id_cliente_oltp, nome, cidade, estado 
    FROM staging.stg_cliente
    WHERE id_cliente_oltp NOT IN (SELECT id_cliente_oltp FROM dw.Dim_Cliente);

    INSERT INTO dw.Dim_Produto (id_produto_oltp, nome, categoria, tema)
    SELECT id_produto_oltp, nome, categoria, tema 
    FROM staging.stg_produto
    WHERE id_produto_oltp NOT IN (SELECT id_produto_oltp FROM dw.Dim_Produto);

    INSERT INTO dw.Dim_Maquina (id_maquina_oltp, nome, marca, modelo)
    SELECT id_maquina_oltp, nome, marca, modelo 
    FROM staging.stg_maquina
    WHERE id_maquina_oltp NOT IN (SELECT id_maquina_oltp FROM dw.Dim_Maquina);

    INSERT INTO dw.Dim_Insumo (id_insumo_oltp, nome, tipo_material)
    SELECT id_insumo_oltp, nome, tipo_material 
    FROM staging.stg_insumo
    WHERE id_insumo_oltp NOT IN (SELECT id_insumo_oltp FROM dw.Dim_Insumo);

    INSERT INTO dw.Dim_Plataforma (nome_plataforma)
    SELECT nome_plataforma 
    FROM staging.stg_plataforma
    WHERE nome_plataforma NOT IN (SELECT nome_plataforma FROM dw.Dim_Plataforma);

    PRINT 'Procedimento: Dimensões do DW carregadas com sucesso.';
END;
GO

CREATE OR ALTER PROCEDURE dw.CarregarFatos
AS
BEGIN
    SET NOCOUNT ON;


    INSERT INTO dw.Fato_Venda (
        id_tempo, id_cliente, id_produto, id_plataforma, 
        quantidade_vendida, preco_unitario, valor_venda_bruto, 
        custo_embalagem_rateado, custo_plataforma_rateado, valor_venda_liquido
    )
    SELECT 
        dt.id_tempo, 
        dc.id_cliente, 
        dp.id_produto, 
        dplat.id_plataforma,
        s.quantidade, 
        s.preco_unitario, 
        (s.quantidade * s.preco_unitario) AS valor_venda_bruto,
        s.custo_embalagem_rateado, 
        s.custo_plataforma_rateado,
        -- Cálculo da métrica líquida
        ((s.quantidade * s.preco_unitario) - s.custo_embalagem_rateado - s.custo_plataforma_rateado) AS valor_venda_liquido
    FROM staging.stg_fato_venda s
    JOIN dw.Dim_Tempo dt ON dt.data = CAST(s.data_venda AS DATE)
    JOIN dw.Dim_Cliente dc ON dc.id_cliente_oltp = s.id_cliente_oltp
    JOIN dw.Dim_Produto dp ON dp.id_produto_oltp = s.id_produto_oltp
    JOIN dw.Dim_Plataforma dplat ON dplat.nome_plataforma = s.nome_plataforma
    -- Garantir que não insere dados duplicados (Idempotência)
    WHERE NOT EXISTS (
        SELECT 1 FROM dw.Fato_Venda f 
        WHERE f.id_tempo = dt.id_tempo 
          AND f.id_cliente = dc.id_cliente 
          AND f.id_produto = dp.id_produto 
          AND f.id_plataforma = dplat.id_plataforma
    );

    INSERT INTO dw.Fato_Producao (
        id_tempo, id_maquina, id_produto, id_insumo, 
        quantidade_produzida, quantidade_insumo_utilizada, 
        custo_energia_estimado, qtd_desperdicio, qtd_falhas_peca, tempo_impressao_minutos
    )
    SELECT 
        dt.id_tempo, 
        dm.id_maquina, 
        dp.id_produto, 
        di.id_insumo,
        s.quantidade_produzida, 
        s.quantidade_insumo, 
        s.custo_energia,
        s.desperdicio, 
        s.falhas, 
        s.tempo_impressao_minutos
    FROM staging.stg_fato_producao s
    JOIN dw.Dim_Tempo dt ON dt.data = CAST(s.data_inicio AS DATE)
    JOIN dw.Dim_Maquina dm ON dm.id_maquina_oltp = s.id_maquina_oltp
    JOIN dw.Dim_Produto dp ON dp.id_produto_oltp = s.id_produto_oltp
    JOIN dw.Dim_Insumo di ON di.id_insumo_oltp = s.id_insumo_oltp
    WHERE NOT EXISTS (
        SELECT 1 FROM dw.Fato_Producao f 
        WHERE f.id_tempo = dt.id_tempo 
          AND f.id_maquina = dm.id_maquina 
          AND f.id_produto = dp.id_produto 
          AND f.id_insumo = di.id_insumo
    );

    PRINT 'Procedimento: Fatos do DW carregados com sucesso.';
END;
GO


EXEC dw.CarregarDimensoes;
EXEC dw.CarregarFatos;