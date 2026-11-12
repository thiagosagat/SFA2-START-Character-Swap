-- Street Fighter Alpha 2 (USA) - captura somente-leitura para BizHawk
-- Compatibilidade: BizHawk 2.9+ (recomendado: release atual)
-- SNES WRAM: 128 KiB, dominio "WRAM"
-- Controle 1: SELECT + L = captura ANTES; SELECT + R = captura DEPOIS.
-- O script NAO escreve na memoria do jogo. Apenas le e salva arquivos.

local DOMAIN = "WRAM"
local WRAM_SIZE = 0x20000
local before_data = nil
local before_frame = nil
local status = "SCRIPT ATIVO | P1: SELECT+L antes | SELECT+R depois"
local prev_before = false
local prev_after = false
local output_dir = os.getenv("USERPROFILE")
if output_dir and output_dir ~= "" then
  output_dir = output_dir .. "\\Documents"
else
  output_dir = "."
end

local function outpath(name)
  return output_dir .. "\\" .. name
end

local function write_binary(name, data)
  local path = outpath(name)
  local f, err = io.open(path, "wb")
  if not f then return false, path .. " | " .. tostring(err) end
  local ok, werr = f:write(data)
  f:close()
  if not ok then return false, tostring(werr) end
  return true, path
end

local function write_text(name, data)
  local path = outpath(name)
  local f, err = io.open(path, "w")
  if not f then return false, path .. " | " .. tostring(err) end
  local ok, werr = f:write(data)
  f:close()
  if not ok then return false, tostring(werr) end
  return true, path
end

local function read_wram()
  local size = memory.getmemorydomainsize(DOMAIN)
  if size ~= WRAM_SIZE then
    return nil, "O dominio WRAM tem " .. tostring(size) .. " bytes; esperado: " .. tostring(WRAM_SIZE) .. ". Confira se a ROM SNES esta carregada."
  end
  local ok, data = pcall(memory.read_bytes_as_binary_string, 0, WRAM_SIZE, DOMAIN)
  if not ok then return nil, tostring(data) end
  if type(data) ~= "string" or #data ~= WRAM_SIZE then
    return nil, "A leitura da WRAM nao retornou 131072 bytes."
  end
  return data
end

local function capture_before()
  status = "LENDO WRAM antes do golpe..."
  local data, err = read_wram()
  if not data then status = "ERRO: " .. err; console.log(status); return end
  local ok, result = write_binary("SFA2_WRAM_ANTES.bin", data)
  if not ok then status = "ERRO ao salvar: " .. tostring(result); console.log(status); return end
  before_data = data
  before_frame = emu.framecount()
  write_text("SFA2_WRAM_ANTES_info.txt",
    "Street Fighter Alpha 2 USA\nCaptura: ANTES do golpe\nFrame: " .. tostring(before_frame) ..
    "\nDominio: WRAM\nTamanho: " .. tostring(#data) .. " bytes\nArquivo: " .. tostring(result) .. "\n")
  status = "CAPTURA ANTES salva. Agora receba UM golpe e use SELECT+R."
  console.log(status)
  console.log("Arquivo: " .. tostring(result))
end

local function capture_after()
  if not before_data then
    status = "FALTA A CAPTURA ANTES: use SELECT+L primeiro."
    console.log(status)
    return
  end
  status = "LENDO WRAM depois do golpe..."
  local data, err = read_wram()
  if not data then status = "ERRO: " .. err; console.log(status); return end

  local ok, result = write_binary("SFA2_WRAM_DEPOIS.bin", data)
  if not ok then status = "ERRO ao salvar: " .. tostring(result); console.log(status); return end

  local csvpath = outpath("SFA2_WRAM_DIFERENCAS.csv")
  local f, ferr = io.open(csvpath, "w")
  if not f then status = "Snapshots salvos, mas nao criou CSV: " .. tostring(ferr); console.log(status); return end
  f:write("WRAM_OFFSET,SNES_CPU_MIRROR,ANTES,DEPOIS\n")
  local changed = 0
  for offset = 0, WRAM_SIZE - 1 do
    local a = before_data:byte(offset + 1)
    local b = data:byte(offset + 1)
    if a ~= b then
      -- Enderecos $7E:0000-$7F:FFFF da WRAM principal do SNES.
      local snes_addr = 0x7E0000 + offset
      f:write(string.format("$%05X,$%06X,$%02X,$%02X\n", offset, snes_addr, a, b))
      changed = changed + 1
    end
  end
  f:close()

  write_text("SFA2_WRAM_DEPOIS_info.txt",
    "Street Fighter Alpha 2 USA\nCaptura: DEPOIS do golpe\nFrame: " .. tostring(emu.framecount()) ..
    "\nFrame da captura ANTES: " .. tostring(before_frame) ..
    "\nDominio: WRAM\nTamanho: " .. tostring(#data) .. " bytes\nBytes diferentes: " .. tostring(changed) ..
    "\nArquivo: " .. tostring(result) .. "\nCSV: " .. csvpath .. "\n")

  status = "CONCLUIDO: " .. tostring(changed) .. " bytes mudaram. Veja Documentos."
  console.log(status)
  console.log("Arquivos: SFA2_WRAM_ANTES.bin | SFA2_WRAM_DEPOIS.bin | SFA2_WRAM_DIFERENCAS.csv")
  before_data = nil
  before_frame = nil
end

-- Usa o controle fisico 1; as combinacoes SELECT+L/R sao apenas gatilhos de captura.
event.onframestart(function()
  local pad = joypad.getimmediate(1) or {}
  local do_before = pad.Select == true and pad.L == true
  local do_after = pad.Select == true and pad.R == true
  if do_before and not prev_before then capture_before() end
  if do_after and not prev_after then capture_after() end
  prev_before = do_before
  prev_after = do_after
end, "SFA2_RAM_CAPTURE_INPUT")

event.onframeend(function()
  gui.text(4, 4, status, "white", "topleft")
  gui.text(4, 18, "P1: SELECT+L = ANTES | SELECT+R = DEPOIS", "yellow", "topleft")
end, "SFA2_RAM_CAPTURE_OVERLAY")

console.log("SFA2 captura carregada. Dominio: " .. DOMAIN .. " (128 KiB).")
console.log("Os arquivos serao salvos em: " .. output_dir)
console.log("Entre em uma luta: SELECT+L antes do golpe; SELECT+R logo depois.")
