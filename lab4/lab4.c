#include "nios2_control.h"
#include "leds.h"
#include "chario.h"
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

/* define global program variables here */

int timer_3_flag;
int timer_1_flag;
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

	/* set up ienable */

   	NIOS2_WRITE_IENABLE(TIMER1_TO_BIT | TIMER3_TO_BIT);  /* enable timer interrupt */

	/* enable global recognition of interrupts in procr. status reg. */

   NIOS2_WRITE_STATUS( 0x1 );  /* enable interrupts globally */
	/* set up ienable */

	/* enable global recognition of interrupts in procr. status reg. */
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

		}
		if(timer_1_flag)
		{
			
		}
		/* fill in body of infinite loop */
	}

	return 0;	/* never reached, but main() must return a value */
}
