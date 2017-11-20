
    

    radio.openWritingPipe(pipes[1]);
    radio.openReadingPipe(1,pipes[0]);



    // Dump the payloads until we've gotten everything
    unsigned char got_data[2];
    bool done = false;
    while (!done)
    {
      // Fetch the payload, and see if this was the last one.
      done = radio.read(&got_data, 2 );

      delay(20);

    }

    // First, stop listening so we can talk
    radio.stopListening();

    // Send the final one back.
    radio.write(&got_data, 2 );

    // Now, resume listening so we catch the next packets.
    radio.startListening();
  