local CollectionService = game:GetService("CollectionService")

-- Constrói uma sequência de tamanhos que somam exatamente a 'total',
-- usando "step" como tamanho padrão e reduzindo só o último bloco.
local function buildSlices(total: number, step: number): { number }
	assert(step > 0, "step deve ser > 0")
	local slices = {}
	local remain = total
	local EPS = 1e-6

	while remain > EPS do
		local chunk = math.min(step, remain)
		table.insert(slices, chunk)
		remain -= chunk
	end

	-- Normaliza resíduos numéricos (somatória = total exato)
	-- (opcional: arredonda pra 1e-6 pra evitar “0.0000001”)
	local sum = 0
	for i = 1, #slices do
		slices[i] = tonumber(string.format("%.6f", slices[i]))
		sum += slices[i]
	end
	-- Ajuste final de precisão no último slice
	local diff = total - sum
	if math.abs(diff) > EPS and #slices > 0 then
		slices[#slices] += diff
	end

	return slices
end

-- Divide 'part' em blocos (GRID_XZ x GRID_Y x GRID_XZ), sem nunca ultrapassar o tamanho da original.
-- Bordas recebem blocos menores quando necessário (X/Z/Y).
-- Copia Tags/Attributes e destrói a peça original.
local function splitPartIntoGrid3D(part: BasePart, GRID_XZ: number?, GRID_Y: number?): ()
	assert(part and part:IsA("BasePart"), "Passe uma BasePart válida")

	GRID_XZ = GRID_XZ or 4
	GRID_Y = GRID_Y or 14

	local cf = part.CFrame
	local size = part.Size
	local parent = part.Parent

	-- Listas de tamanhos por eixo que somam exatamente o total
	local sizesX = buildSlices(size.X, GRID_XZ :: number)
	local sizesZ = buildSlices(size.Z, GRID_XZ :: number)
	local sizesY = buildSlices(size.Y, GRID_Y :: number)

	-- Snapshots de Tags e Attributes
	local tags = CollectionService:GetTags(part)
	local attrs = part:GetAttributes()

	-- Ponto inicial (bordas) no espaço local
	-- Vamos avançando e posicionando cada segmento pelo centro do bloco atual:
	-- start = -total/2; center = start + chunk/2; start += chunk
	local parts = {}
	local startX = -size.X * 0.5
	for ix = 1, #sizesX do
		local sx = sizesX[ix]
		local cx = startX + sx * 0.5

		local startY = -size.Y * 0.5
		for iy = 1, #sizesY do
			local sy = sizesY[iy]
			local cy = startY + sy * 0.5

			local startZ = -size.Z * 0.5
			for iz = 1, #sizesZ do
				local sz = sizesZ[iz]
				local cz = startZ + sz * 0.5

				local seg = Instance.new("Part")
				seg.Size = Vector3.new(sx, sy, sz)
				seg.CFrame = cf * CFrame.new(cx, cy, cz)
				seg.Anchored = part.Anchored
				seg.Material = part.Material
				seg.Color = part.Color
				seg.MaterialVariant = part.MaterialVariant
				seg.Transparency = part.Transparency
				seg.Reflectance = part.Reflectance
				seg.CanCollide = part.CanCollide
				seg.CastShadow = part.CastShadow
				seg.Name = string.format("%s_seg_%d_%d_%d", part.Name, ix, iy, iz)

				-- Física personalizada (se houver)
				if part.CustomPhysicalProperties then
					seg.CustomPhysicalProperties = part.CustomPhysicalProperties
				end

				-- CollisionGroup (se você usa)
				pcall(function()
					seg.CollisionGroup = part.CollisionGroup
				end)

				-- Copiar Attributes
				for k, v in pairs(attrs) do
					seg:SetAttribute(k, v)
				end

				-- Copiar Tags
				for _, tag in ipairs(tags) do
					CollectionService:AddTag(seg, tag)
				end

				seg.Parent = parent
				table.insert(parts, seg)
				startZ += sz
			end

			startY += sy
		end

		startX += sx
	end

	part:Destroy()

	return parts
end

return splitPartIntoGrid3D
