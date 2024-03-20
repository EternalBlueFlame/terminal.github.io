GDPC                P                                                                         T   res://.godot/exported/133200997/export-01b62da50da7472eef2caa23e00d1ea7-widget.scn  �L      �      ��HÏŢoj�C�\    P   res://.godot/exported/133200997/export-3070c538c03ee49b7677ff960a3f5195-main.scn@      �      �م�6��d����[\    T   res://.godot/exported/133200997/export-7aeadb58d35a3c0bfb71a821ef748161-login.scn   P9      s      �Fu�㚟H���o�    ,   res://.godot/global_script_class_cache.cfg  �a             ��Р�8���8~$}P�    D   res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex�)      �      �Yz=������������       res://.godot/uid_cache.bin  �e      r       ����|��g�递�       res://globals.gd�'      �      x'��su�t"���X�p       res://icon.svg  b      �      C��=U���^Qu��U3       res://icon.svg.import   �6      �       f��wrJJ���A7|�c       res://login.gd  �7      �      ��d�v�n�	ql�N�       res://login.tscn.remap  �`      b       �	��l�\��}IX�[       res://main.gd   �=      5      ���
�Y#���1��!��       res://main.tscn.remap   a      a       �J�Sw� ������       res://move.gd    I      �      g�#�T�c<��� �       res://project.binaryPf      @      ����^nO��VO.4�       res://widget.tscn.remap �a      c       ����@���       res://widgets/chatbot.gd        �      E:�ҧ��h5��z\�        res://widgets/company_search.gd �      {      �Ժ�q�ܱ�$����9        res://widgets/company_window.gd @      �      |�pǂ�������    $   res://widgets/sec_filing_window.gd          �      P"��yL�ܩՔw)    �q�ȁ��extends "res://move.gd"


#todo: add a rest API for
# curl https://api-inference.huggingface.co/models/microsoft/phi-2 -X POST -d '{"inputs": "provide a summary of the Nvidia Corporation SEC prospectus securities\n\n"}' -H 'Content-Type: application/json' -H "Authorization: Bearer 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"
#curl https://api-inference.huggingface.co/models/google/gemma-7b      -X POST         -d '{"inputs": "provide a summary of the SEC prospectus risk factors for the Nvidia Corporation\n\n"}'  -H 'Content-Type: application/json'     -H "Authorization: Bearer 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"

# curl https://api.openai.com/v1/chat/completions   -H "Content-Type: application/json"   -H "Authorization: Bearer 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"   -d '{
#    "model": "gpt-3.5-turbo",
#    "messages": [
#      {
#        "role": "system",
#        "content": "You are a financial assistant."
#      },
#      {
#        "role": "user",
#        "content": "summarize the following: https://www.sec.gov/Archives/edgar/data/1045810/000119312521191303/d187484d424b5.htm"
#      }
#    ]
#  }'

#user shuls paste a link a webcrawler should take that, parse the data into a basic string with few special characters, then ask the AI to summarize it without using technical terms or boilerplate info

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	position.y=50
	position.x=740
	size.x=400;
	get_node("Title").text="AI Assistant"
	var panel = get_node("Container/Content")
	var label = RichTextLabel.new();
	label.position= Vector2(10,40);
	label.size = Vector2(420, 250);
	label.scale.x=0.9;
	label.scale.y=0.9;
	label.text=""
	label.name="chatbox_text";
	add_child(label);
	var text_edit = TextEdit.new()
	text_edit.name="text_edit";
	text_edit.caret_blink=true;
	text_edit.position= Vector2(10,280);
	text_edit.size = Vector2(420, 50);
	text_edit.scale.x=0.9;
	text_edit.scale.y=0.9;
	text_edit.placeholder_text="SEC edgar link";
	text_edit.connect("gui_input", Callable(self, "_on_text_edit_gui_input"))
	add_child(text_edit);
	pass # Replace with function body.

	

func _on_text_edit_gui_input(event):
	if event is InputEventKey:
		print(event.keycode)
	# Check if the Enter key is pressed and the event is a key press event
	if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER:
		# Call your method to handle the Enter key press
		req()
		get_node("text_edit").text="";
		
