/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.

 * File Name : mojo-coms.cpp

 * Purpose : Communicate with FPGA using simple protocol

 * Creation Date : 25-03-2015

 * Created By : Michael Christen

 _._._._._._._._._._._._._._._._._._._._._.*/

#include "mojo-coms.h"

void send_txn_command(bool write, uint8_t addr, uint8_t n) {
	//Clear spot for write
	n &= ~(1 << 7);
	n |= write ? (1 << 7) : 0;
	Serial.write(n);
	Serial.write(addr);
}

void read_from_mojo(uint8_t addr, uint8_t *buf, uint8_t n) {
	send_txn_command(false,addr,n);
	uint8_t i = 0;
	while(i < n) {
		if(Serial.available()){
			buf[i++] = Serial.read();
		}
	}
}

void write_to_mojo(uint8_t addr, uint8_t *buf, uint8_t n) {
	send_txn_command(true,addr,n);
	for(int i = 0; i < n; ++i) {
		Serial.write(buf[i]);
	}
}
