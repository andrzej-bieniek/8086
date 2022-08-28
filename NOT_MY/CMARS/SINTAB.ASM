	.model	large

	.data

	PUBLIC	sintable,costable,_B

_B	dw	002d4h

sintable	label	word
	dw	00000h, 0023bh, 00477h, 006b2h, 008edh, 00b27h, 00d61h, 00f99h
	dw	011d0h, 01405h, 01639h, 0186ch, 01a9ch, 01ccah, 01ef7h, 02120h
	dw	02347h, 0256ch, 0278dh, 029abh, 02bc6h, 02ddeh, 02ff2h, 03203h
	dw	0340fh, 03617h, 0381ch, 03a1bh, 03c17h, 03e0dh, 03fffh, 041ech
	dw	043d3h, 045b6h, 04793h, 0496ah, 04b3bh, 04d07h, 04ecdh, 0508ch
	dw	05246h, 053f9h, 055a5h, 0574bh, 058e9h, 05a81h, 05c12h, 05d9ch
	dw	05f1eh, 06099h, 0620ch, 06378h, 064dch, 06638h, 0678dh, 068d9h
	dw	06a1dh, 06b58h, 06c8bh, 06db6h, 06ed9h, 06ff2h, 07103h, 0720bh
	dw	0730ah, 07400h, 074eeh, 075d2h, 076adh, 0777eh, 07846h, 07905h
	dw	079bbh, 07a67h, 07b09h, 07ba2h, 07c31h, 07cb7h, 07d32h, 07da4h
	dw	07e0dh, 07e6bh, 07ec0h, 07f0ah, 07f4bh, 07f82h, 07fafh, 07fd2h
	dw	07febh, 07ffah, 07ffeh, 07ffah, 07febh, 07fd2h, 07fafh, 07f82h
	dw	07f4bh, 07f0ah, 07ec0h, 07e6bh, 07e0dh, 07da4h, 07d32h, 07cb7h
	dw	07c31h, 07ba2h, 07b09h, 07a67h, 079bbh, 07905h, 07846h, 0777eh
	dw	076adh, 075d2h, 074eeh, 07400h, 0730ah, 0720bh, 07103h, 06ff2h
	dw	06ed9h, 06db6h, 06c8bh, 06b58h, 06a1dh, 068d9h, 0678dh, 06638h
	dw	064dch, 06378h, 0620ch, 06099h, 05f1eh, 05d9ch, 05c12h, 05a81h
	dw	058e9h, 0574bh, 055a5h, 053f9h, 05246h, 0508ch, 04ecdh, 04d07h
	dw	04b3bh, 0496ah, 04793h, 045b6h, 043d3h, 041ech, 03fffh, 03e0dh
	dw	03c17h, 03a1bh, 0381ch, 03617h, 0340fh, 03203h, 02ff2h, 02ddeh
	dw	02bc6h, 029abh, 0278dh, 0256ch, 02347h, 02120h, 01ef7h, 01ccah
	dw	01a9ch, 0186ch, 01639h, 01405h, 011d0h, 00f99h, 00d61h, 00b27h
	dw	008edh, 006b2h, 00477h, 0023bh, 00000h, 0fdc5h, 0fb89h, 0f94eh
	dw	0f713h, 0f4d9h, 0f29fh, 0f067h, 0ee30h, 0ebfbh, 0e9c7h, 0e794h
	dw	0e564h, 0e336h, 0e109h, 0dee0h, 0dcb9h, 0da94h, 0d873h, 0d655h
	dw	0d43ah, 0d222h, 0d00eh, 0cdfdh, 0cbf1h, 0c9e9h, 0c7e4h, 0c5e5h
	dw	0c3e9h, 0c1f3h, 0c001h, 0be14h, 0bc2dh, 0ba4ah, 0b86dh, 0b696h
	dw	0b4c5h, 0b2f9h, 0b133h, 0af74h, 0adbah, 0ac07h, 0aa5bh, 0a8b5h
	dw	0a717h, 0a57fh, 0a3eeh, 0a264h, 0a0e2h, 09f67h, 09df4h, 09c88h
	dw	09b24h, 099c8h, 09873h, 09727h, 095e3h, 094a8h, 09375h, 0924ah
	dw	09127h, 0900eh, 08efdh, 08df5h, 08cf6h, 08c00h, 08b12h, 08a2eh
	dw	08953h, 08882h, 087bah, 086fbh, 08645h, 08599h, 084f7h, 0845eh
	dw	083cfh, 08349h, 082ceh, 0825ch, 081f3h, 08195h, 08140h, 080f6h
	dw	080b5h, 0807eh, 08051h, 0802eh, 08015h, 08006h, 08002h, 08006h
	dw	08015h, 0802eh, 08051h, 0807eh, 080b5h, 080f6h, 08140h, 08195h
	dw	081f3h, 0825ch, 082ceh, 08349h, 083cfh, 0845eh, 084f7h, 08599h
	dw	08645h, 086fbh, 087bah, 08882h, 08953h, 08a2eh, 08b12h, 08c00h
	dw	08cf6h, 08df5h, 08efdh, 0900eh, 09127h, 0924ah, 09375h, 094a8h
	dw	095e3h, 09727h, 09873h, 099c8h, 09b24h, 09c88h, 09df4h, 09f67h
	dw	0a0e2h, 0a264h, 0a3eeh, 0a57fh, 0a717h, 0a8b5h, 0aa5bh, 0ac07h
	dw	0adbah, 0af74h, 0b133h, 0b2f9h, 0b4c5h, 0b696h, 0b86dh, 0ba4ah
	dw	0bc2dh, 0be14h, 0c001h, 0c1f3h, 0c3e9h, 0c5e5h, 0c7e4h, 0c9e9h
	dw	0cbf1h, 0cdfdh, 0d00eh, 0d222h, 0d43ah, 0d655h, 0d873h, 0da94h
	dw	0dcb9h, 0dee0h, 0e109h, 0e336h, 0e564h, 0e794h, 0e9c7h, 0ebfbh
	dw	0ee30h, 0f067h, 0f29fh, 0f4d9h, 0f713h, 0f94eh, 0fb89h, 0fdc5h
