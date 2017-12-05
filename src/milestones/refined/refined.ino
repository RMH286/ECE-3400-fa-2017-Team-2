#include <Servo.h>
#include "radio.h"

#define NORTHWALL 0x01
#define SOUTHWALL 0X02
#define EASTWALL 0x04
#define WESTWALL 0x08
#define UNREACHABLE 0x10
#define VISITED 0x20
#define SEVEN_TREASURE 0x40
#define TWELVE_TREASURE 0x80
#define SEVENTEEN_TREASURE 0xc0

enum DIRECTION {
  north,
  south,
  east,
};

unsigned char maze[5][4] =
      { {0, 0, 0, 0},  west

        {0, 0, 0, 0},
        {0, 0, 0, 0},
        {0, 0, 0, 0},
        {0, 0, 0, 0}
      };
unsigned int possible_moves_maze[5][4] =
      { {0, 0, 0, 0},
        {0, 0, 0, 0},
        {0, 0, 0, 0},
        {0, 0, 0, 0},
        {0, 0, 0, 0}
       };
int backtrack[20];
int backtrack_pointer;
bool backtracking;

enum DIRECTION dir;
int current_row;
int current_column;

// line sensors
int fr_linepin = A4;
int fl_linepin = A3;
int br_linepin = A2;
int bl_linepin = A1;

// wall and treasure sensors
int mux_pin = A0;
// mux select bits;
int mux_s0 = 2;
int mux_s1 = 3;
int mux_s2 = 4;
int LED = 8;
int BUTTON = 7;

// servos
Servo left_wheel;
Servo right_wheel;
int left_wheelpin = 5;
int right_wheelpin = 6;

int right_pwm;
int left_pwm;

void turn_left() {
  Serial.println("turning left");
  left_wheel.write(0);
  right_wheel.write(0);
  int fr = analogRead(fr_linepin);
  int fl = analogRead(fl_linepin);
  while (fr > 800 || fl > 800) {
    fr = analogRead(fr_linepin);
    fl = analogRead(fl_linepin);
  }
  while (fr < 800 || fl < 800) {
    fr = analogRead(fr_linepin);
    fl = analogRead(fl_linepin);
  }
  left_wheel.write(90);
  right_wheel.write(90);
}

void turn_right() {
  left_wheel.write(180);
  right_wheel.write(180);
  int fr = analogRead(fr_linepin);
  int fl = analogRead(fl_linepin);
  while (fr > 800 || fl > 800) {
    fr = analogRead(fr_linepin);
    fl = analogRead(fl_linepin);
  }
  while (fr < 800 || fl < 800) {
    fr = analogRead(fr_linepin);
    fl = analogRead(fl_linepin);
  }
  left_wheel.write(90);
  right_wheel.write(90);
}

void move_forward() {
  while (!detect_junction()) {
    int fr = analogRead(fr_linepin);
    int fl = analogRead(fl_linepin);

    if (fr > 800 && fl < 800) {
      right_pwm = 90;
    }
    else if (fr < 800 && fl > 800) {
      left_pwm = 90;
    }
    else {
      right_pwm = 0;
      left_pwm = 180;
    }
    right_wheel.write(right_pwm);
    left_wheel.write(left_pwm);
  }
  step_past_junction();
}

bool detect_junction() {
  int br = analogRead(br_linepin);
  int bl = analogRead(bl_linepin);
  if (br > 800 && bl > 800) {
    Serial.println("detect junction");
    return true;
  }
  return false;
}

void step_past_junction() {
  right_wheel.write(0);
  left_wheel.write(180);
  int br = analogRead(br_linepin);
  int bl = analogRead(bl_linepin);
  while (br > 800 || bl > 800) {
    br = analogRead(br_linepin);
    bl = analogRead(bl_linepin);
  }
  right_wheel.write(90);
  left_wheel.write(90);
}

bool left_wall() {
  digitalWrite(mux_s2, LOW);
  digitalWrite(mux_s1, LOW);
  digitalWrite(mux_s0, LOW);

  int wall = analogRead(mux_pin);
  
  if (wall>250) {
    return true;
  }
  else {
    return false;
  }
}

bool front_wall() {
  digitalWrite(mux_s2, LOW);
  digitalWrite(mux_s1, LOW);
  digitalWrite(mux_s0, HIGH);

  int wall = analogRead(mux_pin);
  
  if (wall>250) {
    return true;
  }
  else {
    return false;
  }
}

bool right_wall() {
  digitalWrite(mux_s2, LOW);
  digitalWrite(mux_s1, HIGH);
  digitalWrite(mux_s0, LOW);

  int wall = analogRead(mux_pin);
  
  if (wall>250) {
    return true;
  }
  else {
    return false;
  }
}

