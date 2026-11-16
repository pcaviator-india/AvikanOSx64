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
 *  [1]  = Code segment (execute/read, 4KB pages, privilege 0)
 *  [2]  = Data segment (read/write, 4KB pages, privilege 0)
 *  [3]  = Code segment (for privilege 3)
 *  [4]  = Data segment (for privilege 3)
 */

/* Null descriptor (must be all zeros) */
struct gdt_entry gdt[5];
struct gdt_pointer gp;

/* Forward declaration */
void gdt_flush(unsigned long long gdt_ptr);

/* Initialize GDT */
void gdt_init(void) {
    /* Set up the GDT pointer - null entry + 3 code/data segments */
    gp.limit = sizeof(gdt) - 1;
    gp.base  = (unsigned long long)&gdt;
    
    /* Null descriptor */
    gdt[0].limit_low = 0;
    gdt[0].base_low = 0;
    gdt[0].base_middle = 0;
    gdt[0].access = 0;
    gdt[0].granularity = 0;
    gdt[0].base_high = 0;
    
    /* Code Segment Descriptor (Kernel mode, privilege 0) */
    /* Base = 0, Limit = 4GB (4KB pages × 1M entries), 64-bit code segment */
    gdt[1].limit_low = 0xFFFF;         /* Limit 0-15 bits */
    gdt[1].base_low = 0;               /* Base 0-15 bits */
    gdt[1].base_middle = 0;            /* Base 16-23 bits */
    gdt[1].access = 0x9A;              /* Present, Ring0, Exec, Read */
    /* 64-bit code segment flag in granularity, plus 32-bit segment */
    gdt[1].granularity = 0xCF;         /* 4KB pages, 32-bit, Granularity */
    gdt[1].base_high = 0;              /* Base 32-39 bits */
    
    /* Data Segment Descriptor (Kernel mode, privilege 0) */
    gdt[2].limit_low = 0xFFFF;
    gdt[2].base_low = 0;
    gdt[2].base_middle = 0;
    gdt[2].access = 0x92;              /* Present, Ring0, Write, Read */
    gdt[2].granularity = 0xCF;         /* 4KB pages, 32-bit, Granularity */
    gdt[2].base_high = 0;
    
    /* Code Segment Descriptor (User mode, privilege 3) */
    gdt[3].limit_low = 0xFFFF;
    gdt[3].base_low = 0;
    gdt[3].base_middle = 0;
    gdt[3].access = 0x9A;              /* Present, Ring3, Exec, Read */
    gdt[3].granularity = 0xCF;
    gdt[3].base_high = 0;
    
    /* Data Segment Descriptor (User mode, privilege 3) */
    gdt[4].limit_low = 0xFFFF;
    gdt[4].base_low = 0;
    gdt[4].base_middle = 0;
    gdt[4].access = 0x92;              /* Present, Ring3, Write, Read */
    gdt[4].granularity = 0xCF;
    gdt[4].base_high = 0;
    
    /* Load GDT into CPU */
    gdt_flush((unsigned long long)&gp);
}

/* GDT Flush - loads GDTR register via inline assembly */
void gdt_flush(unsigned long long gdt_ptr) {
    __asm__ volatile ("lgdt %0" : /* no output */ : "m" (gdt_ptr));
}