func req():
	# URL to fetch text from
	var url = get_node("text_edit").text;
	
	if "https://www.sec.gov/" in url and "edgar" in url:
		get_node("text_edit").text="";
		get_node("chatbox_text").text="Fetching data..."
		# Fetch text from URL
		var http_request = HTTPRequest.new()
		add_child(http_request);
		http_request.request_completed.connect(self.http_get)
		var error = http_request.request(url)
		await http_request.request_completed
	else:
		get_node("chatbox_text").text="Error: Please enger a valid sec.gov link"
		get_node("text_edit").text="";
		



func http_get(result, response_code, headers, body):
	get_node("chatbox_text").text="Fetching data...\nProcessing AI summary..."
		# Check if request was successful
	if result==HTTPRequest.RESULT_SUCCESS:
		# Get response text
		var response_text = strip_html_tags(body.get_string_from_utf8())
		response_text=deduplicate_newline(response_text);
		response_text=response_text.replacen("&nbsp;", " ").replace("\t", " ").replace("&amp;","&")
		
		var filing = Globals._build_menu(load("res://widgets/sec_filing_window.gd"), "", self.get_parent())
		filing.get_node("Panel/Container/Content/bg/web_text").text=response_text;
		var send_headers:PackedStringArray = [
			'Content-Type: application/json',
			'Authorization: Bearer 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'
		]

		# Set up data (if needed)
		var data = {
			"model": "gpt-4",
			"messages": [
				{
				"role": "user",
				"content": "Summarize this and avoid the boiler plate info: " + response_text
				}
			]
		}
		# Use response text as header for REST request
		var rest_request = HTTPRequest.new()
		add_child(rest_request);
		rest_request.request_completed.connect(self.rest_get)
		rest_request.request("https://api.openai.com/v1/chat/completions", send_headers, HTTPClient.METHOD_POST, JSON.stringify(data))
		await rest_request.request_completed
		
	else:
		print("Error: Unable to fetch data from URL")

func rest_get(result, response_code, headers, body):
	print(body.get_string_from_utf8())
	var j = JSON.parse_string(body.get_string_from_utf8())
	get_node("chatbox_text").text="Summary:\n"+j["choices"][0]["message"]["content"];
	pass
	

func strip_html_tags(text):
	var in_tag = false
	var plain_text = ""
	
	for i in range(text.length()):
		var char = text[i]
		
		if char == "<":
			in_tag = true
		elif char == ">":
			in_tag = false
		else:
			if not in_tag:
				plain_text += char
	return plain_text

func deduplicate_newline(text):
	while "\n\n" in text:
		text=text.replacen("\n\n","\n");
	return text;
	
�FD�� extends "res://move.gd"

# List of strings
var list_of_strings = ["APPL", "ADBE", "ANET", "AMZN"]


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	position.x=210;
	position.y=50;
	get_node("Title").text="Search"
	var panel = get_node("Container/Content")
	var text_edit = TextEdit.new()
	text_edit.position= Vector2(10,10);
	text_edit.size = Vector2(180, 30);
	text_edit.placeholder_text="Search";
	panel.add_child(text_edit)
	# Connect the text_changed signal to a custom function
	
	var search_list = Control.new()
	search_list.position= Vector2(10,40);
	search_list.size = Vector2(180, 400);
	panel.add_child(search_list)
	text_edit.connect("text_changed", Callable(self, "_on_text_edit_text_changed").bind(text_edit,search_list))
	
	pass # Replace with function body.


func _on_text_edit_text_changed(new_text, panel):
	# Remove all existing buttons
	for child in panel.get_children():
		if child is Button:
			child.queue_free()
	var count=0;
	# Create a new button for each item in the list that contains the entered text
	for item in list_of_strings:
		if new_text.get_text() in item:
			var button = Button.new()
			button.position= Vector2(0,30*count);
			button.text = item
			button.connect("pressed", Callable(Globals, "_build_menu").bind(load("res://widgets/company_window.gd"),item, get_parent()))
			panel.add_child(button)
			count+=1;
��˪�extends "res://move.gd"

