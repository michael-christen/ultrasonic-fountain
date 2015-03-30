/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.

 * File Name : mojo-coms.cpp

 * Purpose : Communicate with FPGA using simple protocol

 * Creation Date : 25-03-2015

 * Created By : Michael Christen

 _._._._._._._._._._._._._._._._._._._._._.*/

#include <SPI.h>
#include "mojo-coms.h"

const int chipSelectPin = 7;

void mojoComsSetup() {
	  // start the SPI library:
	  SPI.begin();
	  // initalize the  data ready and chip select pins:
	  pinMode(chipSelectPin, OUTPUT);
}

void send_txn_command(bool write, uint8_t addr, uint8_t n) {
	uint8_t b = addr & 0x3F;
	b |= write ? (1 << 7) : 0x00;
	b |= (n>1) ? (1 << 6) : 0x00;
	SPI.transfer(b);
}

void read_from_mojo(uint8_t addr, uint8_t *buf, uint8_t n) {
	digitalWrite(chipSelectPin, LOW);
	send_txn_command(false,addr,n);
	uint8_t i = 0;
	while(i < n) {
		if(Serial.available()){
			buf[i++] = SPI.transfer(0xff);
		}
	}
	digitalWrite(chipSelectPin, HIGH);
}

void write_to_mojo(uint8_t addr, uint8_t *buf, uint8_t n) {
	digitalWrite(chipSelectPin, LOW);
	send_txn_command(true,addr,n);
	for(int i = 0; i < n; ++i) {
		SPI.transfer(buf[i]);
	}
	digitalWrite(chipSelectPin, HIGH);
}
