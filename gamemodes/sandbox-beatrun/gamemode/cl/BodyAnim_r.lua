
/*
	Keeps track of the in-use playermodel bones, ones that will be animated. 
*/
local PlayerMdlBones = {
	"ValveBiped.Bip01_R_Clavicle",
	"ValveBiped.Bip01_R_UpperArm",
	"ValveBiped.Bip01_R_Forearm",
	"ValveBiped.Bip01_R_Hand",
	"ValveBiped.Bip01_L_Clavicle",
	"ValveBiped.Bip01_L_UpperArm",
	"ValveBiped.Bip01_L_Forearm",
	"ValveBiped.Bip01_L_Hand",
	"ValveBiped.Bip01_L_Wrist",
	"ValveBiped.Bip01_R_Wrist",
	"ValveBiped.Bip01_L_Finger4",
	"ValveBiped.Bip01_L_Finger41",
	"ValveBiped.Bip01_L_Finger42",
	"ValveBiped.Bip01_L_Finger3",
	"ValveBiped.Bip01_L_Finger31",
	"ValveBiped.Bip01_L_Finger32",
	"ValveBiped.Bip01_L_Finger2",
	"ValveBiped.Bip01_L_Finger21",
	"ValveBiped.Bip01_L_Finger22",
	"ValveBiped.Bip01_L_Finger1",
	"ValveBiped.Bip01_L_Finger11",
	"ValveBiped.Bip01_L_Finger12",
	"ValveBiped.Bip01_L_Finger0",
	"ValveBiped.Bip01_L_Finger01",
	"ValveBiped.Bip01_L_Finger02",
	"ValveBiped.Bip01_R_Finger4",
	"ValveBiped.Bip01_R_Finger41",
	"ValveBiped.Bip01_R_Finger42",
	"ValveBiped.Bip01_R_Finger3",
	"ValveBiped.Bip01_R_Finger31",
	"ValveBiped.Bip01_R_Finger32",
	"ValveBiped.Bip01_R_Finger2",
	"ValveBiped.Bip01_R_Finger21",
	"ValveBiped.Bip01_R_Finger22",
	"ValveBiped.Bip01_R_Finger1",
	"ValveBiped.Bip01_R_Finger11",
	"ValveBiped.Bip01_R_Finger12",
	"ValveBiped.Bip01_R_Finger0",
	"ValveBiped.Bip01_R_Finger01",
	"ValveBiped.Bip01_R_Finger02"
}

BodyAnim_Global = {
	ToolEquipped = false,
} or nil

// The main BodyAnim object, creates one if it doesn't exist
BodyAnim = BodyAnim or {
	Animation = BodyAnim["Animation"] or nil,

	BModel = BodyAnim["BModel"] or nil,
	BModelArm = BodyAnim["BModelArm"] or nil,
	WeaponModel = BodyAnim["WeaponModel"] or nil,

	Cycle = BodyAnim["Cycle"] or nil,
	Speed = 1,

	EyeAngle = Angle(0, 0, 0);

	ShowWeapon		 		= false,
	ShowViewModel 		= false,
	UseFullBody 			= false,
	IgnoreZAxis 			= false,
	CustomCycle 			= false,
	LockAngle 				= false,
	BodyAnimLimitEase = false,

	CrouchLerp = 1,
	CrouchLerpZ = 0,

	FollowPlayer 		= true,
	DeleteOnEnd 		= true,

	Cache = {
		LastAttachAngle = Angle(0, 0, 0),
	},

	CurrentAnimation = {
		NameString = "nil",
		ModelString = "nil",
		AnimSpeed = 1,
	},

}

CamAddAng = false
CamIgnoreAng = false

// Add more tools if there are
local DefaultTools = {
	["gmod_tool"] = true,
	["weapon_physgun"] = true,
	["gmod_camera"] = true
}

// Detect if the player has a tool equipped
// using the player's active weapon
//
// Sets: BodyAnim_Global["ToolEquipped"]
hook.Add("Think", "BR_DetectTool", function()
	local Ply = LocalPlayer()

	if not IsValid(Ply) then return end

	local weapon = Ply:GetActiveWeapon()
	if not IsValid(weapon) then return end

	if (IsValid(DefaultTools[weapon:GetClass()])) then
		BodyAnim_Global["ToolEquipped"] = true
	end
end)

