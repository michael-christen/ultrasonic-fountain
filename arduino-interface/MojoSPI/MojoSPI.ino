/*
 */
#include <SPI.h>
#include "mojo-coms.h"

void setup()  
{
  // Open serial communications and wait for port to open:
  Serial.begin(9600);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for Leonardo only
  }
  Serial.println("Time to communicate");
  mojoComsSetup();
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
		read_from_mojo(addr,receive_arr, len);
	} else {
		Serial.print("Writing ");
		write_to_mojo(addr,send_arr,len);
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
