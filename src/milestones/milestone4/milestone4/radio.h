#include <SPI.h>
#include "nRF24L01.h"
#include "RF24.h"


void radio_setup(void);

bool transmit_node(char node, int row, int column);

