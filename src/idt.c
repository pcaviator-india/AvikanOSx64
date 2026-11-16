/*------------------------------------------------------
  idt.c - Interrupt Descriptor Table for x64
  ------------------------------------------------------*/
#include "idt.h"
#include "terminal.h"

#define IDT_ENTRIES 256

/* IDT Descriptor */
struct idt_entry {
    unsigned short base_low;
    unsigned short selector;
    unsigned char always0;
    unsigned char flags;
    unsigned short base_high;
} __attribute__((packed));

/* IDT Pointer */
struct idt_pointer {
    unsigned short limit;
    unsigned long long base;
} __attribute__((packed));

/* IDT Entry handlers (placeholder for future use) */
struct idt_entry idt_entries[IDT_ENTRIES];
struct idt_pointer idt_pointer;

/* Forward declaration */
void idt_flush(unsigned long long idt_ptr);

/* Placeholder ISR handler */
static void isr_stub(void) {
    /* We'll just halt */
    __asm__ volatile ("hlt");
}

/* Set up IDT handler for a specific interrupt */
void idt_set_gate(unsigned char num, unsigned long long base, unsigned short selector, unsigned char flags) {
    idt_entries[num].base_low = (unsigned short)(base & 0xFFFF);
    idt_entries[num].base_high = (unsigned short)((base >> 16) & 0xFFFF);
    idt_entries[num].selector = selector;
    idt_entries[num].always0 = 0;
    idt_entries[num].flags = flags;
}

/* Initialize IDT */
void idt_init(void) {
    /* Initialize IDT pointer */
    idt_pointer.limit = (IDT_ENTRIES * sizeof(struct idt_entry)) - 1;
    idt_pointer.base = (unsigned long long)&idt_entries;
    
    /* Clear all IDT entries */
    for (int i = 0; i < IDT_ENTRIES; i++) {
        idt_set_gate((unsigned char)i, 0, 0, 0);
    }
    
    /* Install IRQ0 timer handler */
    idt_set_gate(0x20, (unsigned long long)isr_stub, 0x08, 0x8E); /* 0x8E = Present+Ring0+InterruptGate */
    
    /* Load IDT */
    idt_flush((unsigned long long)&idt_pointer);
}

/* IDT Flush - loads IDTR register via inline assembly */
void idt_flush(unsigned long long idt_ptr) {
    __asm__ volatile ("lidt %0" : /* no output */ : "m" (idt_ptr));
}