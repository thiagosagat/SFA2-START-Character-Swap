# Captura de WRAM no BizHawk (português)

1. Baixe o BizHawk x64 pela página oficial: https://github.com/TASEmulators/BizHawk/releases/latest
2. Extraia o ZIP e execute `EmuHawk.exe`.
3. Abra a ROM original USA em `File > Open ROM`.
4. Na janela principal, abra `Tools > Lua Console`.
5. Na janela Lua Console, escolha `File > Open Script` e abra `SFA2_CAPTURA_BIZHAWK.lua`.
6. Em uma luta, use o controle 1: `SELECT + L` antes do golpe; após a barra diminuir, `SELECT + R`.
7. O script grava `SFA2_WRAM_ANTES.bin`, `SFA2_WRAM_DEPOIS.bin` e `SFA2_WRAM_DIFERENCAS.csv` na pasta `Documents` do usuário.

O script lê a WRAM e grava arquivos no computador. Não escreve na ROM nem na memória do jogo. O script ainda precisa ser validado em execução com uma instalação real do BizHawk. Não use o Snes9x comum para executar este Lua Console.

Não envie a ROM ao repositório. Ao compartilhar as capturas para análise, prefira anexá-las na conversa e não fazer commit dos snapshots no Git.
