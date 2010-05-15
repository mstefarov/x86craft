;; module taking care of console i/o
;; this module will later on be using the file i/o module as a base for console i/o.
;; for now, just basic i/o support.

global console_putchar
global console_putstr

extern __imp__GetStdHandle@4
extern __imp__WriteConsoleA@20
extern __imp__lstrlen@4

%define  GetStdHandle   [__imp__GetStdHandle@4]
%define WriteConsoleA [__imp__WriteConsoleA@20]
%define       lstrlen        [__imp__lstrlen@4]

NULL              equ   0
STD_INPUT_HANDLE  equ -10
STD_OUTPUT_HANDLE equ -11
STD_ERROR_HANDLE  equ -12

section .text

  console_putchar:
    push ebp
    mov ebp, esp
    sub esp, 4

    cmp [OutputHandle], dword 0
    je .putchar_getconsole

    .putchar_put:
      push dword NULL
      lea eax, [ebp - 4]
      push eax
      push dword 1
      lea eax, [ebp + 8]
      push eax
      push dword [OutputHandle]
      call WriteConsoleA
      jmp .putchar_return

    .putchar_getconsole:
      push STD_OUTPUT_HANDLE
      call console_getconsole
      mov [OutputHandle], eax
      jmp .putchar_put

    .putchar_return:
      mov esp, ebp
      pop ebp
      ret 4
      
  console_putstr:
    push ebp
    mov ebp, esp
    sub esp, 4
    
    cmp [OutputHandle], dword 0
    je .putstr_getconsole
    
    .putstr_put:
      push dword [ebp + 8]
      call lstrlen
      push dword NULL
      lea ecx, [ebp - 4]
      push ecx
      push eax
      push dword [ebp + 8]
      push dword [OutputHandle]
      call WriteConsoleA
      jmp .putstr_return
    
    .putstr_getconsole:
      push STD_OUTPUT_HANDLE
      call console_getconsole
      mov [OutputHandle], eax
      jmp .putstr_put
      
    .putstr_return:
      mov esp, ebp
      pop ebp
      ret 4

  console_getconsole:
    push ebp
    mov ebp, esp
    push dword [ebp + 8]
    call GetStdHandle
    mov esp, ebp
    pop ebp
    ret 4

section .data

  OutputHandle: dd 0
  InputHandle: dd 0
  ErrorHandle: dd 0
