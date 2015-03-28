/*
 */
#include "mojo-coms.h"

void setup()  
{
  // Open serial communications and wait for port to open:
  Serial.begin(9600);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for Leonardo only
  }
}
uint8_t send_arr[256];
uint8_t receive_arr[256];

void loop() // run over and over
{
	//Read 8 bytes from mojo
	read_from_mojo(0,receive_arr, 8);
	write_to_mojo(1,receive_arr,8);//Send right back, shifted up 1
}

