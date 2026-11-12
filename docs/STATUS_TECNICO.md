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
