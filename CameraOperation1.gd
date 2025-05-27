extends Node3D

signal moving_on_3d(event: InputEvent)
signal detect_mouse_focused_object(obj: Node3D, position: Vector3)

@export var MainCamera: Node3D
@export var Front3DCam: Camera3D
@export var Front2DCam: Camera3D

@export var targetObject: Node3D
@export var rotationSpeed: Vector2 = Vector2(0.25, 0.25)
@export var zoomSpeed: float = 1
@export var reverse: bool = true

@export var rotateTargetObject: Node3D
@export var rotateTargetSpeed: float = 0
@export var isRotateMode: bool

var camOperateType: Dictionary = {
	"rotate" : false,
	"translate" : false,
	"zoom" : false
}
var curMousePos: Vector2
var lastMousePos: Vector2
var lastScrollWheel: float
var lastMousePressed: bool
var lastDragPos: Vector2
var newAngle: Vector3 = Vector3.ZERO
var virtualRightClick: bool

@export var ndlabel: Label
@export var ndlabel2: Label
@export var ndlabel3: Label
#@export var UiMain: UIMain

# Called when the node enters the scene tree for the first time.
func _ready():
	#pass # Replace with function body.
	virtualRightClick = false
	
	lastScrollWheel = 0
	
	lastMousePos = Vector2(-1,-1)
	if targetObject != null:
		MainCamera.global_transform.looking_at(targetObject.global_position)
	
	#ndlabel = get_tree().root.get_node("/root/Root/UI/Panel/GridContainer/BoxContainer/Label")
	#ndlabel2 = get_tree().root.get_node("/root/Root/UI/Panel/GridContainer/BoxContainer/Label2")
	#ndlabel3 = get_tree().root.get_node("/root/Root/UI/Panel/GridContainer/BoxContainer/Label3")

func _onroot_gltf_loaded(_success, _gltf):
	pass


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	#print("Area2D input event=")
	#print(viewport)
	#print(event)
	#print(shape_idx)
	#input(event)
	pass

func _input(event):
	var scrollWheel: float = 0
	var curmousepressed: bool = false;
	var curkeypressed: bool = false;
	
	var vp = get_viewport()
	var vppos = vp.get_mouse_position()
	#print(vp.get_mouse_position())
	if ndlabel != null:
		ndlabel.text = String.num(round(vppos.x)) + ":" + String.num(round(vppos.y))
	#print(MainCamera.project_local_ray_normal(vppos))
	#---Detect Target object to move, or waiting target to move.
	var space_state = get_world_3d().get_direct_space_state()
	var from = MainCamera.project_ray_origin(vppos)
	var to = from + MainCamera.project_ray_normal(vppos) * 1000.0
	#---set from position and to position of ray of Camera3D
	var rayq = PhysicsRayQueryParameters3D.new()
	rayq.from = from
	rayq.to = to
	var result = space_state.intersect_ray(rayq)
	if "collider" in result:
		#print(result)
		pass
	
	#if UiMain.mouse_operation_in_2d == true:
	#	return
	
	if event is InputEventMouseMotion:
		#---Moving mouse
		curMousePos = event.position
