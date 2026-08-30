--!strict
-- ModelFingerprint
-- Creates deterministic fingerprints for Roblox models based on their
-- internal structure and properties.
--
-- World-space position and model pivot position are ignored.
-- The model's bounding-box CFrame is used as the canonical coordinate system.

local ModelFingerprint = {}

local DEFAULT_PRECISION = 2

local function roundNumber(value: number, precision: number): number
	local multiplier = 10 ^ precision
	return math.round(value * multiplier) / multiplier
end

local function addVector3(data: {number}, vector: Vector3, precision: number)
	table.insert(data, roundNumber(vector.X, precision))
	table.insert(data, roundNumber(vector.Y, precision))
	table.insert(data, roundNumber(vector.Z, precision))
end

local function addCFrame(data: {number}, cframe: CFrame, precision: number)
	for _, value in ipairs({cframe:GetComponents()}) do
		table.insert(data, roundNumber(value, precision))
	end
end

local function getInstanceData(
	model: Model,
	object: Instance,
	referenceCFrame: CFrame,
	precision: number
)
	local data = {
		ClassName = object.ClassName,
	}

	if object:IsA("BasePart") then
		-- Use the model's bounding box as the canonical reference.
		-- This avoids relying on potentially inconsistent model pivots.
		local relativeCFrame = referenceCFrame:ToObjectSpace(object.CFrame)

		data.CFrame = {}
		addCFrame(data.CFrame, relativeCFrame, precision)

		data.Size = {}
		addVector3(data.Size, object.Size, precision)

		data.Material = object.Material.Name
		data.Transparency = roundNumber(object.Transparency, precision)
		data.Reflectance = roundNumber(object.Reflectance, precision)
		data.CastShadow = object.CastShadow

		data.Color = {
			roundNumber(object.Color.R, precision),
			roundNumber(object.Color.G, precision),
			roundNumber(object.Color.B, precision),
		}

		if object:IsA("Part") then
			pcall(function()
				data.Shape = object.Shape.Name
			end)
		end

		if object:IsA("WedgePart") then
			data.PartType = "WedgePart"
		elseif object:IsA("CornerWedgePart") then
			data.PartType = "CornerWedgePart"
		elseif object:IsA("TrussPart") then
			data.PartType = "TrussPart"
		elseif object:IsA("Seat") then
			data.PartType = "Seat"
		elseif object:IsA("VehicleSeat") then
			data.PartType = "VehicleSeat"
		end

		if object:IsA("MeshPart") then
			data.MeshId = object.MeshId
			data.TextureID = object.TextureID

			pcall(function()
				data.RenderFidelity = object.RenderFidelity.Name
			end)

			pcall(function()
				data.DoubleSided = object.DoubleSided
			end)
		end
	end

	if object:IsA("SpecialMesh") then
		data.MeshType = object.MeshType.Name
		data.MeshId = object.MeshId
		data.TextureId = object.TextureId

		data.Scale = {}
		addVector3(data.Scale, object.Scale, precision)

		data.Offset = {}
		addVector3(data.Offset, object.Offset, precision)
	end

	if object:IsA("Decal") then
		data.Texture = object.Texture
		data.Face = object.Face.Name
		data.Transparency = roundNumber(object.Transparency, precision)

		pcall(function()
			data.Color3 = {
				roundNumber(object.Color3.R, precision),
				roundNumber(object.Color3.G, precision),
				roundNumber(object.Color3.B, precision),
			}
		end)
	end

	if object:IsA("Texture") then
		data.Texture = object.Texture
		data.Face = object.Face.Name
		data.Transparency = roundNumber(object.Transparency, precision)
		data.StudsPerTileU = roundNumber(object.StudsPerTileU, precision)
		data.StudsPerTileV = roundNumber(object.StudsPerTileV, precision)

		pcall(function()
			data.Color3 = {
				roundNumber(object.Color3.R, precision),
				roundNumber(object.Color3.G, precision),
				roundNumber(object.Color3.B, precision),
			}
		end)
	end

	if object:IsA("Attachment") then
		data.Position = {}
		addVector3(data.Position, object.Position, precision)

		data.Orientation = {}
		addVector3(data.Orientation, object.Orientation, precision)
	end

	return data
