ENTRY(_start)

. = 0x80000000;

SECTIONS {
	.text : ALIGN(4K) {
		*(.init);
		*(.text);
	}

	.rodata : ALIGN(4K) {
		*(.rodata);
	}

	.data : ALIGN(4K) {
		*(.data);
	}

	.bss : ALIGN(4K) {
		PROVIDE(bss_start = .);
		*(.bss);
		. += 4K;
		PROVIDE(stack_top = .);
		PROVIDE(bss_end = .);
	}
}