#		var space_state = get_world_3d().get_direct_space_state()
#		var from = Front3DCam.project_ray_origin(curMousePos)
#		var to = from + Front3DCam.project_ray_normal(curMousePos) * 1000.0
#		#---set from position and to position of ray of Camera3D
#		var rayq = PhysicsRayQueryParameters3D.new()
#		rayq.from = from
#		rayq.to = to
#		var result = space_state.intersect_ray(rayq)
#		if "collider" in result:
#			#print(result.collider.name + " - " + String.num(result.collider_id))
#			#print(result.position)
#			var rcoll = result.collider  #CollisionObject3D
#			var collparent = rcoll.get_parent_node_3d()
#			ndlabel2.text = String.num(to.x) + " : " + String.num(to.x) + " : " + String.num(to.z)
#			ndlabel3.text = collparent.name
#			detect_mouse_focused_object.emit(collparent, result.position)
#			if typeof(collparent) == TYPE_OBJECT:
#				#print(typeof(collparent))
#				var cs:Array[Node] = collparent.find_children("*","Skeleton3D",true)
#				for c1 in cs:
#					print(c1.name)
				
		
		if lastMousePressed == true:
			if virtualRightClick == true:
				execCameraRotater(curMousePos)
			
	elif event is InputEventMouseButton:
		curmousepressed = event.pressed
		if event.button_index == MOUSE_BUTTON_LEFT:
			#---Mouse left button
			if event.pressed == true:
				if Input.is_key_pressed(KEY_CTRL):
					camOperateType["rotate"] = true;
					curMousePos = event.position
					newAngle = MainCamera.rotation
					virtualRightClick = true
				elif Input.is_key_pressed(KEY_SPACE):
					camOperateType["translate"] = true
					lastDragPos = event.position
			else:
				camOperateType["rotate"] = false
				camOperateType["translate"] = false
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			#---Mouse right button
			camOperateType["rotate"] = event.pressed
			
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			#---Mouse wheel
			if event.pressed == true:
				lastDragPos = event.position
			camOperateType["translate"] = event.pressed
		elif (event.button_index == MOUSE_BUTTON_WHEEL_UP):
			scrollWheel = event.factor * 0.1
		elif (event.button_index == MOUSE_BUTTON_WHEEL_DOWN):
			scrollWheel = event.factor * 0.1 * -1
	elif event is InputEventKey:
		curkeypressed = event.pressed
		if (event.keycode == KEY_CTRL) and (event.pressed == false):
			virtualRightClick = false
		
			

	#---fire effect
	if scrollWheel != 0.0:
		#MainCamera.position = MainCamera.position + (Vector3.FORWARD * scrollWheel * zoomSpeed)
		if targetObject != null:
			#targetObject.position = targetObject.position + (Vector3.FORWARD * scrollWheel * zoomSpeed)
			targetObject.translate(Vector3.FORWARD * scrollWheel * zoomSpeed)
	
	
	if camOperateType["rotate"] == true:
		execCameraRotater(curMousePos)
	
	
	if camOperateType["translate"] == true:
		execCameraMover(curMousePos)

	lastScrollWheel = scrollWheel
	lastMousePos = curMousePos
	lastMousePressed = curmousepressed

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	#pass
#	if isRotateMode == true:
#		pass
	
func execCameraRotater(mousepos: Vector2):
	var x: int = 0
	var y: int = 0
	var diff:Vector2
	
	if (lastMousePos.x == -1) and (lastMousePos.y == -1):
		lastMousePos = mousepos
	
	if reverse == false:
		x = lastMousePos.x - mousepos.x
		y = mousepos.y - lastMousePos.y
		diff = lastMousePos - mousepos
	else:
		x = mousepos.x - lastMousePos.x
		y = lastMousePos.y - mousepos.y
		diff = mousepos - lastMousePos
		
	if diff.x < 0:
		diff.x = -1
	elif 0 < diff.x:
		diff.x = 1
	if diff.y < 0:
		diff.y = -1
	elif 0 < diff.y:
		diff.y = 1
	
	#print("mousepos=",mousepos)
	#print("lastMousePos=",lastMousePos)
	#print("diff=",diff)
	if abs(x) < abs(y):
		x = 0
	else:
		y = 0
	
	diff.x = x * rotationSpeed.x
	diff.y = y * rotationSpeed.y
	
	var tarpos: Vector3 = MainCamera.position - (Vector3.BACK * 0.1) 
	if targetObject != null:
		tarpos = targetObject.global_position
		
	
	if Input.is_key_pressed(KEY_SHIFT):
		#---view like FPS game
		MainCamera.rotate(Vector3.UP, diff.x * 0.01)
		MainCamera.rotate(Vector3.RIGHT, -diff.y * 0.01)
	else:
		#MainCamera.position = tarpos + (MainCamera.position - tarpos).rotated(Vector3.UP, diff.x)
		var tarrot:Vector3 = targetObject.global_rotation
		tarrot.x = tarrot.x + (diff.y * 0.05)
		tarrot.y = tarrot.y + (diff.x * -0.05) 
		#print("  tarrot=",tarrot)
		targetObject.global_rotation = tarrot
		
		"""
		if diff.x != 0:
			#targetObject.transform = targetObject.transform.rotated(Vector3.UP,diff.x * 0.01)
			targetObject.global_rotation = global_rotate(Vector3.UP,  diff.x * 0.1)
		if diff.y != 0:
			#targetObject.transform = targetObject.transform.rotated(Vector3.RIGHT,diff.y * 0.01)
			targetObject.global_rotate(Vector3.RIGHT, diff.y * 0.1)
		"""
		
	lastMousePos = mousepos

func execCameraMover(mousepos: Vector2):
	var delta = lastDragPos - mousepos
	var delta3: Vector3 = Vector3(delta.x * 0.01, delta.y * 0.01 * -1, 0)
	#print(delta3)
	#MainCamera.translate(delta3 * 0.6 * 0.25)
	if targetObject != null:
		targetObject.translate(delta3 * 0.6 * 0.25)
	
