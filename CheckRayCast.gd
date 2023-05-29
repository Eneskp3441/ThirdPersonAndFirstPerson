extends Node3D

var lastCollided = null

@onready var fpc := $%FPC
@onready var tpc := $%TPC

func _process(delta):
	
	var cam = fpc if fpc.current else tpc
	
	var space = get_world_3d().direct_space_state
	var mousePos = get_viewport().get_mouse_position()
	var rayOrigin =  cam.project_ray_origin(mousePos)
	var rayend = rayOrigin + cam.project_ray_normal(mousePos) * 100
	var ray = PhysicsRayQueryParameters3D.new()
	ray.from = rayOrigin
	ray.to = rayend
	ray.collision_mask = 2
	var intersection = space.intersect_ray(ray)
	
	if not intersection.is_empty():
		print(intersection.collider)
	
	
	if not intersection.is_empty():
		var c = intersection.collider.get_parent()
		
		if lastCollided != c:
			if c.has_method("onHoverExited"):
				c.call("onHoverExited")
			lastCollided = c
			
		if c.has_method("onHover"):
			c.call("onHover")
		
		if Input.is_action_just_pressed("interact") and c.has_method("onClick"):
			c.call("onClick")
	else:
		if lastCollided != null:
			if lastCollided.has_method("onHoverExited"):
				lastCollided.call("onHoverExited")
				lastCollided = null
