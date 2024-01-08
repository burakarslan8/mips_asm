	#+ BITTE NICHT MODIFIZIEREN: Vorgabeabschnitt
	#+ ------------------------------------------

.data

str_eingabe: .asciiz "numeral: "
str_rueckgabewert: .asciiz "\nRueckgabewert: "
romdigit_table: .word 0, 0, 0, 100, 500, 0, 0, 0, 0, 1, 0, 0, 50, 1000, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 10, 0, 0, 0, 0, 0, 0, 0

.text

.eqv SYS_PUTSTR 4
.eqv SYS_PUTCHAR 11
.eqv SYS_PUTINT 1
.eqv SYS_EXIT 10

main:
	# Roemische Zahl wird ausgegeben:
	li $v0, SYS_PUTSTR
	la $a0, str_eingabe
	syscall

	li $v0, SYS_PUTSTR
	la $a0, test_numeral
	syscall
	
	li $v0, SYS_PUTSTR
	la $a0, str_rueckgabewert
	syscall

	move $v0, $zero
	# Aufruf der Funktion roman:
	la $a0, test_numeral
	jal roman
	
	# Rueckgabewert wird ausgegeben:
	move $a0, $v0
	li $v0, SYS_PUTINT
	syscall

	# Ende der Programmausfuehrung:
	li $v0, SYS_EXIT
	syscall
	
	# Hilfsfunktion: int romdigit(char digit);
romdigit:
	move $v0, $zero
	andi $t0, $a0, 0xE0
	addi $t1, $zero, 0x40
	beq $t0, $t1, _romdigit_not_null
	addi $t1, $zero, 0x60
	beq $t0, $t1, _romdigit_not_null
	jr $ra
_romdigit_not_null:
	andi $t0, $a0, 0x1F
	sll $t0, $t0, 2
	la $t1, romdigit_table
	add $t1, $t1, $t0
	lw $v0, 0($t1)
	jr $ra

	#+ BITTE VERVOLLSTAENDIGEN: Persoenliche Angaben zur Hausaufgabe 
	#+ -------------------------------------------------------------

	# Vorname:
	# Nachname:
	# Matrikelnummer:
	
	#+ Loesungsabschnitt
	#+ -----------------

.data

test_numeral: .asciiz "CLXXXIV"

.text

roman:
	move $t3, $zero # gesamtwert
	move $t4, $zero # initialisiere für das nächste zeichen
	la $t7, test_numeral
	
	# stack um $ra-WERT zu speichern
	addi $sp, $sp, -4
    	sw $ra, 0($sp)

loop:
	lb $t1, 0($t7)      # das aktuelle zeichen
	beqz $t1, end # null-terminator

	# dekodiere das aktuelle zeichen
	move $a0, $t1
	jal romdigit
	move $t2, $v0  # wert des aktuellen zeichens
	
	lb $t4, 1($t7)      # das nächste zeichen
	beqz $t4, add_last
	
	# dekodiere das nächste zeichen
	move $a0, $t4
	jal romdigit
	move $t5, $v0  # wert des nächsten zeichens
	
	blt $t2, $t5, substract
	add $t3, $t3, $t2
	
	j next

add_last:
	add $t3, $t3, $t2
	j end
	
substract:
	sub $t3, $t3, $t2

next:
	addi $t7, $t7, 1
	
	j loop

end:
	lw $ra, 0($sp)
    	addi $sp, $sp, 4
    	
	move $v0, $t3
	jr $ra
