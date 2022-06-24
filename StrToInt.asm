TITLE Portfolio Project: Designing low-level I/O procedures     (Proj6_lilients.asm)

; Author: Sophia Lilienthal
; Last Modified: 12/4/21
; OSU email address: lilients@oregonstate.edu
; Course number/section: CS271 Section 400
; Project Number: 6           Due Date: 12/5/21
; Description:  This program uses a mixture of macros and procedures to get 10 valid integers
;				(that will fit in a 32 byte register) one at a time from the user. Using Irvine's
;				ReadString and WriteString procedures only, the integers are read as strings and 
;				then converted into their decimal equivalents. These numeric values are then stored
;				in an array. The program then converts these numeric values to their equivalent ascii
;				digits and displays the integers, their sum, and their average (all as strings).

INCLUDE Irvine32.inc

;------------------------------------------------------------------------
; Name: mGetString
;
; Prompts the user to enter a signed integer. Saves the user's input into 
; user_num var and saves the number of characters entered into byte_count var.
;
; Preconditions: All parameters must be declared in the data segment.
;
; Receives: prompt = OFFSET prompt_1
;			mem_address = OFFSET user_num
;			mem_size = user_num_size
;			num_char = OFFSET byte_count
;
; Returns: Saves user input to user_num var. Saves number of characters
; user entered to byte_count var.
;------------------------------------------------------------------------

mGetString MACRO prompt:REQ, mem_address:REQ, mem_size:REQ, num_char:REQ

	; Preserve registers that will be used in this macro
	push EDX
	push ECX
	push EAX

	; Prompts user for a signed integer
	mov EDX, prompt
	call WriteString

	; Saves user input to user_num var and number of characters entered to byte_count var
	mov EDX, mem_address
	mov ECX, mem_size
	call ReadString
	mov [num_char], EAX										

	; Restore registers to pre-macro condition
	pop EAX
	pop ECX
	pop EDX

ENDM


;------------------------------------------------------------------------
; Name: mDisplayString
;
; Takes the OFFSET of a string array as a parameter and displays the string
; in the console.
;
; Preconditions: Strings must be declared in data segment.
;
; Receives: str_1 = OFFSET string
;
; Returns: Displays the string which is stored in the given memory location.
;------------------------------------------------------------------------

mDisplayString MACRO str_1:REQ

	; Preserves registers that will be used in this macro
	push EDX

	; Displays the string given as a parameter
	mov EDX, str_1
	call WriteString

	; Restores registers to pre-macro condition
	pop EDX

ENDM


.data

title_1				BYTE		"Project 6: Designing low-level I/O procedures    By Sophia Lilienthal", 0
intro_1				BYTE		"Please provide 10 signed decimal integers, one at a time. Each number ", 13, 10,
								"needs to be small enough to fit inside a 32 bit register. ", 13, 10,
								"After you have finished inputting the raw numbers, I will display ", 13, 10,
								"a list of the integers, their sum, and their average value.", 0
prompt_1			BYTE		"Please enter a signed integer: ", 0
user_num			BYTE		20 DUP(?)
user_num_size		DWORD		SIZEOF user_num						; Size of mem destination to pass to ReadString
byte_count			DWORD		0									; Num of characters of user input integer
is_neg				DWORD		0									; 0 if user entered num is positive, 1 if negative
user_num_int		SDWORD		?									; Array of user entered nums as ints
error_1				BYTE		"ERROR: You did not enter a signed number or your number was too big!", 0
int_array			SDWORD		10 DUP(?)							; Holds array of ints after converted from strings
int_sum				SDWORD		?									; Holds int value of sum
int_avg				SDWORD		?									; Holds int value of avg
format_str			BYTE		"   ", 0
print_nums			BYTE		"You entered the following numbers:", 0
print_sum			BYTE		"The sum of these numbers is: ", 0
print_avg			BYTE		"The truncated average is: ", 0
int_to_str			BYTE		20 DUP(?)							; Holds str digits of int val after converted from int in reverse order	
final_str			BYTE		20 DUP(?)							; Holds str digits of int val after converted from int in correct order
goodbye				BYTE		"Thanks for playing! Farewell.", 0


.code
main PROC

	; Displays title and introduction to program
	mDisplayString OFFSET title_1
	call CrLf
	call CrLf
	mDisplayString OFFSET intro_1
	call CrLf
	call CrLf


