/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.

 * File Name : mojo-coms.cpp

 * Purpose : Communicate with FPGA using simple protocol

 * Creation Date : 25-03-2015

 * Created By : Michael Christen

 _._._._._._._._._._._._._._._._._._._._._.*/

#include "mojo-coms.h"

void send_txn_command(SoftwareSerial s, bool write, uint8_t addr, uint8_t n) {
	//Clear spot for write
	n &= ~(1 << 7);
	n |= write ? 0 : (1 << 7);
	s.write(n);
	s.write(addr);
}

void read_from_mojo(SoftwareSerial s, uint8_t addr, uint8_t *buf, uint8_t n) {
	send_txn_command(s,false,addr,n);
	uint8_t i = 0;
	while(i < n) {
		if(s.available()){
			buf[i++] = s.read();
		}
	}
}

void write_to_mojo(SoftwareSerial s, uint8_t addr, uint8_t *buf, uint8_t n) {
	send_txn_command(s,true,addr,n);
	for(int i = 0; i < n; ++i) {
		s.write(buf[i]);
	}
}
