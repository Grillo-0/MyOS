/*
 * Copyright Arthur Grillo (c) 2024
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

#ifndef __MISC_H__
#define __MISC_H__

#include <stdint.h>

void outb(uint64_t port, uint8_t val);
uint8_t inb(uint64_t port);

void panic();

#endif // __MISC_H__
