/* for standalone testing of this file by itself using the simulator,
   keep the following line, but for in-lab activity with the Monitor Program
   to have a multi-file project, comment out the following line */

#define TEST_CHARIO


/* no #include statements should be required, as the character I/O functions
   do not rely on any other code or definitions (the .h file for these
   functions would be included in _other_ .c files) */


/* because all character-I/O code is in this file, the #define statements
   for the JTAG UART pointers can be placed here; they should not be needed
   in any other file */

#define JTAG_UART_BASE     0x10001000
#define JTAG_UART_DATA     (*(volatile unsigned int *)(JTAG_UART_BASE + 0))
#define JTAG_UART_STATUS   (*(volatile unsigned int *)(JTAG_UART_BASE + 4))

void PrintChar(unsigned char c)
{
    while ((JTAG_UART_STATUS & 0xFFFF << 16) == 0)
        ;
    JTAG_UART_DATA = c;
}

void PrintHexDigit(unsigned int digit)
{
    char c;
    if (digit < 10)
        c = '0' + digit;
    else
        c = 'A' + (digit - 10);

    PrintChar(c);
}


void PrintString(const char *s)
{
    while (*s != 0)
    {
        PrintChar(*s);
        s++;
    }
}

unsigned char GetChar()
{
    unsigned int data;

    while (1)
    {
        data = JTAG_UART_DATA;   // NOW this reads from the actual hardware register
        if (data & 0x8000)       // RVALID = bit 15
            break;
    }

    return (unsigned char)(data & 0xFF);
}

#ifdef TEST_CHARIO

/* this portion is conditionally compiled based on whether or not
   the symbol exists; it is only for standalone testing of the routines
   using the simulator; there is a main() routine in lab4.c, so
   for the in-lab activity, the following code would conflict with it */

int main (void)
{
   PrintString("hello\n");
   PrintHexDigit(1);
   PrintHexDigit(0xF);
   PrintChar(GetChar());
  /* place calls here to the various character-I/O routines
     to test their behavior, e.g., PrintString("hello\n");  */

  return 0;
} 

#endif /* TEST_CHARIO */
