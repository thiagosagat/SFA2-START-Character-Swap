# Notas de pesquisa e proveniência

A análise usa uma cópia local do arquivo de fonte do patch MSU-1 de Street Fighter Alpha 2, creditado a gizaha e baseado no trabalho de PepilloPEV. O arquivo de fonte consultado inclui `main.asm`, `fix intro timing.asm` e `speed tweaks/player movesets sdd1 dma.asm`.

Referência externa dos autores: https://www.zeldix.net/t1831-street-fighter-alpha-2

Este projeto não redistribui os arquivos ASM completos, ROM, patches, música ou assets desse projeto de terceiros. As tabelas e observações daqui são anotações de engenharia reversa feitas para orientar a investigação desta modificação separada.

## Registro de evidência

- [x] Identificados os hooks de moveset/hitbox de P1 e P2 no fonte ASM.
- [x] Identificados os IDs de personagem e caches consultados pelo carregador.
- [x] Confirmado fallback para o descompressor original quando não há bloco S-DD1 customizado.
- [x] Confirmado que a rotina global `$C03CDA` é usada num fluxo de transição pré-luta.
- [ ] Identificar a vida atual/máxima em WRAM por captura dinâmica.
- [ ] Confirmar rotina de carregamento segura em luta.
- [ ] Implementar troca START independente.
