# Teste headless inicial — 2026-11-13

## Ambiente

- Artefato do GitHub Actions: `sfa2-headless-linux-x64`
- Workflow run: `43349023654`
- Commit de build: `51b2e10332c0e36b694f1991aa8f26f242395cdb`
- Build: sucesso; jobs `build-linux-x64` e etapas de compilação/upload concluídos.
- Frontend: `snesref` (SNESRef)
- Núcleo: Snes9x Libretro 1.63, revisão `fae2fea`
- ROM: `Street Fighter Alpha 2 (USA).sfc`
- Tamanho: 4.194.304 bytes
- CRC32 verificado: `9C59DDFF` (corresponde à ROM de referência do projeto)

## Execução realizada

Comando equivalente:

```sh
SNESREF_HEADLESS=1 SNESREF_FAST=1 SNESREF_FRAMES=6000 \
SNESREF_WRAM_DUMP=SFA2_HEADLESS_WRAM_6000.bin \
SNESREF_TRACE_FILE=SFA2_HEADLESS_TRACE_6000.csv \
./snesref ./snes9x_libretro.so "Street Fighter Alpha 2 (USA).sfc"
```

Resultado observado:
- O frontend carregou o core e a ROM.
- O core reportou WRAM de 131.072 bytes e VRAM de 65.536 bytes.
- A execução terminou normalmente após 6.000 frames.
- Foi gerado dump final de WRAM (128 KiB) e rastreamento de alterações.
- O log reportou temporização de aproximadamente 60,0988 fps.

## Limitações / interpretação

- Este é um smoke test do runtime e da abertura da ROM, não um teste de gameplay.
- A execução sem comandos de controle ficou na sequência de inicialização/telas iniciais.
- Os endereços candidatos de vida (`$073E` P1 e `$09BE` P2) estavam em zero no dump final; isso não confirma nem refuta seus usos durante uma luta.
- Os IDs de personagem (`$07A2` e `$0A22`) também estavam em zero no dump final, indicando que o estado de combate não foi alcançado.
- O core stock não expõe os símbolos de depuração adicionais do SNESRef; dumps de CGRAM/OAM/registradores/PPU writes não foram gerados.
- Portanto, ainda não houve confirmação dinâmica de vida, dano, leitura de START em combate ou troca de personagem.

## Próximo passo

Ajustar a sequência de entrada determinística para passar da tela de título, selecionar modo/personagens e iniciar uma luta. Só depois coletar capturas de WRAM em estado estável e antes/depois de dano em P1 e P2.
