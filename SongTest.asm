; BeepTest.asm
; Sends the value from the switches to the
; tone generator peripheral once per second.

ORG 0

Line1:
	; Set note
	LOADI  &B0000000000010101
	; Send to the peripheral
	OUT    Beep
	LOADI  -8
	STORE  DelayTime
	; Delay for 1 second
	CALL   Delay
	
	CALL   End
	
	; Do it again
	LOADI  &B0000000000010101
	OUT    Beep
	LOADI  -8
	STORE  DelayTime
	CALL   Delay
	
	CALL   End
	
	LOADI  &B0000000000011100
	OUT    Beep
	LOADI  -8
	STORE  DelayTime
	CALL   Delay
	
	CALL   End

	LOADI  &B0000000000011100
	OUT    Beep
	LOADI  -8
	STORE  DelayTime
	CALL   Delay

	CALL   End
	
	LOADI  &B0000000000100010
	OUT    Beep
	LOADI  -8
	STORE  DelayTime
	CALL   Delay

	CALL   End
	
	LOADI  &B0000000000100010
	OUT    Beep
	LOADI  -8
	STORE  DelayTime
	CALL   Delay

	CALL   End
	
	LOADI  &B0000000000011100
	OUT    Beep
	LOADI  -16
	STORE  DelayTime
	CALL   Delay
	
	CALL   End
	
	LOADI  &B0000000000011010
	OUT    Beep
	LOADI  -8
	STORE  DelayTime
	CALL   Delay
	
	CALL   End
	
	LOADI  &B0000000000011010
	OUT    Beep
	LOADI  -8
	STORE  DelayTime
	CALL   Delay
	
	CALL   End
	
	LOADI  &B0000000000011001
	OUT    Beep
	LOADI  -8
	STORE  DelayTime
	CALL   Delay
	
	CALL   End
	
	LOADI  &B0000000000011001
	OUT    Beep
	LOADI  -8
	STORE  DelayTime
	CALL   Delay
	
	CALL   End
	
	LOADI  &B0000000000010111
	OUT    Beep
	LOADI  -8
	STORE  DelayTime
	CALL   Delay
	
	CALL   End
	
	LOADI  &B0000000000010111
	OUT    Beep
	LOADI  -8
	STORE  DelayTime
	CALL   Delay
	
	CALL   End
	
	LOADI  &B0000000000010101
	OUT    Beep
	LOADI  -16
	STORE  DelayTime
	CALL   Delay
	
	CALL   End
	
	JUMP   0
; Subroutine at note end
End:
	LOADI  0
	OUT    Beep
	LOADI  -1
	STORE  DelayTime
	CALL   Delay
	RETURN
; Subroutine to delay for 0.2 seconds.
Delay:
	OUT    Timer
WaitingLoop:
	IN     Timer
	ADD    DelayTime
	JNEG   WaitingLoop
	RETURN

; Note Constants
DelayTime: DW 0
Gsharp: DW &B0000000000000001 ;2
A: DW &B0000000000000010 ;2
Asharp: DW &B0000000000000011 ;2
B: DW &B0000000000000100 ;2
C: DW &B0000000000000101
Csharp: DW &B0000000000000110
D: DW &B0000000000000111
Dsharp: DW &B0000000000001000
E: DW &B0000000000001001
F: DW &B0000000000001010
Fsharp: DW &B0000000000001011
G: DW &B0000000000001100


; IO address constants
Switches:  EQU 000
LEDs:      EQU 001
Timer:     EQU 002
Hex0:      EQU 004
Hex1:      EQU 005
Beep:      EQU &H40











