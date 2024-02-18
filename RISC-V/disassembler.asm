	.data
hex_prompt:  .asciiz "Enter a 32-bit hexadecimal instruction: "
msg_unhandled: .asciiz "Unhandled instruction\n"

.globl _start
	.text
_start:
    # Print prompt
    li a0, 1       # File descriptor: STDOUT
    li a1, hex_prompt
    li a2, 40      # Length of the prompt
    li a7, 64      # System call number: write
    ecall

    # Read input
    li a0, 0       # File descriptor: STDIN
    li a1, buffer
    li a2, 32      # Buffer size
    li a7, 63      # System call number: read
    ecall

    # Disassemble instruction
    la a0, buffer   # Load address of the buffer
    jal disassemble_riscv

    # Exit program
    li a7, 10      # System call number: exit
    ecall

# Function to disassemble RISC-V instruction
disassemble_riscv:
    lw t0, 0(a0)    # Load the 32-bit instruction from buffer

    # Extract opcode and funct3 fields
    andi t1, t0, 127         # Extract opcode (7 LSB)
    andi t2, t0, 3584        # Extract funct3 (bits 12-14)

    # Decode and disassemble based on opcode and funct3
    beqz t1, handle_r_type    # Branch to handle R-type instruction if opcode is zero
    beqz t2, handle_i_type    # Branch to handle I-type instruction if funct3 is zero
    beq t2, t2, handle_b_type  # Branch to handle B-type instruction if funct3 is 000
    beq t2, t2, handle_load    # Branch to handle Load instruction if funct3 is 000
    beq t2, t2, handle_store   # Branch to handle Store instruction if funct3 is 000

    # Unhandled instruction
    li a0, 1       # File descriptor: STDOUT
    li a1, msg_unhandled
    li a2, 23      # Length of the message
    li a7, 64      # System call number: write
    ecall
    j _exit

handle_r_type:
    # Decode R-type instruction
    lw t3, 20(t0)   # rd
    lw t4, 12(t0)   # rs1
    lw t5, 7(t0)    # rs2
    lw t6, 0(t0)    # funct7

    # Check funct3 and funct7 to determine the specific R-type instruction
    andi t7, t0, 7   # Extract funct3
    andi t8, t0, 127 # Extract funct7 (7 LSB)

    beqz t7, add_sub_r_type   # Branch to handle ADD and SUB
    j unhandled_instruction

add_sub_r_type:
    bnez t8, unhandled_instruction  # Only handle ADD and SUB

    beqz t6, add_instruction
    j sub_instruction

add_instruction:
    # ADD instruction
    jal print_register
    j _exit

sub_instruction:
    # SUB instruction
    jal print_register 
    j _exit

handle_i_type:
    # Decode I-type instruction
    lw t3, 20(t0)   # rd
    lw t4, 12(t0)   # rs1
    lw t5, 0(t0)    # imm[11:0]

    # Check funct3 to determine the specific I-type instruction
    andi t6, t0, 7   # Extract funct3

    beqz t6, addi_i_type   # Branch to handle ADDI
    j unhandled_instruction

addi_i_type:
    # ADDI instruction
    jal print_register_imm
    j _exit

handle_b_type:
    # Decode B-type instruction
    lw t3, 12(t0)   # rs1
    lw t4, 7(t0)    # rs2
    lw t5, 1(t0)    # imm[4] (bit 11)
    lw t6, 20(t0)   # imm[10:5]
    lw t7, 24(t0)   # imm[12] (bit 12)
    lw t8, 25(t0)   # imm[10:11]

    # Check funct3 to determine the specific B-type instruction
    andi t9, t0, 7   # Extract funct3

    beqz t9, beq_b_type   # Branch to handle BEQ
    j unhandled_instruction

beq_b_type:
    # BEQ instruction
    jal print_branch
    j _exit

handle_load:
    # Decode Load instruction
    lw t3, 20(t0)   # rd
    lw t4, 12(t0)   # rs1
    lw t5, 0(t0)    # imm[11:0]

    # Check funct3 to determine the specific Load instruction
    andi t6, t0, 7   # Extract funct3

    beqz t6, lw_load   # Branch to handle LW
    j unhandled_instruction

lw_load:
    # LW instruction
    jal print_load_store
    j _exit

handle_store:
    # Decode Store instruction
    lw t3, 12(t0)   # rs1
    lw t4, 7(t0)    # rs2
    lw t5, 0(t0)    # imm[11:5]

    # Check funct3 to determine the specific Store instruction
    andi t6, t0, 7   # Extract funct3

    beqz t6, sw_store   # Branch to handle SW
    j unhandled_instruction

sw_store:
    # SW instruction
    jal print_load_store
    j _exit

unhandled_instruction:
    # Print unhandled instruction message
    li a0, 1       # File descriptor: STDOUT
    li a1, msg_unhandled
    li a2, 23      # Length of the message
    li a7, 64      # System call number: write
    ecall
    j _exit

# Print register value
print_register:
    move a0, t1
    move a1, t2
    move a2, t3
    li a7, 64      # System call number: write
    ecall
    j _exit

# Print register value with immediate
print_register_imm:
    move a0, t1
    move a1, t2
    move a2, t3
    move a3, t4
    li a7, 64      # System call number: write
    ecall
    j _exit

# Print branch instruction
print_branch:
    move a0, t1
    move a1, t2
    move a2, t3
    move a3, t4
    move a4, t5
    li a7, 64      # System call number: write
    ecall
    j _exit

# Print load/store instruction
print_load_store:
    move a0, t1
    move a1, t2
    move a2, t3
    li a7, 64      # System call number: write
    ecall
    j _exit

_exit:
    li a7, 10      # System call number: exit
    ecall

.section .bss
buffer: .space 32
