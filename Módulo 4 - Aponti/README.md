# Projeto PRF 2025 - Preparação dos Dados (Módulo 4)

Pipeline de preparação de dados dos acidentes registrados pela Polícia Rodoviária Federal
(PRF) em 2025, agrupados por ocorrência. Este projeto transforma o arquivo bruto da PRF em
dois ativos analíticos reprodutíveis: uma **base analítica completa** (para EDA e Power BI)
e uma **base modelável sem data leakage** (para a árvore de decisão).

---

## 1. Objetivo

Preparar os dados de acidentes da PRF 2025 para:
- Análise Exploratória de Dados (Módulo 5);
- Dashboard no Power BI (Módulo 6);
- Árvore de decisão explicável (Módulo 7).

O projeto segue a fase de **Preparação dos Dados** do CRISP-DM, revisitando a Compreensão
dos Dados e deixando a base pronta para Modelagem, Avaliação e Comunicação.

---

## 2. Variável-alvo

`acidente_fatal`:
- `1` quando `mortos >= 1`
- `0` quando `mortos = 0`

Validada com teste lógico (`assert`) garantindo zero violações da regra antes da exportação.

---

## 3. Fonte de dados

- **Arquivo:** `dados_abertos_prf-datatran2025.csv`
- **Origem:** dados abertos da PRF, acidentes de 2025 agrupados por ocorrência.
- **Formato:** CSV com separador `;`, encoding `latin1` (ISO-8859-1), campos entre aspas.
- **Volume:** 72.529 linhas × 30 colunas na leitura bruta.
- **Particularidade:** os campos `km`, `latitude` e `longitude` usam vírgula como separador
  decimal (padrão brasileiro) - são convertidos para ponto antes da conversão numérica.

O arquivo bruto **não é versionado nem alterado**; toda transformação gera novos arquivos em
`dados_tratados/`.

---

## 4. Requisitos para rodar o notebook

### 4.1. Ambiente
- Google Colab (recomendado) ou Jupyter local com Python ≥ 3.9.
- Não é necessário GPU nem hardware especial - o processamento é feito inteiramente com
  `pandas` em memória (a base cabe tranquilamente em RAM padrão do Colab).

### 4.2. Bibliotecas utilizadas

| Biblioteca | Uso no projeto | Já vem no Colab? |
|---|---|---|
| `pandas` | Leitura, limpeza, transformação e exportação das bases | sim |
| `numpy` | Regras condicionais vetorizadas (`np.where`) para alvo e indicadores | sim |
| `matplotlib` | Gráfico de conferência da distribuição do alvo | sim |
| `pathlib` (stdlib) | Caminhos reprodutíveis entre sistemas operacionais | sim (padrão do Python) |
| `datetime` (stdlib) | Timestamp do log de decisões | sim (padrão do Python) |
| `unicodedata` (stdlib) | Remoção de acentos na padronização de nomes de colunas | sim (padrão do Python) |

Nenhuma instalação extra é necessária - todas as bibliotecas já vêm pré-instaladas no
Google Colab. Se for rodar localmente, basta:

```bash
pip install pandas numpy matplotlib
```

### 4.3. Arquivo de entrada
Antes de rodar, faça o upload do `dados_abertos_prf-datatran2025.csv` para a pasta
`dados_brutos/` (no Colab: ícone de pasta na lateral esquerda → clique com o botão direito
em `dados_brutos` → *Upload*).

---

## 5. Estrutura de pastas

```
.
├── dados_brutos/        # arquivo original da PRF - nunca é sobrescrito
├── dados_tratados/       # bases exportadas (analítica, modelável, dicionário)
├── notebooks/            # notebook do módulo
├── sql/                  # reservado para consultas futuras
├── dashboards/           # reservado para o Módulo 6 (Power BI)
├── relatorios/           # reservado para relatórios de apoio
├── apresentacao/         # reservado para material de apresentação
├── logs/                 # log de decisões de tratamento
└── README.md             # este arquivo
```

