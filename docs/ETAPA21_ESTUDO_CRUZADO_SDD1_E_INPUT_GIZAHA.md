# Etapa 21 — Estudo cruzado do S-DD1, ASM Gizaha e entrada de botões

Data: 2026-11-12
ROM-base local: Street Fighter Alpha 2 (USA), 4 MiB
CRC-32: `9C59DDFF`
SHA-256: `910a29f834199c63c22beddc749baba746da9922196a553255deade59f4fc127`

## 1. Escopo realmente estudado

Foram inspecionados:
- `MSU1_StreetFighterAlpha2_20221021_gizaha.zip`, especialmente `main.asm`, `select gouki with select+start.asm`, `fix intro timing.asm`, `speed tweaks/player movesets sdd1 dma.asm`, `speed tweaks/decompressor.asm` e `speed tweaks/object code.asm`;
- a ROM USA local, com comparação de bytes nos offsets dos hooks e rotinas;
- o ZIP local `snes-street-fighter-alpha-2-nochip-main.zip` e o estado atual do repositório público.

## 2. Resultado importante: o projeto “no-chip” não é um código-fonte completo no ZIP local

O repositório público `gufranco/snes-street-fighter-alpha-2-nochip` foi arquivado em 10/11/2026. O ZIP local contém apenas 22 entradas: READMEs em vários idiomas, configuração do site, layout e imagens de evidência. Não contém `REFERENCE.md`, `sdd1map.py`, `sdd1sites.py`, `hardware/`, testes ou módulos de engenharia reversa. Portanto, não é correto afirmar que o ZIP local traz as ferramentas executáveis.

A página pública indexada de `sdd1sites.py` ainda permite estudar uma parte da metodologia:
- converte offsets LoROM em endereços CPU;
- cria uma máscara das regiões comprimidas usando o mapa de streams;
- procura instruções `STA $4800-$4807` fora dos dados comprimidos;
- desassembla uma janela antes/depois das escritas para identificar programação dos registradores S-DD1.

Isso é útil para encontrar pontos de programação do S-DD1 e evitar falsos positivos dentro de streams. Não é, por si só, um localizador de carregadores de personagens nem fornece a rotina de troca durante combate.

Fontes públicas:
- https://github.com/gufranco/snes-street-fighter-alpha-2-nochip
- https://github.com/gufranco/snes-street-fighter-alpha-2-nochip/blob/main/sdd1sites.py
- https://github.com/gufranco/snes-street-fighter-alpha-2-nochip/blob/main/CONTRIBUTING.md

## 3. Achado novo no ASM Gizaha: bytes de botões usados pelo código de seleção

O arquivo `select gouki with select+start.asm` injeta lógica no endereço de ROM `$00CA80`:
- lê `$AB` para P1 e `$B1` para P2;
- executa `AND #$30` e compara com `#$30`;
- quando ambos os bits estão ativos, seleciona o ID `#$14` (Gouki/Shin Akuma, conforme o comentário do patch) no slot correspondente;
- P1 grava em `$1C20`, P2 em `$1C21`; limpa também flags auxiliares `$07C8` / `$0A48`.

O comentário do autor chama `$AB` e `$B1` de “P1 keypresses” e “P2 keypresses”, e descreve `#$30` como Select+Start. Isso fornece evidência específica de que esses bytes são usados pelo patch como estado de botões para os dois jogadores, e que o par de bits `$10|$20` corresponde à combinação Select+Start nesse contexto.

**Inferência controlada:** se o objetivo for testar START isolado nesses mesmos bytes, o candidato de máscara é `#$10`, pois o código de referência usa `#$30` para Select+Start. Ainda é necessário confirmar experimentalmente a polaridade/semântica exata do bit e se esses bytes são válidos no estado de combate. Não inserir esse teste no hook de seleção e não presumir que `$CA80` seja chamado durante o round.

O código de seleção também testa o ID de personagem e altera variáveis de seleção. Isso confirma que é lógica de seleção/segredo, não uma rotina comprovada para troca no meio da luta.