void update_node() {
  switch(dir) {
    case(north):
      if (left_wall()) { maze[current_row][current_column] |= WESTWALL; }
      if (front_wall()) { maze[current_row][current_column] |= NORTHWALL; }
      if (right_wall()) { maze[current_row][current_column] |= EASTWALL; }
      break;
    case(south):
      if (left_wall()) { maze[current_row][current_column] |= EASTWALL; }
      if (front_wall()) { maze[current_row][current_column] |= SOUTHWALL; }
      if (right_wall()) { maze[current_row][current_column] |= WESTWALL; }
      break;
    case(east):
      if (left_wall()) { maze[current_row][current_column] |= NORTHWALL; }
      if (front_wall()) { maze[current_row][current_column] |= EASTWALL; }
      if (right_wall()) { maze[current_row][current_column] |= SOUTHWALL; }
      break;
    case(west):
      if (left_wall()) { maze[current_row][current_column] |= SOUTHWALL; }
      if (front_wall()) { maze[current_row][current_column] |= WESTWALL; }
      if (right_wall()) { maze[current_row][current_column] |= NORTHWALL; }
      break;
  }
  //int treasure = detect_treasure();
  //Serial.println(treasure);
  //treasure = treasure << 6;
//  maze[current_row][current_column] |= treasure;
    Serial.println(maze[current_row][current_column]);
    transmit_node(maze[current_row][current_column], current_row, current_column);
//  if(treasure!=0){
//    digitalWrite(LED, HIGH);
//    delay(500);
//    digitalWrite(LED, LOW);
//    Serial.print("treasure");
//    Serial.println(treasure);
//  }
  Serial.print("Row: ");
  Serial.print(current_row);
  Serial.print(" Column: ");
  Serial.print(current_column);
  Serial.print("NorthWall: ");
  Serial.print(maze[current_row][current_column] & NORTHWALL);
  Serial.print("SouthWall: ");
  Serial.print(maze[current_row][current_column] & SOUTHWALL);
  Serial.print("EastWall: ");
  Serial.print(maze[current_row][current_column] & EASTWALL);
  Serial.print("WestWall: ");
  Serial.println(maze[current_row][current_column] & WESTWALL);
  }

int next_move() {
  int possible_moves[5] = {0, 0, 0, 0, 0};
  int num_moves = 0;
  if((!(maze[current_row][current_column] & NORTHWALL)) && (!(maze[current_row-1][current_column] & VISITED))){
    possible_moves[north] = 1;
    possible_moves_maze[current_row-1][current_column] = 1;
    num_moves += 1;
  }
  if((!(maze[current_row][current_column] & SOUTHWALL)) && (!(maze[current_row+1][current_column] & VISITED))){
    possible_moves[south] = 1;
    possible_moves_maze[current_row+1][current_column] = 1;
    num_moves += 1;
  }
  if((!(maze[current_row][current_column] & EASTWALL)) && (!(maze[current_row][current_column+1] & VISITED))){
    possible_moves[east] = 1;
    possible_moves_maze[current_row][current_column+1] = 1;
    num_moves += 1;
  }
  if((!(maze[current_row][current_column] & WESTWALL)) && (!(maze[current_row][current_column-1] & VISITED))){
    possible_moves[west] = 1;
    possible_moves_maze[current_row][current_column-1] = 1;
    num_moves += 1;
  }
  if (num_moves == 0) {
    possible_moves[4] = 1;
  }
  Serial.print("Possible Moves: ");
  Serial.print(possible_moves[4]);
  Serial.print(possible_moves[3]);
  Serial.print(possible_moves[2]);
  Serial.print(possible_moves[1]);
  Serial.print(possible_moves[0]);
  Serial.print("\n");
  Serial.println(dir);
  int next_move = best_move(possible_moves);
  Serial.println(next_move);
  return next_move;
}

int best_move(int *possible_moves) {
  if (possible_moves[4]) {
    backtracking = true;
    int done = 1;
    for (int x = 0; x < 4; x++) {
      for (int y = 0; y < 5; y++) {
        if ((possible_moves_maze[y][x])) {
          done = 0;
        }
      }
    }
    if (done) { return -1; }
    Serial.print("backtracking");
    Serial.println(backtrack_pointer);
    Serial.println(backtrack[backtrack_pointer]);
    Serial.println(backtrack[backtrack_pointer-1]);
    Serial.println(backtrack[backtrack_pointer-2]);
    int next_move = backtrack[backtrack_pointer];
    Serial.print("NEXT move: ");
    Serial.println(next_move);
    return next_move;
  }
  switch (dir) {
    case(north):
      if (possible_moves[north]) { return north; }
      else if (possible_moves[east]) { return east; }
      else if (possible_moves[west]) { return west; }
      else if (possible_moves[south]) { return south; }
      break;
    case(south):
      if (possible_moves[south]) { return south; }
      else if (possible_moves[west]) { return west; }
      else if (possible_moves[east]) { return east; }
      else if (possible_moves[north]) { return north; }
      break;
    case(east):
      if (possible_moves[east]) { return east; }
      else if (possible_moves[south]) { return south; }
      else if (possible_moves[north]) { return north; }
      else if (possible_moves[west]) { return west; }
      break;
    case(west):
      if (possible_moves[west]) { return west; }
      else if (possible_moves[north]) { return north; }
      else if (possible_moves[south]) { return south; }
      else if (possible_moves[east]) { return east; }
      break;
  }
}

