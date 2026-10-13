-- Z Studios | Protótipo visual do mapa v0.1
-- Coloque este Script em ServerScriptService no Roblox Studio.
-- Não cria contas, não salva progresso e não inclui mecânicas de jogo.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local ROOT_NAME = "ZStudios_MapaVisual"
local previous = Workspace:FindFirstChild(ROOT_NAME)
if previous then previous:Destroy() end

local root = Instance.new("Model")
root.Name = ROOT_NAME
root.Parent = Workspace

local C = {
 grass = Color3.fromRGB(107, 169, 89),
 darkGrass = Color3.fromRGB(77, 137, 71),
 stone = Color3.fromRGB(120, 126, 133),
 stoneLight = Color3.fromRGB(166, 170, 172),
 path = Color3.fromRGB(202, 177, 132),
 wood = Color3.fromRGB(107, 73, 47),
 leaf = Color3.fromRGB(51, 132, 66),
 leaf2 = Color3.fromRGB(77, 155, 76),
 beige = Color3.fromRGB(225, 205, 164),
 red = Color3.fromRGB(161, 58, 51),
 gold = Color3.fromRGB(234, 193, 87),
 white = Color3.fromRGB(242, 240, 223),
}

local function part(name, size, cf, color, material, parent, shape)
 local p = Instance.new("Part")
 p.Name = name
 p.Size = size
 p.CFrame = cf
 p.Color = color
 p.Material = material or Enum.Material.SmoothPlastic
 p.Anchored = true
 p.CanCollide = true
 if shape then p.Shape = shape end
 p.TopSurface = Enum.SurfaceType.Smooth
 p.BottomSurface = Enum.SurfaceType.Smooth
 p.Parent = parent or root
 return p
end

local function model(name, parent)
 local m = Instance.new("Model")
 m.Name = name
 m.Parent = parent or root
 return m
end

local function disk(name, radius, y, color, material, parent, thickness)
 return part(name, Vector3.new(radius * 2, thickness or 3, radius * 2),
  CFrame.new(0, y, 0), color, material, parent, Enum.PartType.Cylinder)
end

local function sign(facePart, text, color)
 local gui = Instance.new("SurfaceGui")
 gui.Name = "PlacaVisual"
 gui.Face = Enum.NormalId.Front
 gui.PixelsPerStud = 35
 gui.Parent = facePart
 local label = Instance.new("TextLabel")
 label.Size = UDim2.fromScale(1, 1)
 label.BackgroundTransparency = 1
 label.Text = text
 label.TextColor3 = color or C.white
 label.TextScaled = true
 label.Font = Enum.Font.GothamBold
 label.Parent = gui
end

local function tree(pos, scale, parent)
 local m = model("Arvore", parent)
 part("Tronco", Vector3.new(3, 13, 3)*scale,
  CFrame.new(pos + Vector3.new(0, 6.5*scale, 0)), C.wood, Enum.Material.Wood, m)
 local crown = part("Copa", Vector3.new(15, 15, 15)*scale,
  CFrame.new(pos + Vector3.new(0, 16*scale, 0)),
  (math.floor(pos.X + pos.Z) % 2 == 0) and C.leaf or C.leaf2,
  Enum.Material.Grass, m, Enum.PartType.Ball)
 crown.CanCollide = false
end

local function rock(pos, scale, parent)
 local p = part("Pedra", Vector3.new(7, 5, 6)*scale,
  CFrame.new(pos + Vector3.new(0, 2*scale, 0)) * CFrame.Angles(0, math.rad(31), math.rad(9)),
  C.stoneLight, Enum.Material.Slate, parent, Enum.PartType.Ball)
 p.CanCollide = true
end

-- Ilha central: terreno cilíndrico horizontal (eixo do Cylinder alinhado ao Y)
local island = disk("IlhaCentral", 225, -3, C.grass, Enum.Material.Grass, root, 6)
island.CFrame = CFrame.new(0, -3, 0) * CFrame.Angles(0, 0, math.rad(90))

-- Arena central decorativa
local arena = disk("ArenaCentral", 37, 0.15, C.stoneLight, Enum.Material.Slate, root, 0.35)
arena.CFrame = CFrame.new(0, 0.15, 0) * CFrame.Angles(0, 0, math.rad(90))
local arenaInner = disk("CirculoArena", 31, 0.38, C.path, Enum.Material.Sand, root, 0.18)
arenaInner.CFrame = CFrame.new(0, 0.38, 0) * CFrame.Angles(0, 0, math.rad(90))

-- Muralha circular segmentada: oito aberturas alinhadas aos terrenos.
-- Um segmento por 5 graus, com vão de +/- 8 graus em cada portão.
local WALL_RADIUS = 212
local GATE_ANGLES = {}
for i = 0, 7 do GATE_ANGLES[i+1] = i * math.pi / 4 end
local wallFolder = model("MuralhaEOitoPortoes")
for degree = 0, 355, 5 do
 local theta = math.rad(degree + 2.5)
 local gate = false
 for _, a in ipairs(GATE_ANGLES) do
  local diff = math.atan2(math.sin(theta-a), math.cos(theta-a))
  if math.abs(diff) < math.rad(8) then gate = true; break end
 end
 if not gate then
  local x, z = math.cos(theta)*WALL_RADIUS, math.sin(theta)*WALL_RADIUS
  local seg = part("Muralha", Vector3.new(18.5, 25, 8),
   CFrame.new(x, 12.5, z) * CFrame.Angles(0, -theta-math.pi/2, 0),
   C.stone, Enum.Material.Cobblestone, wallFolder)
 end
end

