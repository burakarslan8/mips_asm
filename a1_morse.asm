	#+ BITTE NICHT MODIFIZIEREN: Vorgabeabschnitt
	#+ ------------------------------------------

.data

decoder_heap: .asciiz "_ETIANMSURWDKGOHVF*L*PJBXCYZQ**54*3***2&*+****16=/***(*7***8*90"
str_eingabe: .asciiz "morse_in: "
str_ausgabe: .asciiz "\ntext_out: "
str_rueckgabewert: .asciiz "\nRueckgabewert: "
buf_out: .space 256

.text

.eqv SYS_PUTSTR 4
.eqv SYS_PUTCHAR 11
.eqv SYS_PUTINT 1
.eqv SYS_EXIT 10

main:
	# Morsecode-Eingabe wird ausgegeben:
	li $v0, SYS_PUTSTR
	la $a0, str_eingabe
	syscall

	li $v0, SYS_PUTSTR
	la $a0, test_msg
	syscall
	
	li $v0, SYS_PUTSTR
	la $a0, str_rueckgabewert
	syscall

	move $v0, $zero
	# Aufruf der Funktion morse:
	la $a0, decoder_heap
	la $a1, test_msg
	la $a2, buf_out
	jal morse
	
	# Rueckgabewert und Ausgabetext wird ausgegeben:
	move $a0, $v0
	li $v0, SYS_PUTINT
	syscall

	li $v0, SYS_PUTSTR
	la $a0, str_ausgabe
	syscall

	li $v0, SYS_PUTSTR
	la $a0, buf_out
	syscall

	# Ende der Programmausfuehrung:
	li $v0, SYS_EXIT
	syscall
	
	#+ BITTE VERVOLLSTAENDIGEN: Persoenliche Angaben zur Hausaufgabe 
	#+ -------------------------------------------------------------

	# Vorname:
	# Nachname:
	# Matrikelnummer:
	
	#+ Loesungsabschnitt
	#+ -----------------
.data

test_msg: .asciiz ".... .- .-.. .-.. ---"

.text
morse:
    move $t0, $a1  # test_msg zeiger
    move $t1, $a2  # buf_out zeiger
    move $t2, $a0  # decoder_heap zeiger
    li $t7, 0      # zähler 

decode_loop:
    lb $t3, 0($t0)
    beq $t3, 32, add_underscore   # leerzeichen (ASCII 32)
    beqz $t3, end      # null-terminator
    move $t4, $t2        # $t4 auf den Anfang des Decoder-Heaps setzen

decode_char:
    lb $t5, 0($t4)
    beq $t3, 46, dot     # punkt (ASCII 46)
    beq $t3, 45, dash    # strich (ASCII 45)

next_char:
    addi $t0, $t0, 1     # test_msg zeiger
    j decode_loop

dot:
    sub $k1, $t4, $t2	  # k1 memory substraktion
    sll $k1, $k1, 1
    addi $k1, $k1, 1
    add $k1, $k1, $t2
    move $t4, $k1     # linker Kindknoten
    j decode_next_char

dash:
    sub $k1, $t4, $t2	  # k1 memory substraktion
    sll $k1, $k1, 1
    addi $k1, $k1, 2
    add $k1, $k1, $t2
    move $t4, $k1     # rechter Kindknoten
    j decode_next_char

decode_next_char:
    lb $t3, 1($t0)
    addi $t0, $t0, 1
    beqz $t3, save_char
    beq $t3, 32, save_char
    j decode_char

save_char:
    move $k1, $zero
    lb $t5, 0($t4)
    sb $t5, 0($t1)       # speichern
    addi $t1, $t1, 1     # buf_out zeiger
    addi $t7, $t7, 1     # zähler erhöhen
    j next_char

add_underscore:
    li $t8, 95
    sb $t8, 0($t1)
    addi $t1, $t1, 1
    addi $t7, $t7, 1
    move $t3, $zero
    j next_char

end:
    # funktion beenden
    li $t8, 0
    sb $t8, 0($t1)
    move $v0, $t7
    jr $ra
