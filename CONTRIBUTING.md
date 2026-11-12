# Como contribuir

Este repositório documenta e desenvolve um patch experimental para Street Fighter Alpha 2 (USA), SNES.

## Regras obrigatórias

1. Não envie ROM, imagens de disco, dumps completos de RAM, saves, músicas, sprites ou assets comerciais.
2. Não trate endereços encontrados por busca estática como confirmados sem captura reproduzível.
3. Não altere a ROM-base do usuário. Trabalhe em cópia local e registre hash antes/depois.
4. Cada mudança de código deve explicar o endereço/offset, o contexto de execução e o efeito esperado.
5. Não chame hooks interceptores diretamente sem reconstruir o contexto de registradores e pilha esperado.
6. Não chame a rotina global CPU $C03CDA durante uma luta.
7. Nenhum patch será considerado funcional sem testes independentes de P1 e P2 e validação de vida, round, relógio, posição, animação, golpes e hitboxes.

## Fluxo recomendado

- Abra uma Issue para cada hipótese ou defeito.
- Trabalhe em branch separada para mudanças de código.
- Registre evidências e resultados em `docs/`.
- Execute a checagem local de sintaxe Lua antes de enviar alterações.
- Descreva como reproduzir qualquer teste e informe a versão do emulador.

## Commits

Use mensagens curtas e específicas, por exemplo:
- `docs: documenta endereço confirmado de energia P1`
- `tools: corrige captura de WRAM no BizHawk`
- `patch: adiciona detecção de START para P1`

## Estado do projeto

A troca de personagens durante o round ainda não está implementada. Não publique binários como funcionais antes de validar todos os critérios.