Essa estrutura é criada automaticamente pela primeira célula de código do notebook - não é
preciso criar nada manualmente.

---

## 6. Como executar

1. Abra o notebook `Modulo4_PRF_Preparacao_Dados.ipynb` no Google Colab.
2. Rode a célula que cria a estrutura de pastas.
3. Faça o upload de `dados_abertos_prf-datatran2025.csv` em `dados_brutos/`.
4. Execute as células em ordem, de cima para baixo (Kernel → Reiniciar e executar tudo,
   antes da entrega final, para garantir reprodutibilidade).
5. Ao final, confira o **checklist de saída** (seção 9 abaixo) - todos os itens devem
   retornar `True`/`OK`.

---

## 7. Principais decisões de tratamento

| Decisão | Regra adotada |
|---|---|
| Nomes de colunas | minúsculas, sem acento, `snake_case` |
| `km`, `latitude`, `longitude` | vírgula decimal trocada por ponto antes de `pd.to_numeric` |
| Colunas numéricas | `pd.to_numeric(errors="coerce")` |
| Datas | `pd.to_datetime(errors="coerce")` |
| Categorias ausentes relevantes | preenchidas como `"IGNORADO"` |
| Contagens de vítimas ausentes | preenchidas como `0` (hipótese operacional conservadora) |
| Duplicidade | remoção apenas de duplicidade exata (`df.duplicated()`) |
| Alvo | `acidente_fatal = 1` quando `mortos >= 1`, validado com `assert` |
| Separador de exportação | `;` (padrão da base PRF) |
| Encoding de exportação | `utf-8-sig` (compatível com Excel/Power BI, evita erro de acentuação) |

O detalhamento completo, com data e hora de geração, fica registrado automaticamente em
`logs/decisoes_tratamento_modulo4.md` a cada execução.

---

## 8. Bases geradas

- **`dados_tratados/base_analitica_prf_2025.csv`** - base completa para EDA e Power BI.
  Contém `mortos`, `feridos` e os indicadores de gravidade (`total_vitimas`,
  `indice_gravidade`, `acidente_grave`).
- **`dados_tratados/base_modelavel_prf_2025.csv`** - base para modelagem (árvore de
  decisão). Contém apenas variáveis explicativas pré-acidente + o alvo `acidente_fatal`.
  **Não contém** nenhuma variável derivada do desfecho.
- **`dados_tratados/dicionario_variaveis_modulo4.csv`** - dicionário das principais
  variáveis criadas no módulo (nome, descrição, uso previsto).

### Variáveis proibidas na base modelável (checadas por `verificar_data_leakage`)
`mortos`, `feridos`, `feridos_leves`, `feridos_graves`, `total_vitimas`,
`indice_gravidade`, `acidente_grave`, `classificacao_acidente`.

---

## 9. Checklist final da entrega

- Notebook executa do início ao fim sem erro (kernel reiniciado antes da entrega)
- Bases exportadas em `dados_tratados/` (analítica e modelável)
- README criado e atualizado
- Decisões de tratamento registradas em `logs/`
- `verificar_data_leakage()` retorna `"OK - nenhuma variável proibida encontrada."`
- Teste lógico do alvo (`assert`) sem violações
- Bases reabertas após exportação com dimensões validadas (`assert`)

---

## 10. Observações e limitações conhecidas

- O arquivo bruto do CSV usa vírgula decimal em `km`, `latitude` e `longitude` - apenas
  `km` é convertido, pois é a única dessas três exigida pelo roteiro do módulo. Latitude e
  longitude permanecem como texto e não são usadas em nenhuma etapa deste módulo.
- Colunas presentes na base mas fora do escopo do roteiro (`id`, `sentido_via`, `ilesos`,
  `ignorados`, `regional`, `delegacia`, `uop`) seguem para a base analítica normalmente e
  são automaticamente excluídas da base modelável pela seleção explícita de variáveis.
- Nulos em `regional`, `delegacia` e `uop` não são tratados individualmente por não fazerem
  parte da lista de categóricas relevantes do módulo nem das variáveis modeláveis.
