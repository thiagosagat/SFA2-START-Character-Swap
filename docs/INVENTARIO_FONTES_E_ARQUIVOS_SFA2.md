# Inventário de arquivos e fontes — Street Fighter Alpha 2 (SNES)

Data da busca: 2026-11-12

Este inventário reúne arquivos SFA2 identificados no ambiente de trabalho e na biblioteca desta conversa, além de fontes públicas encontradas. Não contém ROMs comerciais nem redistribui dados do jogo.

## 1. Fonte pública mais importante: engenharia reversa S-DD1

- Repositório: https://github.com/gufranco/snes-street-fighter-alpha-2-nochip
- O projeto reconstrói SFA2 USA e SFZ2 Japão sem depender do chip S-DD1, com modelo Python da descompressão, mapa de streams, disassembler 65816, ferramentas de auditoria e testes.
- O README público informa correspondência do SHA-256 USA `910a29f834199c63c22beddc749baba746da9922196a553255deade59f4fc127`, igual à ROM-base examinada neste projeto.
- O repositório foi arquivado pelo proprietário em 10/11/2026 e está somente leitura na página consultada. Ainda assim, seu código e documentação públicos são uma fonte de pesquisa valiosa.
- Arquivos/pontos de entrada para estudar no código: `REFERENCE.md`, `CONTRIBUTING.md`, `sdd1sites.py`, `sdd1map.py`, módulos de hardware `mos65xx`, `sdd1`, ferramentas de ROM/stream e testes.
- Não é um hack de troca de personagem; é principalmente tooling para S-DD1, mapeamento de streams e correções do jogo.

## 2. Fonte pública de hacks e ASM: tópico Zeldix/Gizaha

- Tópico principal: https://www.zeldix.net/t1831-street-fighter-alpha-2
- Páginas relevantes encontradas: páginas 6, 7, 12, 13 e 14.
- O histórico contém patches MSU-1, mudanças de áudio, tempos de carregamento, correções de sprites/poses, ajustes de cenário e discussões de compatibilidade SD2SNES/FXPak.
- Há relatos explícitos de riscos de sobrescrever dados de AI/moveset/hitbox e de bugs de leitura de dados em versões antigas do SD2SNES MSU. Isso reforça que qualquer recarga de dados de personagem no meio da luta exige auditoria de memória e compatibilidade.
- Página 7 menciona workaround de bug SD2SNES que poderia quebrar AI/moveset/hitbox; páginas 12–14 registram problemas e testes de builds. Não assumir que patches antigos são seguros ou compatíveis com a ROM USA sem verificar base e checksum.

## 3. Arquivos locais encontrados em /mnt/data

### ROM e base de comparação
- `Street Fighter Alpha 2 (USA).sfc` — 4.194.304 bytes; SHA-256 acima.
- `Street Fighter Alpha 2 (USA).zip` — arquivo compactado da ROM; não redistribuir.

### Pacote de referência Gizaha / MSU-1
- `MSU1_StreetFighterAlpha2_20221021_gizaha.zip`
  - `ReadMe.txt`, patch IPS, fontes ASM, assets de áudio, dados S-DD1 e dumps .raw.
  - Fontes ASM incluem: `main.asm`, `changes.asm`, `fix intro timing.asm`, `select gouki with select+start.asm`, `player movesets sdd1 dma.asm`, `decompressor.asm`, `object code.asm`, `stage mods.asm`, `audio tweaks.asm`, `restore player names.asm`, `akuma win pose reorder.asm`, entre outras.
  - Diretório `sdd1/player movesets/`: 16 pares .sdd1/.raw identificados no pacote.
  - O material é referência de modificação, não documentação oficial completa do código do jogo.

