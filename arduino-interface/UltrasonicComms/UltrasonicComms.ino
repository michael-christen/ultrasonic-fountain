/*		Ard.	Mojo
 * SS	7		40
 * MOSI	11		34	
 * MISO	12		35
 * SCK	13		41
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

double getDistFromUS(uint16_t raw_val) {
//Each tick is 10us, and us --> cm is t/57,
//so, we'll just divide by 5.7
	return (raw_val + 0.0)/5.7;
}

const int numSensors = 9;
double sensorVals[numSensors];
void loop() // run over and over
{
	read_from_mojo(0,receive_arr,numSensors * 2);
	for(int i = 0; i < numSensors; ++i) {
		uint16_t val = receive_arr[2*i];
		val |= (receive_arr[2*i+1] << 8);
		sensorVals[i] = getDistFromUS(val);
	}
	Serial.print("Dist: ");
	Serial.print(sensorVals[0]);
	Serial.println("cm");
	delay(100);
}
