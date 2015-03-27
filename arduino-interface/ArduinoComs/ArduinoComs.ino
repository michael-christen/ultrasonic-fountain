/*
  Software serial multple serial test
 
 Receives from the hardware serial, sends to software serial.
 Receives from software serial, sends to hardware serial.
 
 The circuit: 
 * RX is digital pin 10 (connect to TX of other device) (50)
 * TX is digital pin 11 (connect to RX of other device) (51)
 
 Note:
 Not all pins on the Mega and Mega 2560 support change interrupts, 
 so only the following can be used for RX: 
 10, 11, 12, 13, 50, 51, 52, 53, 62, 63, 64, 65, 66, 67, 68, 69
 
 Not all pins on the Leonardo support change interrupts, 
 so only the following can be used for RX: 
 8, 9, 10, 11, 14 (MISO), 15 (SCK), 16 (MOSI).
 
 created back in the mists of time
 modified 25 May 2012
 by Tom Igoe
 based on Mikal Hart's example
 
 This example code is in the public domain.
 
 */
#include <SoftwareSerial.h>
#include "mojo-coms.h"

SoftwareSerial mySerial(10, 11); // RX, TX

void setup()  
{
  // Open serial communications and wait for port to open:
  Serial.begin(57600);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for Leonardo only
  }


  Serial.println("Time to communicate");

  // set the data rate for the SoftwareSerial port
  mySerial.begin(9600);
  //mySerial.println("Hello, world?");
}
uint8_t send_arr[256];
uint8_t receive_arr[256];

void loop() // run over and over
{
  if (Serial.available()) {
	bool read = Serial.read() == 'r';
	Serial.print("Read: ");
	Serial.println(read);
	while(!Serial.available());
	uint8_t addr = Serial.read() - '0'; 
	while(!Serial.available());
	uint8_t len  = Serial.read() - '0';
	int i = 0;
	if(!read) {
		for(int i = 0; i < len; ++i) {
			while(!Serial.available());
			send_arr[i] = Serial.read() - '0';
		}
	}
	if(read) {
		Serial.print("Reading ");
		read_from_mojo(mySerial,addr,receive_arr, len);
	} else {
		Serial.print("Writing ");
		write_to_mojo(mySerial,addr,send_arr,len);
	}
	Serial.print(len);
	Serial.print(" bytes @ addr ");
	Serial.println(addr);
	for(int i = 0; i < len; ++i) {
		if(read) {
			Serial.print("r: ");
			Serial.println(receive_arr[i]);
		} else {
			Serial.print("w: ");
			Serial.println(send_arr[i]);
		}
	}
  }
}

