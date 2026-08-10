# Análise de Acidentes - Polícia Rodoviária Federal (PRF)

## Contexto
Este repositório/documento descreve o conteúdo do arquivo Excel referente ao Módulo 02, que contém a base de dados de acidentes registrados pela Polícia Rodoviária Federal (PRF). O objetivo deste material é explorar, consolidar e analisar os dados de trânsito para extrair insights sobre causas, gravidade e condições dos acidentes nas rodovias federais.

## Estrutura do Arquivo
O arquivo Excel está dividido nas seguintes abas (planilhas):

### 1. `dados`
Contém a base de dados principal com **72.529 registros** de acidentes e **32 colunas**.  
Principais variáveis incluem:
- **Localização e Tempo:** `data_inversa`, `dia_semana`, `horario`, `uf`, `br`, `km`, `municipio`, `mes`
- **Detalhes do Acidente:** `causa_acidente`, `tipo_acidente`, `classificacao_acidente`, `fase_dia`, `condicao_metereologica`, `tipo_pista`
- **Vítimas e Envolvidos:** `pessoas`, `mortos`, `feridos_leves`, `feridos_graves`, `ilesos`, `veiculos`
- **Marcadores:** `acidente_fatal`

### 2. `dicionario_resumido`
Apresenta o dicionário de dados da base, explicando o significado das variáveis e facilitando a compreensão técnica das colunas presentes na aba de dados.

### 3. `tabelas`
Contém tabelas de resumo estáticas criadas a partir dos dados brutos, agrupando informações essenciais para análise direta.

### 4. `tabelas_dinamicas`
Apresenta tabelas dinâmicas (*Pivot Tables*) utilizadas para explorar as relações multivariadas dos dados, permitindo a visualização de métricas como o número de acidentes por UF, causas mais comuns e gravidade.

### 5. `graficos`
Painel com representações visuais (gráficos) elaborados a partir das tabelas dinâmicas e de resumo, facilitando a identificação de tendências e padrões.

### 6. `observacoes`
Contém as **Observações da Exploração - Base PRF**. Aqui estão listados os principais insights, hipóteses validadas e conclusões obtidas durante a análise exploratória dos dados.

## Objetivo da Análise
O objetivo central destas análises em Excel é organizar, limpar e visualizar dados para responder a perguntas de negócios essenciais sobre segurança viária, como a identificação dos maiores causadores de acidentes com vítimas e a relação das condições da via com a gravidade das ocorrências.
