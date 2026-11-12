# Etapa 12 — Como o jogo prepara e atualiza os personagens

Data: 2026-11-12  
ROM-base analisada: Street Fighter Alpha 2 USA, CRC-32 9C59DDFF.

## Conclusão principal

A evidência disponível aponta que o jogo **não possui uma rotina documentada de troca de personagem durante um round ativo**. O caminho conhecido de seleção/preparação carrega os dados dos dois lutadores durante transições pré-luta. A troca pedida exigirá criar uma rotina limitada que reutilize os trechos de carregamento por jogador, ou adaptar o estado do personagem em um ponto seguro do loop de combate. Ainda não há prova de que os quatro hooks possam ser chamados diretamente como subrotinas.

## Evidência primária: fonte Gizaha

### 1. Preparação pré-luta

Em `fix intro timing.asm`, o patch antecipa a preparação dos personagens ao fim da sequência contra Sagat:

- grava `$00` em WRAM `$7E:07A2` (P1);
- grava `$01` em WRAM `$7E:0A22` (P2);
- chama `$C0:3CDA`;
- usa o tempo restante da transição para permitir o carregamento.

O próprio comentário do autor diz que os movesets de Ryu/Ken são carregados após o fim da sequência de Sagat, durante o intervalo anterior à luta. Isso é evidência direta de que esse caminho é de preparação, não de troca em combate.

### 2. Cache e carregadores

O arquivo `player movesets sdd1 dma.asm` intercepta quatro pontos do fluxo normal:

| Jogador | Dados | Offset ROM |
|---|---|---:|
| P1 | moveset | $003D33 |
| P1 | hitboxes | $003D59 |
| P2 | moveset | $003DC0 |
| P2 | hitboxes | $003DE6 |

Cada hook lê o ID correspondente (`$7A2` ou `$A22`), multiplica por dois para indexar `.len_table`, e escolhe entre a rota S-DD1 especial (`$DADFCF`) ou o descompressor original (`$C02889`). Os hooks são interceptores do fluxo de descompressão e dependem de registradores/ponteiros já preparados; não são, por si só, APIs seguras para JSL arbitrário.

Os caches são `$7E:1C07` (P1) e `$7E:1C08` (P2). O comentário do patch descreve que esses bytes controlam se o jogo considera os dados do personagem já carregados.

### 3. Por que não reutilizar a inicialização geral

A rotina `$C0:3CDA` processa os dois jogadores e limpa uma região ampla de WRAM, incluindo `$7E:0C00-$7E:0FFF`. Portanto, não deve ser chamada durante um round ativo. Ela pode apagar objetos, projéteis, efeitos e outros estados compartilhados.

### 4. Evidência adicional: falha de cache/ponteiro

Em `changes.asm`, o autor comenta um defeito em que o endereço-base de hitbox (`dc`) incorreto fazia dados errados serem gravados. O comentário cita Ryu com base correta `$4BC2`, em vez de `$5648`, e observa que uma comparação de cache podia impedir o recarregamento do moveset. O workaround posterior invalida `$1C07` e `$1C08` antes de uma demo battle. Isso reforça que ID, cache e ponteiro-base de hitbox precisam permanecer coerentes; simplesmente alterar o ID é insuficiente.

## O que a pesquisa externa confirma

- O changelog público do patch Gizaha registra que moveset, hitboxes e IA foram transferidos sem compressão para MSU antes da fase Z, para acelerar o carregamento pré-luta.
- O mesmo tópico registra problemas relatados com corrupção de IA/moveset/hitboxes quando um workaround falhava.
- O projeto público S-DD1 sem chip documenta que o jogo constrói uma tabela de 24.704 bytes antes de cada luta. Isso confirma trabalho de preparação pré-luta, mas não prova uma API de troca em tempo real.

## Modelo técnico mais provável

O caminho de preparação normal parece seguir esta sequência:

1. IDs de P1/P2 já definidos;
2. comparação dos IDs com caches `$1C07/$1C08`;
3. preparação dos ponteiros/tabelas dependentes do personagem;
4. carregamento do moveset de cada jogador;
5. carregamento das hitboxes;
6. gravação dos IDs nos caches;
7. continuação da transição até a luta.

A ordem exata e todos os efeitos colaterais ainda precisam ser confirmados em execução. Não se deve assumir que essa sequência seja independente por jogador apenas porque há quatro hooks.

## Próximo passo de engenharia reversa

1. Desmontar o bloco completo `$C0:3CDA-$C0:3E??` com fluxo de controle e identificar o início/fim exato do caminho P1 e P2.
2. Comparar as instruções que preparam `$10/$12/$14/$16` antes de cada hook.
3. Identificar a rotina que constrói/atualiza o ponteiro-base de hitboxes e a tabela derivada mencionada em `changes.asm`.
4. Mapear campos do objeto do lutador que apontam para animação, hitbox atual, dimensões, palette e IA.
5. Só então implementar wrappers independentes P1/P2 que preservem estado do round e atualizem somente dados derivados do personagem.
6. Testar primeiro em save state e validar que vida, posição, timer, adversário, projéteis e objetos permanecem iguais.

## Estado honesto

- Confirmado: existe preparação pré-luta de ambos os personagens via `$C0:3CDA`.
- Confirmado: existem quatro pontos de interceptação de descompressão e caches separados P1/P2.
- Confirmado: erros de cache/ponteiro-base podem corromper hitboxes/movesets.
- Não confirmado: existe uma subrotina stock de reload individual pronta para uso no meio do round.
- Não confirmado: chamar isoladamente os quatro hooks preserva o estado da luta.
- Não implementado: troca via START durante round ativo.
- Não gerado: patch funcional.

## Fontes

- Gizaha, `fix intro timing.asm` e `player movesets sdd1 dma.asm`, incluídos no pacote-fonte MSU1 fornecido para esta investigação.
- Zeldix, Street Fighter Alpha 2, changelog e relatos: https://www.zeldix.net/t1831p275-street-fighter-alpha-2
- Zeldix, relatos de workaround e corrupção de IA/moveset/hitboxes: https://www.zeldix.net/t1831p150-street-fighter-alpha-2
- GitHub, projeto S-DD1 sem chip e documentação da tabela pré-luta: https://github.com/gufranco/snes-street-fighter-alpha-2-nochip
