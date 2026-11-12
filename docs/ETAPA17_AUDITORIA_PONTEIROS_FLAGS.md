# ETAPA 17 — Auditoria dos ponteiros auxiliares e correção de offsets

## Escopo

Auditoria independente dos arquivos locais do ROM USA e dos documentos das Etapas 14–16. Esta etapa não implementa a troca.

## 1. Correção necessária na Etapa 14

A leitura byte a byte do ROM confirma:

- `$C0:3DF1`: início do carregador auxiliar de P1 (`AD C5 07 F0 4F`).
- `$C0:3E45`: RTL de retorno do carregador auxiliar de P1.
- `$C0:3E46`: início do carregador auxiliar de P2 (`AD 45 0A F0 4F`).
- `$C0:3E9A`: RTL de retorno do carregador auxiliar de P2.

Portanto, a Etapa 14 tinha os endereços de início dos testes de flag deslocados. O documento foi corrigido no commit `1ce76c87827595924c1733840674c4c51dd49f09`.

Os desvios condicionais `F0 4F` partem de:
- P1: opcode em `$C0:3DF4`, próximo PC `$C0:3DF6`, destino `$C0:3E45`.
- P2: opcode em `$C0:3E49`, próximo PC `$C0:3E4B`, destino `$C0:3E9A`.

Isso confirma que cada caminho retorna sem executar os dois blocos de descompressão quando seu sinalizador está zero.

## 2. Preparação dos destinos — confirmação independente

O trecho do ROM em `$003CA7-$003CD8` confirma a sequência descrita na Etapa 15:

- P1 recebe os destinos-base `$6840` e `$8240` em `$07FA/$07FC`.
- P2 recebe os destinos-base `$C800` e `$E200` em `$0A7A/$0A7C`.
- A rotina em `$C0:B8EC` é chamada com X=`$0700` e X=`$0980`.
- Depois são chamados os carregadores auxiliares P1 (`$C0:3DF1`) e P2 (`$C0:3E46`).

A rotina `$C0:B8EC` faz ajustes de destino:
- ID `$04`: soma `$0100` ao campo relativo `$00FC,X`.
- IDs `$02/$14/$11/$13`: soma `$0200` ao campo relativo `$00FA,X`.

A leitura dos bytes confirma as instruções e os deslocamentos. Ainda não identifica o significado dos dados que são gravados nesses destinos.

## 3. Auditoria dos sinalizadores

O ROM contém as seguintes escritas candidatas identificadas por padrões de opcode:

### P1 — `$07C5`
- `STZ`: `$000BD4`, `$006420`, `$009C29`, `$00CA0F`, `$00DE14`, `$12BE74`.
- `INC`: `$00372D`, `$009B82`, `$12C4A8`.
- `STA`: `$00CA3E`, `$00CA50`.

### P2 — `$0A45`
- `STZ`: `$000BD7`, `$006423`, `$009C2C`, `$00CA12`, `$00E5EA`, `$12BE77`.
- `INC`: `$00375C`, `$009B8B`, `$12C4B4`.
- `STA`: `$00CA68`, `$00CA7A`.

No trecho `$00CA0F-$00CA7A`, a rotina zera ambos, depois atribui IDs de personagem e grava `1` nos sinalizadores em caminhos separados para P1/P2. Existem também caminhos condicionais adicionais de atribuição.

**Limite:** a presença de `INC` impede modelar o campo como booleano estrito em toda a lógica. O carregador auxiliar apenas testa zero/não-zero, mas outros consumidores podem depender do valor numérico. A semântica desses incrementos ainda não foi determinada. Não alterar esses bytes por tentativa.

## 4. Busca de referências aos destinos

Foi feita uma busca bruta por opcodes que mencionam diretamente `$07FA/$07FC/$0A7A/$0A7C` e pelos endereços-base `$6840/$8240`.

A busca encontrou ocorrências espalhadas pelo ROM, mas vários candidatos caem em regiões que podem conter dados comprimidos ou tabelas. Uma busca por bytes não distingue código executável de dados; por isso, **nenhuma ocorrência adicional foi classificada como consumidor válido nesta etapa**.

Próximo requisito: disassemblar cada candidato com estado M/X correto e confirmar fluxo de controle/referência cruzada antes de atribuir significado.

## 5. Consequência de implementação

A rotina de troca não pode:
- presumir que os quatro campos de destino são constantes;
- forçar `$07C5/$0A45` para 1 sem preservar a semântica;
- chamar a inicialização global `$C0:3CDA` no meio da luta;
- sobrescrever os blocos auxiliares antes de saber quais estruturas continuam ativas.

## 6. Próximo trabalho técnico

1. Desassemblar os candidatos a referências de `$07FA/$07FC/$0A7A/$0A7C` com contexto M/X.
2. Classificar os blocos auxiliares por comparação de conteúdo descomprimido para diferentes IDs, sem publicar dados extraídos.
3. Rastrear consumidores efetivos desses blocos.
4. Determinar se os sinalizadores são contadores, marcadores de estado ou campos com semântica mista em cada rotina.
5. Localizar o loop de combate e o caminho de leitura de START.
6. Só então desenhar um recarregador isolado por jogador.

## Resultado desta etapa

- Offset incorreto na Etapa 14 identificado e corrigido.
- Sequência de preparação de destinos da Etapa 15 confirmada diretamente no ROM.
- Ciclo de escrita dos sinalizadores parcialmente confirmado, mas sem semântica completa.
- Nenhum consumidor dos blocos auxiliares foi ainda provado.
- Nenhum patch funcional foi produzido.
