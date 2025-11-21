#include "nios2_control.h"
#include "leds.h"
#include "chario.h"
#include "adc.h"
/* place additional #define macros here */

#define TIMER3_STATUS	((volatile unsigned int *) 0x10004060)

#define TIMER3_CONTROL	((volatile unsigned int *) 0x10004064)

#define TIMER3_START_LO	((volatile unsigned int *) 0x10004068)

#define TIMER3_START_HI	((volatile unsigned int *) 0x1000406C)

#define TIMER3_SNAP_LO	((volatile unsigned int *) 0x10004070)

#define TIMER3_SNAP_HI	((volatile unsigned int *) 0x10004074)

#define TIMER1_STATUS	((volatile unsigned int *) 0x10004020)

#define TIMER1_CONTROL	((volatile unsigned int *) 0x10004024)

#define TIMER1_START_LO	((volatile unsigned int *) 0x10004028)

#define TIMER1_START_HI	((volatile unsigned int *) 0x1000402C)

#define TIMER1_SNAP_LO	((volatile unsigned int *) 0x10004030)

#define TIMER1_SNAP_HI	((volatile unsigned int *) 0x10004034)

/* define global program variables here */

#define TIMER1_IRQ 0x4000
#define TIMER3_IRQ 0x10000

// 0.125s timer interval at 50 MHz clock
#define TIMER1_CYCLES 6250000

// 0.25s timer interval at 50 MHz clock
#define TIMER3_CYCLES 12500000


#define COMPANION_IRQ 0x1000

#define SWITCHES ((volatile unsigned int *)0x10000040)
#define HEX ((volatile unsigned int *)0x10000020)

#define HEX_DASH_PATTERN ((volatile unsigned int)0x40404040)
#define HEX_O_PATTERN ((volatile unsigned int)0x3F3F3F3F)

int timer_3_flag;
int timer_1_flag;

unsigned int lights[] = {0x303, 0x186, 0x0CC, 0x078, 0x030};
int counter = 0;
int direction = 0;

/* place additional functions here */



/*-----------------------------------------------------------------*/

/* this routine is called from the_exception() in exception_handler.c */

void interrupt_handler(void)
{
	/* read current value in ipending register */
	
	unsigned int ipending;
	
	ipending = NIOS2_READ_IPENDING();

	/* do one or more checks for different sources using ipending value */

	if (ipending & (TIMER1_IRQ)) {
		
		if (direction == 0) {
			counter++;
			*LEDS = (unsigned volatile int)lights[counter];
			if (counter == 4) direction = 1;
		}
		else {
			counter--;
			*LEDS = (unsigned volatile int)lights[counter];
			if (counter == 0) direction = 0;
		}
			
		timer_1_flag = 1;
		
		/* Clear interrupt sources */
		*TIMER1_STATUS =0;
		
		
	}
	
	if (ipending & (TIMER3_IRQ)) {
		
		timer_3_flag = 1;
		
		/* Clear interrupt sources */
		*TIMER3_STATUS = 0;
		
		
	}
	

	/* remember to clear interrupt sources */
}

/*-----------------------------------------------------------------*/

void Init (void)
{
	/* initialize software variables */

	/* set up each hardware interface */

	*TIMER1_CONTROL = 0x8;
    *TIMER1_START_LO = TIMER1_CYCLES & 0xFFFFFFFF;
    *TIMER1_START_HI = (TIMER1_CYCLES >> 16) & 0xFFFFFFFF;
    *TIMER1_CONTROL = 0x7;

   	*TIMER3_CONTROL = 0x8;
   	*TIMER3_START_LO = TIMER3_CYCLES & 0xFFFFFFFF;
   	*TIMER3_START_HI = (TIMER3_CYCLES >> 16) & 0xFFFFFFFF;
   	*TIMER3_CONTROL = 0x7;

	*LEDS = 0x303;
	InitADC(2,2);
	/* set up ienable */

	NIOS2_WRITE_IENABLE(COMPANION_IRQ | TIMER1_IRQ | TIMER3_IRQ);  /* enable timer interrupt */

	/* enable global recognition of interrupts in procr. status reg. */
	
	NIOS2_WRITE_STATUS( 0x1 );  /* enable interrupts globally */
}

/*-----------------------------------------------------------------*/

int main (void)
{
	
	//PrintChar('h');
	Init ();	/* perform software/hardware initialization */
	int show_dash = 0;
	if(GetChar() == '-')
	{
		show_dash = 1;
	}
	PrintChar('\n');
	PrintString("ELEC 371 Lab 4 by Ethan,Sebastien\n");
	PrintChar('\n');
	PrintString("Hexadecimal result from A/D conversion: 0x??");



	while (1)
	{
		if(timer_3_flag)
		{
			unsigned int number = ADConvert();
			number &= 0x000000FF;

			PrintChar('\b');
			PrintChar('\b');
			PrintHexDigit((number & 0x000000F0) >> 4 );
			PrintHexDigit(number & 0x0000000F);

			timer_3_flag = 0;
		}
		if(timer_1_flag)
		{
			volatile unsigned int hex_pattern_mask = 0;
			if (*SWITCHES & 0x1)
			{
				hex_pattern_mask += 0xFF;
			}
			if (*SWITCHES & 0x2)
			{
				hex_pattern_mask += 0xFF00;
			}
			if (*SWITCHES & 0x4)
			{
				hex_pattern_mask += 0xFF0000;
			}
			if (*SWITCHES & 0x8)
			{
				hex_pattern_mask += 0xFF000000;
			}

			if(show_dash)
			{

				*HEX = HEX_DASH_PATTERN & hex_pattern_mask;
			}
			else
			{
				*HEX = HEX_O_PATTERN & hex_pattern_mask;
			}
			timer_1_flag = 0;
		}
		/* fill in body of infinite loop */
	}

	return 0;	/* never reached, but main() must return a value */
}
