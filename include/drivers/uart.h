/*
 * Copyright Arthur Grillo (c) 2024
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

#ifndef __UART_H__
#define __UART_H__

#include <stdbool.h>

#define COM1_BASE_ADDR 0x1000'0000

bool uart_init();
int uart_is_tx_empty();
void uart_printf(const char *str);

#endif // __UART_H__
