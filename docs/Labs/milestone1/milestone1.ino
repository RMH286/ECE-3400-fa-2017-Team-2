

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


enum State {
  Start,
  Junction,
  Forward
};


//State variable 
enum State state = Start;

//Keeps Track of where in the figure 8 we are
int turnCount = 0;

//If true, we are making right turns, if false we make left turns
bool rightTurn = true;

//Used to line follow, number to be written to right wheel servo.
int right = 0;

//Used to line follow, number to be written to left wheel servo.
int left = 180;



//turn left (still need to adjust the delay)
void turnLeft(){
  leftWheel.write(180);
  rightWheel.write(180);
  delay(500);
  leftWheel.write(90);
  rightWheel.write(90);
  
}


//turn right (still need to adjust the delay)
void turnRight(){
  leftWheel.write(0);
  rightWheel.write(0);
  delay(500);
  leftWheel.write(90);
  rightWheel.write(90);
  
}


//check sensors to properly follow the line (DOES NOT WORK YET)
void moveForward(){
  leftWheel.write(0);
  rightWheel.write(180);
  //Front Right Line Sensor Value
  int FR = analogRead(FRlinepin);
  //Front Left Line Sensor Value
  int FL = analogRead(FLlinepin);
  leftWheel.write(left);
  rightWheel.write(right);
  //after looking at serial monitor values, chose a value to initiate when adjustments need to be made.
  if(FR<880){
    left = left +1;
  }
  if(FL<960){
    right = right-1;
  }
}

//check the line sensors for junctions.(NOT WRITTEN YET)
bool detectJunction(){

}




// the setup function runs once when you press reset or power the board
void setup() {
  // initialize inputs
  pinMode(FRlinepin, INPUT);
  pinMode(FLlinepin, INPUT);
  pinMode(BRlinepin, INPUT);
  pinMode(BLlinepin, INPUT);
  
  Serial.begin(9600);          //  setup serial

  leftWheel.attach(leftWheelpin);
  rightWheel.attach(rightWheelpin);
}




// the loop function runs over and over again forever
void loop() {
//the first turn in the figure 8 should be a left turn. 
  if (state==Start){
    moveForward();
    if(detectJunction()==true){
      turnLeft();
      state = Forward;
    }
    
  }
//turn at a junction
  else if (state==Junction){
    //turn right or left depending on the turn count, a figure 8 is 4 right turns followed by 4 left turns.
    if(turnCount<4){
      if(rightTurn==true){
        turnRight();
        turnCount = turnCount + 1;
      }
      else{
        turnLeft();
        turnCount = turnCount +1;
      }
    }
    //if 4 left or right turns have been completed, turn the other way next time.
    else{
      if(rightTurn==true){
        turnRight();
        rightTurn = false;
        turnCount = 0;
      }
      else{
        turnLeft();
        rightTurn = true;
        turnCount = 0;
      }
    }
    
  }
//move forward unless a junction is detected.
  else if (state==Forward){
    moveForward();
    delay(500);
    if(detectJunction()==true){
      state = Junction;
    }
    
  }
  
}