costable	label	word
	dw	07fffh, 07ffah, 07febh, 07fd2h, 07fafh, 07f82h, 07f4bh, 07f0ah
	dw	07ec0h, 07e6bh, 07e0dh, 07da4h, 07d32h, 07cb7h, 07c31h, 07ba2h
	dw	07b09h, 07a67h, 079bbh, 07905h, 07846h, 0777eh, 076adh, 075d2h
	dw	074eeh, 07400h, 0730ah, 0720bh, 07103h, 06ff2h, 06ed9h, 06db6h
	dw	06c8bh, 06b58h, 06a1dh, 068d9h, 0678dh, 06638h, 064dch, 06378h
	dw	0620ch, 06099h, 05f1eh, 05d9ch, 05c12h, 05a81h, 058e9h, 0574bh
	dw	055a5h, 053f9h, 05246h, 0508ch, 04ecdh, 04d07h, 04b3bh, 0496ah
	dw	04793h, 045b6h, 043d3h, 041ech, 03fffh, 03e0dh, 03c17h, 03a1bh
	dw	0381ch, 03617h, 0340fh, 03203h, 02ff2h, 02ddeh, 02bc6h, 029abh
	dw	0278dh, 0256ch, 02347h, 02120h, 01ef7h, 01ccah, 01a9ch, 0186ch
	dw	01639h, 01405h, 011d0h, 00f99h, 00d61h, 00b27h, 008edh, 006b2h
	dw	00477h, 0023bh, 00000h, 0fdc5h, 0fb89h, 0f94eh, 0f713h, 0f4d9h
	dw	0f29fh, 0f067h, 0ee30h, 0ebfbh, 0e9c7h, 0e794h, 0e564h, 0e336h
	dw	0e109h, 0dee0h, 0dcb9h, 0da94h, 0d873h, 0d655h, 0d43ah, 0d222h
	dw	0d00eh, 0cdfdh, 0cbf1h, 0c9e9h, 0c7e4h, 0c5e5h, 0c3e9h, 0c1f3h
	dw	0c001h, 0be14h, 0bc2dh, 0ba4ah, 0b86dh, 0b696h, 0b4c5h, 0b2f9h
	dw	0b133h, 0af74h, 0adbah, 0ac07h, 0aa5bh, 0a8b5h, 0a717h, 0a57fh
	dw	0a3eeh, 0a264h, 0a0e2h, 09f67h, 09df4h, 09c88h, 09b24h, 099c8h
	dw	09873h, 09727h, 095e3h, 094a8h, 09375h, 0924ah, 09127h, 0900eh
	dw	08efdh, 08df5h, 08cf6h, 08c00h, 08b12h, 08a2eh, 08953h, 08882h
	dw	087bah, 086fbh, 08645h, 08599h, 084f7h, 0845eh, 083cfh, 08349h
	dw	082ceh, 0825ch, 081f3h, 08195h, 08140h, 080f6h, 080b5h, 0807eh
	dw	08051h, 0802eh, 08015h, 08006h, 08002h, 08006h, 08015h, 0802eh
	dw	08051h, 0807eh, 080b5h, 080f6h, 08140h, 08195h, 081f3h, 0825ch
	dw	082ceh, 08349h, 083cfh, 0845eh, 084f7h, 08599h, 08645h, 086fbh
	dw	087bah, 08882h, 08953h, 08a2eh, 08b12h, 08c00h, 08cf6h, 08df5h
	dw	08efdh, 0900eh, 09127h, 0924ah, 09375h, 094a8h, 095e3h, 09727h
	dw	09873h, 099c8h, 09b24h, 09c88h, 09df4h, 09f67h, 0a0e2h, 0a264h
	dw	0a3eeh, 0a57fh, 0a717h, 0a8b5h, 0aa5bh, 0ac07h, 0adbah, 0af74h
	dw	0b133h, 0b2f9h, 0b4c5h, 0b696h, 0b86dh, 0ba4ah, 0bc2dh, 0be14h
	dw	0c001h, 0c1f3h, 0c3e9h, 0c5e5h, 0c7e4h, 0c9e9h, 0cbf1h, 0cdfdh
	dw	0d00eh, 0d222h, 0d43ah, 0d655h, 0d873h, 0da94h, 0dcb9h, 0dee0h
	dw	0e109h, 0e336h, 0e564h, 0e794h, 0e9c7h, 0ebfbh, 0ee30h, 0f067h
	dw	0f29fh, 0f4d9h, 0f713h, 0f94eh, 0fb89h, 0fdc5h, 00000h, 0023bh
	dw	00477h, 006b2h, 008edh, 00b27h, 00d61h, 00f99h, 011d0h, 01405h
	dw	01639h, 0186ch, 01a9ch, 01ccah, 01ef7h, 02120h, 02347h, 0256ch
	dw	0278dh, 029abh, 02bc6h, 02ddeh, 02ff2h, 03203h, 0340fh, 03617h
	dw	0381ch, 03a1bh, 03c17h, 03e0dh, 03fffh, 041ech, 043d3h, 045b6h
	dw	04793h, 0496ah, 04b3bh, 04d07h, 04ecdh, 0508ch, 05246h, 053f9h
	dw	055a5h, 0574bh, 058e9h, 05a81h, 05c12h, 05d9ch, 05f1eh, 06099h
	dw	0620ch, 06378h, 064dch, 06638h, 0678dh, 068d9h, 06a1dh, 06b58h
	dw	06c8bh, 06db6h, 06ed9h, 06ff2h, 07103h, 0720bh, 0730ah, 07400h
	dw	074eeh, 075d2h, 076adh, 0777eh, 07846h, 07905h, 079bbh, 07a67h
	dw	07b09h, 07ba2h, 07c31h, 07cb7h, 07d32h, 07da4h, 07e0dh, 07e6bh
	dw	07ec0h, 07f0ah, 07f4bh, 07f82h, 07fafh, 07fd2h, 07febh, 07ffah


	end
