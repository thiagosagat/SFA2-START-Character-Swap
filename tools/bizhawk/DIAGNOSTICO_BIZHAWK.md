# Diagnóstico de BizHawk para SFA2

Use este arquivo antes do capturador principal caso queira confirmar que o BizHawk está reconhecendo os botões e a WRAM.

1. Abra a ROM USA no BizHawk.
2. Abra **Tools > Lua Console**.
3. No console, use **File > Open Script** e selecione `DIAGNOSTICO_BIZHAWK.lua`.
4. Pressione SELECT, L e R separadamente no controle 1.
5. Observe a janela Lua Console: ela deve registrar os nomes dos botões detectados.
6. Confira na saída se existe o domínio `WRAM` e se o tamanho é 131072 bytes.
7. Depois de confirmar, pare/remova o diagnóstico e carregue `SFA2_CAPTURA_BIZHAWK.lua`.

O diagnóstico só consulta input e domínios. Não escreve na memória e não altera a ROM.

Se os nomes dos botões aparecerem de modo diferente, envie uma foto da janela Lua Console. Se WRAM não aparecer ou o tamanho for diferente, envie a saída completa do console antes de usar o capturador.