var menu_items = {"Menu 1":[
		{"name": "Item 1", "action": Callable(self, "action_1")},
		{"name": "Item 2", "action": Callable(self, "action_2")},
		{"name": "Item 3", "action": Callable(self, "action_3")}
	], "Menu 2": [
		{"name": "Item 1", "action": Callable(self, "action_1")},
		{"name": "Item 2", "action": Callable(self, "action_2")},
		{"name": "Item 3", "action": Callable(self, "action_3")}
	]}

var title="title"

func set_data(s):
	get_node("Title").text=s;
	
var buttons = []
var menus = []

func _ready():
	super._ready()
	position.y=50;
	var y_position = 30
	for menu in menu_items.keys():
		var button = Button.new()
		button.text = menu
		button.size.y = 40
		button.size.x = 200
		add_child(button)
		button.position.y = y_position
		button.position.x=5;
		y_position += 40

		var vbox = VBoxContainer.new()
		vbox.visible = false
		add_child(vbox)

		for item in menu_items[menu]:
			var item_button = Button.new()
			item_button.text = item["name"]
			vbox.add_child(item_button)
			item_button.connect("pressed", item["action"])

		buttons.append(button)
		menus.append(vbox)

		button.connect("pressed", Callable(self, "_on_Button_pressed").bind([vbox]))

func _on_Button_pressed(menu):
	for item in menu:
		item.visible = !item.visible
	_re_sort_menus()

func _re_sort_menus():
	var y_position = 30
	for i in range(len(buttons)):
		buttons[i].position.y = y_position
		y_position += 40
		if menus[i].visible:
			menus[i].position.y = y_position
			y_position += menus[i].size.y

# Define your action functions here
func action_1():
	print("Action 1 was triggered!")

func action_2():
	print("Action 2 was triggered!")

func action_3():
	print("Action 3 was triggered!")
�>w�|
�}extends "res://move.gd"

#todo: add a rest API for
# curl https://api-inference.huggingface.co/models/microsoft/phi-2 -X POST -d '{"inputs": "provide a summary of the Nvidia Corporation SEC prospectus securities\n\n"}' -H 'Content-Type: application/json' -H "Authorization: Bearer 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"
#curl https://api-inference.huggingface.co/models/google/gemma-7b      -X POST         -d '{"inputs": "provide a summary of the SEC prospectus risk factors for the Nvidia Corporation\n\n"}'  -H 'Content-Type: application/json'     -H "Authorization: Bearer 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"

# curl https://api.openai.com/v1/chat/completions   -H "Content-Type: application/json"   -H "Authorization: Bearer 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"   -d '{
#    "model": "gpt-3.5-turbo",
#    "messages": [
#      {
#        "role": "system",
#        "content": "You are a financial assistant."
#      },
#      {
#        "role": "user",
#        "content": "summarize the following: https://www.sec.gov/Archives/edgar/data/1045810/000119312521191303/d187484d424b5.htm"
#      }
#    ]
#  }'
#user shuls paste a link a webcrawler should take that, parse the data into a basic string with few special characters, then ask the AI to summarize it without using technical terms or boilerplate info

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	position.y=50
	position.x=40
	size.x=680;
	size.y=500;
	var bg= ColorRect.new();
	bg.name="bg";
	bg.set_anchors_preset(PRESET_FULL_RECT)
	bg.color=Color.WHITE;
	get_node("Container/Content").add_child(bg);
	get_node("Title").text="SEC Filing"
	var web_label = RichTextLabel.new();
	web_label.position= Vector2(10,40);
	web_label.size = Vector2(770, 480);
	web_label.scale.x=0.9;
	web_label.scale.y=0.9;
	web_label.text=""
	web_label.add_theme_color_override("default_color",Color.BLACK)
	web_label.name="web_text";
	bg.add_child(web_label);
	
	pass # Replace with function body.

	

kextends Node

var node_z:int=0;

var widget_base = preload("res://widget.tscn");


func _build_menu(script, text, node):
	var panel= widget_base.instantiate();
	panel.get_node("Panel").set_script(script);
	node.add_child(panel);
	panel.get_node("Panel").set_data(text);
	
	return panel;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
