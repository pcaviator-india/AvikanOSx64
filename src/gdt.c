/*------------------------------------------------------
  gdt.c - Global Descriptor Table for x64
  ------------------------------------------------------*/
#include "gdt.h"

/* GDT Descriptor (64-bit style) */
struct gdt_entry {
    unsigned short limit_low;
    unsigned short base_low;
    unsigned char base_middle;
    unsigned char access;
    unsigned char granularity;
    unsigned char base_high;
} __attribute__((packed));

/* GDT Pointer structure */
struct gdt_pointer {
    unsigned short limit;
    unsigned long long base;
} __attribute__((packed));

/* GDT Entries:
 *  [0]  = NULL descriptor
 *  [1]  = Code segment (32-bit, execute/read, 4KB pages, privilege 0)
 *  [2]  = Data segment (32-bit, read/write, 4KB pages, privilege 0)
 *  [3]  = Code segment (32-bit, for privilege 3)
 *  [4]  = Data segment (32-bit, for privilege 3)
 *  [5]  = Code segment (64-bit long mode, execute/read, privilege 0)
 */

/* GDT Entries - defined in entry.asm (must be in identity-mapped range) */
extern struct gdt_entry gdt_start[6];
extern struct {
    unsigned short limit;
    unsigned int base;
} gdt_ptr;

/* Forward declaration */
void gdt_flush(void);

/* Initialize GDT */
void gdt_init(void) {
    /* Set up the GDT pointer */
    gdt_ptr.limit = sizeof(gdt_start) - 1;
    gdt_ptr.base  = (unsigned int)&gdt_start;
    
    /* Null descriptor */
    gdt_start[0].limit_low = 0;
    gdt_start[0].base_low = 0;
    gdt_start[0].base_middle = 0;
    gdt_start[0].access = 0;
    gdt_start[0].granularity = 0;
    gdt_start[0].base_high = 0;

    /* Code Segment Descriptor (Kernel mode, privilege 0) */
    /* Base = 0, Limit = 4GB (4KB pages × 1M entries), 64-bit code segment */
    gdt_start[1].limit_low = 0xFFFF;         /* Limit 0-15 bits */
    gdt_start[1].base_low = 0;               /* Base 0-15 bits */
    gdt_start[1].base_middle = 0;            /* Base 16-23 bits */
    gdt_start[1].access = 0x9A;              /* Present, Ring0, Exec, Read */
    /* 64-bit code segment flag in granularity, plus 32-bit segment */
    gdt_start[1].granularity = 0xCF;         /* 4KB pages, 32-bit, Granularity */
    gdt_start[1].base_high = 0;              /* Base 32-39 bits */

    /* Data Segment Descriptor (Kernel mode, privilege 0) */
    gdt_start[2].limit_low = 0xFFFF;
    gdt_start[2].base_low = 0;
    gdt_start[2].base_middle = 0;
    gdt_start[2].access = 0x92;              /* Present, Ring0, Write, Read */
    gdt_start[2].granularity = 0xCF;         /* 4KB pages, 32-bit, Granularity */
    gdt_start[2].base_high = 0;

    /* Code Segment Descriptor (User mode, privilege 3) */
    gdt_start[3].limit_low = 0xFFFF;
    gdt_start[3].base_low = 0;
    gdt_start[3].base_middle = 0;
    gdt_start[3].access = 0x9A;              /* Present, Ring3, Exec, Read */
    gdt_start[3].granularity = 0xCF;
    gdt_start[3].base_high = 0;

    /* Data Segment Descriptor (User mode, privilege 3) */
    gdt_start[4].limit_low = 0xFFFF;
    gdt_start[4].base_low = 0;
    gdt_start[4].base_middle = 0;
    gdt_start[4].access = 0x92;              /* Present, Ring3, Write, Read */
    gdt_start[4].granularity = 0xCF;
    gdt_start[4].base_high = 0;

    /* Code Segment Descriptor (64-bit long mode, kernel, privilege 0) */
    gdt_start[5].limit_low = 0xFFFF;
    gdt_start[5].base_low = 0;
    gdt_start[5].base_middle = 0;
    gdt_start[5].access = 0x9A;
    gdt_start[5].granularity = 0xA0;
    gdt_start[5].base_high = 0;

    /* Load GDT into CPU */
    gdt_flush();
}

/* GDT Flush - loads GDTR register with our GDT */
void gdt_flush(void) {
    __asm__ volatile ("lgdt %0" : /* no output */ : "m" (gdt_ptr));
}