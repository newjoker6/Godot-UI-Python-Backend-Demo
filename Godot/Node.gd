extends Node

var websocket_client: WebSocketPeer
var uri = "ws://localhost:8765"
var data: Dictionary
var PID: int
var win: Window
var x = []
var y = []
var title:String
var cansend: bool = false
@export var CreateButton: Button

func _ready():

	win = get_window()
	win.connect("close_requested", Callable(self, "close_backend"))
	OS.shell_open("PATH TO COMPILED PYTHON EXE")
	for c in $HBoxContainer.get_children():
		c.connect("text_changed", Callable(self, "text_changed"))
	for c in $HBoxContainer2.get_children():
		c.connect("value_changed", Callable(self, "value_changed"))

	websocket_client = WebSocketPeer.new()
	websocket_client.connect_to_url(uri)
	print("Connected to WebSocket server")

func text_changed(new_text):
	x.clear()
	for c in $HBoxContainer.get_children():
		x.append(c.text)
	if x.size() == y.size():
		cansend = true

func value_changed(value):
	y.clear()
	for c in $HBoxContainer2.get_children():
		y.append(int(c.value))
	if x.size() == y.size():
		cansend = true

func _on_create_button_pressed():
	print(title)
	data = {
		"arg1": "graph",
		"arg2": x,
		"arg3":y,
		"arg4": title
	}  
	websocket_client.put_packet(JSON.stringify(data).to_utf8_buffer())


func _process(delta: float) -> void:
	websocket_client.poll()
	if cansend:
		CreateButton.disabled = false
	else:
		CreateButton.disabled = true
	var state = websocket_client.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		while websocket_client.get_available_packet_count():
			var servermsg = websocket_client.get_packet().get_string_from_utf8()
			print("Packet: ", servermsg)
			if "pid:" in servermsg:
				servermsg = servermsg.split(":")
				PID = servermsg[1] as int
			
	
	elif state == WebSocketPeer.STATE_CLOSING:
		pass
	
	elif state == WebSocketPeer.STATE_CLOSED:
		var code =  websocket_client.get_close_code()
		var reason = websocket_client.get_close_reason()
		print("Websocket closed with code: %s reason: %s" %[code, reason])


func close_backend():
	if PID:
		OS.kill(PID)
	print("closing backend")


func _on_line_edit_text_changed(new_text: String) -> void:
	title = new_text
