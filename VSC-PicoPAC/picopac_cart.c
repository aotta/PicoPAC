/*
//                       PicoPAC MultiCART by Andrea Ottaviani 2024
//
//  VIDEOPAC  multicart based on Raspberry Pico board -
//
//  More info on https://github.com/aotta/ 
//
//   parts of code are directly from the A8PicoCart project by Robin Edwards 2023
//  
//   Needs to be a release NOT debug build for the cartridge emulation to work
// 
//   Edit myboard.h depending on the type of flash memory on the pico clone//
//
//   v. 1.0 2024-08-05 : Initial version for Pi Pico 
//
*/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "pico/multicore.h"
#include "hardware/gpio.h"
#include "pico/platform.h"
#include "pico/stdlib.h"
#include "hardware/vreg.h"
#include "pico/divider.h"
#include "hardware/flash.h"
#include "hardware/sync.h"


#include "gamelist.h"

#include "tusb.h"
#include "ff.h"
#include "fatfs_disk.h"

// Pico pin usage definitions

#define A0_PIN    0
#define A1_PIN    1
#define A2_PIN    2
#define A3_PIN    3
#define A4_PIN    4
#define A5_PIN    5
#define A6_PIN    6
#define A7_PIN    7
#define A8_PIN    8
#define A9_PIN    9
#define A10_PIN  10
#define A11_PIN  11
#define P11_PIN  12
#define P10_PIN  13
#define D0_PIN   14
#define D1_PIN   15
#define D2_PIN   16
#define D3_PIN   17
#define D4_PIN   18
#define D5_PIN   19
#define D6_PIN   20
#define D7_PIN   21
#define PSEN_PIN 22
#define WR_PIN 23
#define CS_PIN 24   // P14
#define LED_PIN  25 
#define NOTCS_PIN  26 
#define TD_PIN  27 

// Pico pin usage masks
#define A0_PIN_MASK     0x00000001L //gpio 0
#define A1_PIN_MASK     0x00000002L
#define A2_PIN_MASK     0x00000004L
#define A3_PIN_MASK     0x00000008L
#define A4_PIN_MASK     0x00000010L
#define A5_PIN_MASK     0x00000020L
#define A6_PIN_MASK     0x00000040L
#define A7_PIN_MASK     0x00000080L
#define A8_PIN_MASK     0x00000100L
#define A9_PIN_MASK     0x00000200L
#define A10_PIN_MASK    0x00000400L
#define A11_PIN_MASK    0x00000800L
#define P11_PIN_MASK    0x00001000L  // P11 high bank select
#define P10_PIN_MASK    0x00002000L  // P10 low bank select
#define D0_PIN_MASK     0x00004000L //gpio 14
#define D1_PIN_MASK     0x00008000L
#define D2_PIN_MASK     0x00010000L
#define D3_PIN_MASK     0x00020000L
#define D4_PIN_MASK     0x00040000L
#define D5_PIN_MASK     0x00080000L  // gpio 19
#define D6_PIN_MASK     0x00100000L
#define D7_PIN_MASK     0x00200000L
#define PSEN_PIN_MASK   0x00400000L //gpio 22
#define WR_PIN_MASK     0x00800000L //gpio 23  
#define CS_PIN_MASK     0x01000000L //gpio 24   - P14  
#define LED_PIN_MASK    0x02000000L //gpio 25   
#define NOTCS_PIN_MASK  0x04000000L //gpio 26  
#define TD_PIN_MASK     0x08000000L //gpio 27 

// Aggregate Pico pin usage masks
#define ALL_GPIO_MASK  	0x0FFFFFFFL
#define BUS_PIN_MASK    0x00003FFFL
#define BANK_PIN_MASK   0x00003000L
#define DATA_PIN_MASK   0x003FC000L
#define FLAG_MASK       0x0FC00000L
#define ALWAYS_IN_MASK  (BUS_PIN_MASK | FLAG_MASK)
#define ALWAYS_OUT_MASK (DATA_PIN_MASK )

