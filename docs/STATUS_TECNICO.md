# Status técnico

Última consolidação: 2026-11-12

## Requisitos do comportamento

1. START sozinho ativa a troca durante um round em andamento.
2. P1 e P2 são independentes.
3. A troca preserva a fração de energia: `vida_nova = vida_max_nova * (vida_atual_antiga / vida_max_antiga)` (arredondamento e limites ainda precisam ser definidos após localizar as variáveis reais).
4. Não reinicia round, relógio, cenário, posição nem o estado do adversário.
5. A sequência de personagens e o tratamento de personagens secretos precisam ser documentados antes de fechar a lógica.

## Achados estáticos confirmados na fonte ASM examinada

| Item | Referência | Estado |
|---|---|---|
| ID P1 | WRAM `$7E07A2` | Localizado na fonte |
| ID P2 | WRAM `$7E0A22` | Localizado na fonte |
| Cache P1 | `$1C07` | Localizado na fonte |
| Cache P2 | `$1C08` | Localizado na fonte |
| Hook moveset P1 | ROM offset `$003D33` | Localizado na fonte |
| Hook hitbox P1 | ROM offset `$003D59` | Localizado na fonte |
| Hook moveset P2 | ROM offset `$003DC0` | Localizado na fonte |
| Hook hitbox P2 | ROM offset `$003DE6` | Localizado na fonte |
| Inicialização pré-luta | CPU `$C03CDA` | Uso durante luta considerado inseguro; não chamar |
| Vida atual/máxima | ainda desconhecidos | Pendente |
| Rotina segura por frame em combate | ainda não validada | Pendente |
| Troca completa em combate | não implementada | Pendente |

**Atenção:** os quatro offsets de hook são pontos interceptores do fluxo de descompressão, não APIs de chamada. Não chamar diretamente como subrotinas sem reconstruir o contexto esperado pelo código original.

## Carregamento S-DD1 e fallback

A tabela `.len_table` do arquivo `player movesets sdd1 dma.asm` fornece dados S-DD1 específicos para alguns IDs (incluindo Ryu 2, Sodom, Birdie e Zangief) e o ID compartilhado de seleção de personagem. Para os demais, o código retorna ao descompressor original `$C02889`. A implementação deve manter os dois caminhos.

## Hitboxes/cache

O projeto de referência contém comentários sobre cache e ponteiros-base de hitbox, incluindo o caso de Ryu (base correta citada como `$4BC2`, e valor incorreto observado `$5648`). Isso é evidência de que cache e tabelas de hitbox precisam ser atualizados de forma coerente. Não prova, por si só, qual correção é segura durante uma luta ativa.

Uma rotina de reconstrução de tabela citada no fonte deve ser validada antes de ser executada em combate.

## Vida

Os endereços gráficos `$B904` e `$B924` são referências de destino gráfico/VRAM para as barras, não a vida real. Não usar esses endereços como energia. A rotina `$C0A329` foi identificada no fluxo relacionado a personagem atingido, mas não está provado que seja o ponto que calcula ou grava a vida.

## Próximo marco técnico

1. Executar `tools/bizhawk/SFA2_CAPTURA_BIZHAWK.lua` com a ROM original.
2. Gerar snapshots antes/depois de um único golpe.
3. Repetir para P2 e, se possível, com estados de jogo diferentes (parado, ataque, defesa).
4. Analisar bytes alterados e separar energia de animação, temporizadores, efeitos e HUD.
5. Repetir capturas com dois ou mais golpes para encontrar contador/representação de energia.
6. Só então desenhar um monitor de escrita ou rastreamento de rotina para confirmar os endereços.

## Build

Asar 1.9 foi compilado localmente durante a investigação, mas ainda não há um patch `.asm` de troca pronto para ser montado. O `main.asm` do patch MSU-1 de referência contém dependências de caminhos externos e assets S-DD1; não é uma base de compilação autossuficiente.


## Atualização de desenvolvimento — 2026-11-12

### Ferramentas adicionadas ao repositório

