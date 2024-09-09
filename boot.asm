# 
# Copyright Arthur Grillo (c) 2024
# 
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

.section .init
.global _start
.type _start, @function
_start:
	csrw satp, zero		# disable paging
	la sp, stack_top	# setup stack

	# clear the bss section
	la t5, bss_start
	la t6, bss_end
bss_clear:
	sd zero, (t5)
	addi t5, t5, 8
	bltu t5, t6, bss_clear

	tail main