### Pacotes de análise e desmontagem desta investigação
- `SFA2_Gizaha_source_analysis.zip` — fontes ASM e notas de análise.
- `SFA2_Gizaha_stage2_trace.zip` — inclui `C03CDA_disassembly_bytes.txt` e `STAGE2_ROM_TRACE.txt`.
- `SFA2_ETAPA3_RASTREAMENTO.zip` — `main.asm`, `select gouki with select+start.asm`, `ANALYSIS_FINDINGS.txt`, `STAGE2_ROM_TRACE.txt`.
- `SFA2_ETAPA4_REFERENCIAS.zip` — relatório de referências e script `SFA2_scan_refs.py`.
- `SFA2_ETAPA5_CONTROLES.zip` — levantamento inicial de controles.
- `SFA2_ETAPA6_DESMONTAGEM.zip` — desmontagem do candidato de rotina de controle.
- `SFA2_ETAPA7_ROTINA_CONTROLE.zip` — análise do bloco candidato de controle.
- `SFA2_ETAPA8_CARREGADORES.zip` — ASM de carregadores, incluindo movesets S-DD1.
- `SFA2_ETAPA9_CACHE_E_CARREGAMENTO.zip` — cache e carregamento.
- `SFA2_ETAPA10_SEPARACAO_CARREGADORES.md` — separação dos carregadores individuais P1/P2.
- `SFA2_RASTREAMENTO_ROTINAS_CARREGAMENTO.md` — análise estática de carregadores.
- `SFA2_RASTREAMENTO_ESCRITAS_DESCOMPRESSOR.md` — escritas do descompressor $C0:2889/$C0:29EA.
- `SFA2_MEDICAO_INTERVALOS_SAIDA_ETAPA11.md` — tamanhos de dumps descomprimidos disponíveis; não equivale a execução do descompressor na ROM.
- `SFA2_START_switch_stage1.zip` — rascunho de desenho de troca, análise inicial e script de busca de input.
- `SFA2_START_SWAP_REPOSITORIO_v1.zip` e `SFA2_START_SWAP_GITHUB_INICIAL.zip` — estrutura inicial do projeto, documentação, plano de testes e ferramenta BizHawk.
- `SFA2_START_SWAP_INSTRUCOES_RAPIDAS.txt` — instruções do pacote inicial.
- `SF2MIX_REFERENCIA_PARA_SFA2.zip` — nota de referência de SF2MIX; não é fonte de código SFA2.
- `GUIA_BIZHAWK_SFA2.zip` — guia de execução/captura BizHawk.
- `SFA2_ARQUIVO_TESTE.zip` — script de teste e LEIA-ME.
- `asar-asar_19.zip` — assembler Asar 1.9, ferramenta de montagem 65816.
- `snes-street-fighter-alpha-2-nochip-main.zip` — cópia ZIP local do repositório público; atenção: ZIP do GitHub não inclui os nove submódulos fixados, segundo o README do projeto.
- `BizHawk-2.11.1-win-x64.zip` — pacote do emulador Windows.

### Scripts de captura/monitoramento
- `SFA2_CAPTURA_BIZHAWK.zip` — scripts e instruções para captura no BizHawk.
- `SFA2_CAPTURA_RAM_SNES9X.zip` — captura de RAM para Snes9x.
- `SFA2_CAPTURA_RAM_SUPERSNES9X.zip` — variante para SuperSnes9x.
- `SFA2_CAPTURA_AUTOMATICA_WRAM.lua` — snapshot/diferenças de WRAM; somente leitura.
- `SFA2_MONITOR_VIDA_CANDIDATOS.lua` — monitor exploratório.
- `SFA2_MONITOR_VIDA_CONFIRMADA.lua` — monitor somente leitura para endereços indicados por códigos Action Replay da ROM USA.
- Imagens-guia na biblioteca: `Tutorial SFA2: Captura de Memória RAM.png` e `Guia de Captura de Memória no Snes9x.png`.

## 4. Relatórios recentes publicados no repositório do projeto

Repositório do usuário: https://github.com/thiagosagat/SFA2-START-Character-Swap

- Etapa 17 — auditoria de ponteiros/flags.
- Etapa 18 — auditoria do candidato $C0:6C04.
- Etapa 19 — captura automática dos controles P1/P2 em $C0:76D6.
- Etapa 20 — auditoria de consumo dos valores de joypad.
- Status técnico consolidado: `docs/STATUS_TECNICO.md`.

## 5. Fontes técnicas complementares

- SNESdev Wiki — leitura de controles: https://snes.nesdev.org/wiki/Controller_reading
- Super Famicom Development Wiki — registradores: https://wiki.superfamicom.org/registers
- SNESdev Wiki — controle padrão e layout de bits: https://snes.nesdev.org/wiki/Standard_controller
- Spriters Resource — sprites/arte SFA2 SNES: https://www.spriters-resource.com/snes/sfalphaII/
- AwakeEchidna/wiiu-vc-extractor issue #50 — extração de dados S-DD1 em ROM SFA2: https://github.com/AwakeEchidna/wiiu-vc-extractor/issues/50

## 6. Limites desta busca

- A lista acima reúne arquivos SFA2 identificados na pasta de trabalho e na biblioteca pesquisada; não é uma auditoria de cada arquivo pessoal da conta.
- Alguns arquivos existem em duplicata com sufixo `(1)`; não foram contados como fontes independentes.
- Arquivos de captura/tutorial descrevem procedimentos; não provam que uma captura de jogo foi realmente executada.
- Dumps .raw do pacote Gizaha medem saídas já disponíveis; não provam todos os destinos ou intervalos de WRAM.
- Não foi encontrado, até esta busca, um patch público que implemente START durante o round para trocar personagens preservando vida/estado.
