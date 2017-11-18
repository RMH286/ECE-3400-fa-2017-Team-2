
#include <Servo.h>
#include <StackArray.h>
//#include "FFT.h" // include the library
#include "radio.h"
#include "treasure.h"

static int dir = 0;
static int currentRow;
static int currentColumn;
#define NORTHWALL 1
#define EASTWALL 2
#define SOUTHWALL 4
#define WESTWALL 8
#define UNREACHABLE 16
#define VISITED 32
#define CURRENT 64
unsigned char maze[5][4] = 
      { {0, 0, 0, 0},
        {0, 0, 0, 0},
        {0, 0, 0, 0},
        {0, 0, 0, 0},
        {0, 0, 0, 0}
      };
unsigned char backTrack[20][2];
unsigned char backTrackPointer = 0;


Servo leftWheel;
Servo rightWheel;
//Front Right Line Sensor
int FRlinepin = A5;
//Front Left Line Sensor
int FLlinepin = A4;
//Back Right Line Sensor
int BRlinepin = A2;
//Back Left Line Sensor
int BLlinepin = A1;
int leftWheelpin = 5;
int rightWheelpin = 3;
//Front Wall Sensor
int wallpin = A0;
int treasurepin = A3;
//Wall Selector
int wallbit1 = 6;
int wallbit0 = 2;
int tbit0 = 7;
int tbit1 = 8;
int RED = 1;
int GREEN = 0;
int BLUE = 4;


//Wall MUX Pins Digital 2, 6
//000 Left Wall Sensor
//001 Front Wall Sensor
//010 Right Wall Sensor
//A0 is MUX Output

//Treasure MUX pins digital 7,8
//000 Left Treasure Sensor
//001 Front Treasure Sensor
//010 Right Treasure Sensor 
//A3 is MUX output


//Used to line follow, number to be written to right wheel servo.
int right = 0;

//Used to line follow, number to be written to left wheel servo.
int left = 180;

//turn left (still need to adjust the delay)
void turnLeft(){
  leftWheel.write(0);
  rightWheel.write(0);
  int FR = analogRead(FRlinepin);
  int FL = analogRead(FLlinepin);
  while(FR > 800 || FL > 800) {
    FR = analogRead(FRlinepin);
    FL = analogRead(FLlinepin);
  }
  while(FR < 800 || FL < 800) {
    FR = analogRead(FRlinepin);
    FL = analogRead(FLlinepin);
  }
  leftWheel.write(90);
  rightWheel.write(90); 
}


//turn right (still need to adjust the delay)
void turnRight(){
  leftWheel.write(180);
  rightWheel.write(180);
  int FR = analogRead(FRlinepin);
  int FL = analogRead(FLlinepin);
  while(FR > 800 || FL > 800) {
    FR = analogRead(FRlinepin);
    FL = analogRead(FLlinepin);
  }
  while(FR < 800 || FL < 800) {
    FR = analogRead(FRlinepin);
    FL = analogRead(FLlinepin);
  }
  leftWheel.write(90);
  rightWheel.write(90);
}


//check sensors to properly follow the line (DOES NOT WORK YET)
void moveForward(){
  //Front Right Line Sensor Value
  int FR = analogRead(FRlinepin);
  //Front Left Line Sensor Value
  int FL = analogRead(FLlinepin);

  if (FR > 800 && FL < 800) {
    right = 90;
  }
  else if (FR < 800 && FL > 800) {
    left = 90;
  }
  else {
    right = 0;
    left = 180;
  }
  leftWheel.write(left);
  rightWheel.write(right);
}

//check the line sensors for junctions.(NOT WRITTEN YET)
bool detectJunction(){
  int BR = analogRead(BRlinepin);
  int BL = analogRead(BLlinepin);
  if (BL>800 && BR>800){
    return true;
  }
  else{
    return false;
  }
}

void stepPastJunction() {
  leftWheel.write(180);
  rightWheel.write(0);
  int BR = analogRead(BRlinepin);
  int BL = analogRead(BLlinepin);
  while(BR > 800 || BL > 800) {
    BR = analogRead(BRlinepin);
    BL = analogRead(BLlinepin);
  }
  leftWheel.write(90);
  rightWheel.write(90);
}

bool detectLeftWall() {
  digitalWrite(wallbit1, LOW);
  digitalWrite(wallbit0, LOW);

  int wall = analogRead(wallpin);
  
  if (wall>250) {
    return true;
  }
  else {
    return false;
  }
}

