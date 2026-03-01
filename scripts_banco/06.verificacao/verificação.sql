USE Projeto_SAD;
GO

-- -------------------------------------------------------------------------------------
-- a) Qual a margem de lucro média?
-- Margem (%) = (Faturamento Líquido / Faturamento Bruto) * 100
-- -------------------------------------------------------------------------------------
SELECT 
    AVG((valor_venda_liquido / NULLIF(valor_venda_bruto, 0)) * 100) AS Margem_Lucro_Media_Percentual
FROM dw.Fato_Venda;
GO

-- -------------------------------------------------------------------------------------
-- b) Qual o total de vendas realizadas (Por mês, Semana)?
-- -------------------------------------------------------------------------------------
SELECT 
    dt.ano,
    dt.mes,
    DATEPART(WEEK, dt.data) AS Semana_do_Ano,
    SUM(fv.quantidade_vendida) AS Total_Itens_Vendidos,
    COUNT(fv.id_produto) AS Numero_de_Transacoes
FROM dw.Fato_Venda fv
JOIN dw.Dim_Tempo dt ON fv.id_tempo = dt.id_tempo
GROUP BY dt.ano, dt.mes, DATEPART(WEEK, dt.data)
ORDER BY dt.ano DESC, dt.mes DESC, Semana_do_Ano DESC;
GO

-- -------------------------------------------------------------------------------------
-- c) Qual o tempo médio de impressão por produto?
-- -------------------------------------------------------------------------------------
SELECT 
    dp.nome AS Produto,
    AVG(fp.tempo_impressao_minutos) AS Tempo_Medio_Impressao_Minutos
FROM dw.Fato_Producao fp
JOIN dw.Dim_Produto dp ON fp.id_produto = dp.id_produto
GROUP BY dp.nome
ORDER BY Tempo_Medio_Impressao_Minutos DESC;
GO

-- -------------------------------------------------------------------------------------
-- d) Qual a taxa de desperdício (peças falhas) por impressora ou por tipo de material?
-- -------------------------------------------------------------------------------------
-- Por Impressora:
SELECT 
    dm.nome AS Impressora,
    SUM(fp.qtd_falhas_peca) AS Total_Pecas_Falhas,
    SUM(fp.qtd_desperdicio) AS Total_Desperdicio_Gramas
FROM dw.Fato_Producao fp
JOIN dw.Dim_Maquina dm ON fp.id_maquina = dm.id_maquina
GROUP BY dm.nome;

-- Por Tipo de Material:
SELECT 
    di.tipo_material AS Material,
    SUM(fp.qtd_falhas_peca) AS Total_Pecas_Falhas,
    SUM(fp.qtd_desperdicio) AS Total_Desperdicio_Gramas
FROM dw.Fato_Producao fp
JOIN dw.Dim_Insumo di ON fp.id_insumo = di.id_insumo
GROUP BY di.tipo_material;
GO

-- -------------------------------------------------------------------------------------
-- e) Quais são os produtos que apresentam o maior volume de vendas nos últimos seis meses?
-- -------------------------------------------------------------------------------------
SELECT 
    dp.nome AS Produto,
    SUM(fv.quantidade_vendida) AS Volume_Vendas
FROM dw.Fato_Venda fv
JOIN dw.Dim_Produto dp ON fv.id_produto = dp.id_produto
JOIN dw.Dim_Tempo dt ON fv.id_tempo = dt.id_tempo
WHERE dt.data >= DATEADD(MONTH, -6, GETDATE())
GROUP BY dp.nome
ORDER BY Volume_Vendas DESC;
GO

-- -------------------------------------------------------------------------------------
-- f) Qual o faturamento total bruto e líquido por período?
-- -------------------------------------------------------------------------------------
SELECT 
    dt.ano,
    dt.trimestre,
    dt.mes,
    SUM(fv.valor_venda_bruto) AS Faturamento_Bruto,
    SUM(fv.valor_venda_liquido) AS Faturamento_Liquido
