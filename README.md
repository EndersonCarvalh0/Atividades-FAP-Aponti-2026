 Documentação Consolidada do Projeto: Análise de Acidentes em Rodovias Federais (PRF 2025)

**Autor:** Enderson dos Santos Carvalho  
**Tema:** Acidentes de Trânsito em Rodovias Federais Brasileiras  
**Fonte de Dados:** Base Aberta da Polícia Rodoviária Federal (PRF) 2025

Este repositório consolida as entregas das quatro primeiras unidades do curso, demonstrando a evolução do entendimento do negócio, exploração inicial, estruturação via banco de dados e a preparação de dados para machine learning e BI.

---

## Unidade 1: Fundamentos de Data Analytics (Compreensão do Negócio)

**Objetivo:** Definir o escopo do problema e estruturar a abordagem analítica utilizando o framework CRISP-DM.
- **Contexto:** Acidentes nas rodovias federais e a necessidade de identificar atributos para reduzir ocorrências.
- **Público-Alvo:** Órgãos governamentais e consumidores de análise de dados.
- **Variável-Alvo:** Causa do acidente e a identificação de acidentes com vítimas fatais.
- **Pergunta de Negócio:** *"Quais fatores estão associados a acidentes com vítimas fatais nas rodovias federais brasileiras?"*
- **Limitações:** A análise considerará restrições, como a associação da gravidade com tipos específicos de veículos (motos, caminhões, etc.).

---

## Unidade 2: Excel para Análise de Dados (Exploração Inicial)

**Objetivo:** Iniciar a exploração e limpeza básica dos dados (72.529 registros) através de planilhas eletrônicas.
- **Arquivo de Referência:** `modulo_02_excel_prf_enderson.xlsx`
- **Conteúdo das Abas:**
  - `dados`: Base bruta com variáveis de tempo, localização, ambiente e vítimas.
  - `dicionario_resumido`: Metadados das colunas.
  - `tabelas` e `tabelas_dinamicas`: Agrupamentos para análise de letalidade e causas principais.
  - `graficos`: Painéis visuais para identificar padrões.
  - `observacoes`: Registro de insights e hipóteses iniciais.

---

## Unidade 3: SQL com DuckDB ou SQLite (Estruturação e Agregação)

**Objetivo:** Desenvolver scripts em SQL para escalar a análise, realizar agregações complexas e criar *views* analíticas.
- **Arquivo de Referência:** `Atividade2SQL.sql`
- **Principais Etapas:**
  - **View Base:** Criação da flag `acidente_fatal` (1 para mortos >= 1, 0 para mortos = 0).
  - **Métricas:** Consultas para calcular o percentual de letalidade cruzando estado, rodovia, causas, tipo de pista, clima e período do dia.
  - **Efeito Lift:** Consulta estatística para avaliar o risco de morte de tipos específicos de acidentes em relação à média global.
  - **Feature Engineering Preliminar:** Construção das *views* `vw_base_analitica` e `vw_base_modelavel_preliminar` para conectar com ferramentas de BI.

---

## Unidade 4: Preparação dos Dados com Python (Data Prep)

**Objetivo:** Desenvolver um pipeline reproduzível (ETL) em Python utilizando a biblioteca `pandas` para limpeza profunda e geração de ativos de dados finais.
- **Arquivos de Entrada:** `dados_abertos_prf-datatran2025.csv`
- **Decisões de Tratamento:**
  - Padronização de nomes de colunas (`snake_case`).
  - Conversão de tipos de dados (datas e números com separador de decimal corrigido).
  - Preenchimento de valores nulos (categóricos como "IGNORADO", numéricos como 0).
- **Ativos Gerados (em `dados_tratados/`):**
  1. **`base_analitica_prf_2025.csv`**: Base completa com variáveis derivadas do evento (mortos, feridos) destinada à Análise Exploratória (EDA) e Dashboards em Power BI.
  2. **`base_modelavel_prf_2025.csv`**: Base purificada estruturada para modelos de Machine Learning (Árvore de Decisão). **Garante ausência de *Data Leakage***, omitindo atributos pós-acidente para prever o alvo (`acidente_fatal`).
  3. **Dicionário de Variáveis**: Arquivo de suporte descrevendo os novos atributos gerados.
