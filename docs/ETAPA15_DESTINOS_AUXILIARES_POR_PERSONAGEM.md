# ETAPA 15 — Origem dos destinos auxiliares e chamada dos carregadores

## Objetivo

Aprofundar a Etapa 14 rastreando quem prepara os destinos `$07FA/$07FC/$0A7A/$0A7C`, como eles variam por personagem e como os dois carregadores adicionais são chamados.

## 1. Preparação dos destinos

No ROM USA, o trecho em offset `$003CA7-$003CD8` contém a preparação anterior às chamadas dos carregadores:

- Inicializa o par de destinos de P1 em `$07FA/$07FC` com os valores-base `$6840/$8240`.
- Inicializa o par de destinos de P2 em `$0A7A/$0A7C` com os valores-base `$C800/$E200`.
- Chama a rotina em `$C0:B8EC` duas vezes, com X = `$0700` e X = `$0980`.
- Em seguida chama `$C0:3DF1` (P1) e `$C0:3E46` (P2).

A notação de banco acima usa a janela LoROM: os offsets do arquivo correspondem à metade alta do banco. Os offsets de arquivo observados são os que foram lidos diretamente do dump USA.

## 2. A rotina auxiliar ajusta o destino conforme o personagem

A rotina em offset `$0038EC` (CPU `$C0:B8EC`) começa lendo o ID do jogador indexado por X (`$00A2,X`).

Ela aplica ajustes aos ponteiros de destino:

- ID `$04`: soma `$0100` ao ponteiro em `$00FC,X`.
- IDs `$02`, `$14`, `$11` ou `$13`: soma `$0200` ao ponteiro em `$00FA,X`.
- Outros IDs seguem sem ajuste por esses caminhos.

Como X é `$0700` para P1 e `$0980` para P2, os campos relativos usados pela rotina correspondem aos pares de destino de cada jogador.

**Conclusão segura:** os endereços de destino dos dois blocos auxiliares não são necessariamente constantes para todo o elenco; há ajuste explícito condicionado ao ID do personagem.

## 3. Fluxo completo observado

1. Preparar destinos-base de P1 e P2.
2. Ajustar destinos de acordo com cada ID, chamando a rotina auxiliar separadamente para cada jogador.
3. Chamar o carregador adicional de P1 em `$C0:3DF1`.
4. Chamar o carregador adicional de P2 em `$C0:3E46`.
5. Cada carregador verifica seu próprio sinalizador (`$07C5` ou `$0A45`), prepara dois fluxos comprimidos e chama `$C0:2889` duas vezes.
6. Cada carregador termina com RTL. Os desvios condicionais também alcançam o RTL correspondente quando o sinalizador está zerado.

## 4. O que os sinalizadores ainda não nos dizem

As referências encontradas a `$07C5` e `$0A45` mostram que esses bytes também participam de lógica em outras regiões do jogo. Isso impede tratá-los, sem mais evidência, como simples flags de “dados carregados”. Precisamos rastrear os contextos de escrita e os estados em que mudam.

## 5. Implicações para a troca em combate

A troca precisa considerar pelo menos:

- o par de blocos de moveset/hitboxes já analisado;
- os dois blocos auxiliares condicionais;
- os destinos auxiliares ajustados por personagem;
- os caches e os sinalizadores separados por jogador;
- o risco de sobrescrever regiões ainda usadas por objetos ativos.

Não é seguro copiar somente os blocos auxiliares para endereços fixos. O próprio código calcula ajustes de destino conforme o personagem.

## 6. Próximos testes estáticos e dinâmicos

1. Rastrear todas as escritas em `$07C5/$0A45` e identificar a função de cada estado.
2. Identificar os consumidores dos dados nas quatro regiões de destino, em especial os endereços efetivos após os ajustes de `$0100/$0200`.
3. Comparar os fluxos descomprimidos para IDs diferentes, sem publicar ou distribuir dados extraídos do jogo.
4. Verificar se as regiões de destino estão vivas durante o round e se há uma janela segura de recarga.
5. Só então desenhar uma rotina de troca que preserve a vida, o timer, a posição, o round e o estado do oponente.

## Limites desta etapa

- A leitura estática confirma a preparação e o ajuste dos destinos.
- Ainda não foi identificado com certeza o significado funcional dos blocos auxiliares.
- Ainda não foi executado um teste de troca em combate.
- Nenhum patch funcional foi produzido.