;-------------------------------------------------------------------
; Uses ReadVal proc to get 10 valid string inputs from user and converts
;	each one to its decimal numeric equivalent and stores it in user_num_int var.
;	After each loop, stores each numeric equivalent in consecutive memory in 
;	int_array var.
;
;-------------------------------------------------------------------

	; Sets ECX to get 10 inputs
	mov ECX, 10											; Sets ECX to get 10 inputs

	; Sets EDI to first mem address of int_array
	mov EDI, OFFSET int_array

_GetInputLoop:
; Calls ReadVal proc 10 times to get 10 valid inputs, saving the decimal int in consecutive mem in int_array

	; Gets input and saves decimal val in user_num_int var
	push OFFSET error_1
	push OFFSET user_num_int
	push OFFSET prompt_1
	push OFFSET user_num
	push user_num_size
	push OFFSET byte_count
	call ReadVal

	; Moves val from user_num_int to current mem address in int_array addressed by EDI
	mov EBX, user_num_int
	mov [EDI], EBX

	; Moves EDI pointer to next mem address in int_array
	add EDI, TYPE int_array

	loop _GetInputLoop
	call CrLf


;-------------------------------------------------------------------
; Now that valid decimal ints are in int_array var, finds the sum of all
;	ints in int_array var.
;
;-------------------------------------------------------------------
	
	mov ESI, OFFSET int_array								; Moves address of first element of int_array in ESI
	mov EAX, 0												; Sets accumulator to 0 to hold sum
	mov ECX, 10

_FindSumLoop:
; Loops through int_array and finds the sum of all the elements

	add EAX, [ESI]
	add ESI, TYPE int_array

	loop _FindSumLoop

	mov int_sum, EAX										; Stores final sum in int_sum
	mov EAX, 0												; Restores EAX


;-------------------------------------------------------------------
; Finds avg of int elements in int_array var using int_sum var and stores
;	avg in int_avg var.
;
;-------------------------------------------------------------------
	
	mov EBX, 10												; Divisor (10) in EBX
	mov EAX, int_sum
	cdq
	idiv EBX
	
	mov int_avg, EAX										; Moves final value of avg to int_avg var
	mov EAX, 0												; Restores EAX
	mov EBX, 0												; Restores EBX


;-------------------------------------------------------------------
; Uses WriteVal proc and mDisplayString macro to print out ascii representations
;	of user entered integers.
;
;-------------------------------------------------------------------

	; Prints intro for printing nums entered
	mDisplayString OFFSET print_nums
	call CrLf

	; Prepares to pass first decimal val of int_array to WriteVal proc
	mov ESI, OFFSET int_array

	; Sets ECX to length of int_array to print all vals
	mov ECX, 10

_PrintStrLoop:
; Uses WriteVal proc to convert each decimal val of int_array to ascii, prints ascii string of digits, then moves to next dec val

	; Calls WriteVal with current int value in ESI
	push OFFSET final_str
	push [ESI]
	push OFFSET int_to_str
	call WriteVal

	; Adds a space after each val is displayed, for formatting
	mDisplayString OFFSET format_str

	; Increments ESI to point at next val in int_array
	add ESI, 4

	loop _PrintStrLoop
	call CrLf


;-------------------------------------------------------------------
; Uses WriteVal proc and mDisplayString macro to print out ascii representations
;	of sum of all values in int_array. Decimal val of sum has already
;	been calculated above and is stored in int_sum var.
;
;-------------------------------------------------------------------

	; Prints intro for printing sum
	mDisplayString OFFSET print_sum

	; Prepares to pass first decimal val of int_array to WriteVal proc
	mov ESI, OFFSET int_sum

	; Calls WriteVal to convert sum to string and print out
	push OFFSET final_str
	push [ESI]
	push OFFSET int_to_str
	call WriteVal
	call CrLf


;-------------------------------------------------------------------
; Uses WriteVal proc and mDisplayString macro to print out ascii representations
;	of average of all values in int_array. Decimal val of average has already
;	been calculated above and is stored in int_avg var.
;
;-------------------------------------------------------------------

	; Prints intro for printing sum
	mDisplayString OFFSET print_avg

	; Prepares to pass first decimal val of int_array to WriteVal proc
	mov ESI, OFFSET int_avg

	; Calls WriteVal to convert sum to string and print out
	push OFFSET final_str
	push [ESI]
	push OFFSET int_to_str
	call WriteVal
	call CrLf
	call CrLf

	; Says goodbye to user
	mDisplayString OFFSET goodbye
	call CrLf


	Invoke ExitProcess,0	; exit to operating system
main ENDP


