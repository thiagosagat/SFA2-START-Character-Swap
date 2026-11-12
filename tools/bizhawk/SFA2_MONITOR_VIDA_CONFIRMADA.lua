-- Street Fighter Alpha 2 (USA) SNES - monitor de vida
-- BizHawk 2.11.1 | SOMENTE LEITURA
-- Enderecos Action Replay da ROM USA:
-- P1 vida: WRAM $073E (codigo 7E073E90)
-- P2 vida: WRAM $09BE (codigo 7E09BE90)
-- IDs: P1 $07A2; P2 $0A22
-- Nao escreve na memoria. Gera SFA2_health_monitor.csv.

local DOMAIN = "WRAM"
local OUTPUT = "SFA2_health_monitor.csv"
local SAMPLE_FRAMES = 1

local function log(s)
    if console and console.log then console.log(s) else print(s) end
end

local read8 = memory.read_u8
if not read8 then
    log("ERRO: memory.read_u8 indisponivel.")
    return
end

local ok, domain_err = pcall(function()
    memory.usememorydomain(DOMAIN)
end)
if not ok then
    log("ERRO ao selecionar WRAM: " .. tostring(domain_err))
    return
end

local f, ferr = io.open(OUTPUT, "w")
if not f then
    log("ERRO ao criar " .. OUTPUT .. ": " .. tostring(ferr))
    return
end

f:write("frame,p1_health,p2_health,p1_character,p2_character\n")
f:flush()

local function rd(addr)
    return read8(addr, DOMAIN)
end

local function hex(v)
    if v == nil then return "??" end
    return string.format("%02X", v)
end

local previous = {}
local last_frame = -1

log("SFA2 monitor iniciado. WRAM somente leitura.")
log("Vida P1: $073E | Vida P2: $09BE | IDs: P1 $07A2 / P2 $0A22")
log("CSV: " .. OUTPUT)

while true do
    emu.frameadvance()
    local frame = emu.framecount()
    if frame - last_frame >= SAMPLE_FRAMES then
        local p1 = rd(0x073E)
        local p2 = rd(0x09BE)
        local c1 = rd(0x07A2)
        local c2 = rd(0x0A22)

        if p1 ~= previous.p1 or p2 ~= previous.p2 or
           c1 ~= previous.c1 or c2 ~= previous.c2 then
            f:write(string.format("%d,%s,%s,%s,%s\n",
                frame, hex(p1), hex(p2), hex(c1), hex(c2)))
            f:flush()
            previous = {p1=p1, p2=p2, c1=c1, c2=c2}
        end

        if gui and gui.text then
            gui.text(8, 8, "SFA2 VIDA  P1: " .. hex(p1) .. "  P2: " .. hex(p2))
            gui.text(8, 20, "CHAR      P1: " .. hex(c1) .. "  P2: " .. hex(c2))
        end
        last_frame = frame
    end
end
