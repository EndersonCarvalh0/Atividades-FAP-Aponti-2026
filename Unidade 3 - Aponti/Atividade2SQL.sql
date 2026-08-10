-- VERIFICAR A VERSÃO DO SQLITE
SELECT sqlite_version() AS versao_sqlite;

-- EXIBIR A ESTRUTURA DA TABELA IMPORTADA
PRAGMA table_info(acidentes_prf_2025);

-- CONTAR O TOTAL DE REGISTROS/OCORRÊNCIAS
SELECT COUNT(*) AS total_ocorrencias
FROM acidentes_prf_2025;

-- EXCLUIR A VIEW BASE SE JÁ EXISTIR (evita erro de duplicidade)
DROP VIEW IF EXISTS vw_acidentes_base;

-- CRIAR A VIEW BASE COM A FLAG acidente_fatal
CREATE VIEW vw_acidentes_base AS
SELECT
    *,
    CASE
        WHEN CAST(mortos AS INTEGER) >= 1 THEN 1
        ELSE 0
    END AS acidente_fatal
FROM acidentes_prf_2025;

-- Conferência rápida:
SELECT acidente_fatal, COUNT(*) AS qtd
FROM vw_acidentes_base
GROUP BY acidente_fatal;

-- MÉTRICAS GERAIS: total de acidentes, total de fatais, % letalidade
SELECT
    COUNT(*) AS total_acidentes,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(100.0 * SUM(acidente_fatal) / COUNT(*), 2) AS perc_fatais
FROM vw_acidentes_base;

-- AGREGAÇÃO POR ESTADO (UF) — só estados com >= 100 casos
SELECT
    uf,
    COUNT(*) AS total_acidentes,
    SUM(acidente_fatal) AS acidentes_fatais,
    SUM(CAST(mortos AS INTEGER)) AS total_mortos,
    ROUND(100.0 * SUM(acidente_fatal) / COUNT(*), 2) AS perc_fatais
FROM vw_acidentes_base
GROUP BY uf
HAVING COUNT(*) >= 100
ORDER BY perc_fatais DESC;

-- TOP 30 RODOVIAS (BRs) MAIS LETAIS EM NÚMERO ABSOLUTO DE MORTOS
SELECT
    br,
    COUNT(*) AS total_acidentes,
    SUM(CAST(mortos AS INTEGER)) AS total_mortos,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(100.0 * SUM(acidente_fatal) / COUNT(*), 2) AS perc_fatais
FROM vw_acidentes_base
WHERE br IS NOT NULL AND br <> ''
GROUP BY br
HAVING COUNT(*) >= 100
ORDER BY total_mortos DESC
LIMIT 30;

-- EVOLUÇÃO TEMPORAL POR ANO E MÊS
SELECT
    CAST(strftime('%Y', data_inversa) AS INTEGER) AS ano,
    CAST(strftime('%m', data_inversa) AS INTEGER) AS mes,
    COUNT(*) AS total_acidentes,
    SUM(CAST(mortos AS INTEGER)) AS total_mortos,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(100.0 * SUM(acidente_fatal) / COUNT(*), 2) AS perc_fatais
FROM vw_acidentes_base
GROUP BY ano, mes
ORDER BY ano, mes;

-- ANÁLISE BIVARIADA: TIPO DE ACIDENTE x % DE OCORRÊNCIAS FATAIS
SELECT
    tipo_acidente,
    COUNT(*) AS total_acidentes,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(100.0 * SUM(acidente_fatal) / COUNT(*), 2) AS perc_fatais
FROM vw_acidentes_base
GROUP BY tipo_acidente
HAVING COUNT(*) >= 100
ORDER BY perc_fatais DESC;

-- TOP 30 PRINCIPAIS CAUSAS ORDENADAS PELA MAIOR TAXA DE LETALIDADE
SELECT
    causa_acidente,
    COUNT(*) AS total_acidentes,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(100.0 * SUM(acidente_fatal) / COUNT(*), 2) AS perc_fatais
FROM vw_acidentes_base
GROUP BY causa_acidente
HAVING COUNT(*) >= 100
ORDER BY perc_fatais DESC
LIMIT 30;

-- GRAVIDADE POR FASE DO DIA (noite, pleno dia, etc.)
SELECT
    fase_dia,
    COUNT(*) AS total_acidentes,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(100.0 * SUM(acidente_fatal) / COUNT(*), 2) AS perc_fatais
FROM vw_acidentes_base
GROUP BY fase_dia
HAVING COUNT(*) >= 100
ORDER BY perc_fatais DESC;

-- INFLUÊNCIA DA CONDIÇÃO METEOROLÓGICA NO % DE ACIDENTES FATAIS
SELECT
    condicao_metereo,
    COUNT(*) AS total_acidentes,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(100.0 * SUM(acidente_fatal) / COUNT(*), 2) AS perc_fatais
