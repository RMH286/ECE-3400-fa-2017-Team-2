
class Node:
	def __init__(self, x, y):
		self.x = x
		self.y = y
		self.neighbors = []
		self.edges = []
		self.visited = False

	def add_neighbor(self, neighbor):
		if neighbor not in self.neighbors:
			self.neighbors.append(neighbor)
		neighbor.add_neighbor(self)

	def add_edge(self, edge):
		if edge not in self.edges:
			self.edges.append(edge)

	def connect_neighbor(self, neighbor):
		edge = Edge(self, neighbor)
		if edge not in self.edges:
			self.edges.append(edge)
		neigbor.add_edge(edge)

	def visit(self):
		self.visited = True

class Edge:
	def __init__(self, node1, node2):
		self.node1 = node1
		self.node2 = node2

	def __eq__(self, other):
		if isinstance(other, self.__class__):
			if (self.node1 == other.node1 and self.node2 == other.node2):
				return True
			elif (self.node1 == other.node2 and self.node2 == other.node1):
				return True
			return False


def parse_map(seed_file):
	x_dim = 5
	y_dim = 4
	map_array = []
	for y in range(y_dim):
		row = []
		for x in range(x_dim):
			node = Node(x, y)
			if x != 0:
				map_array[y][x-1].add_neighbor(node)
			if y != 0:
				map_array[y-1][x].add_neigbor(node)
			row.append(Node(x, y))
		map_array.append(row)



	with open(seed_file) as f:
		lines = f.readlines():
		for y in range(len(lines)):
			line_nodes = lines[y].split(',').trim();
			for x in range(len(line_nodes)):
				node_val = line_nodes[x]
				node = Node(x, y)
				"""