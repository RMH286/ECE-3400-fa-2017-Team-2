/*
fft_adc_serial.pde
guest openmusiclabs.com 7.7.14
example sketch for testing the fft library.
it takes in data on ADC0 (Analog0) and processes them
with the fft. the data is sent out over the serial
port at 115.2kb.
*/

#define LOG_OUT 1 // use the log output function
#define FFT_N 128 // set to 256 point fft

#include <FFT.h> // include the library

#define s2 4
#define s1 3
#define s0 2

//bool detect_tone() {
//  digitalWrite(s0, HIGH);
//  digitalWrite(s1, HIGH);
//  digitalWrite(s2, LOW);
//  cli();
//    for (int i = 0 ; i < 256 ; i += 2) {
//      fft_input[i] = analogRead(A0); // <-- NOTE THIS LINE
//      fft_input[i+1] = 0;
//    }
//    fft_window();
//    fft_reorder();
//    fft_run();
//    fft_mag_log();
//    sei();
//    Serial.println("start");
//    
//    for (byte i = 0 ; i < FFT_N/2 ; i++) {
//      Serial.println(fft_log_out[i]);
//    }
//  
//  Serial.println(fft_log_out[15]);
//  if (fft_log_out[15]>75) {
//    Serial.println(fft_log_out[15]);
//    return true;
//  }
//  return false;
//}

int detect_treasure() {
  return 0;
  char TIMSK0_temp = TIMSK0;
  char ADCSRA_temp = ADCSRA;
  char ADMUX_temp = ADMUX;
  char DIDR0_temp = DIDR0;
  TIMSK0 = 0; // turn off timer0 for lower jitter
  ADCSRA = 0xe5; // set the adc to free running mode
  ADCSRA &= ~(bit (ADPS0) | bit (ADPS1) | bit (ADPS2)); // clear prescaler bits
  ADCSRA |= bit (ADPS0) | bit (ADPS2);
  ADMUX = 0x40; // use adc0
  DIDR0 = 0x01; // turn off the digital input for adc0
  
  int treasure = 0;
  digitalWrite(s2, HIGH);
  for (int i = 0; i < 3; i++) {
    digitalWrite(s0, LOW);
    digitalWrite(s1, LOW);
    if (i & 1) {
      digitalWrite(s0, HIGH);
    }
    if (i & 2) {
      digitalWrite(s1, HIGH);
    }
    cli();  // UDRE interrupt slows this way down on arduino1.0
    for (int i = 0 ; i < 256 ; i += 2) { // save 256 samples
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
    
    int seven = fft_log_out[24] + fft_log_out[25];
    int twelve = fft_log_out[40] + fft_log_out[41] + fft_log_out[42];
    int seventeen = fft_log_out[57] + fft_log_out[58] + fft_log_out[59];
    
    if (seven > 120){
      treasure = 1;
    }

    else if (twelve > 180){
      treasure = 2;
    }

    else if (seventeen > 180){
      treasure = 3;
    }
  }
  //TIMSK0 = TIMSK0_temp;
  ADCSRA = ADCSRA_temp;
  ADMUX = ADMUX_temp;
  DIDR0 = DIDR0_temp;
  return treasure;
  //fclose(myserialport);
}
