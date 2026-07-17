# Manual de Economia

Manual educacional aberto e abrangente de **Economia**, em português brasileiro, parte da série *Manuais de Ciências*. Livro [Quarto](https://quarto.org) com saída dupla **HTML + PDF**, publicado via GitHub Actions em GitHub Pages.

- **Escopo:** 15 volumes, 108 capítulos, em 3 fases (ver [`ROADMAP.md`](ROADMAP.md)).
- **Público:** do leitor iniciante curioso ao estudante de graduação; sem pré-requisitos além de matemática de ensino médio.

## Como construir localmente

Pré-requisitos: [Quarto](https://quarto.org) ≥ 1.9 e uma distribuição TeX (TinyTeX). As figuras usam a extensão TikZ com patches locais em `_extensions/danmackinlay/tikz/` — **nunca** rode `quarto add`/`quarto update` sobre ela.

```bash
# adicione o bin do TinyTeX ao PATH da sessão (Windows)
export PATH="$HOME/AppData/Roaming/TinyTeX/bin/windows:$PATH"

quarto preview          # servidor local com recarga
quarto render           # gera _book/ (HTML + PDF)
```

## Estrutura

- `capitulos/volNN/` — capítulos em `.qmd`.
- `_quarto.yml` — configuração do livro (filtro `danmackinlay/tikz` antes de `quarto`).
- `referencias.bib` + `referencias-abnt.csl` — bibliografia (ABNT).
- `.github/workflows/publish.yml` — build e deploy automáticos.

## Licença

Conteúdo sob **CC BY-SA**.