-- Caminhos radiais até cada entrada
local pathFolder = model("Caminhos")
for _, theta in ipairs(GATE_ANGLES) do
 local centerR = 124
 local x, z = math.cos(theta)*centerR, math.sin(theta)*centerR
 part("CaminhoPortao", Vector3.new(14, 0.25, 178),
  CFrame.new(x, 0.14, z) * CFrame.Angles(0, -theta+math.pi/2, 0),
  C.path, Enum.Material.Sand, pathFolder)
end

-- Árvores e rochas em anéis entre os caminhos (posições determinísticas)
local scenery = model("Natureza")
local rng = Random.new(20261013)
for i = 1, 95 do
 local theta = rng:NextNumber(0, 2*math.pi)
 local r = rng:NextNumber(55, 188)
 local nearPath = false
 for _, a in ipairs(GATE_ANGLES) do
  local diff = math.atan2(math.sin(theta-a), math.cos(theta-a))
  if math.abs(diff) < 0.095 then nearPath = true; break end
 end
 if not nearPath then
  local pos = Vector3.new(math.cos(theta)*r, 0, math.sin(theta)*r)
  if i % 4 == 0 then rock(pos, rng:NextNumber(0.8, 1.6), scenery)
  else tree(pos, rng:NextNumber(0.75, 1.35), scenery) end
 end
end

-- Terrenos externos: cada lote fica separado, com área livre para futuras melhorias.
local plots = model("OitoAcademias")
for i, theta in ipairs(GATE_ANGLES) do
 local outward = Vector3.new(math.cos(theta), 0, math.sin(theta))
 local center = outward * 335
 local lot = model(string.format("Academia_Terreno_%02d", i), plots)
 local rotation = CFrame.Angles(0, -theta+math.pi/2, 0)
 local baseCF = CFrame.new(center) * rotation
 part("TerrenoExpansivel", Vector3.new(160, 2, 170), baseCF * CFrame.new(0, -1, 0), C.darkGrass, Enum.Material.Grass, lot)
 -- caminho entre portão e terreno
 local bridgeCenter = outward * 263
 part("PassagemAteAcademia", Vector3.new(16, 0.4, 104),
  CFrame.new(bridgeCenter + Vector3.new(0, 0.1, 0)) * rotation,
  C.path, Enum.Material.Sand, lot)
 -- casa central: a frente fica voltada para o mundo compartilhado
 local houseCF = baseCF * CFrame.new(0, 0, 17)
 part("CasaParedes", Vector3.new(48, 23, 38), houseCF * CFrame.new(0, 12, 0), C.beige, Enum.Material.Plaster, lot)
 -- telhado inclinado em duas águas; simples e sem geometria complexa
 for side = -1, 1, 2 do
  part("TelhadoVermelho", Vector3.new(29, 2, 44),
   houseCF * CFrame.new(side*12, 28, 0) * CFrame.Angles(0, 0, math.rad(-side*27)),
   C.red, Enum.Material.Brick, lot)
 end
 part("Porta", Vector3.new(9, 15, 0.5), houseCF * CFrame.new(0, 7.5, -19.35), C.wood, Enum.Material.Wood, lot)
 for _, side in ipairs({-1,1}) do
  part("Janela", Vector3.new(8, 8, 0.55), houseCF * CFrame.new(side*15, 14, -19.4),
   Color3.fromRGB(142, 207, 224), Enum.Material.Glass, lot)
  local localTreePos = (baseCF * CFrame.new(side*45, 0, -23)).Position
  tree(localTreePos, 0.9, lot)
 end
 -- arco de entrada decorativo, com placa
 local archCF = baseCF * CFrame.new(0, 0, -65)
 for side = -1,1,2 do
  part("ColunaArco", Vector3.new(2, 18, 2), archCF * CFrame.new(side*14, 9, 0),
   Color3.fromRGB(35,35,35), Enum.Material.Metal, lot)
 end
 part("TopoArco", Vector3.new(30, 2, 2), archCF * CFrame.new(0, 18, 0),
  Color3.fromRGB(35,35,35), Enum.Material.Metal, lot)
 local nameplate = part("PlacaAcademia", Vector3.new(22, 5, 1), archCF * CFrame.new(0, 15, -1.5),
  C.wood, Enum.Material.Wood, lot)
 sign(nameplate, "Academia " .. i, C.white)
 local lock = part("PlacaAmigos", Vector3.new(17, 4, 1), archCF * CFrame.new(0, 9, -1.5),
  Color3.fromRGB(42, 135, 72), Enum.Material.SmoothPlastic, lot)
 sign(lock, "Amigos permitidos", C.white)
end

-- Spawn do primeiro explorador (ainda sem permissões de admin)
local spawn = Instance.new("SpawnLocation")
spawn.Name = "SpawnExploracao"
spawn.Size = Vector3.new(12, 1, 12)
spawn.CFrame = CFrame.new(0, 1, -48)
spawn.Anchored = true
spawn.Neutral = true
spawn.Duration = 0
spawn.Material = Enum.Material.Neon
spawn.Color = Color3.fromRGB(72, 181, 241)
spawn.Parent = root

-- Aparência global
Lighting.ClockTime = 14.5
Lighting.Brightness = 2.5
Lighting.GlobalShadows = true
Lighting.Ambient = Color3.fromRGB(135, 142, 150)
Lighting.OutdoorAmbient = Color3.fromRGB(172, 179, 181)
local atmosphere = Lighting:FindFirstChild("ZStudios_Atmosfera")
if not atmosphere then
 atmosphere = Instance.new("Atmosphere")
 atmosphere.Name = "ZStudios_Atmosfera"
 atmosphere.Parent = Lighting
end
atmosphere.Density = 0.24
atmosphere.Haze = 1.1
atmosphere.Color = Color3.fromRGB(211, 226, 244)

print("[Z Studios] Mapa visual criado: 8 academias e 8 portoes. Pronto para explorar!")
