# ETAPA 18 — Auditoria do candidato de entrada e rastreamento de chamadas

## Objetivo

Verificar se o bloco `$C0:6C04` é realmente um ponto de leitura de START ou um ponto seguro no loop de combate.

ROM examinada: Street Fighter Alpha 2 (USA), 4 MiB, CRC32 `9C59DDFF`, SHA-256 `910a29f834199c63c22beddc749baba746da9922196a553255deade59f4fc127`.

## 1. O que os bytes de $C0:6C04 mostram

O trecho começa com seleção por `$1D75`:
- Se o bit 0 estiver limpo, testa `$00B0/$00B1`.
- Se o bit 0 estiver ativo, testa `$00AA/$00AB`.
- Para cada byte, usa `BIT #$C0`.
- Se algum teste for verdadeiro, define `$1E=$40` e chama `$C0:9A74`.
- Caso contrário, segue para uma lógica que ajusta `$1A`, chama novamente `$C0:9A74` em alguns caminhos e então chama `$C0:6DD6`.

Isso é compatível com processamento de estado/entrada, mas não identifica isoladamente START. O mapeamento físico de botões depende de como os bytes `$AA/$AB/$B0/$B1` foram formados antes desse trecho.

## 2. Referências cruzadas encontradas

Busca de instruções absolutas no ROM USA encontrou:
- `$00AA`: leitura em `$006C0C`, além de referências em `$1597BE`, `$1895F0`, `$1AE8A1`, `$1C693B`, `$226A4B`, `$270BF5`, `$2F4BDA`, `$33671F`.
- `$00AB`: apenas a leitura em `$006C13` foi encontrada por esse padrão.
- `$00B0`: várias referências, incluindo `$003606`, `$0036FE`, `$0056C1`, `$0056D1`, `$006C1C`, `$1AE8BA`, entre outras.
- `$00B1`: referências em `$006C23`, `$1D2EBE`, `$276D4A`, `$2F6EE2`, entre outras.

A busca por JSL direto para `$C0:6C04` não encontrou ocorrência literal no ROM. Isso não exclui chamada indireta por tabela ou salto; apenas impede afirmar que exista um chamador JSL direto.

## 3. O bloco de $C0:6C00 não é prova de loop de combate

O cabeçalho em `$C0:6C00` contém `04 4C A6 6C`: um byte anterior seguido de JMP para `$C0:6CA6`. A rotina em `$C0:6CA6` manipula os bytes `$10-$17` e os converte em valores gráficos/tabela, e a região subsequente contém outras rotinas de conversão e ordenação.

Isso é um alerta contra classificar o bloco como rotina geral de input do combate apenas pela presença de testes de bits. Ainda não foi provado que esse código execute continuamente durante uma luta.

## 4. Contexto de $00AA/$00B0

O código em `$C0:36FE` copia campos `$00B0,X` e `$00B2,X` de estruturas indexadas por `$8F1B` para outras áreas. O código em `$F5:E8A0` (offset `$1AE8A0`) lê `$00AA` e combina com `$00B0`, e em outro caminho lê `$00B0` e `$00B4`.

Essas referências mostram que os endereços são reutilizados em contextos diferentes. Não se pode assumir que `$00AA/$00AB` e `$00B0/$00B1` sejam diretamente os registradores de joypad, nem que seu bit 6/7 corresponda a START. É necessário localizar a rotina que popula esses bytes e acompanhar a transformação até o consumidor.

## 5. Referência de hardware SNES (externa)

O hardware SNES expõe os resultados automáticos do controle em `$4218/$4219` para P1 e `$421A/$421B` para P2. O bit layout padrão coloca Start no bit 12 da palavra de 16 bits; o byte alto contém B/Y/Select/Start/direções. O estado de leitura automática em andamento aparece em `$4212.0`. A leitura desses registradores durante a janela de auto-read pode ser inválida.

Fontes:
- SNESdev Wiki — Controller reading: https://snes.nesdev.org/wiki/Controller_reading
- Super Famicom Development Wiki — Registers: https://wiki.superfamicom.org/registers

Essa referência define o mapa de hardware, mas não prova como este jogo armazena ou transforma os dados em `$00AA-$00B1`.

## 6. Conclusão técnica

- `$C0:6C04` permanece um candidato de processamento de estado/entrada, não um hook confirmado para START durante combate.
- O teste `BIT #$C0` não basta para identificar START.
- Não foi encontrada chamada JSL direta para `$C0:6C04`; chamadas indiretas ainda são possíveis.
- A rotina `$C0:6CA6` e as referências cruzadas sugerem que o bloco pode estar associado a processamento especializado, não necessariamente ao loop geral de luta.
- Não se deve instalar hook nesse endereço ainda.

## 7. Próxima investigação de maior valor

1. Localizar quem escreve `$00AA/$00AB/$00B0/$00B1` imediatamente antes de `$C0:6C04`.
2. Rastrear a origem até `$4218-$421B` ou leitura serial `$4016/$4017`.
3. Confirmar com breakpoint se `$C0:6C04` é executado durante uma luta e em qual estado.
4. Comparar START, SELECT, B, Y e direções separadamente para P1 e P2.
5. Encontrar o loop de combate por evidência de chamadas por frame, não por semelhança de código.

## Resultado

Nenhum hook de START foi validado. Nenhum patch funcional foi produzido nesta etapa.