local Cached_EyeAngle = Angle(0, 0, 0)

DeathAnimationTicked = false

local AllowMove, AllowAngleChange = false
local Attach, AttachID, WeaponToIdle = nil, nil, nil

local SmoothEnd = false
local EndLerp = 0

AMShake = false
CamShakeAngle = Angle()
CamShakeMult = 1

CameraOffset = Vector()
CameraJoint = "eyes"

local LastAngleY = 0

ViewTiltLerp = Angle()
ViewTiltAngle = Angle()

local BodyAnimStartPosition = Vector()
local View = {}
local JustRemoved = false

function RemoveBodyAnimation(NoAng)
	local shouldRemoveAnimation = hook.Run("BodyAnimDoRemove")

	if not shouldremove then return end

	local PlayerObj = LocalPlayer()
	local NewAngle = PlayerObj:EyeAngles()

	NoAng = NoAng or false

	if AllowedAngleChange then
		NewAngle = View.angles
	else
		NewAngle = BodyAnim["EyeAngle"]
	end

	NewAngle.z = 0

	if IsValid(BodyAnim) then
		hook.Run("BodyAnimRemove")
		BodyAnim:SetNoDraw(true)

		if IsValid(BodyAnimMDL) then
			BodyAnimMDL:SetRenderMode(RENDERMODE_NONE)
			if BodyAnimMDL.callback ~= nil then BodyAnimMDL:RemoveCallback("BuildBonePositions", BodyAnimMDL.callback) end

			BodyAnimMDL:Remove()
			BodyAnimMDL = nil
		end

		if IsValid(BodyAnim["ModelArm"]) then BodyAnim["ModelArm"]:Remove() end
		if IsValid(BodyAnim["WeaponModel"]) then BodyAnim["WeaponModel"]:Remove() end

		if not NoAng then PlayerObj:SetEyeAngles(NewAngle) end
		if not SmoothEnd then EndLerp = 0 end

		BodyAnim["Animation"]:Remove()

		JustRemoved = true
		PlayerObj:DrawViewModel(true)

		DidDraw = false
	end

	local CurrentWeapon = PlayerObj:GetActiveWeapon()
	local ViewModel = PlayerObj:GetViewModel()

	if not IsValid(CurrentWeapon) or not IsValid(ViewModel) or not CurrentWeapon:IsScripted() then
		return
	end

	if PlayerObj:notUsingHands() then
		if CurrentWeapon.PlayViewModelAnimation then
			CurrentWeapon:PlayViewModelAnimation("Draw")
		else
				WeaponToIdle = CurrentWeapon
				CurrentWeapon:SendWeaponAnim(ACT_VM_DRAW)

				local WeightedDrawSeq = ViewModel:SelectWeightedSequence(ACT_VM_DRAW)
				timer.Simple(ViewModel:SequenceDuration(WeightedDrawSeq), function()
					if PlayerObj:GetActiveWeapon() == WeaponToIdle and WeaponToIdle:GetSequenceActivityName(WeaponToIdle:GetSequence()) == "ACT_VM_DRAW" then
						WeaponToIdle:GetSequenceActivityName(WeaponToIdle:GetSequence())
						WeaponToIdle:SendWeaponAnim(ACT_VM_IDLE)
					end
				end)
		end
	end
end

CachedBody = {}
MatrixFrom = {}
local MatrixTo = {}

local Transition = {
	T_Lerp = 0,
	T_Transitioning = false,
}

local ScaleVector = Vector(1, 1, 1)
local MatrixFromPosition = Vector()

