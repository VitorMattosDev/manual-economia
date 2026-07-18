# CLAUDE.md — Manual de Economia

Instruções permanentes para o Claude Code neste repositório. Leia este arquivo integralmente no início de cada sessão.

## O projeto

Manual educacional aberto e abrangente de **Economia**, em **português brasileiro**, parte da série *Manuais de Ciências*. Formato livro Quarto com saída dupla **HTML + PDF**, publicado via GitHub Actions em GitHub Pages.

- **Escopo:** 15 volumes, 108 capítulos, em 3 fases (ver `ROADMAP.md`)
- **Público:** do leitor iniciante curioso ao estudante de graduação; sem pré-requisitos além de matemática de ensino médio (o Volume 2 constrói o restante)
- **Capítulo gabarito:** `capitulos/vol01/cap01-o-que-e-economia.qmd` — é a referência canônica de estilo, tom, profundidade e anatomia. Antes de escrever qualquer capítulo novo, releia-o.

## Modo de execução autônoma

Você está **pré-aprovado** para: criar e editar arquivos, gerar figuras TikZ/SVG, rodar comandos de validação (`quarto render`, `quarto preview`) e fazer `git commit` ao final de cada capítulo — **sem pausar para pedir aprovação**. Pare somente diante de erro verdadeiramente bloqueante.

- **Formato de commit:** `cap NN: <título do capítulo>` (ex.: `cap 04: Elasticidades`). Para tarefas de infraestrutura: `infra: <descrição>`.
- **Windows:** use apenas flags simples `git commit -m "..."`. **Nunca** use here-strings do PowerShell (`@'...'@`) dentro do Bash — o caractere `@` vaza para a mensagem.
- **Fluxo de sessão:** um capítulo por sessão; `/clear` entre capítulos; `/compact` ao atingir ~80% do contexto; `/model opus` para escrever capítulos; `/model sonnet` para tarefas mecânicas (atualizar `_quarto.yml`, status no `ROADMAP.md`).
- **Estratégia de fatia vertical:** complete um volume inteiro antes de abrir o próximo; complete a Fase 1 antes da Fase 2. O `ROADMAP.md` é a fila autoritativa — atualize o status do capítulo (⬜ → ✅) no mesmo commit.

## Anatomia obrigatória de cada capítulo

Na ordem:

1. **Abertura** — parágrafo-gancho conectando o tema à vida real do leitor brasileiro (preços no supermercado, Selic, câmbio, contracheque…)
2. **Objetivos de aprendizagem** — lista curta "Ao final deste capítulo, você será capaz de…"
3. **Desenvolvimento** — seções `##` progressivas, com definições formais em callouts, derivações passo a passo e figuras TikZ para todo gráfico econômico
4. **`## 🇧🇷 Brasil em Foco`** — seção **obrigatória**: aplica a teoria do capítulo a dados e instituições reais do Brasil (IBGE, Bacen/SGS, IPEA, Tesouro Nacional, CADE, B3, PNAD Contínua, IPCA…). Cite as séries e fontes; quando citar números, prefira ordens de grandeza e períodos a valores que envelhecem mal, e sinalize a data de referência.
5. **`## Resumo do capítulo`** — bullets densos recapitulando cada conceito
6. **`## Exercícios`** — 6 a 10 exercícios em dificuldade crescente (conceituais → numéricos → análise de caso), cada um com solução completa em bloco colapsável:
   ```markdown
   ::: {.callout-tip collapse="true" title="Solução"}
   ...
   :::
   ```
7. **`## Para saber mais`** — leituras recomendadas com citações `@chave`

### Convenções de escrita

- Português brasileiro, tom didático e direto, segunda pessoa ("você"); rigor conceitual sem jargão gratuito — todo termo técnico é definido na primeira ocorrência (em **negrito**)
- Callouts Quarto: `.callout-note` (definições formais), `.callout-important` (armadilhas e erros comuns), `.callout-tip` (intuição e mnemônicos), `.callout-warning` (controvérsias e limites do modelo)
- **Pluralismo:** em temas com debate real entre escolas (papel do Estado, política fiscal, salário mínimo…), apresente as posições principais com seus melhores argumentos antes de qualquer síntese
- Referências cruzadas: `@sec-`, `@fig-`, `@tbl-`, `@eq-` sempre que citar outro ponto do manual
- Capítulos com ~2.500–4.500 palavras de corpo (fora exercícios)

### Matemática

- Notação LaTeX padrão via MathJax. **NÃO usar** os pacotes `siunitx`, `physics` nem `bussproofs` (quebram HTML/MathJax)
- Unidades e moeda em texto ou `\mathrm{}` com `\,` (ex.: `R\$\,100`, `5\,\%\ \text{a.a.}`)
- Equações numeradas importantes com rótulo: `$$ ... $$ {#eq-nome}`
- Toda derivação relevante é feita passo a passo; nunca "é fácil ver que"

### Bibliografia

- BibTeX em `referencias.bib` + CSL ABNT; citações no texto via `@chave` / `[@chave, p. 42]`
- Autores canônicos esperados: Mankiw, Varian, Pindyck & Rubinfeld, Blanchard, Krugman & Obstfeld, Mishkin, Wooldridge, Gremaud/Vasconcellos/Toneto (Economia Brasileira Contemporânea), Abreu (A Ordem do Progresso), Giambiagi, Thaler & Kahneman, Smith, Keynes, Marx
- Ao citar um autor pela primeira vez no manual, adicione a entrada ao `referencias.bib` no mesmo commit

## Figuras

