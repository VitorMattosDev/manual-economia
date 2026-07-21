#!/usr/bin/env bash
#
# auto-manual.sh (v2) — genérico para qualquer manual da série Manuais de Ciências
#
# Requisitos no repositório: ROADMAP.md (fila com status ⬜/✅) e CLAUDE.md
# (instruções do projeto — o Claude Code carrega automaticamente).
# Opcional: PROMPT.md — se existir, seu conteúdo é incluído no prompt de cada sessão.
#
# O que mudou em relação à v1:
#   - UM CAPÍTULO por sessão (não um volume) — segue o fluxo do CLAUDE.md e
#     evita sessões gigantes que estouram contexto e custo
#   - fila dirigida pelo ROADMAP.md (conta os ⬜), não por números fixos
#   - quem commita é o Claude (formato do projeto); o script SEMPRE faz push
#     depois (corrige o bug do Volume 10, que ficou commitado sem push)
#   - erro de API (ex.: "Connection closed mid-response") não aborta mais:
#     retenta retomando a mesma sessão com --continue, até 3 vezes
#   - modelo fixado via MODEL (padrão: opus)
#
# Uso:
#   ./auto-manual.sh                       # roda no repositório onde o script está
#   ./auto-manual.sh /caminho/outro-manual # roda em outro manual da série
#   nohup ./auto-manual.sh > /dev/null 2>&1 &   # em background (não feche a janela no Git Bash)
#
set -uo pipefail

# ======================= AJUSTE AQUI =======================
MODEL="opus"          # opus | sonnet | haiku
MAX_RETRIES=3         # tentativas por capítulo em caso de erro de API
STALL_LIMIT=2         # sessões seguidas sem avanço no ROADMAP antes de abortar
# ===========================================================

REPO_DIR="${1:-$(cd "$(dirname "$0")" && pwd)}"
cd "$REPO_DIR" || { echo "Não encontrei $REPO_DIR"; exit 1; }

LOG_FILE="$REPO_DIR/auto-manual.log"
ROADMAP="ROADMAP.md"

# Espera automaticamente o reset do limite de uso (sessão/semanal) em vez de falhar
export CLAUDE_CODE_RETRY_WATCHDOG=1

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"; }

[ -f "$ROADMAP" ] || { log "ERRO: $ROADMAP não encontrado em $REPO_DIR"; exit 1; }

pending() { grep -o "⬜" "$ROADMAP" | wc -l | tr -d ' '; }

BASE_PROMPT="Consulte o ROADMAP.md e identifique o PRÓXIMO capítulo pendente (⬜), respeitando a ordem e a estratégia de fatia vertical. Antes de escrever, rode git status: se já houver arquivos desse capítulo iniciados e não commitados, revise-os e complete-os em vez de recomeçar do zero; descarte alterações espúrias (ex.: site_libs/) para manter o commit limpo. Escreva APENAS UM capítulo nesta sessão, seguindo integralmente o CLAUDE.md do projeto (anatomia, convenções, figuras, validação por capítulo). Ao final: valide, atualize o status no ROADMAP.md (⬜ → ✅) e faça o commit no formato do projeto, tudo no mesmo commit. NÃO faça push."

if [ -f "PROMPT.md" ]; then
  BASE_PROMPT="$(cat PROMPT.md)

$BASE_PROMPT"
fi

stalls=0
log "=== auto-manual iniciado em $REPO_DIR (modelo: $MODEL) ==="

while :; do
  P=$(pending)
  if [ "$P" -eq 0 ]; then
    log "ROADMAP zerado: todos os capítulos concluídos."
    break
  fi
  log "=== Capítulos pendentes: $P — iniciando o próximo ==="

  attempt=1
  ok=false
  resume=false
  OUT=""
  while [ "$attempt" -le "$MAX_RETRIES" ]; do
    if [ "$resume" = false ]; then
      OUT=$(claude -p "$BASE_PROMPT" \
        --model "$MODEL" \
        --permission-mode acceptEdits \
        --allowedTools "Bash,Read,Edit,Write,Glob,Grep" \
        --output-format json 2>>"$LOG_FILE")
    else
      OUT=$(claude -p "Continue de onde parou: finalize o capítulo em andamento, valide, atualize o ROADMAP.md e faça o commit no formato do projeto. NÃO faça push." \
        --continue \
        --model "$MODEL" \
        --permission-mode acceptEdits \
        --allowedTools "Bash,Read,Edit,Write,Glob,Grep" \
        --output-format json 2>>"$LOG_FILE")
    fi
    EC=$?
    echo "$OUT" >> "$LOG_FILE"
    if [ "$EC" -eq 0 ]; then
      ok=true
      break
    fi
    log "Tentativa $attempt falhou (exit $EC) — retomando a mesma sessão em 30s..."
    resume=true
    attempt=$((attempt + 1))
    sleep 30
  done

  if [ "$ok" = false ]; then
    log "ERRO: capítulo falhou após $MAX_RETRIES tentativas. Abortando — revise $LOG_FILE."
    exit 1
  fi

  COST=$(echo "$OUT" | grep -o '"total_cost_usd":[0-9.]*' | head -1 | cut -d: -f2)
  log "Sessão concluída (custo da sessão: \$${COST:-?})."

  # Push incondicional: envia o commit do Claude e qualquer commit local pendente
  if git push >>"$LOG_FILE" 2>&1; then
    log "Push OK."
  else
    log "AVISO: push falhou — verifique credenciais/rede no log."
  fi

  NP=$(pending)
  if [ "$NP" -ge "$P" ]; then
    stalls=$((stalls + 1))
    log "AVISO: ROADMAP não avançou ($P → $NP). Stall $stalls/$STALL_LIMIT."
    if [ "$stalls" -ge "$STALL_LIMIT" ]; then
      log "ERRO: sem progresso em $STALL_LIMIT sessões seguidas. Abortando."
      exit 1
    fi
  else
    stalls=0
  fi

  sleep 5
done

log "=== auto-manual finalizado ==="
