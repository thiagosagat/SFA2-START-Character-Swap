-- Diagnostico de ambiente BizHawk/SNES para o projeto SFA2.
-- Somente leitura: nao altera ROM nem memoria do jogo.
-- Mostra os nomes reais dos botoes detectados e os dominios de memoria.

local function safe_call(fn, ...)
  local ok, value = pcall(fn, ...)
  if ok then return value end
  return nil, tostring(value)
end

local function list_domains()
  local value, err = safe_call(memory.getmemorydomainlist)
  if not value then return "ERRO ao consultar dominios: " .. tostring(err) end
  return tostring(value)
end

local last_keys = ""
local last_frame = -1
local domain_text = list_domains()
local wram_size, wram_error = safe_call(memory.getmemorydomainsize, "WRAM")
local version, version_error = safe_call(client.getversion)

console.log("=== SFA2 BizHawk diagnostic ===")
console.log("BizHawk: " .. tostring(version or version_error or "desconhecido"))
console.log("Sistema: " .. tostring(emu.getsystemid()))
console.log("Dominios de memoria:\n" .. domain_text)
console.log("WRAM size: " .. tostring(wram_size or wram_error or "indisponivel"))
console.log("Pressione SELECT, L e R separadamente no controle 1 para ver os nomes detectados.")

event.onframestart(function()
  local keys, err = safe_call(joypad.getimmediate, 1)
  if not keys then
    last_keys = "ERRO joypad.getimmediate(1): " .. tostring(err)
    return
  end

  local pressed = {}
  for name, value in pairs(keys) do
    if value then pressed[#pressed + 1] = tostring(name) end
  end
  table.sort(pressed)
  local joined = table.concat(pressed, ", ")
  if joined ~= last_keys then
    last_keys = joined
    last_frame = emu.framecount()
    if joined == "" then
      console.log("Controle 1: nenhum botao pressionado")
    else
      console.log("Controle 1 detectado no frame " .. tostring(last_frame) .. ": " .. joined)
    end
  end
end, "SFA2_DIAG_INPUT")

event.onframeend(function()
  gui.text(4, 4, "SFA2 DIAGNOSTICO BIZHAWK", "yellow", "topleft")
  gui.text(4, 18, "Pressione SELECT / L / R separadamente", "white", "topleft")
  gui.text(4, 32, "Botoes: " .. (last_keys ~= "" and last_keys or "(nenhum)"), "white", "topleft")
  gui.text(4, 46, "WRAM: " .. tostring(wram_size or "nao detectada"), "white", "topleft")
end, "SFA2_DIAG_OVERLAY")