�GST2   �   �      ����               � �        �  RIFF�  WEBPVP8L�  /������!"2�H�$�n윦���z�x����դ�<����q����F��Z��?&,
ScI_L �;����In#Y��0�p~��Z��m[��N����R,��#"� )���d��mG�������ڶ�$�ʹ���۶�=���mϬm۶mc�9��z��T��7�m+�}�����v��ح����mow�*��f�&��Cp�ȑD_��ٮ}�)� C+���UE��tlp�V/<p��ҕ�ig���E�W�����Sթ�� ӗ�A~@2�E�G"���~ ��5tQ#�+�@.ݡ�i۳�3�5�l��^c��=�x�Н&rA��a�lN��TgK㼧�)݉J�N���I�9��R���$`��[���=i�QgK�4c��%�*�D#I-�<�)&a��J�� ���d+�-Ֆ
��Ζ���Ut��(Q�h:�K��xZ�-��b��ٞ%+�]�p�yFV�F'����kd�^���:[Z��/��ʡy�����EJo�񷰼s�ɿ�A���N�O��Y��D��8�c)���TZ6�7m�A��\oE�hZ�{YJ�)u\a{W��>�?�]���+T�<o�{dU�`��5�Hf1�ۗ�j�b�2�,%85�G.�A�J�"���i��e)!	�Z؊U�u�X��j�c�_�r�`֩A�O��X5��F+YNL��A��ƩƗp��ױب���>J�[a|	�J��;�ʴb���F�^�PT�s�)+Xe)qL^wS�`�)%��9�x��bZ��y
Y4�F����$G�$�Rz����[���lu�ie)qN��K�<)�:�,�=�ۼ�R����x��5�'+X�OV�<���F[�g=w[-�A�����v����$+��Ҳ�i����*���	�e͙�Y���:5FM{6�����d)锵Z�*ʹ�v�U+�9�\���������P�e-��Eb)j�y��RwJ�6��Mrd\�pyYJ���t�mMO�'a8�R4��̍ﾒX��R�Vsb|q�id)	�ݛ��GR��$p�����Y��$r�J��^hi�̃�ūu'2+��s�rp�&��U��Pf��+�7�:w��|��EUe�`����$G�C�q�ō&1ŎG�s� Dq�Q�{�p��x���|��S%��<
\�n���9�X�_�y���6]���մ�Ŝt�q�<�RW����A �y��ػ����������p�7�l���?�:������*.ո;i��5�	 Ύ�ș`D*�JZA����V^���%�~������1�#�a'a*�;Qa�y�b��[��'[�"a���H�$��4� ���	j�ô7�xS�@�W�@ ��DF"���X����4g��'4��F�@ ����ܿ� ���e�~�U�T#�x��)vr#�Q��?���2��]i�{8>9^[�� �4�2{�F'&����|���|�.�?��Ȩ"�� 3Tp��93/Dp>ϙ�@�B�\���E��#��YA 7 `�2"���%�c�YM: ��S���"�+ P�9=+D�%�i �3� �G�vs�D ?&"� !�3nEФ��?Q��@D �Z4�]�~D �������6�	q�\.[[7����!��P�=��J��H�*]_��q�s��s��V�=w�� ��9wr��(Z����)'�IH����t�'0��y�luG�9@��UDV�W ��0ݙe)i e��.�� ����<����	�}m֛�������L ,6�  �x����~Tg����&c�U��` ���iڛu����<���?" �-��s[�!}����W�_�J���f����+^*����n�;�SSyp��c��6��e�G���;3Z�A�3�t��i�9b�Pg�����^����t����x��)O��Q�My95�G���;w9�n��$�z[������<w�#�)+��"������" U~}����O��[��|��]q;�lzt�;��Ȱ:��7�������E��*��oh�z���N<_�>���>>��|O�׷_L��/������զ9̳���{���z~����Ŀ?� �.݌��?�N����|��ZgO�o�����9��!�
Ƽ�}S߫˓���:����q�;i��i�]�t� G��Q0�_î!�w��?-��0_�|��nk�S�0l�>=]�e9�G��v��J[=Y9b�3�mE�X�X�-A��fV�2K�jS0"��2!��7��؀�3���3�\�+2�Z`��T	�hI-��N�2���A��M�@�jl����	���5�a�Y�6-o���������x}�}t��Zgs>1)���mQ?����vbZR����m���C��C�{�3o��=}b"/�|���o��?_^�_�+��,���5�U��� 4��]>	@Cl5���w��_$�c��V��sr*5 5��I��9��
�hJV�!�jk�A�=ٞ7���9<T�gť�o�٣����������l��Y�:���}�G�R}Ο����������r!Nϊ�C�;m7�dg����Ez���S%��8��)2Kͪ�6̰�5�/Ӥ�ag�1���,9Pu�]o�Q��{��;�J?<�Yo^_��~��.�>�����]����>߿Y�_�,�U_��o�~��[?n�=��Wg����>���������}y��N�m	n���Kro�䨯rJ���.u�e���-K��䐖��Y�['��N��p������r�Εܪ�x]���j1=^�wʩ4�,���!�&;ج��j�e��EcL���b�_��E�ϕ�u�$�Y��Lj��*���٢Z�y�F��m�p�
�Rw�����,Y�/q��h�M!���,V� �g��Y�J��
.��e�h#�m�d���Y�h�������k�c�q��ǷN��6�z���kD�6�L;�N\���Y�����
�O�ʨ1*]a�SN�=	fH�JN�9%'�S<C:��:`�s��~��jKEU�#i����$�K�TQD���G0H�=�� �d�-Q�H�4�5��L�r?����}��B+��,Q�yO�H�jD�4d�����0*�]�	~�ӎ�.�"����%
��d$"5zxA:�U��H���H%jس{���kW��)�	8J��v�}�rK�F�@�t)FXu����G'.X�8�KH;���[  �b��z@��[remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://cerha7wf268e6"
path="res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex"
metadata={
"vram_texture": false
}
 3#���{f>��	[�a]extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_login_pressed():
	if get_node("user").get_text()=="Anthony" && get_node("pass").get_text()=="terminal":
		get_tree().change_scene_to_file("res://main.tscn");
	pass # Replace with function body.
;hxRSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Script    res://login.gd ��������      local://PackedScene_7cn5c          PackedScene          	         names "         Node2D    script    user    offset_left    offset_top    offset_right    offset_bottom    placeholder_text 	   TextEdit    pass    Button    text    _on_login_pressed    pressed    	   variants                      �B     <C    ��C     aC   	   Username      lC    ��C   	   Password      'C    ��C     YC     �C      Login       node_count             nodes     <   ��������        ����                            ����                                                	   ����                                             
   
   ����      	      
                               conn_count             conns                                      node_paths              editable_instances              version             RSRC��H
��TOextends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	_search()
	get_node("Panel3/Panel/HBoxContainer/Search").connect("pressed", Callable(self, "_search"))
	get_node("Panel3/Panel/HBoxContainer/AI").connect("pressed", Callable(self, "_ai"))
	pass

func _search():
	Globals._build_menu(load("res://widgets/company_search.gd"), "", self)
	
func _ai():
	Globals._build_menu(load("res://widgets/chatbot.gd"), "", self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
s0�In���/�}RSRC                    PackedScene            ��������                                            "      resource_local_to_scene    resource_name    interpolation_mode    interpolation_color_space    offsets    colors    script 	   gradient    width    height    use_hdr    fill 
   fill_from    fill_to    repeat    content_margin_left    content_margin_top    content_margin_right    content_margin_bottom    texture    texture_margin_left    texture_margin_top    texture_margin_right    texture_margin_bottom    expand_margin_left    expand_margin_top    expand_margin_right    expand_margin_bottom    axis_stretch_horizontal    axis_stretch_vertical    region_rect    modulate_color    draw_center 	   _bundled       Script    res://main.gd ��������      local://Gradient_o0jbu �          local://GradientTexture2D_3j3t0          local://StyleBoxTexture_oypkj T         local://PackedScene_314i6 �      	   Gradient       $      ���<�� =���=  �?��@<
