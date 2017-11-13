#include <SPI.h>

// SCK = 13
// MISO = 12
// MOSI = 11
// SS = 10

#define speed 100

void setup() {
  // put your setup code here, to run once:
  digitalWrite(SS, HIGH); // ensures SS stays high
  //SPI.beginTransaction(SPISettings(speed, MSBFIRST, SPI_MODE0));
  SPI.begin();
} // end setup

void loop() {
  // put your main code here, to run repeatedly:
  byte coord;
  byte x;
  byte y;

  //digitalWrite(SS, LOW); // SS pin is 10
  //x = 0x00 << 6;
  //y = 0x00 << 3;
  //coord = x | y;
  //SPI.transfer(coord);
  //digitalWrite(SS, HIGH);

  delay(500);
  
  digitalWrite(SS, LOW); // SS pin is 10
  x = 0x00 << 6;
  y = 0x01 << 3;
  coord = x | y;
  SPI.transfer(coord);
  digitalWrite(SS, HIGH);

  delay(500);

  digitalWrite(SS, LOW); // SS pin is 10
  x = 0x01 << 6;
  y = 0x01 << 3;
  coord = x | y;
  SPI.transfer(coord);
  digitalWrite(SS, HIGH);

  delay(500);

  digitalWrite(SS, LOW); // SS pin is 10
  x = 0x02 << 6;
  y = 0x01 << 3;
  coord = x | y;
  SPI.transfer(coord);
  digitalWrite(SS, HIGH);

  delay(500);

  digitalWrite(SS, LOW); // SS pin is 10
  x = 0x03 << 6;
  y = 0x01 << 3;
  coord = x | y;
  SPI.transfer(coord);
  digitalWrite(SS, HIGH);
} // end of loop