bool detectFrontWall() {
  digitalWrite(wallbit1, LOW);
  digitalWrite(wallbit0, HIGH);
  
  
  int wall = analogRead(wallpin);
  
  if (wall>250) {
    return true;
  }
  else {
    return false;
  }
}

bool detectRightWall() {
  digitalWrite(wallbit1, HIGH);
  digitalWrite(wallbit0, LOW);

  int wall = analogRead(wallpin);
  
  if (wall>250) {
    return true;
  }
  else {
    return false;
  }
}
void check(){
  Serial.println(detectFrontWall());
  Serial.println(detectRightWall());
  Serial.println(detectLeftWall());
  if(detectFrontWall()){
    if(dir == 0){
      maze[currentRow][currentColumn] |= NORTHWALL;
    }
    else if(dir == 1){
      maze[currentRow][currentColumn] |= EASTWALL;
    }
    else if(dir == 2){
      maze[currentRow][currentColumn] |= SOUTHWALL;
    }
    else if(dir == 3){
      maze[currentRow][currentColumn] |= WESTWALL;
    } 
  }
  if(detectLeftWall()){
    if(dir == 0){
      maze[currentRow][currentColumn] |= WESTWALL;
    }
    else if(dir == 1){
      maze[currentRow][currentColumn] |= NORTHWALL;
    }
    else if(dir == 2){
      maze[currentRow][currentColumn] |= EASTWALL;
    }
    else if(dir == 3){
      maze[currentRow][currentColumn] |= SOUTHWALL;
    } 
  }
  if(detectRightWall()){
    if(dir == 0){
      maze[currentRow][currentColumn] |= EASTWALL;
    }
    else if(dir == 1){
      maze[currentRow][currentColumn] |= SOUTHWALL;
    }
    else if(dir == 2){
      maze[currentRow][currentColumn] |= WESTWALL;
    }
    else if(dir == 3){
      maze[currentRow][currentColumn] |= NORTHWALL;
    } 
  }
}

void possibleMove(){
  maze[currentRow][currentColumn] &= 0x3F;
  if((!(maze[currentRow][currentColumn] & NORTHWALL)) && (!(maze[currentRow-1][currentColumn] & VISITED))){
    backTrack[backTrackPointer][0] = currentRow;
    backTrack[backTrackPointer][1] = currentColumn;
    backTrackPointer += 1;
    moveNorth();
  }
  else if((!(maze[currentRow][currentColumn] & EASTWALL)) && (!(maze[currentRow][currentColumn+1] & VISITED))){
    backTrack[backTrackPointer][0] = currentRow;
    backTrack[backTrackPointer][1] = currentColumn;
    backTrackPointer += 1;
    moveEast();
  }
  else if((!(maze[currentRow][currentColumn] & SOUTHWALL)) && (!(maze[currentRow+1][currentColumn] & VISITED))){
    backTrack[backTrackPointer][0] = currentRow;
    backTrack[backTrackPointer][1] = currentColumn;
    backTrackPointer += 1;
    moveSouth();
  }
  else if((!(maze[currentRow][currentColumn] & WESTWALL)) && (!(maze[currentRow][currentColumn-1] & VISITED))){
    backTrack[backTrackPointer][0] = currentRow;
    backTrack[backTrackPointer][1] = currentColumn;
    backTrackPointer += 1;
    moveWest();
  }
  else{
    backTracks();
  }
  
}

void backTracks(){
  char prevRow = backTrack[backTrackPointer][0];
  char prevColumn = backTrack[backTrackPointer][1];
  if(prevRow == currentRow){
    if(prevColumn == currentColumn - 1){
      moveWest();
    }
    else{
      moveEast();
    }
  }
    else if(prevColumn == currentColumn){
      if(prevRow == currentRow - 1){
        moveNorth();
      }
      else{
        moveSouth();
      } 
  }
  backTrackPointer -=1;
}

 
void moveNorth(){
  Serial.println("Moving North");
  if(dir==0){
    while (detectJunction()==false){
      moveForward();
    }
    stepPastJunction();
  }
  if(dir==1){
    turnLeft();
    while (detectJunction()==false){
      moveForward();
    }
    stepPastJunction();
  }
  if(dir==2){
    turnLeft();
    turnLeft();
    while (detectJunction()==false){
      moveForward();
    }
    stepPastJunction();
  }
  if(dir==3){
    turnRight();
    while (detectJunction()==false){
      moveForward();
    }
    stepPastJunction();
  }
  dir = 0;
  currentRow -=1;
  maze[currentRow][currentColumn] |= VISITED;
}

