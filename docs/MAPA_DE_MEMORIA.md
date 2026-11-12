# Mapa de memória e referências

Este documento distingue RAM, offsets de ROM e endereços CPU. Não misturar essas três notações.

| Referência | Espaço | Significado/observação |
|---|---|---|
| `$7E07A2` | WRAM | ID do personagem P1 |
| `$7E0A22` | WRAM | ID do personagem P2 |
| `$1C07` | WRAM/offset curto | marcador de cache do moveset P1 |
| `$1C08` | WRAM/offset curto | marcador de cache do moveset P2 |
| `$003D33` | offset ROM | interceptação do carregamento de moveset P1 |
| `$003D59` | offset ROM | interceptação do carregamento de hitboxes P1 |
| `$003DC0` | offset ROM | interceptação do carregamento de moveset P2 |
| `$003DE6` | offset ROM | interceptação do carregamento de hitboxes P2 |
| `$C03CDA` | endereço CPU | inicialização global usada em transição pré-luta; não chamar durante luta |
| `$C0A329` | endereço CPU | rotina no fluxo relacionado a personagem atingido; aplicação de dano não confirmada |
| `$B904`, `$B924` | referência gráfica | não são variáveis de energia |

## ROM original de referência

- Tamanho: `0x400000` bytes
- CRC-32: `9C59DDFF`
- SHA-256: `910a29f834199c63c22beddc749baba746da9922196a553255deade59f4fc127`

## Disciplina de confirmação

Para considerar um endereço como vida atual/máxima:

- deve variar no momento do dano de forma consistente;
- deve ser separado de temporizadores e animações;
- deve responder de forma independente para P1 e P2;
- precisa ser conferido com múltiplos valores de dano e com barra cheia/parcial;
- deve ser confirmado em uma segunda execução ou estado equivalente.
