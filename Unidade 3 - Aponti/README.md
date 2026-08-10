# Análise de Acidentes - Polícia Rodoviária Federal (PRF) com SQL

## Contexto
Este repositório/documento descreve a estrutura e os scripts SQL desenvolvidos para a análise da base de dados de acidentes registrados pela Polícia Rodoviária Federal (PRF). Os scripts são projetados para rodar em **SQLite** e focam na exploração, agregação e criação de bases modeláveis para entender os fatores relacionados a acidentes fatais.

## Estrutura dos Scripts SQL

O arquivo fornecido contém queries para diversas finalidades, organizadas de forma lógica:

### 1. Verificações Iniciais
- `SELECT sqlite_version()`: Retorna a versão do SQLite.
- `PRAGMA table_info(acidentes_prf_2025)`: Exibe a estrutura (colunas e tipos) da tabela bruta.
- `COUNT(*)`: Conta o total de ocorrências.

### 2. Criação da View Base (`vw_acidentes_base`)
Cria uma *view* essencial que introduz a flag binária `acidente_fatal`.
- **Regra:** Se o número de `mortos` for maior ou igual a 1, recebe `1` (fatal); caso contrário, recebe `0`.

### 3. Análise Exploratória e Agregações (Focadas na Letalidade)
Os scripts extraem métricas cruzando diversas variáveis com a taxa de acidentes fatais (`perc_fatais`), sempre filtrando amostras com pelo menos 100 casos:
- **Geografia:** Agregação por Estado (UF) e o TOP 30 Rodovias (BRs) mais letais.
- **Temporal:** Evolução por Ano e Mês.
- **Causas e Tipos:** Análise bivariada por `tipo_acidente` e o TOP 30 `causa_acidente` com maior letalidade.
- **Condições da Via e Clima:** Gravidade por `fase_dia`, `condicao_metereo` e `tipo_pista`.
- **Cruzamento Multivariado:** Combinação de Fatores (Tipo de Pista + Fase do Dia).

### 4. Análise de "Lift"
Um cálculo estatístico avançado (`WITH taxa_global`) para avaliar o *Efeito Lift*.
- Ele compara a letalidade de um `tipo_acidente` específico em relação à taxa de letalidade média global da base, identificando cenários onde o risco de morte é estatisticamente muito superior ao normal.

### 5. Views para Relatórios e Modelagem (Feature Engineering)
Criação de *views* prontas para consumo por ferramentas de BI ou modelos de Machine Learning:
- `vw_indicadores_mensais`: Consolida acidentes e letalidade por ano e mês.
- `vw_indicadores_uf_br`: Consolidação geográfica cruzando Estado e Rodovia.
- `vw_base_analitica`: Seleção refinada das colunas essenciais, já contendo o marcador `acidente_fatal`.
- `vw_base_modelavel_preliminar`: Preparação final dos dados (Feature Selection), descartando variáveis pós-fato (como número de feridos) e focando em atributos do ambiente, tempo e via para prever a flag `acidente_fatal`.

## Objetivo
O principal objetivo desses scripts é criar um fluxo de engenharia de dados (Data Prep) para facilitar análises gerenciais em dashboards e preparar uma tabela estruturada que servirá como *input* (base modelável) para um futuro modelo preditivo sobre a letalidade dos acidentes rodoviários.