FROM dw.Fato_Venda fv
JOIN dw.Dim_Tempo dt ON fv.id_tempo = dt.id_tempo
GROUP BY dt.ano, dt.trimestre, dt.mes
ORDER BY dt.ano, dt.mes;
GO

-- -------------------------------------------------------------------------------------
-- h) Quais categorias mais vendidas?
-- -------------------------------------------------------------------------------------
SELECT 
    dp.categoria AS Categoria,
    SUM(fv.quantidade_vendida) AS Total_Vendido
FROM dw.Fato_Venda fv
JOIN dw.Dim_Produto dp ON fv.id_produto = dp.id_produto
GROUP BY dp.categoria
ORDER BY Total_Vendido DESC;
GO

-- -------------------------------------------------------------------------------------
-- i) Quais conjuntos de modelo (Temas) mais vendidos?
-- -------------------------------------------------------------------------------------
SELECT 
    dp.tema AS Conjunto_Modelo_Tema,
    SUM(fv.quantidade_vendida) AS Total_Vendido
FROM dw.Fato_Venda fv
JOIN dw.Dim_Produto dp ON fv.id_produto = dp.id_produto
GROUP BY dp.tema
ORDER BY Total_Vendido DESC;
GO

-- -------------------------------------------------------------------------------------
-- k) Qual o tempo de impressão por peça de um produto?
-- (Total de minutos gastos a produzir dividida pela quantidade total de peças produzidas)
-- -------------------------------------------------------------------------------------
SELECT 
    dp.nome AS Produto,
    (SUM(fp.tempo_impressao_minutos) / NULLIF(SUM(fp.quantidade_produzida), 0)) AS Minutos_Por_Peca
FROM dw.Fato_Producao fp
JOIN dw.Dim_Produto dp ON fp.id_produto = dp.id_produto
GROUP BY dp.nome
ORDER BY Minutos_Por_Peca DESC;
GO

-- -------------------------------------------------------------------------------------
-- l) Qual o preço de cada peça de um produto (Preço Médio Praticado)?
-- -------------------------------------------------------------------------------------
SELECT 
    dp.nome AS Produto,
    AVG(fv.preco_unitario) AS Preco_Medio_Praticado
FROM dw.Fato_Venda fv
JOIN dw.Dim_Produto dp ON fv.id_produto = dp.id_produto
GROUP BY dp.nome;
GO

-- -------------------------------------------------------------------------------------
-- m) e n) Qual máquina apresenta mais defeitos (desperdício) e mais falhas nos produtos?
-- -------------------------------------------------------------------------------------
SELECT 
    dm.nome AS Maquina,
    SUM(fp.qtd_falhas_peca) AS Qtd_Pecas_Falhadas,
    SUM(fp.qtd_desperdicio) AS Qtd_Desperdicio_Material_Gramas
FROM dw.Fato_Producao fp
JOIN dw.Dim_Maquina dm ON fp.id_maquina = dm.id_maquina
GROUP BY dm.nome
ORDER BY Qtd_Pecas_Falhadas DESC, Qtd_Desperdicio_Material_Gramas DESC;
GO

-- -------------------------------------------------------------------------------------
-- o) Qual cliente compra mais produtos (por valor e por quantidade de peças)?
-- -------------------------------------------------------------------------------------
SELECT 
    dc.nome AS Cliente,
    dc.cidade AS Cidade_Cliente,
    SUM(fv.quantidade_vendida) AS Total_Pecas_Compradas,
    SUM(fv.valor_venda_liquido) AS Total_Gasto
FROM dw.Fato_Venda fv
JOIN dw.Dim_Cliente dc ON fv.id_cliente = dc.id_cliente
GROUP BY dc.nome, dc.cidade
ORDER BY Total_Gasto DESC, Total_Pecas_Compradas DESC;
GO