int onward() {
  Serial.println("onward");
  int next = next_move();
  if (next == north) { move_north(); }
  else if (next == south) { move_south(); }
  else if (next == east) { move_east(); }
  else if (next == west) { move_west(); }
  return next;
}

void move_north() {
  Serial.println("moving north");
  switch (dir) {
    case(north):
      Serial.println("in case north");
      move_forward();
      break;
    case(south):
      turn_left();
      turn_left();
      move_forward();
      break;
    case(east):
      turn_left();
      move_forward();
      break;
    case(west):
      turn_right();
      move_forward();
      break;
  }
  dir = north;
  current_row -= 1;
  maze[current_row][current_column] |= VISITED;
  possible_moves_maze[current_row][current_column] = 0;
  if(backtracking==false){
    backtrack_pointer +=1;
    backtrack[backtrack_pointer] = south;
  }
  else{
    backtrack_pointer -= 1;
  }
  backtracking = false;
}

void move_south() {
  switch (dir) {
    case(south):
      move_forward();
      break;
    case(north):
      turn_left();
      turn_left();
      move_forward();
      break;
    case(west):
      turn_left();
      move_forward();
      break;
    case(east):
      turn_right();
      move_forward();
      break;
  }
  dir = south;
  current_row += 1;
  maze[current_row][current_column] |= VISITED;
  possible_moves_maze[current_row][current_column] = 0;
  if(backtracking==false){
    backtrack_pointer +=1;
    backtrack[backtrack_pointer] = north;
  }
  else{
    backtrack_pointer -= 1;
  }
  backtracking = false;
}

void move_east() {
  switch (dir) {
    case(east):
      move_forward();
      break;
    case(west):
      turn_left();
      turn_left();
      move_forward();
      break;
    case(north):
      turn_right();
      move_forward();
      break;
    case(south):
      turn_left();
      move_forward();
      break;
  }
  dir = east;
  current_column += 1;
  maze[current_row][current_column] |= VISITED;
  possible_moves_maze[current_row][current_column] = 0;
  if(backtracking==false){
    backtrack_pointer +=1;
    backtrack[backtrack_pointer] = west;
  }
  else{
    backtrack_pointer -= 1;
  }
  backtracking = false;
}

void move_west() {
  Serial.println("moving west");
  switch (dir) {
    case(west):
      move_forward();
      break;
    case(east):
      turn_left();
      turn_left();
      move_forward();
      break;
    case(south):
      turn_right();
      move_forward();
      break;
    case(north):
      turn_left();
      move_forward();
      break;
  }
  dir = west;
  current_column -= 1;
  maze[current_row][current_column] |= VISITED;
  possible_moves_maze[current_row][current_column] = 0;
  if(backtracking==false){
    backtrack_pointer +=1;
    backtrack[backtrack_pointer] = east;
  }
  else{
    backtrack_pointer -= 1;
  }
  backtracking = false;
}

void setup() {
  // put your setup code here, to run once:

  pinMode(fr_linepin, INPUT);
  pinMode(fl_linepin, INPUT);
  pinMode(br_linepin, INPUT);
  pinMode(bl_linepin, INPUT);
  pinMode(mux_pin, INPUT);
  pinMode(mux_s2, OUTPUT);
  pinMode(mux_s1, OUTPUT);
  pinMode(mux_s0, OUTPUT);
  pinMode(LED, OUTPUT);
  pinMode(BUTTON, INPUT);
  
  Serial.begin(9600);          //  setup serial

  left_wheel.attach(left_wheelpin);
  right_wheel.attach(right_wheelpin);
  left_wheel.write(90);
  right_wheel.write(90);
  current_row = 4;
  current_column = 3; 
  maze[current_row][current_column] |= SOUTHWALL;
  dir = north;
  radio_setup();
}

void loop() {
  // put your main code here, to run repeatedly:
  while (1) {
    Serial.println("in while");
    if (digitalRead(BUTTON) == HIGH) {
      break;
    }
  }

  maze[4][3] |= VISITED;
  update_node();
  while (onward() != -1) {
    update_node();
  }
  while(1){
    transmit_node(maze[current_row][current_column], 255,255);
  }

//  }

  
  
}
