--!strict
-- ModelFingerprint
-- Creates deterministic fingerprints for Roblox models based on their
-- internal structure and properties, while ignoring world-space position.

local ModelFingerprint = {}

local DEFAULT_PRECISION = 5

local function roundNumber(value: number, precision: number?): number
	precision = precision or DEFAULT_PRECISION

	local multiplier = 10 ^ precision
	return math.round(value * multiplier) / multiplier
end

local function addVector3(data: {number}, vector: Vector3)
	table.insert(data, roundNumber(vector.X))
	table.insert(data, roundNumber(vector.Y))
	table.insert(data, roundNumber(vector.Z))
end

local function addCFrame(data: {number}, cframe: CFrame)
	for _, value in ipairs({cframe:GetComponents()}) do
		table.insert(data, roundNumber(value))
	end
end

local function getInstanceData(model: Model, object: Instance)
	local data = {
		ClassName = object.ClassName,
	}

	if object:IsA("BasePart") then
		local relativeCFrame = model:GetPivot():ToObjectSpace(object.CFrame)

		data.CFrame = {}
		addCFrame(data.CFrame, relativeCFrame)

		data.Size = {}
		addVector3(data.Size, object.Size)

		data.Material = object.Material.Name
		data.Transparency = roundNumber(object.Transparency)
		data.Reflectance = roundNumber(object.Reflectance)
		data.CastShadow = object.CastShadow

		data.Color = {
			roundNumber(object.Color.R),
			roundNumber(object.Color.G),
			roundNumber(object.Color.B),
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
		addVector3(data.Scale, object.Scale)

		data.Offset = {}
		addVector3(data.Offset, object.Offset)
	end

	if object:IsA("Decal") then
		data.Texture = object.Texture
		data.Face = object.Face.Name
		data.Transparency = roundNumber(object.Transparency)

		pcall(function()
			data.Color3 = {
				roundNumber(object.Color3.R),
				roundNumber(object.Color3.G),
				roundNumber(object.Color3.B),
			}
		end)
	end

	if object:IsA("Texture") then
		data.Texture = object.Texture
		data.Face = object.Face.Name
		data.Transparency = roundNumber(object.Transparency)
		data.StudsPerTileU = roundNumber(object.StudsPerTileU)
		data.StudsPerTileV = roundNumber(object.StudsPerTileV)

		pcall(function()
			data.Color3 = {
				roundNumber(object.Color3.R),
				roundNumber(object.Color3.G),
				roundNumber(object.Color3.B),
			}
		end)
	end

	if object:IsA("Attachment") then
		data.Position = {}
		addVector3(data.Position, object.Position)

		data.Orientation = {}
		addVector3(data.Orientation, object.Orientation)
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

--[[
	Creates a fingerprint for a model.

	Options:
		precision: Number of decimal places used when comparing
		          floating-point values. Default: 5

	Returns:
		A hexadecimal fingerprint string.
]]
function ModelFingerprint.Create(model: Model, precision: number?): string
	assert(typeof(model) == "Instance" and model:IsA("Model"), "Expected a Model")

	precision = precision or DEFAULT_PRECISION

	local entries = {}

	for _, object in ipairs(model:GetDescendants()) do
		if object:IsA("BasePart")
			or object:IsA("SpecialMesh")
			or object:IsA("DataModelMesh")
			or object:IsA("Decal")
			or object:IsA("Texture")
			or object:IsA("Attachment") then

			local data = getInstanceData(model, object)

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

	table.sort(entries)

	return hashString(table.concat(entries, "\n"))
end

--[[
	Returns true when two models have identical fingerprints.
]]
function ModelFingerprint.Compare(modelA: Model, modelB: Model, precision: number?): boolean
	return ModelFingerprint.Create(modelA, precision) == ModelFingerprint.Create(modelB, precision)
end

--[[
	Returns the raw serialized structural representation before hashing.

	This is useful for debugging why two models don't match.
]]
function ModelFingerprint.Serialize(model: Model, precision: number?): string
	assert(typeof(model) == "Instance" and model:IsA("Model"), "Expected a Model")

	precision = precision or DEFAULT_PRECISION

	local entries = {}

	for _, object in ipairs(model:GetDescendants()) do
		if object:IsA("BasePart")
			or object:IsA("SpecialMesh")
			or object:IsA("DataModelMesh")
			or object:IsA("Decal")
			or object:IsA("Texture")
			or object:IsA("Attachment") then

			local data = getInstanceData(model, object)

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

	table.sort(entries)

	return table.concat(entries, "\n")
end

return ModelFingerprint
