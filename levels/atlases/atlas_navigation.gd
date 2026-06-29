extends TileMap
#TODO this script does nothing right now. 
# In future layer 0 should be for navigation - copy colliders from wall layer -> redo this script to do this
func _ready():
	bake_navigation()

const FLOOR_LAYER := 0
const WALL_LAYER := 4

func bake_navigation():
	var used_cells = self.get_used_cells(WALL_LAYER)
	for cell in used_cells:
		self.set_cell(FLOOR_LAYER, cell, -1)