#define SET_DATA_MODE_OUT   gpio_set_dir_out_masked(DATA_PIN_MASK)
#define SET_DATA_MODE_IN    gpio_set_dir_in_masked(DATA_PIN_MASK)
#define SET_LED_ON    	gpio_init(PICO_DEFAULT_LED_PIN);(PICO_DEFAULT_LED_PIN,GPIO_OUT);gpio_put(PICO_DEFAULT_LED_PIN,true);
#define SET_LED_OFF    	gpio_init(PICO_DEFAULT_LED_PIN);gpio_set_dir(PICO_DEFAULT_LED_PIN,GPIO_OUT);gpio_put(PICO_DEFAULT_LED_PIN,false);

// We're going to erase and reprogram a region 256k from the start of flash.
// Once done, we can access this at XIP_BASE + 256k.


char RBLo,RBHi;
#define BINLENGTH  1024*128+1
unsigned char rom_table[8][4096];
unsigned char new_rom_table[8][4096];
unsigned char extROM[1024];
unsigned char RAM[1024];
unsigned char files[256*100] = {0};
unsigned char nomefiles[32*25] = {0};
char curPath[256] = "";
char path[256];
int fileda=0,filea=0;
volatile char cmd=0;
char errorBuf[40];
bool cmd_executing;
volatile int bankswitch;
int bksw=0;
int romsize;
int lastpos;
volatile u_int8_t bank_type=1;
volatile u_int8_t new_bank_type=1;
volatile char gamechoosen=0;
volatile char newgame=0;
char extram[0xff];


////////////////////////////////////////////////////////////////////////////////////
//                     Error(N)
////////////////////////////////////////////////////////////////////////////////////
void error(int numblink){
 	multicore_lockout_start_blocking();	
    gpio_init(PICO_DEFAULT_LED_PIN);
	gpio_set_dir(PICO_DEFAULT_LED_PIN,GPIO_OUT);
  while(1){

    for(int i=0;i<numblink;i++) {
      gpio_put(PICO_DEFAULT_LED_PIN,true);
      sleep_ms(600);
      gpio_put(PICO_DEFAULT_LED_PIN,false);
      sleep_ms(500);
    }
  sleep_ms(2000);
  }
}

/*
 Theory of Operation
 -------------------
 //
 //
 //
*/
#pragma GCC push_options
#pragma GCC optimize ("O3")

void __not_in_flash_func(core1_main()) {
    uint32_t addr;
    char dataWrite=0;
    uint32_t pins;
    u_int8_t bank=0;
	u_int8_t romlatch=0;

	multicore_lockout_victim_init();	
   
    //gpio_set_dir_in_masked(ALWAYS_IN_MASK);
	
   newgame=0;

    // Initial conditions
    SET_DATA_MODE_IN;
	while(newgame==0) {
		 	pins=gpio_get_all();
	        addr = (pins & 0b0111111111111);  
			if((gpio_get(CS_PIN)==0) && (gpio_get(WR_PIN)==0)) {
				   extram[addr & 0xff]=((pins & DATA_PIN_MASK)>>D0_PIN);	
				   if (extram[0x7e]==0x0a) {
					  gamechoosen=extram[0x7f];
				   }
			} else {
			bank=3-((gpio_get(P10_PIN)+(gpio_get(P11_PIN)*2)));
	   	  	
			if (gpio_get(PSEN_PIN)==0) {
				SET_DATA_MODE_OUT;
    			gpio_put_masked(DATA_PIN_MASK,(rom_table[bank][addr])<<D0_PIN);
			} 
		  }
		 SET_DATA_MODE_IN;
		}
	SET_DATA_MODE_IN;
	
	switch (new_bank_type) {
	  case 0:  // standard 2k / 4k
        while(1) {	
	    	pins=gpio_get_all();
	        addr = (pins & 0b0111111111111);  
			if (gpio_get(P10_PIN)) {
				bank=0;
			} else {
				bank=1;
			}
			if (gpio_get(PSEN_PIN)==0) {
				SET_DATA_MODE_OUT;
    			gpio_put_masked(DATA_PIN_MASK,(rom_table[bank][addr])<<D0_PIN);
			} 
		 SET_DATA_MODE_IN;
		}
		break;
	  case 1:  // standard 8k
        while(1) {	
	     	pins=gpio_get_all();
	        addr = (pins & 0b0111111111111);  
			bank=3-((gpio_get(P10_PIN)+(gpio_get(P11_PIN)*2)));
	   	  	
			if (gpio_get(PSEN_PIN)==0) {
				SET_DATA_MODE_OUT;
    			gpio_put_masked(DATA_PIN_MASK,(rom_table[bank][addr])<<D0_PIN); 
		  }
		 SET_DATA_MODE_IN;
		}
		break;
	  case 2:   // XROM
        while(1) {	
	    	pins=gpio_get_all();
	        addr = (pins & 0b0111111111111); // for all cart but xrom
	  		if ((gpio_get(PSEN_PIN)==0 )) {
				SET_DATA_MODE_OUT;
    			gpio_put_masked(DATA_PIN_MASK,(rom_table[0][addr])<<D0_PIN);
			} 
			if ((gpio_get(P11_PIN)==1 )) {
				SET_DATA_MODE_OUT;
    			gpio_put_masked(DATA_PIN_MASK,(extROM[addr])<<D0_PIN);
			}
		 SET_DATA_MODE_IN;
		}
		break;
	  case 3:   // 12k/16k
        while(1) {	
	    	pins=gpio_get_all();
	        addr = (pins & 0b0111111111111); // for all cart but xrom
			if((gpio_get(CS_PIN)==0) && (gpio_get(WR_PIN)==0)) {
				if ((addr & 0xff)>=0x80) {
					romlatch=((~(pins & DATA_PIN_MASK)>>D0_PIN)&7);
				}	
			} else {
			if (gpio_get(P10_PIN)==0) {
				bank=romlatch;
			} else {
				bank=0;
			}
				if (gpio_get(PSEN_PIN)==0) {
					SET_DATA_MODE_OUT;
    				gpio_put_masked(DATA_PIN_MASK,(rom_table[bank][addr])<<D0_PIN);
				}
			} 
		 	SET_DATA_MODE_IN;
		  //}
		}
		break;
	}
}
#pragma GCC pop_options
////////////////////////////////////////////////////////////////////////////////////
//                     MENU Reset
////////////////////////////////////////////////////////////////////////////////////    

