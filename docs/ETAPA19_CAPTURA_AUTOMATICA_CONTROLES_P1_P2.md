# ETAPA 19 — Captura automática dos controles P1/P2

## ROM examinada
Street Fighter Alpha 2 (USA), 4 MiB, CRC32 `9C59DDFF`, SHA-256 `910a29f834199c63c22beddc749baba746da9922196a553255deade59f4fc127`.

## Achado confirmado: rotina em CPU $C0:76D4 (offset ROM $0076D4)

Bytes relevantes:

```asm
$C0:76D4  SEP #$20
$C0:76D6  REP #$10
$C0:76D8  LDX #$0096
$C0:76DB  NOP
$C0:76DC  DEX
$C0:76DD  BNE $76DC
$C0:76DF  RTS? ; cuidado: sequência segue para espera do auto-read
$C0:76E0  LDA $4212
$C0:76E3  AND #$01
$C0:76E5  BNE $76E0
$C0:76E7  REP #$30
$C0:76EA  LDA $4218
$C0:76ED  STA $000C
$C0:76F0  LDA $421A
$C0:76F3  STA $000E
$C0:76F6  RTS
```

A sequência real de bytes no ROM em $0076D4-$0076F6 foi conferida diretamente. O acumulador está em 16 bits nas duas leituras (REP #$30), portanto cada LDA lê o par baixo+alto:
- $4218-$4219: palavra completa do controle 1, salva em DP $000C.
- $421A-$421B: palavra completa do controle 2, salva em DP $000E.
- A rotina espera $4212.0 ficar zero antes da leitura.

## Consequência para START

Na palavra completa do joypad, START corresponde ao bit 12 (máscara $1000). Assim, a captura dessa rotina contém START para ambos os jogadores. A referência de hardware confirma a disposição de bits e os registradores automáticos.

Importante: não confundir:
- $4218 e $421A como palavras de 16 bits quando M=0 (acumulador 16-bit).
- seus bytes baixos isolados; a leitura de 16 bits também alcança $4219/$421B.

## O que ainda NÃO está provado

1. Não foi encontrada chamada literal JSR $76D4 nem JSL $C0:76D4 no ROM.
2. Portanto, ainda não sabemos se essa rotina é chamada diretamente, alcançada por fluxo, ou invocada por tabela/ponteiro.
3. Ainda não foi localizado o código que consome $000C/$000E para decidir ações de personagem.
4. Não está demonstrado se a rotina é executada uma vez por frame, em qual estado do jogo, nem se é a melhor posição para inserir a troca.
5. Não se deve ainda escrever o hook de START aqui nem tratar $000C/$000E como armazenamento exclusivo desses botões: são DP genéricos reutilizados em várias rotinas.

## Busca estática reproduzível

Na ROM USA foram procuradas as sequências:
- `20 D4 76` (JSR $76D4): 0 ocorrências.
- `22 D4 76 C0` (JSL $C0:76D4): 0 ocorrências.
- leituras absolutas `AD 19 42` e `AD 1B 42`: 0 ocorrências como instruções isoladas.
- leitura `AD 18 42` e `AD 1A 42`: encontradas em $0076EA e $0076F0, sob acumulador de 16 bits.

A ausência dessas chamadas literais não exclui chamadas indiretas, ponteiros ou entrada por fluxo de controle.

## Próxima investigação

- Localizar o chamador/entrada real da rotina $C0:76D4.
- Seguir os valores escritos em $000C/$000E e identificar a camada de edge-detection (botão recém pressionado versus mantido).
- Encontrar a lógica de seleção de personagem em estado de round ativo e correlacionar com IDs P1 $7E:07A2 e P2 $7E:0A22.
- Só então desenhar o hook independente P1/P2 para START sem interferir nos demais botões.
