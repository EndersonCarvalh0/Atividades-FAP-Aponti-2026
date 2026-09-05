# Projeto PRF 2025 - Relatório Analítico EDA (Módulo 5)

Pipeline de análise exploratória de dados (EDA) e geração do relatório analítico dos
acidentes registrados pela Polícia Rodoviária Federal (PRF) em 2025. Este projeto parte da
**base analítica** exportada pelo Módulo 4 e produz um relatório reprodutível em `.docx`,
com indicadores, rankings, séries temporais, análise bivariada, combinações de fatores e
síntese de hipóteses.

---

## 1. Objetivo

Transformar a base analítica da PRF 2025 em um relatório completo de EDA para:
- Consolidar os achados da Compreensão e Preparação dos Dados (Módulo 4) em um documento
  de leitura corrida, com tabelas e gráficos;
- Servir de insumo para o dashboard no Power BI (Módulo 6);
- Registrar hipóteses e limitações que orientem a árvore de decisão (Módulo 7).

O projeto segue a fase de **Modelagem descritiva / Avaliação** do CRISP-DM, aplicando o
roteiro de EDA: indicadores → rankings/séries → análise bivariada com o alvo → combinações
de fatores → síntese de hipóteses.

---

## 2. Variável-alvo

`acidente_fatal` (herdada da base analítica do Módulo 4):
- `1` quando `mortos >= 1`
- `0` quando `mortos = 0`

Reservado o indicador `mortos` (contagem absoluta de óbitos) como métrica complementar de
gravidade, para não confundir "acidente com pelo menos uma vítima fatal" com "número de
mortos por acidente".

---

## 3. Fontes de dados

| Arquivo | Papel no projeto |
|---|---|
| `base_analitica_prf_2025.csv` | Base principal — 72.529 registros, saída do Módulo 4 |
| `Base_Relatório.pdf` | Roteiro de tópicos exigidos no relatório (fornecido pela atividade) |
| `Modelo_Relatorio_Analitico_EDA.docx` | Modelo de estrutura e formatação do relatório final |
| `Atividade2SQL.sql` | Consultas de apoio (views `vw_acidentes_base`, `vw_indicadores_mensais`, `vw_indicadores_uf_br`) usadas para validar os agregados antes de irem para o relatório |
| `AtividadeFrequências.ipynb`, `GráficosIndicadores.ipynb` | Notebooks de apoio com análises de frequência e gráficos preliminares |
| `modulo_02_excel_prf_enderson.xlsx` | Conferência cruzada de indicadores feita em planilha |
| IBGE — Estimativas da População 2025 (DOU, referência 01/07/2025) | Dado externo usado para enriquecer os rankings por UF/região com mortos e acidentes por 100 mil habitantes |

O arquivo `base_analitica_prf_2025.csv` **não é alterado** neste módulo; todo cálculo é
feito em memória (`pandas`) e todo artefato gerado (gráficos, tabelas, relatório) vai para
`relatorios/` e `dashboards/`.

---

## 4. Requisitos para rodar o pipeline

### 4.1. Ambiente
- Python ≥ 3.9 (cálculo dos indicadores e geração dos gráficos)
- Node.js ≥ 18 (montagem do documento `.docx`)
- LibreOffice (`soffice`), opcional, apenas para conferência visual via conversão para PDF

### 4.2. Bibliotecas utilizadas

| Biblioteca | Uso no projeto | Instalação |
|---|---|---|
| `pandas` | Leitura, agregações, rankings, séries temporais, correlação | `pip install pandas` |
| `matplotlib` | Geração de todos os gráficos do relatório (PNG) | `pip install matplotlib` |
| `Pillow` (PIL) | Leitura de dimensões das imagens para dimensionamento no `.docx` | `pip install pillow` |
| `docx` (Node) | Montagem do documento final `.docx` (títulos, tabelas, imagens) | `npm install docx` |

```bash
pip install pandas matplotlib pillow --break-system-packages
npm install docx
```

### 4.3. Arquivos de entrada
Antes de rodar, garanta que `base_analitica_prf_2025.csv` esteja disponível (saída do
Módulo 4) e que a tabela de população do IBGE por UF (Estimativas 2025) esteja anotada no
script de análise — os valores usados neste relatório já estão fixados no código, já que a
fonte é uma publicação oficial pontual (DOU), não uma API.

---

## 5. Estrutura de pastas

```
.
├── dados_tratados/       # base_analitica_prf_2025.csv (herdada do Módulo 4) - não é sobrescrita
├── analise/              # scripts de cálculo dos indicadores (analysis.py, analysis2.py)
├── graficos/             # PNGs gerados (charts.py) - boxplot, pareto, rankings, heatmap, correlação
├── relatorios/           # build_report.js e o relatório final (.docx / .pdf de conferência)
├── sql/                  # Atividade2SQL.sql - consultas de apoio e views de conferência
├── notebooks/            # AtividadeFrequências.ipynb, GráficosIndicadores.ipynb
├── dashboards/           # reservado para o Módulo 6 (Power BI)
├── apresentacao/         # reservado para material de apresentação
└── README.md             # este arquivo
```

