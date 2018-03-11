extends Node2D

onready var joint1 = get_node("Joint1")
onready var joint2 = get_node("Joint1/Joint2")
onready var joint3 = get_node("Joint1/Joint2/Joint3")

onready var target = get_node("Target")

var length1 = 0
var length2 = 0
var total_length = 0

var is_down = false
var mpos = null

onready var info = get_node("Control/Info")
onready var label1 = get_node("Control/Label1")
onready var label2 = get_node("Control/Label2")
onready var label3 = get_node("Control/Label3")

func _ready():
	length1 = (joint2.global_position - joint1.global_position).length()
	length2 = (joint3.global_position - joint2.global_position).length()
	total_length = length1 + length2
	info.text = "Length Bone1:%02d,  Bone2:%02d, Total:%02d" % [length1,length2, total_length] 

func _input(event):
	if event is InputEventKey and event.pressed and event.scancode==KEY_F10:
		get_tree().quit()
	elif event is InputEventMouseButton and event.button_index==BUTTON_LEFT:
		mpos = event.global_position
		is_down = event.pressed
	elif event is InputEventMouseMotion and is_down:
		mpos = event.global_position
		assert( event.global_position != Vector2(0,0) )


const epsilon = 0.0001

func is_zero( f ):
	return f < epsilon and f > -epsilon

# Use Law of Cosines to find angle(radians) between bone1(a) and the hypotenuse(c)
func find_angle( a, b, c ):
	var numer = ((a * a) + (b * b)) - (c * c)
	var denom = (2 * a * b)
	if not is_zero( denom ):
		return rad2deg( acos( numer / denom ) )
	else:
		return 0
	

func _process(delta):
	if mpos==null:  
		return
	target.global_position = mpos
	var hypot = (target.global_position - joint1.global_position).length()
	var hyp_ang = rad2deg( joint1.global_position.angle_to_point( target.global_position ) )		
	if hypot >= total_length:
		joint1.look_at( target.global_position )
		joint2.rotation_degrees = 0
		label3.text = "Out of range"
	else:
		var mid_ang = find_angle( length1, length2,  hypot ) # find angle between bone1 and bone2
		var side_ang = find_angle( length1, hypot, length2 ) 
		joint1.rotation_degrees = (hyp_ang + side_ang) - 180
		joint2.look_at( target.global_position )
		var error_dist = (joint3.global_position - target.global_position).length()
		label3.text = "Calc Inner angle: %02d, side angles:%02d, error: %02d" % [ mid_ang, side_ang, error_dist ]
	label1.text = "Target Distance: %02d, Angle: %02d" % [ hypot, hyp_ang ]
	label2.text = "Bone1 Ang:%02d , Bone2 Ang:%02d " % [joint1.rotation_degrees, joint2.rotation_degrees ] 
	mpos = null