// define animation arm bones
local ArmBones = {
	["ValveBiped.Bip01_L_Finger0"] = true,
  ["ValveBiped.Bip01_L_Finger02"] = true,
  ["ValveBiped.Bip01_R_Finger3"] = true,
  ["ValveBiped.Bip01_L_Finger42"] = true,
  ["ValveBiped.Bip01_L_Finger32"] = true,
  ["ValveBiped.Bip01_L_Finger41"] = true,
  ["ValveBiped.Bip01_R_UpperArm"] = true,
  ["ValveBiped.Bip01_L_Hand"] = true,
  ["ValveBiped.Bip01_R_Finger4"] = true,
  ["ValveBiped.Bip01_L_Finger4"] = true,
  ["ValveBiped.Bip01_L_UpperArm"] = true,
  ["ValveBiped.Bip01_R_Wrist"] = true,
  ["ValveBiped.Bip01_L_Clavicle"] = true,
  ["ValveBiped.Bip01_L_Forearm"] = true,
  ["ValveBiped.Bip01_L_Finger1"] = true,
  ["ValveBiped.Bip01_R_Finger41"] = true,
  ["ValveBiped.Bip01_R_Hand"] = true,
  ["ValveBiped.Bip01_L_Finger3"] = true,
  ["ValveBiped.Bip01_R_Ulna"] = true,
  ["ValveBiped.Bip01_L_Finger31"] = true,
  ["ValveBiped.Bip01_L_Finger2"] = true,
  ["ValveBiped.Bip01_R_Finger42"] = true,
  ["ValveBiped.Bip01_R_Finger32"] = true,
  ["ValveBiped.Bip01_L_Wrist"] = true,
  ["ValveBiped.Bip01_R_Finger2"] = true,
  ["ValveBiped.Bip01_R_Finger21"] = true,
  ["ValveBiped.Bip01_R_Finger22"] = true,
  ["ValveBiped.Bip01_R_Finger1"] = true,
  ["ValveBiped.Bip01_L_Finger11"] = true,
  ["ValveBiped.Bip01_R_Finger11"] = true,
  ["ValveBiped.Bip01_R_Finger12"] = true,
  ["ValveBiped.Bip01_R_Finger0"] = true,
  ["ValveBiped.Bip01_R_Finger01"] = true,
  ["ValveBiped.Bip01_L_Ulna"] = true,
  ["ValveBiped.Bip01_L_Finger12"] = true,
  ["ValveBiped.Bip01_R_Finger02"] = true,
  ["ValveBiped.Bip01_R_Forearm"] = true,
  ["ValveBiped.Bip01_L_Finger21"] = true,
  ["ValveBiped.Bip01_L_Finger22"] = true,
  ["ValveBiped.Bip01_L_Finger01"] = true,
  ["ValveBiped.Bip01_R_Clavicle"] = true,
  ["ValveBiped.Bip01_R_Finger31"] = true
}

function CacheBodyAnimation()
	if not IsValid(BodyAnim) then return end

	local LP = LocalPlayer()
	local Position = LP:GetPos()

	BodyAnim["Animation"]:SetupBones()
	MatrixFromPosition:Set(LP:GetPos())

	/*
		Fill the CachedBody table with the Body animation's matrices
	*/
	for i = 0, BodyAnim["Animation"]:GetBoneCount() - 1 do
		local BoneMatrice = BodyAnim["Animation"]:GetBoneMatrix(i)
		BoneMatrice:SetTranslation(BoneMatrice:GetTranslation() - Position)

		CachedBody[i] = BoneMatrice
	end

	MatrixTo = {}

	Transition.T_Lerp = 0
	Transition.T_Transitioning = false
end

function CacheLerpBodyAnimation()
	local LP = LocalPlayer()

	if not LP:Alive() then
		Transition.T_Transitioning = false
		return
	end

	if Transition.T_Transitioning and Transition.T_Lerp < 1 then
		BodyAnim["Animation"]:SetupBones()
		BodyAnim["BModel"]:SetNoDraw(true)

		local Position = LP:GetPos()
		local this = BodyAnim["Animation"]
		this.m = this.m or Matrix()

		local From = MatrixFrom // A
		local To = MatrixTo			// B

		for BoneNow = 0, this:GetBoneCount() - 1 do
			if not ArmBones[BodyAnim["Animation"]:GetBoneName(BoneNow)] then

				local ModelBoneMatrix = this:GetBoneMatrix(BoneNow)
				ModelBoneMatrix:SetTranslation(ModelBoneMatrix:GetTranslation())

				
			end
		end
	end
end
