/*
 Copyright (C) 2011 J. Coliz <maniacbug@ymail.com>
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 version 2 as published by the Free Software Foundation.
 */

/**
 * Example for Getting Started with nRF24L01+ radios.
 *
 * This is an example of how to use the RF24 class.  Write this sketch to two
 * different nodes.  Put one of the nodes into 'transmit' mode by connecting
 * with the serial monitor and sending a 'T'.  The ping node sends the current
 * time to the pong node, which responds by sending the value back.  The ping
 * node can then see how long the whole cycle took.
 */

#include "radio.h"


//
// Hardware configuration
//

// Set up nRF24L01 radio on SPI bus plus pins 9 & 10

RF24 radio(9,10);

//
// Topology
//

// Radio pipe addresses for the 2 nodes to communicate.
const uint64_t pipes[2] = { 0x0000000004LL, 0x0000000005LL };

//
// Role management
//
// Set up role.  This sketch uses the same software for all the nodes
// in this system.  Doing so greatly simplifies testing.
//


void radio_setup(void)
{
  //
  // Print preamble
  //
  radio.setPayloadSize(2);

  //Serial.begin(57600);

  //
  // Setup and configure rf radio
  //

  radio.begin();

  // optionally, increase the delay between retries & # of retries
  radio.setRetries(15,15);
  radio.setAutoAck(true);
  // set the channel
  radio.setChannel(0x50);
  // set the power
  // RF24_PA_MIN=-18dBm, RF24_PA_LOW=-12dBm, RF24_PA_MED=-6dBM, and RF24_PA_HIGH=0dBm.
  radio.setPALevel(RF24_PA_MIN);
  //RF24_250KBPS for 250kbs, RF24_1MBPS for 1Mbps, or RF24_2MBPS for 2Mbps
  radio.setDataRate(RF24_250KBPS);

  // optionally, reduce the payload size.  seems to
  // improve reliability
  //radio.setPayloadSize(8);

  //
  // Open pipes to other nodes for communication
  //

  // This simple sketch opens two pipes for these two nodes to communicate
  // back and forth.
  // Open 'our' pipe for writing
  // Open the 'other' pipe for reading, in position #1 (we can have up to 5 pipes open for reading)
    radio.openWritingPipe(pipes[0]);
    radio.openReadingPipe(1,pipes[1]);


  //
  // Start listening
  //

  radio.startListening();

  //
  // Dump the configuration of the rf unit for debugging
  //
  Serial.println("finished setup");
}
bool transmit_node(char node, int row, int column){
  char data_buffer[2];
  row = row<<2;
  char coords = row | column;
  data_buffer[1] = node;
  data_buffer[0] = coords;
  Serial.println("data to send");
  Serial.println( data_buffer[0]);
  Serial.println( data_buffer[1]);




  //
  // Ping out role.  Repeatedly send the current time
  //

 
  // First, stop listening so we can talk.
  radio.stopListening();

  // Take the time, and send it.  This will block until complete
    
  bool ok = radio.write( &data_buffer, 2);

  if (!ok){
    Serial.println("not sending");
    return false;
  }

  // Now, continue listening
  radio.startListening();

  // Wait here until we get a response, or timeout (250ms)
  unsigned long started_waiting_at = millis();
  bool timeout = false;
  while ( ! radio.available() && ! timeout )
    if (millis() - started_waiting_at > 200 )
      timeout = true;

  // Describe the results
  if ( timeout )
  {
    Serial.println("timeout");
    return false;
  }
  else
  {
    // Grab the response, compare, and send to debugging spew
    char got_data[2];
    radio.read( &got_data, 2 );
    if(got_data[0]!=data_buffer[0] | got_data[1]!=data_buffer[1]){
      Serial.println("Not correct");
      return false;
    }

  }

}



// vim:cin:ai:sts=2 sw=2 ft=cpp
