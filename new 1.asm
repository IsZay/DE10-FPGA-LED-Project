; led.asm
; Steps brightness


LOADI 50  
OUT LED_Brightness



ModeLoop:
    LOAD Mode
    OUT LED_Mode
    ADDI 1
    STORE Mode
    ADDI -3
    JZERO ModeReset
    JUMP Update
    
    ModeReset:
    LOADI 0
    Store Mode
   
    
  
    
       

Update:
	IN Switches
    OUT LED_Pattern
    STORE SwitchPattern
    
	LOAD Bright
    OUT LED_Brightness

Loop:
  IN Timer
  ADDI -10	
  JPOS Step
  IN Switches
  SUB SwitchPattern
  JZERO Loop ; Loop if switch pattern hasn't changed
JUMP Update

Step:
	OUT Timer
	LOAD Bright
    ADDI 10
    STORE Bright
    ADDI -100
    JPOS Zero ; if over 100 roll around
    JUMP Update

Zero:	
	LOADI 0
    STORE Bright
    JUMP ModeLoop
    
 
    
SwitchPattern: DW 0
Bright: DW 0
Mode: DW 0

; IO address constants
Switches:       EQU 000
LED_Pattern:    EQU &H020
LED_Mode:       EQU &H021
LED_Brightness: EQU &H022
Timer: EQU 006  