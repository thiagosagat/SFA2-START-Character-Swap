# Plano de testes

## Fase A — diagnóstico sem escrita de memória

- [ ] Validar que a ROM carregada é a versão USA original (CRC-32 `9C59DDFF`).
- [ ] Executar o script BizHawk em uma luta normal.
- [ ] Capturar P1 imediatamente antes de um golpe.
- [ ] Receber exatamente um golpe.
- [ ] Capturar P1 imediatamente depois.
- [ ] Repetir o mesmo procedimento para P2.
- [ ] Arquivar os binários e CSV fora do repositório (não commitar dumps sem necessidade).

## Fase B — identificar energia

- [ ] Comparar snapshots e eliminar alterações de frame, animação e HUD.
- [ ] Repetir com dano diferente.
- [ ] Identificar vida atual e vida máxima de cada lado.
- [ ] Confirmar largura, endianess, escala e comportamento de arredondamento.

## Fase C — identificar entrada START

- [ ] Instrumentar leitura de input durante a luta.
- [ ] Distinguir START de START+outros botões.
- [ ] Confirmar detecção de borda para não repetir a troca a cada frame.
- [ ] Confirmar independência entre P1 e P2.

## Fase D — carregamento seguro

- [ ] Mapear chamada original que compara IDs com caches.
- [ ] Reconstruir contexto de CPU/registradores esperado pelos hooks.
- [ ] Carregar moveset e hitboxes em cada um dos caminhos: S-DD1 customizado e descompressor original.
- [ ] Atualizar referências derivadas sem reiniciar round ou estado global.

## Fase E — integração e validação

- [ ] Trocar P1 e verificar P2 inalterado.
- [ ] Trocar P2 e verificar P1 inalterado.
- [ ] Validar vida percentual.
- [ ] Validar posição, round, cronômetro, cenário, sprites, paleta, animações, golpes e colisões.
- [ ] Testar todos os personagens permitidos e personagens secretos separadamente.
- [ ] Testar no BizHawk e depois confirmar no Snes9x 1.63.
