#include <SPI.h>

// SCK = 13
// MISO = 12
// MOSI = 11
// SS = 4 

#define speed 100

void setup() {

  int SS = 4;
  pinMode( SS, OUTPUT);
  // put your setup code here, to run once:
  digitalWrite(SS, HIGH); // ensures SS stays high
  //SPI.beginTransaction(SPISettings(speed, MSBFIRST, SPI_MODE0));
  SPI.begin();
} // end setup

void loop() {
  // put your main code here, to run repeatedly:
                                                            
  int value;

  //digitalWrite(SS, LOW); // SS pin is 4
  //x = 0x00 << 6;
  //y = 0x00 << 3;
  //coord = x | y;
  //SPI.transfer(coord);
  //digitalWrite(SS, HIGH);

  
  digitalWrite(SS, LOW); // SS pin is 4
  value = 0001001100001110;
  SPI.transfer(value);
  digitalWrite(SS, HIGH);

  delay(500);

 digitalWrite(SS, LOW); // SS pin is 4
  value = 0000111100001100;
  SPI.transfer(value);
  digitalWrite(SS, HIGH);

  delay(500);
   digitalWrite(SS, LOW); // SS pin is 4
  value = 0000101100000101;
  SPI.transfer(value);
  digitalWrite(SS, HIGH);

  delay(500);
   digitalWrite(SS, LOW); // SS pin is 4
  value = 0000101000001011;
  SPI.transfer(value);
  digitalWrite(SS, HIGH);

  delay(500);
  
} // end of loop