---

## 6. Como executar

1. Confirme que `base_analitica_prf_2025.csv` está acessível ao script de análise.
2. Rode os scripts de cálculo (`analysis.py`, `analysis2.py`) para gerar os indicadores,
   rankings, séries temporais, combinações e a matriz de correlação.
3. Rode `charts.py` para gerar todos os gráficos em PNG (boxplot, histograma, Pareto,
   rankings, séries, heatmap, correlação).
4. Rode `build_report.js` (Node) para montar o relatório final em `.docx`, incorporando
   tabelas e imagens.
5. (Opcional) Converta o `.docx` para `.pdf` via `soffice --headless --convert-to pdf`
   apenas para conferência visual das páginas antes da entrega.
6. Confira o **checklist de saída** (seção 9 abaixo).

---

## 7. Principais decisões de análise

| Decisão | Regra adotada |
|---|---|
| Filtro mínimo de volume em rankings | Categorias com menos de 100 registros são excluídas das tabelas de % fatal, para evitar percentuais instáveis |
| Outliers de `mortos` | IQR descartado (mediana/quartis = 0 pela predominância de zeros); usado corte substantivo em `mortos >= 2` |
| Traçado da via (`tracado_via`) | Campo multivalorado (`;`) decomposto em flags binárias (`tem_curva`, `tem_declive`, `tem_reta` etc.) para evitar duplicidade por ordem de concatenação |
| Enriquecimento populacional | Cruzamento por UF e por região com a população do IBGE (2025), para calcular mortos/100 mil hab. ao lado do % fatal por acidente |
| Região | Mapeada a partir da UF (Norte, Nordeste, Centro-Oeste, Sudeste, Sul) — não vem pronta na base |
| Lift | Calculado como (taxa de letalidade da categoria) / (taxa de letalidade global), para medir associação relativa ao alvo |
| Correlação | Pearson, apenas entre variáveis numéricas de gravidade e o alvo — não usada para inferir causalidade |

O detalhamento de cada achado (evidência, comparação, hipótese e limitação) fica registrado
nas seções de síntese do relatório final (Seções 7 e EXTRA 8).

---

## 8. Estrutura do relatório gerado

1. Sumário executivo
2. Estatística descritiva e indicadores globais
3. Rankings — onde os eventos acontecem (UF, região, tipo de acidente)
4. Séries temporais (mensal, turno, dia da semana)
5. Análise bivariada (tipo de acidente, causa, clima/turno, pista/uso do solo, traçado da via)
6. Combinações de fatores e correlação
7. Síntese, hipóteses e limitações
8. EXTRA — Interpretação, hipóteses e limites (achados complementares, sem repetir a Seção 7)

---

## 9. Checklist final da entrega

- Todos os indicadores da Seção 2 recalculados a partir da base analítica, sem números
  hardcoded fora do script de análise
- Tabelas de ranking aplicam o filtro mínimo de 100 registros
- Todos os gráficos referenciados no texto existem em `graficos/` e têm legenda descritiva
- Enriquecimento com dados do IBGE citando a fonte (Estimativas da População 2025, DOU)
- Seção 7 e Seção 8 revisadas para evitar achados duplicados entre si
- Relatório `.docx` gerado sem overflow de tabelas (conferido via conversão para PDF)
- Fonte de cada dado externo (IBGE) citada explicitamente no corpo do texto

---

## 10. Observações e limitações conhecidas

- A população do IBGE usada é uma **estimativa** (Estimativas da População, referência
  01/07/2025), não uma contagem censitária exata; pequenas variações não mudam a leitura
  geral dos rankings.
- O campo `tracado_via` permite múltiplas características por registro (ex.:
  `"CURVA;DECLIVE"` e `"DECLIVE;CURVA"` descrevem o mesmo trecho); a decomposição em flags
  binárias resolve a duplicidade por ordem, mas não diferencia intensidade da curva ou do
  declive, apenas presença/ausência.
- `causa_acidente` e `tipo_acidente` são atribuídos pelo policial rodoviário no boletim de
  ocorrência, sujeitos a critério humano e a variações de padronização entre regionais —
  limitação herdada da fonte primária, não introduzida neste módulo.
- A análise é descritiva e associativa (proporções, rankings, lift e correlação); não
  permite inferir causalidade nem deve embasar decisões operacionais isoladamente.
- Categorias com poucos registros (causas com menos de 100 ocorrências, UF como RR, AM e
  AC) foram excluídas das tabelas de ranking para evitar percentuais instáveis, o que reduz
  a representatividade de regiões menos monitoradas.
