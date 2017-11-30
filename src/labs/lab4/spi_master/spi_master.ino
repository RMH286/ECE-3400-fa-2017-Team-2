#include <SPI.h>

// SCK = 13
// MISO = 12
// MOSI = 11
// FPGASS = 4 

#define speed 100
#define FPGASS 4

void setup() {

  pinMode( FPGASS, OUTPUT);
  // put your setup code here, to run once:
  digitalWrite(FPGASS, HIGH); // ensures SS stays high
  digitalWrite(SS, HIGH);
  //SPI.beginTransaction(SPISettings(20000000, MSBFIRST, SPI_MODE0));
  SPI.begin();
} // end setup

void loop() {
  // put your main code here, to run repeatedly:
                                                            
  int value;

  //digitalWrite(FPGASS, LOW); // FPGASS pin is 4
  //x = 0x00 << 6;
  //y = 0x00 << 3;
  //coord = x | y;
  //SPI.transfer(coord);
  //digitalWrite(FPGASS, HIGH);

  
  digitalWrite(FPGASS, LOW); // FPGASS pin is 4
  value = 0b0001001100001110;
  SPI.transfer16(value);
  digitalWrite(FPGASS, HIGH);

  delay(500);

 digitalWrite(FPGASS, LOW); // FPGASS pin is 4
  value = 0b0000111100001100;
  SPI.transfer16(value);
  digitalWrite(FPGASS, HIGH);

  delay(500);
   digitalWrite(FPGASS, LOW); // FPGASS pin is 4
  value = 0b0000101100000101;
  SPI.transfer16(value);
  digitalWrite(FPGASS, HIGH);

  delay(500);
   digitalWrite(FPGASS, LOW); // FPGASS pin is 4
  value = 0b0000101000001011;
  SPI.transfer16(value);
  digitalWrite(FPGASS, HIGH);

  delay(500);
  
} // end of loop
