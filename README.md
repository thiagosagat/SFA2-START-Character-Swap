# Street Fighter Alpha 2 (SNES) — START Character Swap

Projeto de engenharia reversa e desenvolvimento de um patch experimental para **Street Fighter Alpha 2 (USA), SNES**.

## Objetivo

Durante uma luta ativa, pressionar **START sozinho** deve trocar o personagem daquele jogador pelo próximo personagem da sequência, de forma independente para P1 e P2, mantendo:

- a porcentagem de energia;
- o round e o cronômetro;
- a posição e o estado da luta, tanto quanto tecnicamente possível;
- o outro jogador sem alterações.

## Estado atual

**Ainda não existe patch funcional de troca.** O projeto está na fase de rastreamento de memória e análise dos carregadores de moveset/hitboxes. Os endereços abaixo são referências de código verificadas na fonte ASM examinada; não devem ser tratados como prova de que a troca em combate já funciona.

- IDs de personagem em WRAM: P1 `$7E07A2`, P2 `$7E0A22`.
- Marcadores de cache: P1 `$1C07`, P2 `$1C08`.
- Hooks encontrados no fluxo original de descompressão: offsets ROM `$003D33` (P1 moveset), `$003D59` (P1 hitboxes), `$003DC0` (P2 moveset), `$003DE6` (P2 hitboxes).
- O carregador usa dados S-DD1 específicos para alguns IDs e fallback para o descompressor original para os demais.
- A rotina global `$C03CDA` é usada em transições pré-luta e **não deve ser chamada no meio de uma luta**.
- Os endereços reais de vida atual/máxima ainda não foram confirmados.

Leia [`docs/STATUS_TECNICO.md`](docs/STATUS_TECNICO.md) antes de implementar um patch.

## Captura e análise de memória

A pasta [`tools/bizhawk`](tools/bizhawk) contém um script Lua de **somente leitura** para BizHawk. Ele salva duas capturas de WRAM (128 KiB) antes/depois de um golpe. O script ainda precisa ser executado em BizHawk para validar a captura em ambiente real.

Depois de obter `SFA2_WRAM_ANTES.bin` e `SFA2_WRAM_DEPOIS.bin`, use o analisador Python:

```bash
python tools/analyze_wram.py SFA2_WRAM_ANTES.bin SFA2_WRAM_DEPOIS.bin
```

Ele mostra regiões alteradas e gera `SFA2_ANALISE_WRAM.csv`. O relatório **não identifica automaticamente a vida**: é necessário comparar golpes repetidos e capturas de P1/P2 para separar energia de animações, temporizadores e HUD.

O Snes9x comum não possui o menu Lua Console utilizado por este procedimento.

## ROM e direitos autorais

Este repositório **não inclui** ROM, cópia do jogo, patch IPS/BPS, música, sprites, imagens ou outros assets comerciais. Use uma cópia legítima da ROM original localmente. Não envie ROM nem assets protegidos ao GitHub.

ROM-base de referência (somente identificação/checksum):

- Nome: `Street Fighter Alpha 2 (USA).sfc`
- Tamanho: `4,194,304` bytes
- CRC-32: `9C59DDFF`
- SHA-256: `910a29f834199c63c22beddc749baba746da9922196a553255deade59f4fc127`

## Estrutura

```text
.
├── .github/              # validação automática e modelos de Issue
├── docs/                 # estado técnico, mapa de memória e plano de testes
├── research/             # notas rastreáveis de engenharia reversa
├── tests/                # testes automatizados do analisador
└── tools/                # captura BizHawk e análise de WRAM
```

## Ferramentas

- BizHawk (para Lua Console e captura de WRAM): https://github.com/TASEmulators/BizHawk/releases
- Asar 1.9 (montador): https://github.com/RPGHacker/asar
- Snes9x 1.63 pode ser usado para testes normais de jogo; para o script de diagnóstico Lua, use BizHawk.

## Referência de terceiros

A análise dos carregadores foi feita a partir do código-fonte distribuído no projeto MSU-1 de Street Fighter Alpha 2 de **gizaha**, baseado no patch original de **PepilloPEV**. O código e os assets de terceiros não são redistribuídos neste repositório. Consulte a fonte original e respeite os termos dos autores: https://www.zeldix.net/t1831-street-fighter-alpha-2

## Verificação automática\n\nO GitHub Actions executa a checagem de sintaxe do Lua, testes do analisador Python e bloqueia extensões de ROM, patches e dumps de memória no repositório. Consulte a aba **Actions** para ver o resultado de cada commit.\n\n## Regra de qualidade

Nenhum endereço é considerado confirmado sem evidência reproduzível. Nenhum patch será marcado como funcional sem teste em emulador e validação de P1/P2, energia, round, cronômetro, sprites, animações, golpes e hitboxes.
