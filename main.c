/*
 * Copyright Arthur Grillo (c) 2024
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

#include "drivers/uart.h"
#include "misc.h"

void main() {
	if (uart_init()) {
		panic();
	}

	uart_printf("\n");
	uart_printf("Hello from Myos!\n");
	panic();
}