FROM vw_acidentes_base
GROUP BY condicao_metereo
HAVING COUNT(*) >= 100
ORDER BY perc_fatais DESC;

-- LETALIDADE POR TIPO DE PISTA (simples, dupla, múltipla)
SELECT
    tipo_pista,
    COUNT(*) AS total_acidentes,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(100.0 * SUM(acidente_fatal) / COUNT(*), 2) AS perc_fatais
FROM vw_acidentes_base
GROUP BY tipo_pista
HAVING COUNT(*) >= 100
ORDER BY perc_fatais DESC;

-- COMBINAÇÃO DE DOIS FATORES: TIPO DE PISTA + FASE DO DIA
SELECT
    tipo_pista,
    fase_dia,
    COUNT(*) AS total_acidentes,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS cobertura_perc,
    ROUND(100.0 * SUM(acidente_fatal) / COUNT(*), 2) AS perc_fatais
FROM vw_acidentes_base
GROUP BY tipo_pista, fase_dia
HAVING COUNT(*) >= 100
ORDER BY perc_fatais DESC;

-- EFEITO "LIFT"
WITH taxa_global AS (
    SELECT 1.0 * SUM(acidente_fatal) / COUNT(*) AS taxa
    FROM vw_acidentes_base
)
SELECT
    tipo_acidente,
    COUNT(*) AS total_acidentes,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS cobertura_perc,
    ROUND(1.0 * SUM(acidente_fatal) / COUNT(*), 4) AS confianca,
    ROUND((1.0 * SUM(acidente_fatal) / COUNT(*)) / taxa, 2) AS lift
FROM vw_acidentes_base
CROSS JOIN taxa_global
GROUP BY tipo_acidente, taxa
HAVING COUNT(*) >= 100
ORDER BY lift DESC;

-- VIEW vw_indicadores_mensais — para relatórios temporais
DROP VIEW IF EXISTS vw_indicadores_mensais;

CREATE VIEW vw_indicadores_mensais AS
SELECT
    CAST(strftime('%Y', data_inversa) AS INTEGER) AS ano,
    CAST(strftime('%m', data_inversa) AS INTEGER) AS mes,
    COUNT(*) AS total_acidentes,
    SUM(CAST(mortos AS INTEGER)) AS total_mortos,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(100.0 * SUM(acidente_fatal) / COUNT(*), 2) AS perc_fatais
FROM vw_acidentes_base
GROUP BY ano, mes;

-- Conferência da view:
SELECT * FROM vw_indicadores_mensais ORDER BY ano, mes;

-- VIEW vw_indicadores_uf_br — consolidada por localização
DROP VIEW IF EXISTS vw_indicadores_uf_br;

CREATE VIEW vw_indicadores_uf_br AS
SELECT
    uf,
    br,
    COUNT(*) AS total_acidentes,
    SUM(CAST(mortos AS INTEGER)) AS total_mortos,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(100.0 * SUM(acidente_fatal) / COUNT(*), 2) AS perc_fatais
FROM vw_acidentes_base
WHERE br IS NOT NULL AND br <> ''
GROUP BY uf, br;

-- Conferência da view (Visão Agregada para o dashboard):
SELECT * FROM vw_indicadores_uf_br ORDER BY total_mortos DESC;

-- BASE ANALÍTICA CONSOLIDADA (colunas essenciais + acidente_fatal)
DROP VIEW IF EXISTS vw_base_analitica;

CREATE VIEW vw_base_analitica AS
SELECT
    data_inversa,
    dia_semana,
    horario,
    uf,
    br,
    municipio,
    causa_acidente,
    tipo_acidente,
    classificacao_ac,
    fase_dia,
    condicao_metereo,
    tipo_pista,
    tracado_via,
    uso_solo,
    CAST(mortos AS INTEGER) AS mortos,
    acidente_fatal
FROM vw_acidentes_base;

SELECT * FROM vw_base_analitica LIMIT 20;

-- BASE PRELIMINAR PARA MODELAGEM

DROP VIEW IF EXISTS vw_base_modelavel_preliminar;

CREATE VIEW vw_base_modelavel_preliminar AS
SELECT
    uf,
    br,
    municipio,
    CAST(strftime('%m', data_inversa) AS INTEGER) AS mes,
    dia_semana,
    fase_dia,
    causa_acidente,
    tipo_acidente,
    condicao_metereo,
    tipo_pista,
    tracado_via,
    uso_solo,
    acidente_fatal
FROM vw_acidentes_base;

-- Conferência da view
SELECT * FROM vw_base_modelavel_preliminar LIMIT 20;