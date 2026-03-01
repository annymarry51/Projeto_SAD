USE Projeto_SAD;
GO

SET IDENTITY_INSERT oltp.categoria ON;
INSERT INTO oltp.categoria (id, nome) VALUES 
(1, 'Decoração'), 
(2, 'Cultura Geek'), 
(3, 'Utilidades Domésticas'), 
(4, 'Peças Técnicas');
SET IDENTITY_INSERT oltp.categoria OFF;
GO

SET IDENTITY_INSERT oltp.tema ON;
INSERT INTO oltp.tema (id, nome_tema) VALUES 
(1, 'Geral'), 
(2, 'Star Wars'), 
(3, 'Minimalista');
SET IDENTITY_INSERT oltp.tema OFF;
GO

SET IDENTITY_INSERT oltp.cliente ON;
INSERT INTO oltp.cliente (id, nome, cpf_cnpj, email, telefone, cidade, estado) VALUES 
(1, 'Carlos Eduardo', '11122233344', 'carlos.edu@email.pt', '912345678', 'Lisboa', 'Estremadura'),
(2, 'Maria Fernanda', '55566677788', 'maria.fer@email.pt', '965432198', 'Porto', 'Douro Litoral'),
(3, 'Loja Nerd Store', '12345678000199', 'contato@nerdstore.pt', '223334444', 'Coimbra', 'Beira Litoral');
SET IDENTITY_INSERT oltp.cliente OFF;
GO

SET IDENTITY_INSERT oltp.insumo ON;
INSERT INTO oltp.insumo (id, nome, unidade_medida, estoque_atual, custo_unitario, data_ultima_compra, plataforma_compra) VALUES 
(1, 'Filamento PLA Cinza', 'G', 5000.000, 0.12, '2023-10-01', 'Amazon'),
(2, 'Filamento ABS Preto', 'G', 3000.000, 0.09, '2023-10-05', 'Mercado Livre'),
(3, 'Filamento PETG Transparente', 'G', 2000.000, 0.15, '2023-10-10', 'Shopee'),
(4, 'Resina Standard', 'ML', 1000.000, 0.25, '2023-10-12', 'AliExpress');
SET IDENTITY_INSERT oltp.insumo OFF;
GO

SET IDENTITY_INSERT oltp.maquina ON;
INSERT INTO oltp.maquina (id, nome, status_maquina, marca, modelo, valor_aquisicao, vida_util_meses, consumo_watts) VALUES 
(1, 'Impressora 01', 'Ativa', 'Creality', 'Ender 3 V2', 250.00, 48, 350),
(2, 'Impressora 02', 'Ativa', 'Prusa', 'i3 MK3S+', 800.00, 60, 400),
(3, 'Impressora 03', 'Manutenção', 'Anycubic', 'Photon Mono 4K', 350.00, 36, 150);
SET IDENTITY_INSERT oltp.maquina OFF;
GO

SET IDENTITY_INSERT oltp.produto ON;
INSERT INTO oltp.produto (id, nome, preco_venda, estoque_atual, categoria_id, tema_id) VALUES 
(1, 'Vaso Low Poly Geométrico', 25.00, 15, 1, 3),
(2, 'Action Figure - Darth Vader', 80.00, 5, 2, 2),
(3, 'Suporte para Notebook', 35.00, 10, 3, 1),
(4, 'Engrenagem Industrial', 45.00, 20, 4, 1);
SET IDENTITY_INSERT oltp.produto OFF;
GO

SET IDENTITY_INSERT oltp.producao ON;
-- Inserimos 3 eventos de produção (Repare nas datas, desperdício e falhas)
INSERT INTO oltp.producao (id, data_inicio, data_fim, maquina_id, custo_energy_estimado, desperdicio, falhas) VALUES 
(1, '2023-11-01 08:00:00', '2023-11-01 14:30:00', 1, 1.50, 20, 0),
(2, '2023-11-02 09:00:00', '2023-11-03 01:00:00', 2, 4.20, 50, 1),
(3, '2023-11-03 10:00:00', '2023-11-03 16:00:00', 1, 1.80, 10, 0);
SET IDENTITY_INSERT oltp.producao OFF;
GO

INSERT INTO oltp.producao_has_insumo (producao_id, insumo_id, quantidade_utilizada) VALUES 
(1, 1, 300.000),
(2, 2, 450.000),
(3, 3, 250.000);
GO

INSERT INTO oltp.produto_has_producao (producao_id, produto_id, quantidade_produzida) VALUES 
(1, 1, 5),
(2, 2, 2), 
(3, 3, 4); 
GO

SET IDENTITY_INSERT oltp.venda ON;
INSERT INTO oltp.venda (id, data_venda, cliente_id, valor_total, custo_embalagem, custo_plataforma, nome_plataforma) VALUES 
(1, '2023-11-10 10:15:00', 1, 50.00, 5.00, 9.00, 'Mercado Livre'),
(2, '2023-11-12 14:20:00', 2, 80.00, 8.00, 0.00, 'Loja Física'),
(3, '2023-11-15 16:45:00', 3, 175.00, 15.00, 17.50, 'Shopee');
SET IDENTITY_INSERT oltp.venda OFF;
GO

INSERT INTO oltp.venda_has_produto (venda_id, produto_id, quantidade, preco_unitario_historico) VALUES 
(1, 1, 2, 25.00), 
(2, 2, 1, 80.00), 
(3, 3, 5, 35.00); 
GO
