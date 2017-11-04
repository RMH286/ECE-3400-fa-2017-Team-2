import Tkinter
import bit_map
import time
import random

NODE_WIDTH = 80
NODE_HEIGHT = 80
NUM_ROWS = 5
NUM_COLUMNS = 4

class MazeGUI(Tkinter.Frame):
	def __init__(self):
		Tkinter.Frame.__init__(self)
		self.num_seeds = 5 
		self.seed = 0
		self.maze = bit_map.parse_map('seed{}.txt'.format(self.seed))
		self.grid()
		self.create_widgets()
		self.init_maze()

	def create_widgets(self):
		self.canvas = Tkinter.Canvas(self, width=NUM_COLUMNS*NODE_WIDTH+4, height=NUM_ROWS*NODE_HEIGHT+4)
		self.canvas.grid(row=0, column=0, rowspan=3)
		self.explore_button = Tkinter.Button(self, text='Explore', command=self.explore)
		self.explore_button.grid(row=0, column=1)
		self.reset_button = Tkinter.Button(self, text='Reset', command=self.reset)
		self.reset_button.grid(row=1, column=1)
		self.seed_button = Tkinter.Button(self, text='Next Seed', command=self.next_seed)
		self.seed_button.grid(row=2, column=1)

	def init_maze(self):
		self.drawn_nodes = []
		for row in range(NUM_ROWS):
			drawn_row = []
			for column in range(NUM_COLUMNS):
				x0 = column * NODE_WIDTH + 4
				y0 = row * NODE_HEIGHT + 4
				x1 = x0 + NODE_WIDTH
				y1 = y0 + NODE_HEIGHT
				node = self.maze[row][column]
				if (node & 0b0100000): # visited
					color = 'deep sky blue'
				elif (node & 0b0010000): # unreachable
					color = 'Coral1'
				elif (node & 0b1000000): # current locationi
					color = 'SeaGreen1'
				else:
					color = 'white'
				node_id = self.canvas.create_rectangle(x0, y0, x1, y1, width=0, fill=color, outline='gray')
				drawn_row.append(node_id)
				self.canvas.create_line(x0, y1-NODE_HEIGHT/2, x1, y1-NODE_HEIGHT/2, dash=True, fill='grey')
				self.canvas.create_line(x1-NODE_WIDTH/2, y0, x1-NODE_WIDTH/2, y1, dash=True, fill='grey')
			self.drawn_nodes.append(drawn_row)

		for row in range(NUM_ROWS):
			for column in range(NUM_COLUMNS):
				x0 = column * NODE_WIDTH + 4
				y0 = row * NODE_HEIGHT + 4
				x1 = x0 + NODE_WIDTH
				y1 = y0 + NODE_HEIGHT
				walls = self.maze[row][column]
				if (walls & 0b0001): # north wall
					self.canvas.create_line(x0-2, y0, x1+2, y0, width=4, fill='black')
				if (walls & 0b0010): # south wall
					self.canvas.create_line(x0-2, y1, x1+2, y1, width=4, fill='black')
				if (walls & 0b0100): # east wall
					self.canvas.create_line(x1, y0-2, x1, y1+2, width=4, fill='black')
				if (walls & 0b1000): # west wall
					self.canvas.create_line(x0, y0-2, x0, y1+2, width=4, fill='black')

	def update_maze(self):
		for row in range(NUM_ROWS):
			for column in range(NUM_COLUMNS):
				node = self.maze[row][column]
				color = 'white'
				if (node & 0b0100000): # visited
					color = 'deep sky blue'
				if (node & 0b0010000): # unreachable
					color = 'Coral1'
				if (node & 0b1000000): # current location
					color = 'SeaGreen1'
				self.canvas.itemconfig(self.drawn_nodes[row][column], fill=color)
		self.canvas.update_idletasks()

	def explore(self):
		current_row = NUM_ROWS -1 
		current_column = NUM_COLUMNS - 1
		self.maze[current_row][current_column] |= 0b1100000 # start in bottom right
		self.update_maze()
		backtrack = []
		possible_moves = []
		walls = self.maze[current_row][current_column]
		if (not walls & 0b0001) and (not self.maze[current_row-1][current_column] & 0b0100000): # no north wall and unvisted
			possible_moves.append(0b0001)
		if (not walls & 0b0010) and (not self.maze[current_row+1][current_column] & 0b0100000): # no south wall and unvisted
			possible_moves.append(0b0010)
		if (not walls & 0b0100) and (not self.maze[current_row][current_column+1] & 0b0100000): # no east wall and unvisted
			possible_moves.append(0b0100)
		if (not walls & 0b1000) and (not self.maze[current_row][current_column-1] & 0b0100000): # no west wall and unvisted
			possible_moves.append(0b1000)
		time.sleep(.1)

		while(len(backtrack) != 0 or len(possible_moves) != 0):

			# no more moves ahead -> backtrack
			if (len(possible_moves) == 0):
				self.maze[current_row][current_column] &= 0b0111111
				prev_node = backtrack[-1]
				backtrack.pop()
				current_row = prev_node[0]
				current_column = prev_node[1]
				self.maze[current_row][current_column] |= 0b1100000
				self.update_maze()
				time.sleep(.1)

			else:
				# move in random direction
				next_move = random.choice(possible_moves)
				self.maze[current_row][current_column] &= 0b0111111
				backtrack.append((current_row, current_column))
				if (next_move == 0b0001):
					current_row -= 1
				elif (next_move == 0b0010):
					current_row += 1
				elif (next_move == 0b0100):
					current_column += 1
				elif (next_move == 0b1000):
					current_column -= 1
				self.maze[current_row][current_column] |= 0b1100000
				self.update_maze()
				time.sleep(.1)

			# find possible moves
			del possible_moves[:]
			walls = self.maze[current_row][current_column]
			if (not walls & 0b0001) and (not self.maze[current_row-1][current_column] & 0b0100000): # no north wall and unvisted
				possible_moves.append(0b0001)
			if (not walls & 0b0010) and (not self.maze[current_row+1][current_column] & 0b0100000): # no south wall and unvisted
				possible_moves.append(0b0010)
			if (not walls & 0b0100) and (not self.maze[current_row][current_column+1] & 0b0100000): # no east wall and unvisted
				possible_moves.append(0b0100)
			if (not walls & 0b1000) and (not self.maze[current_row][current_column-1] & 0b0100000): # no west wall and unvisted
				possible_moves.append(0b1000)

		for row in range(NUM_ROWS):
			for column in range(NUM_COLUMNS):
				if (not self.maze[row][column] & 0b0100000): # unvisited
					self.maze[row][column] |= 0b0010000
		self.update_maze()
		
		self.done_sign = Tkinter.Label(text="Done Exploring!")
		self.done_sign.grid(columnspan = 1)

	def reset(self):
		self.maze = bit_map.parse_map('seed{}.txt'.format(self.seed))
		self.init_maze()

	def next_seed(self):
		self.seed = (self.seed + 1) % self.num_seeds
		self.maze = bit_map.parse_map('seed{}.txt'.format(self.seed))
		self.init_maze()

	def create_events(self):
		self.canvas.bind_all('<KeyPress-Up>', self.explore)



if __name__ == '__main__':
	#top = tkinter.Tk()
	maze_gui = MazeGUI()
	maze_gui.master.title("Maze Exploration")
	maze_gui.mainloop()
#w = Canvas(master, width=20, height=20, bg='white' )