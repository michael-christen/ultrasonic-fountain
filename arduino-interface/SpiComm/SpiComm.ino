/*
 * SPI test
 *
 * SS	10	--> 40
 * MOSI	11	--> 34
 * MISO	12	--> 35
 * SCK	13	--> 41
 */
#include <SPI.h>


void setup()  
{
  // Open serial communications and wait for port to open:
  Serial.begin(57600);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for Leonardo only
  }
  Serial.println("Enter character and press enter when ready!");

  //Initialize SPI
  SPI.begin();
}

void loop() // run over and over
{
  if (Serial.available()) {
	  Serial.println((int)SPI.transfer(Serial.read()));
  }
}

