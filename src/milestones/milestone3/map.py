
class Node:
	def __init__(self, x, y):
		self.x = x;
		self.y = y;
		self.north = None;
		self.south = None;
		self.east = None;
		self.west = None;

	def set_north(node):
		self.north = node

	def set_south(node):
		self.south = node

	def set_east(node):
		self.east = node

	def set_west(node):
		self.west = node

def parse_map(seed_file):
	with open(seed_file) as f:
		lines = f.readlines():
		for y in range(len(lines)):
			line_nodes = lines[y].split(',').trim();
			for x in range(len(line_nodes)):
				node_val = line_nodes[x]
				node = Node(x, y)