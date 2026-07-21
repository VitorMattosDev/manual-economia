#!/usr/bin/env bash
#
# auto-volumes.sh
# Gera os volumes restantes do manual de economia, um por um, sem supervisão:
#   1. chama o Claude Code em modo headless (-p) para escrever o volume
#   2. commita e faz push (git)
#   3. (opcional) confere se o GitHub Pages iniciou o build
#   4. se bater no limite de uso (sessão/semanal), o próprio Claude Code espera
#      o reset e continua — sem precisar de cron externo
#
# Roda em bash (Git Bash, WSL ou Linux/Mac). Deixe rodando em background
# (nohup, tmux ou screen) para sobreviver ao fechamento do terminal.
#
# Uso:
#   chmod +x auto-volumes.sh
#   nohup ./auto-volumes.sh > /dev/null 2>&1 &
#
set -uo pipefail

# ======================= AJUSTE AQUI =======================
REPO_DIR="C:\Users\Usuario\Desktop\MANUAIS\manual-economia"     # pasta do repositório git local
OUTLINE_FILE="C:\Users\Usuario\Desktop\MANUAIS\manual-economia\ROADMAP.md"                    # arquivo com o sumário/outline dos volumes (ajuste o nome)
TOTAL_VOLUMES=15                             # total de volumes do manual
START_VOLUME=9                               # a partir de qual volume continuar (mude se já tiver alguns feitos)
GH_PAGES_CHECK=true                          # true/false — usa `gh` CLI para conferir o deploy do Pages
# =============================================================

LOG_FILE="$REPO_DIR/auto-volumes.log"

cd "$REPO_DIR" || { echo "Não encontrei $REPO_DIR"; exit 1; }

# Faz o Claude Code esperar automaticamente o reset do limite de uso (sessão/semanal)
# em vez de falhar. Ele monitora o horário de reset informado pela API e retoma sozinho.
export CLAUDE_CODE_RETRY_WATCHDOG=1

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

check_pages_build() {
  if [ "$GH_PAGES_CHECK" != "true" ] || ! command -v gh >/dev/null 2>&1; then
    return
  fi
  log "Conferindo status do GitHub Pages..."
  # Ajuste o endpoint se seu Pages usa GitHub Actions (workflow) em vez do build clássico
  gh api "repos/{owner}/{repo}/pages/builds/latest" --jq '.status + " - " + (.error.message // "sem erro")' \
    >> "$LOG_FILE" 2>&1 || log "Não consegui checar o Pages (talvez use Actions, não build clássico)."
}

for ((vol=START_VOLUME; vol<=TOTAL_VOLUMES; vol++)); do
  log "=== Iniciando Volume $vol de $TOTAL_VOLUMES ==="

  PROMPT="Leia $OUTLINE_FILE para entender a estrutura do manual e o que já foi feito. Escreva o Volume $vol completo, seguindo o mesmo padrão, tom e formatação dos volumes anteriores já commitados neste repositório. Ao terminar, garanta que os arquivos estão salvos no lugar correto do projeto."

  # --permission-mode acceptEdits: aprova escrita de arquivo automaticamente
  # --allowedTools: libera as ferramentas necessárias sem pedir confirmação
  # Sem --continue/--resume: cada volume começa em sessão nova (equivalente ao /clear)
  claude -p "$PROMPT" \
    --permission-mode acceptEdits \
    --allowedTools "Bash,Read,Edit,Write,Glob,Grep" \
    --output-format json \
    >> "$LOG_FILE" 2>&1

  EXIT_CODE=$?
  if [ $EXIT_CODE -ne 0 ]; then
    log "Volume $vol falhou (exit code $EXIT_CODE). Interrompendo a rotina — revise $LOG_FILE."
    exit 1
  fi

  log "Volume $vol gerado pelo Claude Code."

  git add -A
  if git diff --cached --quiet; then
    log "AVISO: nenhuma alteração para commitar no Volume $vol — confira o log, algo pode ter dado errado."
  else
    git commit -m "Adiciona Volume $vol do manual de economia" >> "$LOG_FILE" 2>&1
    if git push >> "$LOG_FILE" 2>&1; then
      log "Volume $vol commitado e enviado ao GitHub."
    else
      log "Push do Volume $vol falhou. Interrompendo a rotina — revise $LOG_FILE."
      exit 1
    fi
  fi

  check_pages_build

  log "=== Volume $vol concluído ==="
  sleep 5
done

log "Rotina finalizada: volumes $START_VOLUME a $TOTAL_VOLUMES processados."
