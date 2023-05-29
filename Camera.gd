extends Node3D


var sens = .05

@onready var Spring = $SpringArm3D 
@onready var fpc =  $%FPC
@onready var firstPersonCam =  $FirstPersonCamera
@onready var tpc =  $SpringArm3D/TPC 
@onready var boneTransform =  $FirstPersonCamera/BoneTransform
@onready var headBone = $%HeadBone
@onready var followCam := $%FollowCamera
@onready var player := get_parent().get_parent()
# Called when the node enters the scene tree for the first time.
func _ready():
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)

func _process(delta):
	boneTransform.global_position = headBone.global_position
	boneTransform.global_rotation.x = headBone.global_rotation.x
	
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if tpc.current:
			Spring.rotation_degrees.x -= event.relative.y * sens
			Spring.rotation_degrees.x = clamp(Spring.rotation_degrees.x, -90, 40)
			
			Spring.rotation_degrees.y -= event.relative.x * sens
			Spring.rotation_degrees.y = wrapf(Spring.rotation_degrees.y, 0, 360)
			
			firstPersonCam.rotation_degrees.y = Spring.rotation_degrees.y-180

			
			
		elif fpc.current:
			fpc.rotation_degrees.x -= event.relative.y * sens
			fpc.rotation_degrees.x = clamp(fpc.rotation_degrees.x, -90, 40)
			
			firstPersonCam.rotation_degrees.y -= event.relative.x * sens
			firstPersonCam.rotation_degrees.y = wrapf(firstPersonCam.rotation_degrees.y, 0, 360)
			
			Spring.rotation_degrees.y = firstPersonCam.rotation_degrees.y - 180
			



func transition(cam):
	pass
#	var _tween = create_tween()
#	_tween.set_trans(Tween.TRANS_EXPO)
#	var _curCam = tpc if tpc.current else fpc
#	fpc.current = false
#	tpc.current = false
#
#
#	followCam.global_transform = _curCam.global_transform
#	followCam.fov = _curCam.fov
#	followCam.current = true
#
#	_tween.tween_property(followCam, "global_transform", cam.global_transform, .2)
#	_tween.tween_property(followCam, "fov", cam.fov, .5)
#
#	await _tween.finished
#	followCam.current = false
#	cam.current = true
#
#	player.cameraType = 0 if tpc.current else 1
#
#