void reset() {
   
 //multicore_lockout_start_blocking();	

  while (gpio_get(PSEN_PIN)==0) {
  SET_DATA_MODE_OUT;
  gpio_put_masked(DATA_PIN_MASK,0x84<<D0_PIN);
 	}
  SET_DATA_MODE_IN;
 while (gpio_get(PSEN_PIN)==0) {
  SET_DATA_MODE_OUT;
  gpio_put_masked(DATA_PIN_MASK,0x00<<D0_PIN);
 	}
  SET_DATA_MODE_IN;
 
  sleep_ms(5);
 
  while (gpio_get(PSEN_PIN)==0) {
  SET_DATA_MODE_OUT;
  gpio_put_masked(DATA_PIN_MASK,0x84<<D0_PIN);
  }
  SET_DATA_MODE_IN;
  while (gpio_get(PSEN_PIN)==0) {
  SET_DATA_MODE_OUT;
  gpio_put_masked(DATA_PIN_MASK,0x00<<D0_PIN);
 	}
  SET_DATA_MODE_IN;
 
  while (gpio_get(PSEN_PIN)==0) {
  SET_DATA_MODE_OUT;
  gpio_put_masked(DATA_PIN_MASK,0x84<<D0_PIN);
  }
  SET_DATA_MODE_IN;
  while (gpio_get(PSEN_PIN)==0) {
  SET_DATA_MODE_OUT;
  gpio_put_masked(DATA_PIN_MASK,0x00<<D0_PIN);
 	}
  SET_DATA_MODE_IN;



}       

////////////////////////////////////////////////////////////////////////////////////

typedef struct {
	char isDir;
	char filename[13];
	char long_filename[32];
	char full_path[210];
} DIR_ENTRY;	// 256 bytes = 256 entries in 64k

int num_dir_entries = 0; // how many entries in the current directory

int entry_compare(const void* p1, const void* p2)
{
	DIR_ENTRY* e1 = (DIR_ENTRY*)p1;
	DIR_ENTRY* e2 = (DIR_ENTRY*)p2;
	if (e1->isDir && !e2->isDir) return -1;
	else if (!e1->isDir && e2->isDir) return 1;
	else return strcasecmp(e1->long_filename, e2->long_filename);
}