void moveEast(){
  Serial.println("Moving East");
  if(dir==1){
    while (detectJunction()==false){
      moveForward();
    }
    stepPastJunction();
  }
  if(dir==2){
    turnLeft();
    while (detectJunction()==false){
      moveForward();
    }
    stepPastJunction();
  }
  if(dir==3){
    turnLeft();
    turnLeft();
    while (detectJunction()==false){
      moveForward();
    }
    stepPastJunction();
  }
  if(dir==0){
    turnRight();
    while (detectJunction()==false){
      moveForward();
    }
    stepPastJunction();
  }
  dir = 1;
  currentColumn += 1;
  maze[currentRow][currentColumn] |= VISITED;
  
}

void moveSouth(){
  Serial.println("Moving South");
  if(dir==2){
    while (detectJunction()==false){
      moveForward();
    }
    stepPastJunction();
  }
  if(dir==3){
    turnLeft();
    while (detectJunction()==false){
      moveForward();
    }
    stepPastJunction();
  }
  if(dir==0){
    turnLeft();
    turnLeft();
    while (detectJunction()==false){
      moveForward();
    }
    stepPastJunction();
  }
  if(dir==1){
    turnRight();
    while (detectJunction()==false){
      moveForward();
    }
    stepPastJunction();
  }
  dir = 2;
  currentRow +=1;
  maze[currentRow][currentColumn] |= VISITED;
}
void moveWest(){
  Serial.println("Moving West");
  if(dir==3){
    while (detectJunction()==false){
      moveForward();
    }
    stepPastJunction();
  }
  if(dir==0){
    turnLeft();
    while (detectJunction()==false){
      moveForward();
    }
    stepPastJunction();
  }
  if(dir==1){
    turnLeft();
    turnLeft();
    while (detectJunction()==false){
      moveForward();
    }
    stepPastJunction();
  }
  if(dir==2){
    turnRight();
    while (detectJunction()==false){
      moveForward();
    }
    stepPastJunction();
  }
  dir = 3;
  currentColumn -= 1;
  maze[currentRow][currentColumn] |= VISITED;
}

void setup() {
  // put your setup code here, to run once:
  pinMode(FRlinepin, INPUT);
  pinMode(FLlinepin, INPUT);
  pinMode(BRlinepin, INPUT);
  pinMode(BLlinepin, INPUT);
  pinMode(wallpin, INPUT);
  pinMode(treasurepin, INPUT);
  pinMode(wallbit0, OUTPUT);
  pinMode(wallbit1, OUTPUT);
  pinMode(tbit0, OUTPUT);
  pinMode(tbit1, OUTPUT);
  pinMode(RED, OUTPUT);
  pinMode(GREEN, OUTPUT);
  pinMode(BLUE, OUTPUT);
  
  Serial.begin(9600);          //  setup serial

  pinMode(4, OUTPUT);
  leftWheel.attach(leftWheelpin);
  rightWheel.attach(rightWheelpin);
  leftWheel.write(90);
  rightWheel.write(90);
  currentRow = 4;
  currentColumn = 3; 
  dir = 0;
  radio_setup();
  treasure_setup();
  
  
  
  
  StackArray<int> stack;


}

void loop() {
  // put your main code here, to run repeatedly:
//  Serial.println(digitalRead(buttonpin));
//  while(digitalRead(buttonpin)==0){
//    Serial.println("Button Not Pressed");
//  }
  maze[4][3] |= (CURRENT) | (VISITED);
  check();
  Serial.print("direction ");
  Serial.println(dir);
  Serial.println(currentRow);
  Serial.println(currentColumn);
  Serial.println(maze[currentRow][currentColumn]);
  possibleMove();
  while(backTrackPointer != 0){
    check();
    Serial.print("direction ");
    Serial.println(dir);
    Serial.print("Row, Column:");
    Serial.print(currentRow);
    Serial.println(currentColumn);
    Serial.println(maze[currentRow][currentColumn]);
    possibleMove();
  }
  while(1){
    digitalWrite(4, HIGH);    
  }

  
 
   
  
  
}