�t>	�|>  �?         GradientTexture2D                    
   ��>  �?   
   R`?             StyleBoxTexture                         PackedScene    !      	         names "         Node2D    script    Panel3    anchors_preset    anchor_right    anchor_bottom    offset_right    offset_bottom    grow_horizontal    grow_vertical    size_flags_horizontal    size_flags_vertical    theme_override_styles/panel    Panel    layout_mode    HBoxContainer    AI    text    Button    Search    	   variants                            �?     �D     �D                              ����     �B   
ף;      B      AI Assistant       Search       node_count             nodes     `   ��������        ����                            ����
                                       	      
                                   ����            	      
                                      ����                                 	                       ����                                ����                         conn_count              conns               node_paths              editable_instances              version             RSRC�extends Panel

var height:int=0;

var toolbar:Button;

var oldpos:Vector2;



func set_data(s):
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	height=size.y;
	toolbar=get_node("Grabbar");
	get_node("ButtonBox/Close").connect("pressed", Callable(self,"_close"))
		
	pass # Replace with function body.

var drag_start_pos:Vector2=Vector2(0,0);
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if toolbar.button_pressed && drag_start_pos!=Vector2(0,0):
		position = get_global_mouse_position() - drag_start_pos
	elif !toolbar.button_pressed:
		drag_start_pos=Vector2(0,0);
	pass

func _close():
	get_parent().queue_free();

func _on_pressed():
	Globals.node_z+=1;
	z_index=Globals.node_z;
	drag_start_pos = get_global_mouse_position() - position
	pass # Replace with function body.


func _on_minimize(button_pressed):
	if(button_pressed):
		size.y=20;
	else:
		size.y=height;
	pass # Replace with function body.
7i��!8RSRC                    PackedScene            ��������                                            :      resource_local_to_scene    resource_name    content_margin_left    content_margin_top    content_margin_right    content_margin_bottom 	   bg_color    draw_center    skew    border_width_left    border_width_top    border_width_right    border_width_bottom    border_color    border_blend    corner_radius_top_left    corner_radius_top_right    corner_radius_bottom_right    corner_radius_bottom_left    corner_detail    expand_margin_left    expand_margin_top    expand_margin_right    expand_margin_bottom    shadow_color    shadow_size    shadow_offset    anti_aliasing    anti_aliasing_size    script    interpolation_mode    interpolation_color_space    offsets    colors 	   gradient    width    height    use_hdr    fill 
   fill_from    fill_to    repeat    texture    texture_margin_left    texture_margin_top    texture_margin_right    texture_margin_bottom    axis_stretch_horizontal    axis_stretch_vertical    region_rect    modulate_color    line_spacing    font 
   font_size    font_color    outline_size    outline_color 	   _bundled       Script    res://move.gd ��������      local://StyleBoxFlat_pf0a1 �         local://StyleBoxFlat_ksic7           local://Gradient_goete �          local://GradientTexture2D_srihb          local://StyleBoxTexture_f5a8a d         local://LabelSettings_g3rmq �         local://StyleBoxFlat_oan51 �         local://StyleBoxFlat_rwouq >	         local://StyleBoxFlat_rxc2q s	         local://StyleBoxFlat_rsmbs �	         local://StyleBoxFlat_1tgvv �	         local://StyleBoxFlat_2x5sj 
         local://PackedScene_21g57 �
         StyleBoxFlat          ���=��`>s��>  �?         StyleBoxFlat                        �?	         
                                 ��0=���>���>  �?                                          	   Gradient    !   $      ���<�� =���=  �?��@<
�t>	�|>  �?         GradientTexture2D    "            '   
   ��>  �?(   
   R`?             StyleBoxTexture             bg *                     LabelSettings                      ��?         StyleBoxFlat          ��@< �}?�y?  �?                                             StyleBoxFlat          ��?��?��?             StyleBoxFlat          ��?��?��?             StyleBoxFlat          ��?��?��?             StyleBoxFlat          ��?��?��?             StyleBoxFlat          ��@<
