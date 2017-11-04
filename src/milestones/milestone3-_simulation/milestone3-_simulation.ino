
#include <Servo.h>
#include <StackArray.h>

int dir;
int currentRow;
int currentColumn;
unsigned char maze[4][5] = 
      { 0, 0, 0, 0,
        0, 0, 0, 0,
        0, 0, 0, 0,
        0, 0, 0, 0,
        0, 0, 0, 0,
      };
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
int leftWheelpin = 3;
int rightWheelpin = 5;
//Front Wall Sensor
int wallpin = A0;
//Wall Selector
int wallbit2 = 7;
int wallbit1 = 6;
int wallbit0 = 2;


//MUX Pins Digital 2, 6, 7
//000 Left Wall Sensor
//001 Front Wall Sensor
//010 Right Wall Sensor
//A0 is MUX Output


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
  dir = (dir - 1)%4; 
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
  dir = (dir + 1)%4; 
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
  Serial.println(FR);
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
}

bool detectLeftWall() {

  digitalWrite(wallbit2, LOW);
  digitalWrite(wallbit1, LOW);
  digitalWrite(wallbit0, LOW);

  int wall = analogRead(wallpin);
  
  if (wall>400) {
    return true;
  }
  else {
    return false;
  }
}

bool detectFrontWall() {

  digitalWrite(wallbit2, LOW);
  digitalWrite(wallbit1, LOW);
  digitalWrite(wallbit0, HIGH);

  int wall = analogRead(wallpin);
  
  if (wall>400) {
    return true;
  }
  else {
    return false;
  }
}

bool detectRightWall() {

  digitalWrite(wallbit2, LOW);
  digitalWrite(wallbit1, HIGH);
  digitalWrite(wallbit0, LOW);

  int wall = analogRead(wallpin);
  
  if (wall>400) {
    return true;
  }
  else {
    return false;
  }
}
void check(){
  maze[currentRow][currentColumn] = 1;
  if(detectFrontWall()==false){
    addNodes();
  }
  else if(detectLeftWall()==false){
    turnLeft();
    addNodes();
  }
  else if(detectRightWall()==false){
    turnRight();
    addNodes();
  }
  else
}

void addNodes(){
 
    if (dir==0 & maze[currentRow-1][currentColumn] = 0){
      moveForward();
      maze[currentRow][currentColumn] = 2;
      currentRow = currentRow-1;
    }
    if (dir==1 & maze[currentRow][currentColumn+1] = 0){
      moveForward();
      maze[currentRow][currentColumn] = 2;
      currentColumn = currentColumn+1;
    }
    if (dir==2 & maze[currentRow+][currentColumn] = 0){
      moveForward();
      maze[currentRow][currentColumn] = 2;
      currentRow = currentRow+1;
    }
    if (dir==3 & maze[currentRow][currentColumn-1] = 0){
      moveForward();
      maze[currentRow][currentColumn] = 2;
      currentColumn = currentColumn-1;
    }

}

void setup() {
  // put your setup code here, to run once:
  pinMode(FRlinepin, INPUT);
  pinMode(FLlinepin, INPUT);
  pinMode(BRlinepin, INPUT);
  pinMode(BLlinepin, INPUT);
  pinMode(wallpin, INPUT);
  
  Serial.begin(9600);          //  setup serial

  leftWheel.attach(leftWheelpin);
  rightWheel.attach(rightWheelpin);
  currentRow = 4;
  currentColumn = 3; 
  dir = 0;
  
  StackArray<int> stack;


}

void loop() {
  // put your main code here, to run repeatedly:
  
  
}
