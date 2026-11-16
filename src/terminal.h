#ifndef AVIKAN_TERMINAL_H
#define AVIKAN_TERMINAL_H

/* Put a single character to the terminal */
void terminal_putchar(char c);

/* Print a null-terminated string */
void terminal_print(const char *str);

/* Initialize the terminal (VGA) */
void terminal_init(void);

#endif /* AVIKAN_TERMINAL_H */