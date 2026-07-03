extends Node

enum PATTERNS {
	FROM_LEFT_TO_RIGHT,
	FROM_RIGHT_TO_LEFT,
	FROM_CENTER
}

# ---------------------------------------------------------------------
# Returns the grid coordinate for a given index and pattern.
# For LEFT_TO_RIGHT / RIGHT_TO_LEFT the grid origin is top‑left (0,0).
# For FROM_CENTER the grid origin is the centre of the grid, so the
# centre cell returns (0,0) and coordinates can be negative.
# ---------------------------------------------------------------------
static func get_grid_position(index: int, grid_size: Vector2, pattern: PATTERNS) -> Vector2:
	var columns: int = grid_size.x
	var rows: int = grid_size.y
	var total: int = columns * rows
	if index < 0 or index >= total:
		return Vector2.ZERO   # or push_error, depending on your needs

	match pattern:
		PATTERNS.FROM_LEFT_TO_RIGHT:
			var col = index % columns
			var row = index / columns
			return Vector2(col, row)

		PATTERNS.FROM_RIGHT_TO_LEFT:
			var col = columns - 1 - (index % columns)
			var row = index / columns
			return Vector2(col, row)

		PATTERNS.FROM_CENTER:
			# Build the full centre‑out sequence of (col, row) once,
			# then reuse it. Caching is possible but omitted for clarity.
			var sequence = _get_center_out_sequence(columns, rows)
			var center_col = columns / 2   # integer division (floor)
			var center_row = rows / 2
			var abs_pos: Vector2 = sequence[index]
			# Make coordinates relative to the centre cell.
			return Vector2(abs_pos.x - center_col, abs_pos.y - center_row)

		_:
			return Vector2.ZERO

# ---------------------------------------------------------------------
# Generates an array of absolute (col, row) coordinates in the order
# they should be filled when starting from the centre and expanding
# outward, row by row, and within each row from its centre outward.
# ---------------------------------------------------------------------
static func _get_center_out_sequence(columns: int, rows: int) -> Array[Vector2]:
	var seq: Array[Vector2] = []
	seq.resize(columns * rows)

	# Determine the order in which rows are visited (centre row first,
	# then the row above, then below, then further above, etc.)
	var row_order: Array[int] = []
	var mid_row: int = rows / 2
	row_order.append(mid_row)
	var offset: int = 1
	while row_order.size() < rows:
		if mid_row - offset >= 0:
			row_order.append(mid_row - offset)
		if mid_row + offset < rows:
			row_order.append(mid_row + offset)
		offset += 1

	# For each row, pre‑calculate the centre‑out column order.
	var col_order_per_row: Dictionary = {}
	for r in range(rows):
		if not col_order_per_row.has(r):
			col_order_per_row[r] = _get_column_center_order(columns)

	# Fill the sequence in row‑major, centre‑out order.
	var idx: int = 0
	for r in row_order:
		var col_seq: Array = col_order_per_row[r]
		for c in col_seq:
			seq[idx] = Vector2(c, r)
			idx += 1
	return seq

# ---------------------------------------------------------------------
# For a given number of columns, returns the column indices in the
# order: centre → right → left → further right → further left …
# ---------------------------------------------------------------------
static func _get_column_center_order(columns: int) -> Array[int]:
	var order: Array[int] = []
	order.resize(columns)
	if columns == 0:
		return order

	var mid: int = columns / 2
	if columns % 2 == 1:
		order[0] = mid
		var left = mid - 1
		var right = mid + 1
		var i = 1
		while i < columns:
			if right < columns:
				order[i] = right
				right += 1
				i += 1
			if left >= 0 and i < columns:
				order[i] = left
				left -= 1
				i += 1
	else:
		# Even number of columns: start with the two middle columns.
		var mid_left = mid - 1
		var mid_right = mid
		order[0] = mid_left
		order[1] = mid_right
		var left = mid_left - 1
		var right = mid_right + 1
		var i = 2
		while i < columns:
			if right < columns:
				order[i] = right
				right += 1
				i += 1
			if left >= 0 and i < columns:
				order[i] = left
				left -= 1
				i += 1
	return order


# Returns an array of Vector2i target positions for the given number of elements.
# For a 1‑row grid, y is always 0.
static func get_from_center_positions(count: int) -> Array[Vector2i]:
	var pos: Array[Vector2i] = []
	pos.resize(count)
	pos[0] = Vector2i.ZERO
	var step := 1
	var side := 1   # 1 for right, -1 for left
	for i in range(1, count):
		pos[i] = Vector2i(side * step, 0)
		if side == 1:
			side = -1
		else:
			side = 1
			step += 1
	return pos

# After deleting the element at original index 'deleted',
# returns the new target positions for the remaining elements,
# *preserving the original order of the nodes in the 'nodes' array*
# (the node that was at index d is already removed from 'nodes').
static func get_targets_after_deletion(nodes: Array,deleted_index: int) -> Array[Vector2i]:
	var new_count = nodes.size()
	var targets = get_from_center_positions(new_count)
	return targets