char *get_filename_ext(char *filename) {
    char *dot = strrchr(filename, '.');
    if(!dot || dot == filename) return "";
    return dot + 1;
}

int is_valid_file(char *filename) {
	char *ext = get_filename_ext(filename);
	if (strcasecmp(ext, "BIN") == 0 || strcasecmp(ext, "ROM") == 0  || strcasecmp(ext, "CV") )
		return 1;
	return 0;
}

FILINFO fno;
char search_fname[FF_LFN_BUF + 1];

// polyfill :-)
char *stristr(const char *str, const char *strSearch) {
    char *sors, *subs, *res = NULL;
    if ((sors = strdup (str)) != NULL) {
        if ((subs = strdup (strSearch)) != NULL) {
            res = strstr (strlwr (sors), strlwr (subs));
            if (res != NULL)
                res = (char*)str + (res - sors);
            free (subs);
        }
        free (sors);
    }
    return res;
}

int scan_files(char *path, char *search)
{
    FRESULT res;
    DIR dir;
    UINT i;

	res = f_opendir(&dir, path);
	if (res == FR_OK) {
		for (;;) {
			if (num_dir_entries == 99) break;
			res = f_readdir(&dir, &fno);
			if (res != FR_OK || fno.fname[0] == 0) break;
			if (fno.fattrib & (AM_HID | AM_SYS)) continue;
			if (fno.fattrib & AM_DIR) {
				i = strlen(path);
				strcat(path, "/");
				if (fno.altname[0])	// no altname when lfn is 8.3
					strcat(path, fno.altname);
				else
					strcat(path, fno.fname);
				if (strlen(path) >= 210) continue;	// no more room for path in DIR_ENTRY
				res = scan_files(path, search);
				if (res != FR_OK) break;
				path[i] = 0;
			}
			else if (is_valid_file(fno.fname))
			{
				char *match = stristr(fno.fname, search);
				if (match) {
					DIR_ENTRY *dst = (DIR_ENTRY *)&files[0];
					dst += num_dir_entries;
					// fill out a record
					dst->isDir = (match == fno.fname) ? 1 : 0;	// use this for a "score"
					strncpy(dst->long_filename, fno.fname, 31);
					dst->long_filename[31] = 0;
					// 8.3 name
					if (fno.altname[0])
						strcpy(dst->filename, fno.altname);
					else {	// no altname when lfn is 8.3
						strncpy(dst->filename, fno.fname, 12);
						dst->filename[12] = 0;
					}
					// full path for search results
					strcpy(dst->full_path, path);

					num_dir_entries++;
				}
			}
		}
		f_closedir(&dir);
	}
	return res;
}

int search_directory(char *path, char *search) {
	char pathBuf[256];
	strcpy(pathBuf, path);
	num_dir_entries = 0;
	int i;
	FATFS FatFs;
	if (f_mount(&FatFs, "", 1) == FR_OK) {
		if (scan_files(pathBuf, search) == FR_OK) {
			// sort by score, name
			qsort((DIR_ENTRY *)&files[0], num_dir_entries, sizeof(DIR_ENTRY), entry_compare);
			DIR_ENTRY *dst = (DIR_ENTRY *)&files[0];
			// re-set the pointer back to 0
			for (i=0; i<num_dir_entries; i++)
				dst[i].isDir = 0;
			return 1;
		}
	}
	strcpy(errorBuf, "Problem searching flash");
	return 0;
}


int filesize(char *filename) {
    if (!fatfs_is_mounted())
       mount_fatfs_disk();

	FATFS FatFs;
	int car_file = 0;
	UINT br = 0;
	if (f_mount(&FatFs, "", 1) != FR_OK) {
		error(1);
		return 0;
	}

	FIL fil;
	if (f_open(&fil, filename, FA_READ) != FR_OK) {
		sleep_ms(100);
		error(2);
		goto cleanup;
	}



	int byteslong = f_size(&fil);
	romsize=byteslong;

closefile:
	f_close(&fil);
cleanup:
	f_mount(0, "", 1);

	return byteslong;
}



/* load file in  ROM (rom_table) */

