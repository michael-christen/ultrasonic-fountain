#ifndef __MOJO-COMS__H__
#define __MOJO-COMS__H__

#include <stdint.h>
#include <AltSoftSerial.h>
#include <Arduino.h>

/*
 * command is form:
 *  7    [6:0]  [7:0]
 * [w/~r, len] [addr]
 */
void send_txn_command(AltSoftSerial s, bool write, uint8_t addr, uint8_t n);
void read_from_mojo(AltSoftSerial s, uint8_t addr, uint8_t *buf, uint8_t n);
void write_to_mojo(AltSoftSerial s, uint8_t addr, uint8_t *buf, uint8_t n);
#endif