end

local function serializeEntry(data)
	local parts = {
		tostring(data.ClassName or ""),
		tostring(data.Depth or ""),
	}

	local function appendArray(values)
		if not values then
			return
		end

		for _, value in ipairs(values) do
			table.insert(parts, tostring(value))
		end
	end

	appendArray(data.CFrame)
	appendArray(data.Size)
	appendArray(data.Color)
	appendArray(data.Position)
	appendArray(data.Orientation)
	appendArray(data.Scale)
	appendArray(data.Offset)
	appendArray(data.Color3)

	table.insert(parts, tostring(data.Material or ""))
	table.insert(parts, tostring(data.Transparency or ""))
	table.insert(parts, tostring(data.Reflectance or ""))
	table.insert(parts, tostring(data.CastShadow or ""))
	table.insert(parts, tostring(data.Shape or ""))
	table.insert(parts, tostring(data.PartType or ""))
	table.insert(parts, tostring(data.MeshType or ""))
	table.insert(parts, tostring(data.MeshId or ""))
	table.insert(parts, tostring(data.TextureID or ""))
	table.insert(parts, tostring(data.TextureId or ""))
	table.insert(parts, tostring(data.RenderFidelity or ""))
	table.insert(parts, tostring(data.DoubleSided or ""))
	table.insert(parts, tostring(data.Texture or ""))
	table.insert(parts, tostring(data.Face or ""))
	table.insert(parts, tostring(data.StudsPerTileU or ""))
	table.insert(parts, tostring(data.StudsPerTileV or ""))

	return table.concat(parts, "|")
end

local function hashString(value: string): string
	local hash1 = 2166136261
	local hash2 = 2166136261

	for index = 1, #value do
		local byte = string.byte(value, index)

		hash1 = bit32.bxor(hash1, byte)
		hash1 = (hash1 * 16777619) % 4294967296

		hash2 = bit32.bxor(hash2, byte)
		hash2 = (hash2 * 2166136261) % 4294967296
	end

	return string.format("%08x%08x", hash1, hash2)
end

local function buildSerialized(model: Model, precision: number): string
	local entries = {}

	-- This is our canonical reference frame.
	--
	-- Unlike GetPivot(), this is derived directly from the
	-- model's physical contents.
	local referenceCFrame = model:GetBoundingBox()

	for _, object in ipairs(model:GetDescendants()) do
		if object:IsA("BasePart")
			or object:IsA("SpecialMesh")
			or object:IsA("DataModelMesh")
			or object:IsA("Decal")
			or object:IsA("Texture")
			or object:IsA("Attachment") then

			local data = getInstanceData(
				model,
				object,
				referenceCFrame,
				precision
			)

			-- Preserve structural depth.
			local depth = 0
			local parent = object.Parent

			while parent and parent ~= model do
				depth += 1
				parent = parent.Parent
			end

			data.Depth = depth

			table.insert(entries, serializeEntry(data))
		end
	end

	-- Make descendant order irrelevant.
	table.sort(entries)

	return table.concat(entries, "\n")
end

--[[
	Creates a fingerprint for a model.

	precision:
		Number of decimal places used for floating-point values.
	Lower values make the fingerprint more tolerant of tiny differences.

	Default: 5
]]
function ModelFingerprint.Create(model: Model, precision: number?): string
	assert(
		typeof(model) == "Instance" and model:IsA("Model"),
		"Expected a Model"
	)

	precision = precision or DEFAULT_PRECISION

	local serialized = buildSerialized(model, precision)

	return hashString(serialized)
end

--[[
	Returns true when two models have identical fingerprints.
]]
function ModelFingerprint.Compare(
	modelA: Model,
	modelB: Model,
	precision: number?
): boolean
	return ModelFingerprint.Create(modelA, precision)
		== ModelFingerprint.Create(modelB, precision)
end

--[[
	Returns the raw serialized structural representation before hashing.
Useful for debugging.
]]
function ModelFingerprint.Serialize(
	model: Model,
	precision: number?
): string
	assert(
		typeof(model) == "Instance" and model:IsA("Model"),
		"Expected a Model"
	)

	precision = precision or DEFAULT_PRECISION

	return buildSerialized(model, precision)
end

return ModelFingerprint
