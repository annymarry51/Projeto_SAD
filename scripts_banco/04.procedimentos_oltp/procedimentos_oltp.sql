USE Projeto_SAD;
GO

CREATE OR ALTER PROCEDURE staging.CarregarStagingDimensoes
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE staging.stg_cliente;
    TRUNCATE TABLE staging.stg_produto;
    TRUNCATE TABLE staging.stg_maquina;
    TRUNCATE TABLE staging.stg_insumo;
    TRUNCATE TABLE staging.stg_plataforma;

    INSERT INTO staging.stg_cliente (id_cliente_oltp, nome, cidade, estado)
    SELECT id, nome, cidade, estado 
    FROM oltp.cliente;

    INSERT INTO staging.stg_produto (id_produto_oltp, nome, categoria, tema)
    SELECT p.id, p.nome, c.nome, t.nome_tema
    FROM oltp.produto p
    LEFT JOIN oltp.categoria c ON p.categoria_id = c.id
    LEFT JOIN oltp.tema t ON p.tema_id = t.id;

    INSERT INTO staging.stg_maquina (id_maquina_oltp, nome, marca, modelo)
    SELECT id, nome, marca, modelo 
    FROM oltp.maquina;

    INSERT INTO staging.stg_insumo (id_insumo_oltp, nome, tipo_material)
    SELECT id, nome, 
        CASE 
            WHEN nome LIKE '%PLA%' THEN 'PLA'
            WHEN nome LIKE '%ABS%' THEN 'ABS'
            WHEN nome LIKE '%PETG%' THEN 'PETG'
            WHEN nome LIKE '%Resina%' THEN 'Resina'
            ELSE 'Outro'
        END 
    FROM oltp.insumo;

    -- 1.5 Extrair Plataformas (Distinção das plataformas usadas nas vendas)
    INSERT INTO staging.stg_plataforma (nome_plataforma)
    SELECT DISTINCT ISNULL(nome_plataforma, 'Desconhecida') 
    FROM oltp.venda;

    PRINT 'Procedimento: Staging das Dimensões carregado com sucesso.';
END;
GO


CREATE OR ALTER PROCEDURE staging.CarregarStagingFatos
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE staging.stg_fato_venda;
    TRUNCATE TABLE staging.violacao_fato_venda;
    TRUNCATE TABLE staging.stg_fato_producao;
    TRUNCATE TABLE staging.violacao_fato_producao;

    INSERT INTO staging.stg_fato_venda (
        data_venda, id_cliente_oltp, id_produto_oltp, nome_plataforma, 
        quantidade, preco_unitario, custo_embalagem_rateado, custo_plataforma_rateado
    )
    SELECT 
        v.data_venda, v.cliente_id, vp.produto_id, ISNULL(v.nome_plataforma, 'Desconhecida'),
        vp.quantidade, vp.preco_unitario_historico,
        ISNULL(v.custo_embalagem / NULLIF((SELECT SUM(quantidade) FROM oltp.venda_has_produto WHERE venda_id = v.id), 0), 0),
        ISNULL(v.custo_plataforma / NULLIF((SELECT SUM(quantidade) FROM oltp.venda_has_produto WHERE venda_id = v.id), 0), 0)
    FROM oltp.venda v
    JOIN oltp.venda_has_produto vp ON v.id = vp.venda_id
    WHERE vp.quantidade > 0 AND v.cliente_id IS NOT NULL;

    INSERT INTO staging.violacao_fato_venda (
        data_venda, id_cliente_oltp, id_produto_oltp, quantidade, preco_unitario, motivo_violacao
    )
    SELECT 
        v.data_venda, v.cliente_id, vp.produto_id, vp.quantidade, vp.preco_unitario_historico,
        'Quantidade nula/negativa ou cliente não identificado'
    FROM oltp.venda v
    JOIN oltp.venda_has_produto vp ON v.id = vp.venda_id
    WHERE vp.quantidade <= 0 OR v.cliente_id IS NULL;

    INSERT INTO staging.stg_fato_producao (
        data_inicio, data_fim, id_maquina_oltp, id_produto_oltp, id_insumo_oltp, 
        quantidade_produzida, quantidade_insumo, custo_energia, desperdicio, falhas, tempo_impressao_minutos
    )
    SELECT 
        p.data_inicio, p.data_fim, p.maquina_id, pp.produto_id, pi.insumo_id,
        pp.quantidade_produzida, pi.quantidade_utilizada, p.custo_energy_estimado,
        ISNULL(p.desperdicio, 0), ISNULL(p.falhas, 0),
        DATEDIFF(MINUTE, p.data_inicio, p.data_fim) -- Cálculo do tempo em minutos
    FROM oltp.producao p
    JOIN oltp.produto_has_producao pp ON p.id = pp.producao_id
    JOIN oltp.producao_has_insumo pi ON p.id = pi.producao_id
    WHERE p.data_fim IS NOT NULL AND p.data_inicio <= p.data_fim AND pp.quantidade_produzida > 0;

    INSERT INTO staging.violacao_fato_producao (
        data_inicio, data_fim, id_maquina_oltp, id_produto_oltp, id_insumo_oltp, quantidade_produzida, motivo_violacao
    )
    SELECT 
        p.data_inicio, p.data_fim, p.maquina_id, pp.produto_id, pi.insumo_id, pp.quantidade_produzida,
        'Data de fim inválida/nula, datas invertidas ou quantidade produzida nula'
    FROM oltp.producao p
    JOIN oltp.produto_has_producao pp ON p.id = pp.producao_id
    JOIN oltp.producao_has_insumo pi ON p.id = pi.producao_id
    WHERE p.data_fim IS NULL OR p.data_inicio > p.data_fim OR pp.quantidade_produzida <= 0;

    PRINT 'Procedimento: Staging dos Fatos e Violações carregado com sucesso.';
END;
GO