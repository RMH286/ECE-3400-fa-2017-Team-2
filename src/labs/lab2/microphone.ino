#define LOG_OUT 1 // use the log output function
#define FFT_N 256 // set to 256 point fft
#include <FFT.h> // include the library

void setup() {
  Serial.begin(115200); // use the serial port
  pinMode(12, OUTPUT);
}

void loop() {
  while(1) {
    cli();
    for (int i = 0 ; i < 512 ; i += 2) {
      fft_input[i] = analogRead(A0); // <-- NOTE THIS LINE
      fft_input[i+1] = 0;
    }
    fft_window();
    fft_reorder();
    fft_run();
    fft_mag_log();
    sei();
    Serial.println("start");
    
    for (byte i = 0 ; i < FFT_N/2 ; i++) {
      Serial.println(fft_log_out[i]);
      //if (i == 5 && fft_log_out[i] > 75){
        //Serial.println("LED on");
        //digitalWrite(12, HIGH);
        //delay(1000);
        //Serial.println("LED off");
        //digitalWrite(12,LOW);
      
    }

    
    
  }
}