int load_file(char *filename) {
	FATFS FatFs;
	UINT br = 0;
	UINT bw = 0;
    int l,nb;
    int k=0;

			memset(rom_table,0,1024*8*4);
	
	l=filesize(filename);
	
    
	
	if (f_mount(&FatFs, "", 1) != FR_OK) {
		error(1);
	}

	nb = l/2048;   // nb = number of banks, l=file size)
	
	bank_type=0;
	if (nb==4) bank_type=1;
	if (nb>4) bank_type=3;
	
	FIL fil;
	if (f_open(&fil, filename, FA_READ) != FR_OK) {
		error(2);
	}
	

	// read the file to flash RAM
	
		for (int i = nb - 1; i >= 0; i--) {
        	if (f_read(&fil,&rom_table[i][1024], 2048, &br)!= FR_OK) {
				error(3);
			}
			k=k+1;
        	memcpy(&rom_table[i][3072], &rom_table[i][2048], 1024); /* simulate missing A10 */
    	}
            // mirror ROM in higher banks
    if (nb<2) memcpy(&rom_table[1],&rom_table[0],4096);
    if (nb<4) memcpy(&rom_table[2],&rom_table[0],8192);

closefile:
	f_close(&fil);
	    
cleanup:
	f_mount(0, "", 1);

	return br;
}

int load_newfile(char *filename) {
	FATFS FatFs;
	UINT br = 0;
	UINT bw = 0;
    int l,nb;
    int k=0;

	memset(new_rom_table,0,1024*8*4);
	
	l=filesize(filename);
	
	if (f_mount(&FatFs, "", 1) != FR_OK) {
		error(1);
	}

	FIL fil;
	if (f_open(&fil, filename, FA_READ) != FR_OK) {
		error(2);
	}
    
	nb = l/2048;   // nb = number of banks, l=file size)
		
    if ((strcmp(filename,"vp_40.bin")==0)||((strcmp(filename,"vp_31.bin")==0))) {  // 3k games
	        if (f_read(&fil, &extROM[0], 1024, &br) != FR_OK) {
               error(2);
            }
            if (f_read(&fil, &new_rom_table[0][1024], 3072, &br) != FR_OK) {
                error(3);
            } 	
	} else

	 {
		new_bank_type=0;
		if (nb==4) new_bank_type=1;
		if (nb>4) new_bank_type=3;

		for (int i = nb - 1; i >= 0; i--) {
        	if (f_read(&fil,&new_rom_table[i][1024], 2048, &br)!= FR_OK) {
				error(3);
			}
			k=k+1;
        	memcpy(&new_rom_table[i][3072], &new_rom_table[i][2048], 1024); /* simulate missing A10 */
    	}
	}
	    // mirror ROM in higher banks
    if (nb<2) memcpy(&new_rom_table[1],&new_rom_table[0],4096);
    if (nb<4) memcpy(&new_rom_table[2],&new_rom_table[0],8192);
   	
	
closefile:
	f_close(&fil);
	    
cleanup:
	f_mount(0, "", 1);

	return br;
}


////////////////////////////////////////////////////////////////////////////////////
//                     PicoPAC Cart Main
////////////////////////////////////////////////////////////////////////////////////

void picopac_cart_main()
{
    uint32_t pins;
    uint32_t addr;
    uint32_t dataOut=0;
    uint16_t dataWrite=0;
	 int ret=0;

    int l, nb;
 	// overclocking isn't necessary for most functions - but XEGS carts weren't working without it
	// I guess we might as well have it on all the time.
    
	set_sys_clock_khz(270000, true);
    //set_sys_clock_khz(170000, true);
  

    gpio_init_mask(ALL_GPIO_MASK);
  
    
    stdio_init_all();   // for serial output, via printf()
    printf("Start\n");

 
  sleep_ms(400);

  multicore_launch_core1(core1_main);
  sleep_ms(200);

   load_file("/selectgame.bin");
   //load_file("/pb_q-bert.bin");
   
  memset(extram,0,0xff);
  //load_file("/vp_38.bin");
  //load_file("/vp_59_16.bin");
  
    
  // Initial conditions 
  curPath[0]=0;
  while (1) {
	 cmd_executing=false;
   
    if ((gamechoosen>=1)) {

	sleep_ms(1800);

	load_newfile(gamelist[gamechoosen-1]);
	//reset();
	memcpy(rom_table,new_rom_table,1024*32);
	
	newgame=1;
	
   }
  }
}

 	