**Divisão de responsabilidade:** TikZ para todo diagrama esquemático/didático (curvas de oferta e demanda, FPP, IS-LM, AD-AS, curvas de custo, caixa de Edgeworth, árvores de jogos, fluxo circular); SVG/PNG embutido ou placeholder para conteúdo fotográfico.

Sintaxe TikZ obrigatória:

```markdown
::: {#fig-oferta-demanda}

```{.tikz}
%%| filename: fig-oferta-demanda
%%| alt: Curvas de oferta e demanda com ponto de equilíbrio E.
\begin{tikzpicture}
  ...
\end{tikzpicture}
```

Equilíbrio de mercado: o encontro entre oferta e demanda.
:::
```

- Estilos predefinidos: `curva`, `destaque`, `auxiliar`, `eixo`, `ponto`, `vetor`; cores: `manualblue`, `manualred`, `manualgreen`, `manualyellow`, `manualgray`
- Convenção econômica: demanda em `manualblue`, oferta em `manualred`, equilíbrio marcado com `ponto` + linhas `auxiliar` tracejadas até os eixos; deslocamentos de curva com seta `vetor` e curva nova em tom mais claro
- Gráficos de função usam `pgfplots` quando precisar de curvas calculadas
- Referencie sempre via `@fig-nome`

## ⚠️ Toolchain — regras invioláveis

Estas regras existem porque cada uma custou horas de depuração em manuais anteriores. **Nunca as redescubra.**

1. **Extensão TikZ (`danmackinlay/tikz`) tem patches locais.** Os arquivos vivem em `_extensions/danmackinlay/tikz/`, vindos de `figuras-tikz-kit.zip`. **NUNCA execute `quarto add` ou `quarto update`** — isso baixa o upstream sem os patches e quebra a renderização. No `_quarto.yml`, o filtro `danmackinlay/tikz` deve vir **antes** de `quarto`, e `tikz: svg-engine: dvisvgm`.

2. **PATH do TinyTeX é o bloqueador recorrente.** `quarto install tinytex` NÃO adiciona o bin ao PATH da sessão. Sintoma: figura falha, `tikz.lua` com `imgdata nil` por volta da linha 587 — é PATH, não pacote faltando. Antes de qualquer render/preview, prependa ao PATH:
   - Windows: `$HOME/AppData/Roaming/TinyTeX/bin/windows`
   - Linux/macOS: `~/.TinyTeX/bin/<plataforma>`
   Instalação local: `quarto install tinytex` e depois `tlmgr install standalone pgf pgfplots dvisvgm xcolor amsmath amsfonts`.

3. **CI precisa de `chrome-headless-shell`.** O grafo mermaid de pré-requisitos no `index.qmd` trava o render de PDF em runners Ubuntu. Em `.github/workflows/publish.yml`, inclua o passo `run: quarto install chrome-headless-shell` **antes** do render/publish. Use `chrome-headless-shell`, não `chromium`. No CI, após setup do Quarto+TinyTeX, localize `tlmgr` via `find` se não estiver no PATH e rode o mesmo `tlmgr install`.

4. **`styles.css` precisa do marcador SCSS.** Como está listado em `theme: [cosmo, styles.css]`, o Quarto ≥1.9 o trata como camada SCSS e **exige** `/*-- scss:rules --*/` na primeira linha; sem isso, o render inteiro quebra ("doesn't contain at least one layer boundary").

5. **`lang: pt` na raiz** do `_quarto.yml`, nunca dentro de `book:`.

6. **Branch `gh-pages` deve pré-existir** antes do primeiro workflow (`quarto-actions/publish@v2` aborta sem ela):
   ```
   git push origin $(git commit-tree $(git hash-object -t tree /dev/null) -m 'init gh-pages'):refs/heads/gh-pages
   ```

7. **No CI, o bin do TinyTeX NÃO está no PATH e `tlmgr` precisa se autoatualizar antes de instalar.** Custou 4 builds vermelhos no primeiro deploy. O passo `Preparar TeX` do `publish.yml` deve, **antes** do render:
   - localizar `pdflatex` com `command -v` (ou `find ~ -name pdflatex` **sem** `-type f`, pois `pdflatex`/`tlmgr` são **symlinks** e `-type f` os ignora), derivar o bin e adicioná-lo a `$GITHUB_PATH`;
   - rodar **`tlmgr update --self`** antes de `tlmgr install ...` — em TeX Live novo (ex.: 2026), o `tlmgr` empacotado recusa instalar com "tlmgr itself needs to be updated" e **todo** `tlmgr install` falha em silêncio, deixando faltar `pgfplots.sty` e o binário `dvisvgm`;
   - linkar os binários em `/usr/local/bin` (sempre no PATH) como rede de segurança e **verificar** com `kpsewhich pgfplots.sty`/`standalone.cls` e `dvisvgm --version` (sem `|| true`, para falhar alto). Lembre: o template do TikZ sempre faz `\usepackage{pgfplots}`, então **toda** figura precisa de `pgfplots`, mesmo sem gráfico calculado.

## Validação por capítulo (antes do commit)

1. `quarto render capitulos/volNN/capNN-*.qmd --to html` sem erros nem warnings novos
2. Todas as figuras TikZ renderizaram (nenhum placeholder de erro)
3. Toda `@chave` citada existe em `referencias.bib`
4. Capítulo listado no `_quarto.yml` e status atualizado no `ROADMAP.md`
5. Seção 🇧🇷 Brasil em Foco presente e com fontes citadas
6. Exercícios com soluções colapsáveis completas
