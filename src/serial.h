#ifndef AVIKAN_SERIAL_H
#define AVIKAN_SERIAL_H

void serial_init(void);
void serial_putchar(char c);
void serial_print(const char *str);

#endif /* AVIKAN_SERIAL_H */