;------------------------------------------------------------------------
; Name: ReadVal
;
; Invokes mGetString to get a string of digits from user. Converts this string 
; to its numeric decimal representation. Validates whether the decimal number is 
; too large or too small to fit in a 32 bit reg, if so, throws an error and reprompts
; for new string. Also validates the string of digits is a valid number (no letters,
; symbols, etc.), if invalid, throws error and reprompts. Finally, validates if the 
; user enters nothing, if so, throws error and reprompts. If number passes all validation,
; numeric decimal value is saved in user_num_int var.
;
; Preconditions: byte_count var must hold the number of characters entered by user.
; user_num var must be BYTE array declared in data segment with 20 bytes. user_num_int var
; must be SDWORD declared in data segment.
;
; Postconditions: None 
;
; Receives: [EBP + 8] = OFFSET byte_count
;			[EBP + 12] = user_num_size
;			[EBP + 16] = OFFSET user_num
;			[EBP + 20] = OFFSET prompt_1
;			[EBP + 24] = OFFSET user_num_int
;			[EBP + 28] = OFFSET error_1
;			mGetString MACRO
;
; Returns: Changes vars byte_count, user_num, user_num_int. Saves numeric decimal 
; representation of user entered string in user_num_int var for use in main proc.
;------------------------------------------------------------------------

ReadVal PROC

	; Set up local variables
	LOCAL numInt:DWORD								; Will be used to calculate decimal value
	LOCAL numChar:BYTE								; Will hold character's decimal value

	; Preserve registers that will be used in this proc
	push EAX
	push ESI
	push ECX
	push EBX
	push EDI
	push EDX

_UserPrompt:
; Gets a user entered num and starts the validation and conversion process

	; Gets user entered num as a string and num of characters entered
	mGetString [EBP + 20], [EBP + 16], [EBP + 12], [EBP + 8]

	; Checks if user entered nothing (empty input), if so displays error message
	mov EBX, [EBP + 8]								; [EBP + 8] = OFFSET byte_count
	cmp EBX, 0
	je _NotValid

	; Checks if user entered num is negative 
	mov ESI, [EBP + 16]								; [EBP + 16] = OFFSET user_num
	mov AL, '-'
	cmp [ESI], AL
	je _Neg

	; Checks if user entered num is prepended with '+'
	mov AL, '+'
	cmp [ESI], AL
	je _Pos

	; Sets the count to the number of chars the user entered
	mov ECX, [EBP + 8]								; [EBP + 8] = OFFSET byte_count
	
	; Sets up the number to be used when calculating the decimal value
	mov numInt, 0
	jmp _ConvertCharLoop

_Pos:
; If the first char of user entered num is '+', starts loop at second char

	; Sets the count to the number of chars the user entered, minus 1 for positive sign
	mov ECX, [EBP + 8]								; [EBP + 8] = OFFSET byte_count
	dec ECX

	; Increments ESI to point at second char entered
	inc ESI
	
	; Sets up the number to be used when calculating the decimal value
	mov numInt, 0

_ConvertCharLoop:
; Converts each char one by one to its decimal equivalent and saves final decimal value in user_num_int var

	; Gets character of string to convert to int
	cld												; ESI will increment
	lodsb											; Character is now in AL register

	; Checks if character is less than 48, if so displays error message
	cmp AL, 48
	jl _NotValid

	; Checks if character is greater than 57, if so displays error message
	cmp AL, 57
	jg _NotValid

	; Subtracts 48 from decimal equivalent of character and saves result to numChar var
	sub AL, 48
	mov numChar, AL

	; Checks if numInt is large enough to start being validated, must be at least 9 digits to begin process of checking
	cmp numInt, 99999999
	jbe _FinalInt

	; Starts to check whether current val of numInt and value of ECX prove number will fit into a 32 bit reg
	cmp numInt, 214748364							; If numInt is less than given num, jumps to check ECX
	jb _LastNum

	cmp numInt, 214748365							; If numInt is >= than given num, num will be too large for 32 bit reg
	jae _NotValid

	cmp ECX, 1										; If ECX > 1, the number is too large for 32 bit reg
	ja _NotValid

	cmp	numChar, 7									; If number has made it here so far, num will be within 40 to 49
	ja _NotValid									; Jumps if char val to be added is greater than 7 which would make last digits > 47
	
	jmp _FinalInt

_LastNum:
; Checks if this is the second to last  or last digit to be added to numInt

	cmp ECX, 1										; If ECX is greater than 1, number will be too large
	ja _NotValid

