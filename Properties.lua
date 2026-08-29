local Properties = {
	["BasePart"] = {
		"BrickColor", "CanCollide", "Anchored", "Locked", "Velocity", "Transparency", "Reflectance", "Material",
		"BackSurface", "BottomSurface", "FrontSurface", "LeftSurface", "RightSurface", "TopSurface",  "Name", "CFrame", "Size",
		"Elasticity", "Friction", "RotVelocity"
	},
	["PointLight"] = {
		"Brightness", "Color", "Range", "Shadows", "Enabled"
	},
	["SurfaceLight"] = {
		"Angle", "Brightness", "Color", "Enabled", "Face", "Range", "Shadows"
	},
	["Smoke"] = {
		"Color", "Opacity", "Size", "RiseVelocity", "Enabled"
	},
	["Fire"] = {
		"Color", "Heat", "Size", "SecondaryColor", "Enabled"
	},
	["Decal"] = {
		"Texture", "Transparency", "Color3", "Face"
	},
	["Texture"] = {
		"Texture", "Transparency", "Color3", "Face", "OffsetStudsU", "OffsetStudsV", "StudsPerTileU", "StudsPerTileV",
	},
	["Mesh"] = {
		"Offset", "Scale", "VertexColor"
	},
	["Shirt"] = {
		"ShirtTemplate"
	},
	["LocalScript"] = {
		"Disabled"
	},
	["Script"] = {
		"Disabled"
	},
	["Model"] = {},
	["ObjectValue"] = {},
	["SpecialMesh"] = {
		"MeshId",
		"TextureId",
		"MeshType",
		"Scale",
		"Offset",
		"VertexColor"
	},
	["StringValue"] = {
		"Value"
	},
	["Animation"] = {
		"AnimationId"
	},
	["Weld"] = {
		"Part0",
		"Part1",
	},
	["Accoutrement"] = {
		"AttachmentForward",
		"AttachmentPos",
		"AttachmentRight",
		"AttachmentUp"
	},
	["Backpack"] = {},
	["BindableEvent"] = {},
	["BindableFunction"] = {},
	["BodyAngularVelocity"] = {
		"P",
		"angularvelocity",
		"maxTorque"
	},
	["BodyColors"] = {
		"HeadColor",
		"LeftArmColor",
		"LeftLegColor",
		"RightArmColor",
		"RightLegColor",
		"TorsoColor"
	},
	["BodyForce"] = {
		"force"
	},
	["BodyGyro"] = {
		"D",
		"P",
		"maxTorque"
	},
	["BodyPosition"] = {
		"D",
		"P",
		"maxForce",
		"position"
	},
	["BodyThrust"] = {
		"force",
		"location"
	},
	["BodyVelocity"] = {
		"P",
		"maxForce",
		"velocity"
	},
	["CharacterMesh"] = {
		"BaseTextureId",
		"BodyPart",
		"MeshId",
		"OverlayTextureId"
	},
	["Tool"] = {
		"GripForward",
		"GripPos",
		"GripRight",
		"GripUp",
		"ToolTip",
		"TextureId",
		"CanBeDropped",
		"RequiresHandle",
		"Enabled"
	},
	["Team"] = {
		"AutoAssignable",
		"TeamColor"
	},
	["StarterGear"] = {},
	["SpawnLocation"] = {},
	["SurfaceSelection"] = {
		"Color3",
		"Transparency",
		"TargetSurface",
		"Visible"
	},
	["Configuration"] = {},
	["ClickDetector"] = {
		"MaxActivationDistance"
	},
	["Dialog"] = {
		"ConversationDistance",
		"InUse",
		"Purpose",
		"Tone"
	},
	["DialogChoice"] = {},
	["Explosion"] = {
		"BlastPressure",
		"BlastRadius",
		"Position",
		"Visible"
	},
	["Flag"] = {
		"GripForward",
		"GripPos",
		"GripRight",
		"GripUp",
		"ToolTip",
		"TeamColor",
		"TextureId",
		"CanBeDropped",
		"RequiresHandle",
		"Enabled"
	},
	["FlagStand"] = {
		"BrickColor",
		"Material",
		"Reflectance",
		"Transparency",
		"TeamColor",
		"Velocity",
		"Anchored",
		"CanCollide",
		"Locked",
		"FormFactor",
		"Shape",
		"BackParamA",
		"BackParamB",
		"BackSurfaceInput",
		"BottomParamA",
		"BottomParamB",
		"BottomSurfaceInput",
		"FrontParamA",
		"FrontParamB",
		"FrontSurfaceInput",
		"LeftParamA",
		"LeftParamB",
		"LeftSurfaceInput",
		"RightParamA",
		"RightParamB",
		"RightSurfaceInput",
		"TopParamA",
		"TopParamB",
		"TopSurfaceInput",
		"BackSurface",
		"BottomSurface",
		"FrontSurface",
		"LeftSurface",
		"RightSurface",
		"TopSurface",
		"CFrame"
	},
	["FloorWire"] = {
		"Color",
		"Velocity",
		"Texture",
		"TextureSize",
		"StudsBetweenTextures"
	},
	["Folder"] = {},
	["ForceField"] = {},
	["Glue"] = {
		"Part0",
		"Part1",
	},
	["Handles"] = {
		"Style",
		"Adornee",
		"Visible"
	},
	["Hat"] = {
		"AttachmentForward",
		"AttachmentPos",
		"AttachmentRight",
		"AttachmentUp"
	},
	["Message"] = {
		"Text"
	},
	["Sparkles"] = {
		"SparkleColor"
	},
	["Sound"] = {
		"Looped",
		"Pitch",
		"Playing",
		"SoundId",
		"Volume"
	},
	["Sky"] = {
		"CelestialBodiesShown",
		"MoonAngularSize",
		"MoonTextureId",
		"SkyboxBk",
		"SkyboxDn",
		"SkyboxFt",
		"SkyboxLf",
		"SkyboxRt",
		"SkyboxUp",
		"StarCount",
		"SunAngularSize",
		"SunTextureId",
	},
	["Skin"] = {
		"SkinColor"
	},
	["ShirtGraphic"] = {
		"Color3",
		"Graphic"
	},
	["SelectionBox"] = {
		"Color3",
		"LineThickness",
		"SurfaceColor3",
		"SurfaceTransparency",
		"Transparency",
		"Visible"
	},
	["SelectionPartLasso"] = {
		"Color3",
		"Humanoid",
		"Part",
		"Visible"
	},
	["SelectionPointLasso"] = {
		"Color3",
		"Humanoid",
		"Point",
		"Visible"
	},
	["SelectionSphere"] = {
		"Adornee",
		"Color3",
		"SurfaceColor3",
		"SurfaceTransparency",
		"Transparency",
		"Visible"
	},
	["Humanoid"] = {
		"Health",
		"JumpPower",
		"MaxHealth",
		"WalkSpeed",
		"Jump",
		"PlatformStand",
		"Sit",
		"TargetPoint",
		"WalkToPoint"
	},
	["ManualWeld"] = {
		"Part0",
		"Part1"
	},
	["Motor6D"] = {
		"Part0",
		"Part1",
		"C0",
		"C1"
	},
	["ParticleEmitter"] = {
		"Enabled",
		"Color",
		"Size",
		"Transparency",
		"LightEmission",
		"LightInfluence",
		"LockedToPart",
		"Rate",
		"Rotation",
		"RotSpeed",
		"Speed",
		"Texture",
		"VelocitySpread",
		"Acceleration",
		"Drag",
		"EmissionDirection",
		"Lifetime",
		"SpreadAngle",
		"ZOffset"
	},
	["RemoteEvent"] = {},
	["RemoteFunction"] = {},
	["RocketPropulsion"] = {
		"CartoonFactor",
		"TargetOffset",
		"TargetRadius",
		"MaxSpeed",
		"MaxThrust",
		"ThrustD",
		"ThrustP",
		"MaxTorque",
		"TurnD",
		"TurnP"
	},
	["Pants"] = {
		"Color3",
		"PantsTemplate"
	},
	["SpotLight"] = {
		"Angle",
		"Brightness",
		"Color",
		"Enabled",
		"Face",
		"Range",
		"Shadows"
	},
	["Motor"] = {
		"CurrentAngle",
		"DesiredAngle",
		"MaxVelocity",
		"Enabled"
	},
	["BillboardGui"] = {
		"AlwaysOnTop",
		"Enabled",
		"Size",
		"SizeOffset",
		"StudsOffset",
	},
	["ScreenGui"] = {
		"Enabled",
	},
	["Frame"] = {
		"Active",
		"BackgroundColor3",
		"BackgroundTransparency",
		"BorderColor3",
		"BorderSizePixel",
		"Position",
		"Size",
		"SizeConstraint",
		"Style",
		"Visible",
		"ZIndex",
		"ClipsDescendants",
		"Draggable"
	},
	["ScrollingFrame"] = {
		"Active",
		"BackgroundColor3",
		"BackgroundTransparency",
		"BorderColor3",
		"BorderSizePixel",
		"Position",
		"Size",
		"SizeConstraint",
		"Visible",
		"ZIndex",
		"ClipsDescendants",
		"Draggable",
		"CanvasSize",
		"CanvasPosition",
		"ScrollBarThickness",
		"ScrollingEnabled",
		"TopImage",
		"MidImage",
		"BottomImage"
	},
	["ImageButton"] = {
		"Active",
		"AutoButtonColor",
		"BackgroundColor3",
		"BackgroundTransparency",
		"BorderColor3",
		"BorderSizePixel",
		"Image",
		"Modal",
		"Position",
		"Selected",
		"Size",
		"SizeConstraint",
		"Style",
		"Visible",
		"ZIndex",
		"ClipsDescendants",
		"Draggable"
	},
	["ImageLabel"] = {
		"Active",
		"BackgroundColor3",
		"BackgroundTransparency",
		"BorderColor3",
		"BorderSizePixel",
		"Image",
		"Position",
		"Size",
		"SizeConstraint",
		"Visible",
		"ZIndex",
		"ClipsDescendants",
		"Draggable"
	},
	["TextBox"] = {
		"Active",
		"BackgroundColor3",
		"BackgroundTransparency",
		"BorderColor3",
		"BorderSizePixel",
		"ClearTextOnFocus",
		"MultiLine",
		"Position",
		"Size",
		"SizeConstraint",
		"Visible",
		"ZIndex",
		"ClipsDescendants",
		"Draggable",
		"Text",
		"TextColor3",
		"TextScaled",
		"TextStrokeColor3",
		"TextStrokeTransparency",
		"TextTransparency",
		"TextWrapped",
		"TextXAlignment",
		"TextYAlignment"
	},
	["TextButton"] = {
		"Active",
		"AutoButtonColor",
		"BackgroundColor3",
		"BackgroundTransparency",
		"BorderColor3",
		"BorderSizePixel",
		"Modal",
		"Position",
		"Selected",
		"Size",
		"SizeConstraint",
		"Style",
		"Visible",
		"ZIndex",
		"ClipsDescendants",
		"Draggable",
		"Text",
		"TextColor3",
		"TextScaled",
		"TextStrokeColor3",
		"TextStrokeTransparency",
		"TextTransparency",
		"TextWrapped",
		"TextXAlignment",
		"TextYAlignment"
	},
	["TextLabel"] = {
		"Active",
		"BackgroundColor3",
		"BackgroundTransparency",
		"BorderColor3",
		"BorderSizePixel",
		"Position",
		"Size",
		"SizeConstraint",
		"Visible",
		"ZIndex",
		"ClipsDescendants",
		"Draggable",
		"Text",
		"TextColor3",
		"TextScaled",
		"TextStrokeColor3",
		"TextStrokeTransparency",
		"TextTransparency",
		"TextWrapped",
		"TextXAlignment",
		"TextYAlignment"
	}
}

Properties.WedgePart = Properties.BasePart
Properties.Part = Properties.BasePart
Properties.CornerWedgePart = Properties.BasePart

Properties.Seat = Properties.BasePart
Properties.TrussPart = Properties.BasePart
Properties.VehicleSeat = Properties.BasePart
Properties.SpawnLocation = Properties.BasePart
Properties.CylinderMesh = Properties.Mesh
Properties.BlockMesh = Properties.Mesh


Properties.Vector3Value = Properties.StringValue
Properties.NumberValue = Properties.StringValue
Properties.IntValue = Properties.StringValue
Properties.BoolValue = Properties.StringValue
Properties.BrickColorValue = Properties.StringValue
Properties.CFrameValue = Properties.StringValue
Properties.Color3Value = Properties.StringValue

Properties.Hint = Properties.Message

for _,Properties2 in pairs(Properties) do
	table.insert(Properties2, "Name")
end

return Properties
