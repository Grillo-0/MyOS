/*
 * Copyright Arthur Grillo (c) 2024
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

#include "drivers/uart.h"
#include "misc.h"

bool uart_init() {
	outb(COM1_BASE_ADDR + 1, 0x00);    // Disable all interrupts
	outb(COM1_BASE_ADDR + 3, 0x80);    // Enable DLAB (set baud rate divisor)
	outb(COM1_BASE_ADDR + 0, 0x03);    // Set divisor to 3 (lo byte) 38400 baud
	outb(COM1_BASE_ADDR + 1, 0x00);    //                  (hi byte)
	outb(COM1_BASE_ADDR + 3, 0x03);    // 8 bits, no parity, one stop bit
	outb(COM1_BASE_ADDR + 2, 0xC7);    // Enable FIFO, clear them, with 14-byte threshold
	outb(COM1_BASE_ADDR + 4, 0x0f);

	return 0;
}

int uart_is_tx_empty() {
	return inb(COM1_BASE_ADDR + 5) & 0x20;
}

void uart_putc(const char c) {
	while(!uart_is_tx_empty());
	outb(COM1_BASE_ADDR, c);
}

void uart_printf(const char *str) {
	while (*str) {
		uart_putc(*str);
		str++;
	}
}
