ENTRY(EntryPoint) 
SECTIONS { 
  . = 1M; 
  .text : { 
    *(.text) 
  } 
} 
