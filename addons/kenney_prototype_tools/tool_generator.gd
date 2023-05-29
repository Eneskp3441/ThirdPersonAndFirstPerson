# Editor script to generate the materials and cube scenes using the Kenney textures in the textures folder
extends Node

@tool

# Functions as a button to regenerate the materials and scenes
@export var generate := false

const textures_path := "res://addons/kenney_prototype_tools/textures"
const materials_path := "res://addons/kenney_prototype_tools/materials/"
const scenes_path := "res://addons/kenney_prototype_tools/scenes/"

const cube_scene = preload("res://addons/tools/cube.tscn")

# Generates the material and the scene corresponding to this color and texture
func generate_tex(col: String, tex_name: String):
	var id =  tex_name.trim_prefix("texture_").trim_suffix(".png")

	# Create the material and save it
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = load(textures_path.path_join(col).path_join(tex_name))
	mat.vertex_color_is_srgb = true
	mat.uv1_triplanar = true
	mat.uv1_world_triplanar = true
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	var mat_name = "material_" + id + ".tres"
	var mat_path = materials_path.path_join(col).path_join(mat_name)
	ResourceSaver.save(mat, mat_path)

	# Create the scene and save it
	var cube = cube_scene.instantiate()
	cube.get_node("Mesh").material_override = load(mat_path)
	var new_cube_scene = PackedScene.new()
	new_cube_scene.pack(cube)
	var scene_name = col + "_" + id + ".tscn"
	var scene_path = scenes_path.path_join(col).path_join(scene_name)
	ResourceSaver.save(new_cube_scene, scene_path)

# Generates materials and scenes for all colors and textures
func generate_tools():
	# Iterate over all colors in textures
	for col in DirAccess.open(textures_path).get_directories():
		# Creates materials and scenes parent folders
		DirAccess.make_dir_recursive_absolute(materials_path.path_join(col))
		DirAccess.make_dir_recursive_absolute(scenes_path.path_join(col))
		# Get texture files of current color
		var tex_col_path = textures_path.path_join(col)
		var files = Array(DirAccess.open(tex_col_path).get_files())
		# Ignore .import files generated by Godot
		files = files.filter(func(s): return !s.ends_with(".import"))
		# Iterate over all texture files
		for tex in files:
			generate_tex(col, tex)

func _process(_delta):
	if generate:
		generate = false
		generate_tools()
