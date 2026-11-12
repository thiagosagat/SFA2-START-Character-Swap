# ETAPA 14 — Carregadores adicionais condicionais por jogador

## Objetivo

Continuar a análise de `$C0:3CDA` além dos carregadores de moveset/hitboxes identificados na Etapa 13, verificando o trecho `$C0:3DED-$C0:3E98`.

## Evidência examinada

Fonte local: `C03CDA_disassembly_bytes.txt`, no arquivo de análise `SFA2_Gizaha_stage2_trace.zip`, com bytes do ROM USA em offsets equivalentes ao trecho analisado.

Trecho relevante:

- `$C0:3DF1`: `AD C5 07 F0 4F` — início do carregador auxiliar de P1.
- `$C0:3DF9` em diante: preparação de ponteiros usando o ID P1 `$07A2`, seguida de duas chamadas a `$C0:2889`.
- `$C0:3E46`: `AD 45 0A F0 4F` — início do carregador auxiliar de P2.
- `$C0:3E4E` em diante: preparação de ponteiros usando o ID P2 `$0A22`, seguida de duas chamadas a `$C0:2889`.

## Interpretação direta dos bytes

### P1

1. Começa em `$C0:3DF1` e lê `$07C5`.
2. Se o valor for zero, o desvio relativo `F0 4F` alcança o RTL de P1 em `$C0:3E45`, retornando ao chamador.
3. Se não for zero, limpa `$07ED`.
4. Usa o ID em `$07A2` para indexar as tabelas em `$B7BA/$B7BC` e `$B7F9/$B7FB`.
5. Prepara os destinos a partir de `$07FA` e `$07FC`, com banco de destino `$7E`.
6. Faz duas chamadas a `$C0:2889`.

### P2

1. Começa em `$C0:3E46` e lê `$0A45`.
2. Se o valor for zero, o desvio relativo `F0 4F` pula o bloco P2 e alcança seu RTL em `$C0:3E9A`.
3. Se não for zero, limpa `$0A6D`.
4. Usa o ID em `$0A22 para indexar as mesmas famílias de tabelas.
5. Prepara os destinos a partir de `$0A7A` e `$0A7C`, com banco de destino `$7F`.
6. Faz duas chamadas a `$C0:2889`.

## O que está confirmado

- Há dois carregadores adicionais, condicionais e separados por jogador.
- P1 e P2 usam seus próprios IDs de personagem.
- Os destinos são distintos: P1 no banco WRAM `$7E`, P2 no banco WRAM `$7F`.
- Cada caminho contém duas chamadas adicionais ao descompressor.
- Os sinalizadores `$07C5` e `$0A45` controlam se cada bloco de carregamento é executado.

## O que NÃO está confirmado

- O significado semântico dos quatro blocos descomprimidos.
- Se esses blocos contêm animação, dados de colisão, dados auxiliares ou outra estrutura.
- Se os sinalizadores são sempre ativos durante uma luta.
- Se esses dados podem ser recarregados isoladamente sem invalidar ponteiros, objetos ativos ou caches.
- O dump completo do trecho confirma o RTL de P1 em `$C0:3E45` e o RTL de P2 em `$C0:3E9A`; a leitura inicial que dizia que o dump terminava no meio da sequência estava incorreta.

## Consequência para a troca durante a luta

A hipótese de trocar apenas o ID e recarregar moveset/hitboxes fica incompleta. Antes de implementar a troca, é necessário identificar o conteúdo e os consumidores dos blocos apontados por:

| Jogador | Destinos | Banco |
|---|---|---|
| P1 | `$07FA`, `$07FC` | `$7E` |
| P2 | `$0A7A`, `$0A7C` | `$7F` |

Também é necessário rastrear as leituras desses endereços e verificar quando os sinalizadores `$07C5/$0A45` são definidos e limpos.

**Decisão técnica:** não chamar `$C0:3CDA` durante a luta. A rotina principal contém limpeza global e os carregadores adicionais ainda não foram isolados nem validados para execução em combate. Nenhum patch funcional de troca foi produzido nesta etapa.

## Próxima investigação

1. Identificar os valores e usos dos ponteiros em `$07FA/$07FC/$0A7A/$0A7C`.
2. Rastrear leituras desses destinos no código do jogo.
3. Descobrir quem define `$07C5` e `$0A45`, e em quais fases.
4. Comparar os blocos carregados para personagens diferentes.
5. Só então desenhar uma rotina isolada de recarga por jogador, preservando os objetos ativos e o estado da luta.
