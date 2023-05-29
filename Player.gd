extends CharacterBody3D



const WALK_SPEED := 3.0
const RUN_SPEED := 5.0
const CHROUCH_SPEED := 1.0
const ACC = .08
const FRIC = .1
const JUMP_VELOCITY = 4.5
const RUN_SPEED_ACC := .25
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var airControl = .2
var SPEED = 0
var chrouch = false
var jumping = false
var lookCam = null


@onready var arm := $Systems/Camera/SpringArm3D
@onready var mesh := $Mesh
@onready var anim := $MainCharacter/AnimationPlayer
@onready var animTree := $AnimationTree
@onready var checkFloor := $Systems/CheckFloor
@onready var skeleton := $Mesh/Charater/Armature/Skeleton3D
@onready var Cameras := $Systems/Camera
@onready var camFp := $Systems/Camera/FirstPersonCamera
@onready var headBone := $Mesh/Charater/Armature/Skeleton3D/HeadBone
@onready var camFpc := $%FPC
@onready var camTpc := $%TPC
@onready var StandCollision := $StandCollision
@onready var ChrouchCollision := $ChrouchCollision

@export_enum("ThirdPerson", "FirstPerson") var cameraType:int = 0 : set = cameraUpdated


func _ready():
	animTree.active = true
	cameraUpdated(cameraType)

func cameraUpdated(val):
	cameraType = val
	camFpc.current = cameraType == 1;
	camTpc.current = cameraType == 0;

func _physics_process(delta):
	lookCam = arm if cameraType == 0 else camFp
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	animTree.set("parameters/MainState/conditions/onAir", !is_on_floor())
	animTree.set("parameters/MainState/conditions/onFloor", is_on_floor() or checkFloor.is_colliding())
	
	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and !chrouch:
		
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_pressed("chrouch"):
		chrouch = !chrouch
		StandCollision.disabled = chrouch
		ChrouchCollision.disabled = !chrouch
		animTree.set("parameters/ChrouchStand/transition_request", ["Stand","Chrouch"][int(chrouch)])
	
	if Input.is_action_just_pressed("camSwitch"):
#		Cameras.transition(camFpc if camTpc.current else camTpc)
		cameraType = !cameraType
	
	if chrouch:
		SPEED = lerpf(SPEED, CHROUCH_SPEED, RUN_SPEED_ACC)
	elif Input.is_action_pressed("Run"):
		SPEED = lerpf(SPEED, RUN_SPEED, RUN_SPEED_ACC)
	else:
		SPEED = lerpf(SPEED, WALK_SPEED, RUN_SPEED_ACC)

#	var pose = skeleton.get_bone_pose(skeleton.find_bone("mixamorig1_Spine1"))
#	pose.origin.y = 32
#	skeleton.set_bone_global_pose_override(skeleton.find_bone("mixamorig1_Spine1"), Transform3D(), 0,0 )
#

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Vector3()
	input_dir.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_dir.z = Input.get_action_strength("backward") - Input.get_action_strength("forward")
#	mesh.rotation.y = arm.rotation.y - PI
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.z)).normalized()
	var __revRot = PI if cameraType == 1 else 0
	
	input_dir = input_dir.rotated(Vector3.UP, lookCam.rotation.y - __revRot).normalized()
	
	if cameraType == 0:
		if direction.length() > 0:
			var _mrot = Vector2(input_dir.z, input_dir.x).angle()
			mesh.rotation.y = lerp_angle(mesh.rotation.y, _mrot, .2)
	else:
		mesh.rotation.y = lerp_angle(mesh.rotation.y, camFp.rotation.y, .2)
	
	var __control = 1 if is_on_floor() else airControl
	var __interpolate = ACC if direction.length() > 0 else FRIC
	velocity.x = lerp(velocity.x, input_dir.x * SPEED, __interpolate * __control) 
	velocity.z = lerp(velocity.z, input_dir.z * SPEED, __interpolate * __control) 
	var moveLength = (transform.basis * Vector3(velocity.x, 0, velocity.z))
	animTree.set("parameters/MainState/WalkRun/blend_position", (moveLength).length())
	animTree.set("parameters/ChoruchIdleWalk/blend_position", (moveLength).length())
	
	
	

	move_and_slide()


func _process(delta):
	if cameraType == 1:
		pass
