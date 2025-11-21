#include "nios2_control.h"

/* place additional #define macros here */

#define TIMER3_STATUS	((volatile unsigned int *) 0x10004040)

#define TIMER3_CONTROL	((volatile unsigned int *) 0x10004044)

#define TIMER3_START_LO	((volatile unsigned int *) 0x10004048)

#define TIMER3_START_HI	((volatile unsigned int *) 0x1000404C)

#define TIMER3_SNAP_LO	((volatile unsigned int *) 0x10004050)

#define TIMER3_SNAP_HI	((volatile unsigned int *) 0x10004054)

#define TIMER1_STATUS	((volatile unsigned int *) 0x10004000)

#define TIMER1_CONTROL	((volatile unsigned int *) 0x10004004)

#define TIMER1_START_LO	((volatile unsigned int *) 0x10004008)

#define TIMER1_START_HI	((volatile unsigned int *) 0x1000400C)

#define TIMER1_SNAP_LO	((volatile unsigned int *) 0x10004010)

#define TIMER1_SNAP_HI	((volatile unsigned int *) 0x10004014)


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
#define HEX_O_PATTERN ((volatile unsigned int)0x1F1F1F1F)
/* define global program variables here */

volatile int timer_3_flag;
volatile int timer_1_flag;
unsigned int raw_ADC;
/* place additional functions here */



/*-----------------------------------------------------------------*/

/* this routine is called from the_exception() in exception_handler.c */

void interrupt_handler(void)
{
	unsigned int ipending;

	/* read current value in ipending register */

	/* do one or more checks for different sources using ipending value */

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

	InitADC(2,2);

	/* set up ienable */

   	NIOS2_WRITE_IENABLE(COMPANION_IRQ || TIMER1_IRQ | TIMER3_IRQ);  /* enable timer interrupt */

	/* enable global recognition of interrupts in procr. status reg. */

   NIOS2_WRITE_STATUS( 0x1 );  /* enable interrupts globally */

}

/*-----------------------------------------------------------------*/

int main (void)
{
	Init ();	/* perform software/hardware initialization */
	int show_dash = 0;
	if(GetChar() == '-')
	{
		show_dash = 1;
	}
	PrintChar('\n');
	PrintString("ELEC 4 Lab 4 by Ethan,Sebastian\n");
	PrintChar('\n');
	PrintString("Hexadecimal result from A/D conversion: 0x??");


	while (1)
	{
		if(timer_3_flag)
		{
			unsigned int number = ADConnvert();
			number &= 0x000000FF;

			PrintChar("\b\b");
			PrintHex(number & 0x000000F0);
			PrintHex(number & 0x0000000F);

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