_FinalInt:
; Current val of numInt has proven to be within valid range, continues calculation to find char's value

	; Multiplies already calculated number numInt by 10 and saves result in EBX
	mov EAX, 10
	mul numInt
	mov EBX, EAX

	; Resets EAX and moves numChar back into AL
	mov EAX, 0
	mov AL, numChar

	; Adds numInt and numChar to find final decimal value of character
	add EBX, EAX									; EBX = 10 * numInt + numChar
	mov numInt, EBX									; Holds this final val in numInt for future calculations with next chars
	mov EAX, 0										; Restore EAX

	loop _ConvertCharLoop

	; Stores the final decimal value of the entire string byte in user_num_int var
	mov EDI, [EBP + 24]								; [EBP + 24] = OFFSET user_num_int
	mov EBX, numInt
	mov [EDI], EBX

	jmp _End


_Neg:
; If the first char of user entered num is '-', makes notes that num is neg and starts loop at second char


	; Sets the count to the number of chars the user entered, minus 1 for negative sign
	mov ECX, [EBP + 8]								; [EBP + 8] = OFFSET byte_count
	dec ECX

	; Increments ESI to point at second char entered
	inc ESI
	
	; Sets up the number to be used when calculating the decimal value
	mov numInt, 0

_ConvertNegCharLoop:
; Converts each char one by one to its decimal equivalent and saves the final decimal value in user_num_int var

	; Gets character of string to convert to int
	cld												; ESI will increment
	lodsb											; Character is now in AL register

	; Checks if character is less than 48
	cmp AL, 48
	jl _NotValid

	; Checks if character is greater than 57
	cmp AL, 57
	jg _NotValid

	; Subtracts 48 from decimal equivalent of character and saves result to numChar var
	sub AL, 48
	mov numChar, AL

	; Checks if numInt is large enough to start being validated, must be at least 9 digits to begin process to check
	cmp numInt, 99999999							
	jbe _FinalNegInt

	; Starts to check whether current val of numInt and value of ECX prove number will fit into a 32 bit reg
	cmp numInt, 214748364							; If numInt is less than given num, jumps to check ECX
	jb _LastNegNum

	cmp numInt, 214748365							; If numInt is >= than given num, num will be too large for 32 bit reg
	jae _NotValid

	cmp ECX, 1										; If ECX > 1, the number is too large for 32 bit reg
	ja _NotValid

	cmp	numChar, 8									; If number has made it here so far, num will be within 40 to 49 (last digits)
	ja _NotValid									; Jumps if char val to be added is greater than 8 which would make last digits > 48
	
	jmp _FinalNegInt

_LastNegNum:
; Checks if this is the second to last or last digit to be added to numInt

	cmp ECX, 1										; If ECX is greater than 1, number will be too large
	ja _NotValid

_FinalNegInt:
; Current val of numInt has proven to be within valid range, continues calculation to find char's value

	; Multiplies already calculated number numInt by 10 and saves result in EBX
	mov EAX, 10
	mul numInt
	mov EBX, EAX

	; Resets EAX and moves numChar back into AL
	mov EAX, 0
	mov AL, numChar

	; Adds numInt and numChar to find final decimal value of character
	add EBX, EAX									; EBX = 10 * numInt + numChar
	mov numInt, EBX									; Holds this final val in numInt for future calculations with next chars
	mov EAX, 0										; Restore EAX

	loop _ConvertNegCharLoop

	; Stores the final decimal value of the entire string byte in user_num_int var
	mov EDI, [EBP + 24]								; [EBP + 24] = OFFSET user_num_int
	mov EBX, numInt
	neg EBX											; Turns number into negative val before moving to user_num_int var
	mov [EDI], EBX

	jmp _End


_NotValid:
; If the user enters non-digits other than something which will indicate sign, '-' or '+', or the entered num
; is too large for a 32 bit reg, an error message displays.

	mDisplayString [EBP + 28]						; [EBP + 28] = OFFSET error_1
	call CrLf
	call CrLf

	; Jumps to prompt user for new number
	jmp _UserPrompt


_End:

	; Restore registers to pre-procedure condition
	pop EDX
	pop EDI
	pop EBX
	pop ECX
	pop ESI
	pop EAX
	
	RET 24											; 24 is the number in bytes that were pushed to stack before proc call

ReadVal ENDP


;------------------------------------------------------------------------
; Name: WriteVal
;
; Takes a numeric decimal value and converts it into its ascii representation.
; Prints out the converted str to console and saves it in final_int var.
;
; Preconditions: int_to_str var and final_str var must be 10 byte arrays each 
; declared in the data segment. int_array var must be SDWORD array declared in 
; data segment. int_sum and int_avg vars must be SDWORDs declared in data segment.
;
; Postconditions: None.
;
; Receives: [EBP + 8] = OFFSET int_to_str
;			[EBP + 12] = int to be converted
;			[EBP + 16] = OFFSET final_str
;			mDisplayString MACRO
;
; Returns: Changes int_to_str var and final_str var and prints to console
; ascii representation of given int value.
;------------------------------------------------------------------------

