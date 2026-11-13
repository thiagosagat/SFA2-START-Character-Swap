# ETAPA 20 — Auditoria cruzada dos valores capturados do joypad

## Objetivo
Determinar se os valores salvos pela rotina de captura em DP $000C (P1) e $000E (P2) podem ser seguidos até um consumidor de START, e se a rotina $C0:76D6 tem chamadas diretas localizáveis.

ROM: Street Fighter Alpha 2 (USA), SHA-256 `910a29f834199c63c22beddc749baba746da9922196a553255deade59f4fc127`.

## 1. Confirmação dos bytes em $C0:76D6

No arquivo, a sequência é:

```asm
$C0:76D6  SEP #$20
$C0:76D8  REP #$10
$C0:76DA  LDX #$0096
$C0:76DD  NOP
$C0:76DE  DEX
$C0:76DF  BNE $76DE
$C0:76E1  LDA $4212
$C0:76E4  AND #$01
$C0:76E6  BNE $76E1
$C0:76E8  REP #$30
$C0:76EA  LDA $4218
$C0:76ED  STA $000C
$C0:76EF  LDA $421A
$C0:76F2  STA $000E
$C0:76F4  RTS
```

Com M=0 após REP #$30, as duas leituras são de 16 bits. START está no bit 12: máscara `$1000` em cada palavra. Isso confirma que o dado bruto do START está presente na captura, mas não demonstra como o jogo o consome.

## 2. Busca por chamadas diretas

Busca na ROM inteira pelas codificações literais:
- JSR absoluto `20 D6 76`: zero ocorrências.
- JSL `22 D6 76 C0`: zero ocorrências.
- JMP absoluto `4C D6 76`: zero ocorrências.
- JML `5C D6 76 C0`: zero ocorrências.

Foi feita também busca pela sequência de bytes `D6 76` como possível endereço/tabela: 39 ocorrências. A maior parte aparece em regiões de dados comprimidos ou sem contexto de tabela comprovado. Nenhuma foi classificada como ponteiro executável para $C0:76D6. Portanto, a busca não prova chamada indireta nem prova que a rotina seja morta.

## 3. DP $000C/$000E são campos genéricos, não buffers exclusivos

Busca bruta de opcodes de página direta no ROM encontrou:
- `LDA $0C`: 143 ocorrências do padrão de bytes.
- `LDA $0E`: 39 ocorrências.
- `STA $0C`: 186 ocorrências.
- `STA $0E`: 51 ocorrências.

Essas contagens são ocorrências de bytes, não uma desassemblagem semântica completa: alguns padrões podem estar em dados ou em instruções com outro contexto. Mesmo assim, deixam claro que não é seguro tratar DP $000C/$000E como armazenamento exclusivo dos controles. A própria ROM reutiliza a página direta em muitas rotinas.

## 4. Conclusão técnica

Confirmado:
- $C0:76D6 lê as palavras automáticas dos dois controles depois de aguardar $4212.0=0.
- As palavras incluem START no bit 12.
- Os resultados são gravados em DP $000C e $000E.

Não confirmado:
- quem chama $C0:76D6;
- se a rotina é executada uma vez por frame;
- quais rotinas consomem os valores salvos;
- se existe uma cópia filtrada/edge-triggered de START;
- se essa rotina está ativa durante o round.

**Decisão:** não inserir o hook de troca em $C0:76D6 ainda. A rotina só coleta dados e retorna; o ponto de execução e o ciclo de vida dos valores ainda não foram demonstrados.

## 5. Próxima investigação

1. Reconstruir o fluxo de execução em torno das rotinas de inicialização do PPU/joypad e do scheduler principal.
2. Identificar quem chama a rotina de captura por análise de fluxo, incluindo possíveis despachos indiretos.
3. Classificar consumidores de $000C/$000E por contexto de execução e estado M/X.
4. Encontrar o caminho de input que diferencia botão mantido de botão recém pressionado.
5. Correlacionar esse caminho com o estado de luta ativa e os IDs P1 $7E:07A2 / P2 $7E:0A22.
