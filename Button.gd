extends MeshInstance3D


var active = preload("res://addons/kenney_prototype_tools/materials/green/material_01.tres")
var disabled = preload("res://addons/kenney_prototype_tools/materials/red/material_01.tres")
var hovered = false

var dust = preload("res://dust.tscn")

@onready var anim = $AnimationPlayer
func _ready():
	set_surface_override_material(0, disabled)

func onHover():
	if !hovered:
		anim.play("in")
		hovered = true

	set_surface_override_material(0, active)
	
func onHoverExited():
	anim.play_backwards("in")
	hovered = false
	set_surface_override_material(0, disabled)


func onClick():
	var inst = dust.instantiate()
	$Marker3D.add_child(inst)
	anim.play("click")
