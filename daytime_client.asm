section .data
    ; syscalls 
    SYS_EXIT        EQU     60
    SYS_READ        EQU     0
    SYS_WRITE       EQU     1
    SYS_SOCKET      EQU     41
    SYS_CLOSE       EQU     13
    SYS_CONNECT     EQU     42
    PORT            EQU     0x0D00  ; Port 13 in little-endian hex

    ; some constants
    STDOUT          EQU     1
    AF_INET         EQU     2
    SOCK_STREAM     EQU     1

buffer: 
    ; Buffer to store the received data initiallized with nulls
    times 256   db 0  

address:
    sa_family   dw      2
    sin_port    dw      PORT
    sin_addr    dd      0x0460A384
                dq      0       ; Padding

section .text
global _start

; rdi   rsi   rdx   r10   r8    r9
_start:
    ; Create socket
    ; syscall socket(AF_INET, SOCK_STREAM, 0)
    mov     rax, SYS_SOCKET             ; Socket system call number
    mov     rdi, AF_INET                ; AF_INET = 2
    mov     rsi, SOCK_STREAM            ; SOCK_STREAM = 1
    xor     rdx, rdx                    ; Protocol = 0
    syscall
    
    mov     r12, rax
    ; Check for error
    test    rax, rax
    js      handle_error

    ; Connect to server
    ; syscall connect(sock_fd, addr, addrlen)
    mov     rax, SYS_CONNECT            ; Connect system call number
    mov     rdi, r12                    ; Socket file descriptor
    lea     rsi, address                ; Address of sockaddr_in structure
    mov     rdx, 16                     ; Size of sockaddr_in structure
    syscall

    ; Check for error
    test    rax, rax
    js      handle_error

    ; Receive data
    ; syscall read(sock_fd, buffer, len)
    mov     rax, SYS_READ               ; Read system call number
    mov     rdi, r12                    ; Socket file descriptor
    lea     rsi, [buffer]               ; Buffer address
    mov     rdx, 256                    ; Maximum length to receive
    syscall

    ; Check for error
    test    rax, rax
    js      handle_error

    ; Print received data
    ; syscall write(stdout_fd, buffer, len)
    mov     rax, SYS_WRITE              ; Write system call number
    mov     rdi, STDOUT                 ; STDOUT file descriptor
    lea     rsi, [buffer]               ; Buffer address
    mov     rdx, 256                    ; Length
    syscall

    ; Close socket
    ; syscall close(sock_fd)
    mov     rax, SYS_CLOSE              ; Close system call number
    mov     rdi, r12                    ; Socket file descriptor
    syscall

    ; Exit
    ; syscall exit(status)
    mov     rax, SYS_EXIT               ; Exit syscall number
    xor     rdi, rdi                    ; Clear EDI register
    syscall

handle_error:
    ; Handle error
    mov     rdi, rax                    ; Move error code to EDI
    mov     rax, SYS_EXIT               ; Exit syscall number
    syscall

