
#include <Servo.h>

Servo leftWheel;
Servo rightWheel;
//Front Right Line Sensor
int FRlinepin = A5;
//Front Left Line Sensor
int FLlinepin = A0;
//Back Right Line Sensor
int BRlinepin = A2;
//Back Left Line Sensor
int BLlinepin = A1;
int leftWheelpin = 3;
int rightWheelpin = 5;

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

void setup() {
  // put your setup code here, to run once:
  pinMode(FRlinepin, INPUT);
  pinMode(FLlinepin, INPUT);
  pinMode(BRlinepin, INPUT);
  pinMode(BLlinepin, INPUT);
  
  Serial.begin(9600);          //  setup serial

  leftWheel.attach(leftWheelpin);
  rightWheel.attach(rightWheelpin);

}

void loop() {
  // put your main code here, to run repeatedly:
  while (detectJunction()==false){
    moveForward();
  }
  stepPastJunction();
  turnLeft();
  while (detectJunction()==false){
    moveForward();
  }
  stepPastJunction();
  turnRight();
  while (detectJunction()==false){
    moveForward();
  }
  stepPastJunction();
  turnRight();
  while (detectJunction()==false){
    moveForward();
  }
  stepPastJunction();
  turnRight();
  while (detectJunction()==false){
    moveForward();
  }
  stepPastJunction();
  turnRight();
  while (detectJunction()==false){
    moveForward();
  }
  stepPastJunction();
  turnLeft();
  while (detectJunction()==false){
    moveForward();
  }
  stepPastJunction();
  turnLeft();
  while (detectJunction()==false){
    moveForward();
  }
  stepPastJunction();
  turnLeft();
}
