"""
0b____ represents a node

0th bit represents the north wall
1st bit represents the south wall
2nd bit represents the east wall
3rd bit represents the west wall
4th bit represents that the node is unreachable
5th bit represents that the node has been visited
6th bit represents that robot is currently at the node

A 1 in the bit location denotes a wall is present

Example:
	0b0110 = 6 is a node with a south and east wall

A map is represented as a 2-dimensional array
Each entry in the highest level array is a row in the map
Each entry in a row array is a node in the map
"""

def parse_map(seedfile):
	map_array = []
	with open(seedfile) as f:
		for line in f.readlines():
			row = []
			for node in line.split(','):
				row.append(int(node, base=2))
			map_array.append(row)
	return map_array