- `tools/analyze_wram.py`: compara dois snapshots de WRAM de 128 KiB, lista bytes/regiões alterados e gera CSV com offset WRAM e endereço espelhado da CPU.
- `tests/test_analyze_wram.py`: verifica detecção de diferenças e rejeição de snapshots com tamanho inválido.
- `.github/workflows/validate.yml`: automatiza validação de sintaxe Lua, sintaxe Python, testes do analisador e bloqueio de ROMs/patches/dumps no Git.
- `.gitignore`: ignora ROMs, patches binários, dumps, saves e temporários.
- `CONTRIBUTING.md` e modelos de Issue: padronizam evidências e revisões técnicas.

### Validação contínua

GitHub Actions executou com sucesso na branch `main`:
- compilação sintática do Lua com Lua 5.4;
- compilação sintática do analisador Python;
- testes unitários do analisador;
- verificação de arquivos protegidos/dumps.

Esse CI valida a estrutura e as ferramentas auxiliares. **Não valida o comportamento dentro do emulador e não significa que a troca de personagem já funciona.**

### Próxima medição necessária

Executar o capturador Lua em BizHawk e fornecer os dois snapshots de WRAM feitos antes/depois de um único golpe. Em seguida, executar:

```bash
python tools/analyze_wram.py SFA2_WRAM_ANTES.bin SFA2_WRAM_DEPOIS.bin
```

Repetir o procedimento para dano em P1 e P2 e com mais de um golpe. Não commitar snapshots completos no repositório; compartilhar apenas para análise controlada.


## Atualização — endereços de vida identificados (2026-11-12)

Os endereços de energia agora têm evidência externa específica para a ROM USA:

- P1: WRAM $7E:073E. Código Action Replay de vida infinita: 7E073E90.
- P2: WRAM $7E:09BE. Código Action Replay de vida infinita: 7E09BE90.

A base libretro-database lista ambos os códigos para Street Fighter Alpha 2 (USA, Europe). GameHacking.org também identifica a ROM USA com CRC32 9C59DDFF e lista os mesmos endereços. A ROM fornecida para análise tem CRC32 9C59DDFF e SHA-256 910a29f834199c63c22beddc749baba746da9922196a553255deade59f4fc127.

Referências:
- https://github.com/libretro/libretro-database/blob/master/cht/Nintendo%20-%20Super%20Nintendo%20Entertainment%20System/Street%20Fighter%20Alpha%202%20%28USA%2C%20Europe%29%20%28Action%20Replay%29.cht
- https://gamehacking.org/game/44609

Foi adicionado tools/bizhawk/SFA2_MONITOR_VIDA_CONFIRMADA.lua. Ele apenas lê WRAM, monitora $073E e $09BE junto dos IDs $07A2 e $0A22, e grava SFA2_health_monitor.csv. O script precisa ser executado no BizHawk real para confirmar os valores normais e a variação durante dano; o monitor não escreve na memória.

A localização dos bytes de vida não significa que a troca já esteja implementada. Ainda falta descobrir a rotina segura que atualiza os carregadores de moveset/hitboxes durante uma luta sem chamar a inicialização global.


## Auditoria adicional — Etapa 17 (2026-11-12)

- Corrigidos os offsets de entrada dos carregadores auxiliares: P1 `$C0:3DF1`, P2 `$C0:3E46`; retornos em `$C0:3E45` e `$C0:3E9A`.
- Confirmada a preparação dos destinos-base `$6840/$8240` para P1 e `$C800/$E200` para P2, com ajustes por ID em `$C0:B8EC`.
- Confirmado que `$07C5/$0A45` recebem zeragens, incrementos e atribuições explícitas; não devem ser tratados como booleanos puros sem análise dos consumidores.
- Busca bruta por referências aos destinos encontrou candidatos, mas nenhum consumidor foi classificado como código com segurança; é necessário disassembly com M/X.
- Documento: `docs/ETAPA17_AUDITORIA_PONTEIROS_FLAGS.md`.
- Nenhum patch funcional foi produzido.
