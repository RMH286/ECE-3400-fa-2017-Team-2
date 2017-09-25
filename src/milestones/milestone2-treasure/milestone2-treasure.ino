/*
fft_adc_serial.pde
guest openmusiclabs.com 7.7.14
example sketch for testing the fft library.
it takes in data on ADC0 (Analog0) and processes them
with the fft. the data is sent out over the serial
port at 115.2kb.
*/

#define LOG_OUT 1 // use the log output function
#define FFT_N 256 // set to 256 point fft

#include <FFT.h> // include the library



void setup() {

  //Treasure Sensors
  pinMode(2, OUTPUT); //7kHz
  pinMode(4, OUTPUT); //12kHz
  pinMode(7, OUTPUT); //17kHz
  Serial.begin(9600); // use the serial port
  TIMSK0 = 0; // turn off timer0 for lower jitter
  ADCSRA = 0xe5; // set the adc to free running mode
  ADCSRA &= ~(bit (ADPS0) | bit (ADPS1) | bit (ADPS2)); // clear prescaler bits
  ADCSRA |= bit (ADPS0) | bit (ADPS2);
  ADMUX = 0x40; // use adc0
  DIDR0 = 0x01; // turn off the digital input for adc0

  //myserialport = serial(comport, ‘BaudRate’, 9600)
}

void loop() {
  while(1) { // reduces jitter
    cli();  // UDRE interrupt slows this way down on arduino1.0
    for (int i = 0 ; i < 512 ; i += 2) { // save 256 samples
      while(!(ADCSRA & 0x10)); // wait for adc to be ready
      ADCSRA = 0xf5; // restart adc
      byte m = ADCL; // fetch adc data
      byte j = ADCH;
      int k = (j << 8) | m; // form into an int
      k -= 0x0200; // form into a signed int
      k <<= 6; // form into a 16b signed int
      fft_input[i] = k; // put real data into even bins
      fft_input[i+1] = 0; // set odd bins to 0
    }
    fft_window(); // window the data for better frequency response
    fft_reorder(); // reorder the data before doing the fft
    fft_run(); // process the data in the fft
    fft_mag_log(); // take the output of the fft
    sei();
    
    int seven = fft_log_out[46] + fft_log_out[47] + fft_log_out[48];
    int twelve = fft_log_out[79] + fft_log_out[80] + fft_log_out[81];
    int seventeen = fft_log_out[112] + fft_log_out[113] + fft_log_out[114];
      
    if (seven > 300){
       digitalWrite(2,HIGH); //7kHz detected
       delay(2000);
       digitalWrite(2,LOW);
    }

    if (twelve > 300){
       digitalWrite(4,HIGH); //12kHz detected
       delay(2000);
       digitalWrite(4,LOW);
    }

    if (seventeen > 300){
       digitalWrite(7,HIGH); //17kHz detected
       delay(2000);
       digitalWrite(7,LOW);
    }
    Serial.println("start");
    for (byte i = 0 ; i < FFT_N/2 ; i++) { 
      Serial.println(fft_log_out[i]); // send out the data
    }
  }
  //fclose(myserialport);
}
