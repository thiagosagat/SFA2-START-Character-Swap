# Etapa 13 — Separação real dos caminhos P1/P2 em C0:3CDA

Data: 2026-11-12  
Base: Street Fighter Alpha 2 USA, CRC-32 9C59DDFF.  
Evidência: dump de bytes $003CDA-$003E98 em `SFA2_Gizaha_stage2_trace.zip`, conferido contra a ROM-base.

## Resultado novo

A desmontagem byte a byte permite delimitar melhor o código:

- `$C0:3D99` é um subprograma individual de P2. Ele compara o ID em `$0A22` com cache `$1C08`; se mudou, prepara ponteiros, chama `$C0:2889` para moveset e hitboxes e grava o ID no cache.
- O fluxo de P1 começa em `$C0:3D0D` após a chamada a `$C0:3D99`. Ele compara `$07A2` com `$1C07`; se mudou, prepara ponteiros, chama o mesmo descompressor duas vezes e grava o ID no cache.
- A limpeza ampla de WRAM só começa depois do armazenamento do cache P1, aproximadamente em `$C0:3D64`, com `LDX #$0C00; STZ $0000,X; INX; CPX #$1000; BNE`. O loop limpa `$7E:0C00-$7E:0FFF`.

## Sequência P2 em $C0:3D99

A rotina faz:
1. Lê `$0A22`, compara com `$1C08`.
2. Se iguais, salta para RTL sem recarregar.
3. Calcula índice do personagem e carrega ponteiro de moveset nas variáveis temporárias `$10/$12`, prepara destino em `$14` e banco em `$16`.
4. Chama `$C0:2889`.
5. Repete a preparação para hitboxes e chama `$C0:2889`.
6. Grava novo ID em `$1C08` e retorna com RTL.

**Conclusão:** P2 tem uma rotina de carregamento estreita, mas ela não foi demonstrada como segura em combate. O destino é o banco WRAM $7F e os dados auxiliares ainda podem ser usados por atores/IA.

## Sequência P1 em $C0:3D0D

A rotina:
1. Compara `$07A2` com `$1C07`.
2. Se mudou, prepara origem/destino e chama `$C0:2889` para moveset.
3. Prepara segundo fluxo e chama `$C0:2889` para hitboxes.
4. Grava o ID em `$1C07`.
5. Só então executa a limpeza de objetos/WRAM e zera vários campos globais.

**Conclusão:** o trecho de carregamento P1 pode ser conceitualmente separado do bloco de limpeza. Ainda não é um callable wrapper: os registradores e variáveis temporárias precisam ser preservados, e a rotina deve manter o modo A/X/Y esperado em cada chamada. O caminho P1 também depende das tabelas em $C0:B736/$C0:B738 e do banco destino $7E.

## Ordem real do inicializador

O fluxo de entrada em $C0:3CDA prepara os IDs/tabelas, chama primeiro o helper P2 ($C0:3D99), depois processa P1 e finalmente executa a limpeza global. Isso corrige uma simplificação anterior: P2 não é simplesmente carregado depois da limpeza P1; o helper P2 é chamado antes do trecho P1 que contém a limpeza.

## Hipótese de implementação segura (ainda não testada)

- P2: criar um wrapper que replique a preparação de registradores e invoque somente a rotina de $C0:3D99, depois de salvar/restaurar contexto e validar todos os destinos.
- P1: extrair em nova rotina o trecho que prepara e descomprime moveset/hitboxes, terminando logo após gravar $1C07; nunca executar o loop $0C00-$0FFF nem os stores globais subsequentes.
- Ambos: só disparar em ponto de frame em que o jogador não esteja executando ataque, hitstun, queda, super, transição ou outra animação com dados de personagem em uso. Esse gate ainda precisa ser descoberto.
- Antes de usar, calcular intervalos efetivos e mapear todas as referências ao ponteiro-base de hitbox, animação e IA.

## O que ainda falta provar

1. Que $C0:3D99 pode ser chamado em combate sem corromper o estado P2.
2. Que o trecho P1 extraído pode ser convertido em subrotina reentrante e segura.
3. Que os destinos de descompressão não sobrescrevem objetos/efeitos.
4. Que as tabelas de hitbox e os ponteiros-base derivados são atualizados por esses dois blocos ou exigem atualização adicional.
5. Que a troca não deixa o lutador preso em um estado de animação inválido.
6. Que START pode ser detectado por jogador no loop ativo sem disparos repetidos.

## Evidência e referências

- `C03CDA_disassembly_bytes.txt` e `STAGE2_ROM_TRACE.txt` no pacote de rastreamento local, ROM CRC conferido.
- Fonte Gizaha `speed tweaks/player movesets sdd1 dma.asm`: quatro hooks P1/P2 para moveset e hitboxes.
- Projeto S-DD1 sem chip: https://github.com/gufranco/snes-street-fighter-alpha-2-nochip
- O projeto S-DD1 confirma o fluxo de descompressão gráfica e os custos de preparação pré-luta, mas não documenta troca de lutador durante round.

## Estado

- Confirmado por bytes: P2 helper em $C0:3D99, comparação/cache e duas chamadas ao descompressor.
- Confirmado por bytes: trecho P1 de carga antes do loop de limpeza.
- Confirmado por bytes: limpeza de $7E:0C00-$7E:0FFF após o carregamento P1.
- Ainda não confirmado: segurança de qualquer carregador durante round.
- Não implementado: wrappers novos ou troca via START.
- Não gerado: patch funcional.
