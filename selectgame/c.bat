bin\asw -cpu 8048 text-engine_V31.asm
bin\asw -cpu 8048 text-engine_bank2.asm
bin\asw -cpu 8048 text-engine_bank1.asm
bin\asw -cpu 8048 text-engine_bank0.asm
cd ..
del o2em\roms\text-engine_0123.bin
cd asw
bin\p2bin text-engine_V31.p text-engine_bank3.bin -r 1024-3071
bin\p2bin text-engine_bank2.p text-engine_bank2.bin -r 1024-3071
bin\p2bin text-engine_bank1.p text-engine_bank1.bin -r 1024-3071
bin\p2bin text-engine_bank0.p text-engine_bank0.bin -r 1024-3071
copy /b text-engine_bank0.bin+text-engine_bank1.bin+text-engine_bank2.bin+text-engine_bank3.bin text-engine_0123.bin
copy text-engine_0123.bin ..\O2em\roms\selectgame.bin
cd ..\O2em\
o2emlauncher
cd ..\asw


