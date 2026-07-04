extends Node2D

class_name UltimateBoxContainer

@export var pattern : ArrangeMethods.PATTERNS
@export var grid_limits : Vector2i = Vector2i(1,0)
@export var gaps : Vector2
@export var auto_rearrange : bool = true

var linked_nodes : Array


func _ready() -> void:
	pass
	#for i in range(0,8):
	#	print(ArrangeMethods.get_grid_position(i, grid_limits, ArrangeMethods.PATTERNS.FROM_CENTER))


func add_element(node, index = -1) -> void:
	if node != null and len(linked_nodes) < grid_limits.x * grid_limits.y:
		if index == -1:
			if auto_rearrange:
				linked_nodes.append([node, len(linked_nodes)])
				
			else:
				if get_available_index() != -1:
					linked_nodes.append([node, get_available_index()])
			
			rearrange()
			
	else:
		push_error("ELEMENT PUSH INCORRECT, NODE == NULL OR ARRAY IS FULL")
			
func remove_element(node) -> void:
	var remove_index : int = -1
	for i in linked_nodes:
		if i[0] == node:
			remove_index = linked_nodes.find(i)
			break
			
	linked_nodes.remove_at(remove_index)
	
	if auto_rearrange and len(linked_nodes) != 0:
		repair_indexes(remove_index)
		rearrange()


func remove_element_at_index(index) -> void:
	var remove_index : int = -1
	for i in linked_nodes:
		if i[1] == index:
			remove_index = linked_nodes.find(i)
			break
	
	linked_nodes.remove_at(remove_index)
	
	if auto_rearrange and len(linked_nodes) != 0:
		repair_indexes(index)
		rearrange()


func get_available_index() -> int:
	var c = 0
	var node_found : bool
	while c < len(linked_nodes):
		node_found = false
		for i in linked_nodes:
			if i[1] == c:
				node_found = true
				break
				
		if not node_found:
			return c
			
		c += 1
		
	return -1


func repair_indexes(deleted_index : int) -> void:
	if pattern != ArrangeMethods.PATTERNS.FROM_CENTER:
		if len(linked_nodes) >= grid_limits.x:
			var max_index = linked_nodes[0][1]
			for i in linked_nodes:
				if i[1] > max_index:
					max_index = i[1]
					
			for i in linked_nodes:
				if i[1] == max_index and max_index > deleted_index - 1:
					i[1] = deleted_index
					break
					
		else:
			for i in linked_nodes:
				if i[1] > deleted_index:
					i[1] -= 1
	
	else:
		var odd = 0
		var even = 0
			
		for i in linked_nodes:
			if i[1] % 2 == 0:
				even += 1
				
			else:
				odd += 1
				
		if deleted_index == 0:
			if even >= odd:
				for i in linked_nodes:
					if i[1] % 2 == 0:
						i[1] -= 2
						
			else:
				for i in linked_nodes:
					if i[1] % 2 != 0 and i[1] != 1:
						i[1] -= 2
					
					elif i[1] == 1:
						i[1] -= 1
		
		
		elif deleted_index % 2 == 0:
			if even >= odd:
				for i in linked_nodes:
					if i[1] % 2 == 0 and i[1] != 0 and i[1] > deleted_index:
						i[1] -= 2
						
			else:
				for i in linked_nodes:
					if i[1] % 2 == 0 and i[1] < deleted_index:
						i[1] += 2
						
					elif i[1] == 1:
						i[1] -= 1
						
					elif i[1] % 2 != 0:
						i[1] -= 2
		
		elif deleted_index % 2 != 0:
			if even > odd + 1 and deleted_index < len(linked_nodes):
				for i in linked_nodes:
					if i[1] == 0:
						i[1] += 1
						
					elif i[1] % 2 == 0:
						i[1] -= 2
						
					elif i[1] % 2 != 0 and i[1] < deleted_index:
						i[1] += 2
						
				
			else:
				for i in linked_nodes:
					if i[1] % 2 != 0 and deleted_index < i[1]:
						i[1] -= 2
						
						
	#print(linked_nodes)

func rearrange() -> void:
	var new_indexes = ArrangeMethods.get_from_center_positions(len(linked_nodes))
	#print(new_indexes)
	#print(linked_nodes)
	for i in linked_nodes:
		i[0].new_pos = position
		if pattern != ArrangeMethods.PATTERNS.FROM_CENTER:
			i[0].new_pos += ArrangeMethods.get_grid_position(i[1], grid_limits, pattern) * gaps
			
		else:
			i[0].new_pos.x += float(new_indexes[i[1]].x) * gaps.x


func clear() -> void:
	linked_nodes.clear()