�t>	�|>  �?	         
                        ��0=���>���>  �?         PackedScene    9      	         names "   '      Node2D    Panel    clip_contents    offset_right    offset_bottom    theme_override_styles/panel    script 
   Container    layout_mode    anchors_preset    anchor_right    anchor_bottom    offset_top    grow_horizontal    grow_vertical    Content    offset_left    Title    scale    text    label_settings    Label    Panel2    Grabbar    theme_override_styles/normal    theme_override_styles/hover    theme_override_styles/pressed    theme_override_styles/focus    Button 
   ButtonBox    anchor_left    Close    Shade    toggle_mode    Pin    _on_pressed    pressed    _on_minimize    toggled    	   variants    ,              QC    ��C                             ����     �?     �A                    �@     ��                     �A     xB     �A
   333?333?      Title               @@     �A              �A                        	         
        ��              �B     �@     �B     B
   ��?��?        X        HB     �B     B        ^        �A     pB      📌       node_count             nodes     �   ��������        ����                      ����                                                   ����         	      
                     	      	      
                    ����         	      
                                       	      	                          ����                                                                    ����                                                        ����                                                              ����         	            
                                               ����                         !      "      #      $                     ����            %            &      '      #   !          (                 "   ����            )             *      "      #   !          +             conn_count             conns              $   #              	      &   %              
      &   %                    node_paths              editable_instances              version             RSRCU6�Mm�ڇ�A�[remap]

path="res://.godot/exported/133200997/export-7aeadb58d35a3c0bfb71a821ef748161-login.scn"
�G!I��Ӊ�r�g [remap]

path="res://.godot/exported/133200997/export-3070c538c03ee49b7677ff960a3f5195-main.scn"
���� >�*�t~��[remap]

path="res://.godot/exported/133200997/export-01b62da50da7472eef2caa23e00d1ea7-widget.scn"
�H��u���@f��list=Array[Dictionary]([])
���ۈ<svg height="128" width="128" xmlns="http://www.w3.org/2000/svg"><rect x="2" y="2" width="124" height="124" rx="14" fill="#363d52" stroke="#212532" stroke-width="4"/><g transform="scale(.101) translate(122 122)"><g fill="#fff"><path d="M105 673v33q407 354 814 0v-33z"/><path fill="#478cbf" d="m105 673 152 14q12 1 15 14l4 67 132 10 8-61q2-11 15-15h162q13 4 15 15l8 61 132-10 4-67q3-13 15-14l152-14V427q30-39 56-81-35-59-83-108-43 20-82 47-40-37-88-64 7-51 8-102-59-28-123-42-26 43-46 89-49-7-98 0-20-46-46-89-64 14-123 42 1 51 8 102-48 27-88 64-39-27-82-47-48 49-83 108 26 42 56 81zm0 33v39c0 276 813 276 813 0v-39l-134 12-5 69q-2 10-14 13l-162 11q-12 0-16-11l-10-65H447l-10 65q-4 11-16 11l-162-11q-12-3-14-13l-5-69z"/><path d="M483 600c3 34 55 34 58 0v-86c-3-34-55-34-58 0z"/><circle cx="725" cy="526" r="90"/><circle cx="299" cy="526" r="90"/></g><g fill="#414042"><circle cx="307" cy="532" r="60"/><circle cx="717" cy="532" r="60"/></g></g></svg>
ff�A�N��t�   �ļ��-�F   res://icon.svg��&���e   res://login.tscny�Y47�G   res://main.tscnj��   res://widget.tscnhS4^-�4-��ԬAECFG      application/config/name         Terminal   application/run/main_scene         res://login.tscn   application/config/features(   "         4.1    GL Compatibility       application/run/max_fps         "   application/run/low_processor_mode         "   application/boot_splash/show_image              application/boot_splash/fullsize          "   application/boot_splash/use_filter             application/config/icon         res://icon.svg     autoload/Globals         *res://globals.gd   )   debug/file_logging/enable_file_logging.pc             dotnet/project/assembly_name         Terminal   editor_plugins/enabled8   "      *   res://addons/coi_serviceworker/plugin.cfg   #   rendering/renderer/rendering_method         gl_compatibility*   rendering/renderer/rendering_method.mobile         gl_compatibility4   rendering/textures/vram_compression/import_etc2_astc         :   rendering/camera/depth_of_field/depth_of_field_bokeh_shape          >   rendering/anti_aliasing/screen_space_roughness_limiter/enabled          