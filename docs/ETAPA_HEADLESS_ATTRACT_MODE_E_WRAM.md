# Etapa — execução headless e observação do modo demonstração

Data: 2026-11-12/13 (UTC do ambiente)

## Ambiente executado

- ROM: Street Fighter Alpha 2 (USA).sfc
- Tamanho: 4.194.304 bytes
- CRC32: 9C59DDFF
- Frontend: snesref headless
- Core: Snes9x Libretro 1.63 (fae2fea)
- WRAM exposta pelo core: 131.072 bytes
- Inicialização: concluída; o jogo executou sem Mono/BizHawk.

## Resultado visual

A execução automática avançou pela sequência de inicialização, exibiu as telas de copyright/Capcom e entrou no modo demonstração (attract mode). Entre os frames 4.700 e 5.300 foi capturada uma luta demonstrativa no cenário noturno. Isso comprova que a ROM roda no core headless e que o caminho de captura de vídeo/WRAM funciona.

O script de input enviou START durante a demonstração. O jogo saiu do attract mode e voltou à tela "PRESS START BUTTON". Uma segunda tentativa, feita durante a janela observada, não chegou à seleção de personagens; a captura após o comando ficou preta por parte da transição e depois voltou à tela de título. Portanto, ainda não foi possível iniciar uma luta controlada de dois jogadores.

## Observação dos endereços candidatos de vida

Foi executada uma captura de 6.000 frames com rastreamento de escritas na WRAM. Endereços observados:

| Endereço WRAM | Eventos registrados |
|---|---|
| $073E (P1 candidato) | frame 1: 00; frame 4620: 08; frame 5282: 00 |
| $09BE (P2 candidato) | frame 1: 00; frame 4620: 08; frame 5282: 00 |

Essas alterações coincidem com a entrada/saída do trecho de demonstração, mas **não demonstram que os bytes sejam a vida atual**. Não houve série de decrementos por golpes nem leitura de vida máxima. Os endereços continuam candidatos apoiados pela base externa de códigos Action Replay, pendentes de validação em uma luta real.

Os IDs de personagem ($07A2 e $0A22) também mudaram durante transições de tela; isso não é prova de troca em combate.

## Limitações técnicas encontradas

- O core Snes9x Libretro compilado é stock; não exporta os símbolos adicionais `snesref_dbg_*`. Capturas de WRAM e framebuffer funcionam; dumps específicos de registradores/PPU adicionais são ignorados.
- O script de input funciona e registra a máscara START (0x008), mas a sequência de telas ainda precisa ser mapeada para alcançar seleção de personagens e luta versus.
- Nenhuma alteração foi feita na ROM.
- Nenhum patch de troca por START foi criado ou testado.

## Próximo passo

Mapear a tela de título e a sequência de confirmação de modo com capturas curtas em torno dos frames de transição. Em seguida, iniciar uma luta versus controlada, registrar golpes em P1 e P2 e verificar se $073E/$09BE diminuem proporcionalmente ao dano. Só depois disso implementar a lógica de troca.