## 4. O que o carregador de moveset realmente faz

Em `speed tweaks/player movesets sdd1 dma.asm`, quatro pontos de interceptação:
- P1 moveset: ROM `$003D33`;
- P1 hitboxes: ROM `$003D59`;
- P2 moveset: ROM `$003DC0`;
- P2 hitboxes: ROM `$003DE6`.

Cada trecho:
1. lê o ID de personagem de P1 `$07A2` ou P2 `$0A22`;
2. duplica o ID para indexar `.len_table`;
3. se a entrada da tabela indica um stream especial, lê o tamanho prefixado e salta para `$DADFCF` (caminho DMA S-DD1 customizado);
4. caso contrário, salta para o descompressor original `$C02889`.

A tabela não cobre todos os IDs com stream customizado. O caminho stock permanece essencial. O código também inclui inserções específicas de alguns streams e manipulação dos caches `$1C07/$1C08`.

**Conclusão:** esses quatro endereços são interceptores executados no fluxo de descompressão, não quatro APIs autônomas que possam ser chamadas arbitrariamente em combate.

## 5. A inicialização pré-luta é inadequada para uma troca durante round

Em `fix intro timing.asm`, o autor altera o ID de P1 para `$00`, o de P2 para `$01`, e chama `$C03CDA` durante uma transição narrativa antes da luta. A rotina ampla prepara dados dos dois jogadores e executa limpeza de áreas de WRAM. Isso confirma o uso pré-luta no patch de referência, mas não prova segurança durante o round.

Não chamar `$C03CDA` no meio da luta.

## 6. Por que a estratégia de troca não pode ser apenas trocar o ID

A partir dos fontes examinados, uma troca coerente precisaria tratar, no mínimo:
- ID ativo do jogador;
- dados de moveset e hitboxes correspondentes;
- caches P1/P2;
- possíveis dados auxiliares condicionais carregados pelas flags `$07C5/$0A45`;
- estruturas de objetos, animações e estado que possam referenciar o personagem antigo;
- energia proporcional, usando os endereços candidatos confirmados por códigos AR apenas após validação dinâmica.

O ASM mostra carregadores auxiliares P1/P2 condicionados por `$07C5` e `$0A45`, com destinos preparados em campos separados. A função semântica completa desses blocos ainda não está estabelecida.

## 7. Próximos testes técnicos prioritários

1. No BizHawk, observar `$AB` e `$B1` enquanto se pressiona separadamente START e SELECT em P1/P2, durante seleção e durante luta.
2. Confirmar se `$AB/$B1` são pulsos de recém-pressionado ou estado mantido; comparar frames pressionado, mantido e liberado.
3. Localizar a origem e os consumidores de `$AB/$B1` na ROM USA, com desassemblagem e estado M/X corretos.
4. Identificar o caminho de execução por frame no round e encontrar um hook que seja realmente alcançado durante combate.
5. Só então desenhar um hook que leia START independentemente para cada jogador.
6. Em paralelo, medir os destinos e comprimentos de moveset/hitbox e os efeitos dos carregadores auxiliares antes de tentar recarga durante a luta.

## 8. Veredito desta etapa

**Confirmado por fonte ASM:**
- `$AB` e `$B1` são usados como bytes de keypresses de P1/P2 pelo patch de seleção;
- `#$30` é a combinação Select+Start nesse código;
- os carregadores de moveset/hitboxes têm quatro pontos de interceptação e caminhos S-DD1 customizado/stock;
- `$C03CDA` é usado em uma transição pré-luta e não deve ser reutilizado sem reconstruir seus efeitos.

**Inferido, ainda sem teste dinâmico:**
- `#$10` é o candidato de máscara para START isolado nos bytes `$AB/$B1`.

**Pendente:**
- ciclo de vida e origem dos bytes `$AB/$B1`;
- ponto de execução por frame seguro durante combate;
- segurança de recarga dos dados no meio do round;
- validação em emulador e patch funcional.

Nenhum patch de troca durante a luta foi criado ou declarado funcional nesta etapa.