WriteVal PROC

	; Set up LOCAL variables
	LOCAL counter:DWORD									; Will be used to count how many digits are converted

	; Preserve registers that will be used in this proc
	push EAX
	push EBX
	push ECX
	push EDX
	push EDI
	push ESI

	; Move int to be converted into ESI
	mov ESI, [EBP + 12]									; [EBP + 12] = int to be converted

	; Moves address that string conversion will be stored in to EDI
	mov EDI, [EBP + 8]									; [EBP + 8] = OFFSET int_to_str

	; Checks if int is negative
	mov EBX, 0
	cmp ESI, EBX
	jl _IsNeg

	; Moves whole int to EAX to be divided
	mov EAX, ESI

	; Sets up counter
	mov counter, 0

_ConvertLoop:
; Takes one digit at a time from current int and converts to its ascii representation, saves in reverse order to int_to_str var

	; Divides int in EAX by 10
	mov EBX, 10
	mov EDX, 0
	div EBX												; numChar will be in EDX, remaining int digits are in EAX

	; NumChar will be in EDX, to get ascii representation, add 48
	add EDX, 48

	; Saves remaining int digits in EAX
	push EAX

	; Clears EAX for AL to hold string char
	mov EAX, 0

	; Loads string char into int_to_str byte array var in reverse order
	cld
	mov EAX, EDX
	stosb

	; Puts remaining digits of int back in EAX
	pop EAX

	; Adds 1 to counter
	inc counter

	; Checks if there are no more digits to be converted
	cmp EAX, 0
	je _EndConversion

	jmp _ConvertLoop

_IsNeg:
; If the int value is negative, there are a couple more steps to take. Makes the int positive for the conversion, then adds
; '-' sign before the string is reversed into correct order

	; Moves whole int to EAX to be divided
	mov EAX, ESI

	; Makes int positive for the conversion, will add '-' to beginning of string at end
	neg EAX

	; Sets up counter
	mov counter, 0

_ConvertNegLoop:
; Takes one digit at a time from current int and converts to its ascii representation, saves in reverse order to int_to_str var

	; Divides int in EAX by 10
	mov EBX, 10
	mov EDX, 0
	div EBX												; numChar will be in EDX, remaining int digits are in EAX

	; NumChar will be in EDX, to get ascii representation, add 48
	add EDX, 48

	; Saves remaining int digits in EAX
	push EAX

	; Clears EAX for AL to hold string char
	mov EAX, 0

	; Loads string char into int_to_str byte array var in reverse order
	cld
	mov EAX, EDX
	stosb

	; Puts remaining digits of int back in EAX
	pop EAX

	; Adds 1 to counter
	inc counter

	; Checks if there are no more digits to be converted
	cmp EAX, 0
	ja _ConvertNegLoop									; If EAX is greater than 0, there are more digits to be converted

	; If end of the digits converted, must add '-' to end of string
	cld
	mov AL, '-'
	stosb
	inc counter											; Increment counter by 1 to account for '-'
	mov EAX, 0											; Restores EAX to 0

	jmp _EndConversion


_EndConversion:
; Because the string is stored in reverse, reverse it to be in correct order, then call mDisplayString to print str to console
	
	; Decrement EDI by 1 so it is pointing at the last element of int_to_str, which should be first element of final_str
	dec EDI
	mov ESI, EDI										; Moves the address in EDI to ESI because it will now be the source

	; Moves OFFSET of final_str var first element into EDI 
	mov EDI, [EBP + 16]									; [EBP + 16] = OFFSET final_str (correct order str)

	; Sets up loop counter
	mov ECX, counter

_ReverseLoop:
; Reverses loop of ascii characters to be in correct order

	; Starts to transfer chars from ESI to EDI, using AL as placeholder
	std
	lodsb

	; Moves value from AL to current value of EDI to create correct order str
	mov [EDI], EAX

	; Increments EDI to point foward at next byte in array for next char
	inc EDI

	loop _ReverseLoop

	; Calls mDisplayString Macro to display the converted ascii string
	mDisplayString [EBP + 16]
	
	; Restore registers to pre-procedure condition
	pop ESI
	pop EDI
	pop EDX
	pop ECX
	pop EBX
	pop EAX
	
	RET 12												; 12 is the number in bytes pushed to the stack before proc call

WriteVal ENDP

END main
