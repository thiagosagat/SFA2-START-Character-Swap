# ETAPA 16 — Escritas e ciclos de vida dos sinalizadores auxiliares

## Objetivo

Rastrear as instruções que escrevem nos sinalizadores lidos pelos carregadores auxiliares: P1 `$07C5` e P2 `$0A45`.

## 1. Escritas encontradas no ROM USA

Busca estática por instruções de escrita absoluta, zeragem e incremento encontrou estes pontos (offsets de arquivo):

### P1 — `$07C5`

- Zeragens `STZ $07C5`: `$000BD4`, `$006420`, `$009C29`, `$00CA0F`, `$00DE14`, `$12BE74`.
- Incrementos `INC $07C5`: `$00372D`, `$009B82`, `$12C4A8`.
- Escritas `STA $07C5`: `$00CA3E`, `$00CA50`.

### P2 — `$0A45`

- Zeragens `STZ $0A45`: `$000BD7`, `$006423`, `$009C2C`, `$00CA12`, `$00E5EA`, `$12BE77`.
- Incrementos `INC $0A45`: `$00375C`, `$009B8B`, `$12C4B4`.
- Escritas `STA $0A45`: `$00CA68`, `$00CA7A`.

## 2. Evidência de inicialização por jogador

No trecho de offset `$00CA0B-$00CA7A`, o código primeiro zera ambos os sinalizadores. Depois, em caminhos separados:

- P1 recebe o ID em `$07A2` e o sinalizador `$07C5` recebe `1`.
- P2 recebe o ID em `$0A22` e o sinalizador `$0A45` recebe `1`.

Há um segundo caminho condicional que também pode atribuir `1` aos sinalizadores. Isso confirma que os bytes fazem parte da preparação/estado dos dados do jogador, mas ainda não prova isoladamente se representam “dados pendentes”, “personagem válido” ou outro estado.

## 3. Evidência de reinicialização

Os pontos de zeragem incluem rotinas de preparação e transição. Um trecho em `$12BE74` zera os dois sinalizadores e, logo depois, escreve valores iniciais nos IDs de P1/P2. Outros pontos limpam os dois em conjunto, indicando que o jogo reinicializa esses estados em mais de uma transição.

## 4. Evidência de incremento

Os incrementos em `$00372D/$00375C`, `$009B82/$009B8B` e `$12C4A8/$12C4B4` mostram que os bytes não são usados exclusivamente como booleanos constantes. Os carregadores só testam zero versus não-zero, mas outros caminhos incrementam o valor.

**Conclusão:** para uma rotina nova de troca, não devemos sobrescrever esses bytes com valores arbitrários nem presumir que basta deixá-los em `1`. É necessário preservar a semântica de seus ciclos de vida.

## 5. Consequência para a implementação

O carregador auxiliar condicional só executa quando o sinalizador correspondente é diferente de zero. A preparação do personagem atribui `1` em determinados caminhos; rotinas de reset zeram o campo; outras rotinas o incrementam.

Assim, uma futura rotina de troca deve:
- tratar P1 e P2 separadamente;
- preservar o valor anterior do sinalizador ou reproduzir o protocolo original;
- evitar executar o carregador quando o estado do jogador não autorizar;
- verificar em runtime em que momento o sinalizador muda durante o round.

## 6. Limites

- As ocorrências acima foram obtidas por busca de padrões de opcodes no ROM e inspeção dos contextos próximos.
- A classificação semântica dos caminhos ainda não foi fechada.
- Ainda não foi comprovado que os blocos auxiliares são necessários em todos os personagens.
- Ainda não foi feito teste de troca em combate.
- Nenhum patch funcional foi produzido.
