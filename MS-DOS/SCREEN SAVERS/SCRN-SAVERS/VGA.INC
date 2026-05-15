;
;       VGA.INC
;
;       declares the VGA-specific procedures used by VGAMoire.
;



MaxBound        equ     8               ;velocity variables are in range [-MaxBound,-MinBound] || [MinBound,MaxBound]
MinBound        equ     3


BytesPerLine    equ     80              ;bytes in one horizontal line
VideoBufferSeg  equ     0a000h          ;segment of video buffer
CGenRAMSeg      equ     0a000h          ;segment of character generator RAM
TextBufferSeg   equ     0b000h          ;text memory starts here
OriginOffset    equ     0               ;byte offset of (0,0)
ByteOffsetShift equ     3               ;used to convert pixels to byte offset
RMWbits         equ     0               ;value for Data Rotate/Func Select reg



MaxY            dw      479             ;maximum y-coordinate
MaxX            dw      639             ;maximum x-coordinate



refresh proc    near                    ;enable/disable screen refresh
;       call with al = 00h --> enable refresh
;                    = 01h --> disable refresh
        mov     ah,12h
        mov     bl,36h
        int     10h
        ret
refresh endp



getDAC  proc    near                    ;read video DAC color registers
;       ARGS:   al = video DAC color register to start at
;               cx = 3 * (number of registers to read)
;               es:di -> where to store registers read
        mov     dx,03c7h                ;set video DAC read
        cli                             ;disable interrupts
        out     dx,al
        mov     dx,03c9h                ;read video DAC color registers
@@vDACget:
        in      al,dx                   ;get color register value
        and     al,3fh                  ;mask off the upper 2 bits
        stosb                           ;store it
        loop    @@vDACget               ;loop until done
        sti                             ;enable interrupts
        ret
getDAC  endp



setDAC  proc    near                    ;set video DAC color registers
;       ARGS:   al = video DAC color register to start at
;               cx = 3 * (number of registers to write)
;               ds:si -> where to get values to write
        mov     dx,03c8h                ;set video DAC write
        cli                             ;disable interrupts
        out     dx,al
        mov     dx,03c9h                ;write video DAC color registers
@@vDACset:
        lodsb                           ;get stored video DAC color values
        out     dx,al                   ;write value to video DAC color reg
        loop    @@vDACset               ;loop until done
        sti                             ;enable interrupts
        ret
setDAC  endp



SETCOLORS       macro
        mov     si,offset blackcolor    ;where to get video DAC color defs from
        mov     al,0                    ;set video DAC color regs 0 thru 5
        mov     cx,6*3
        call    setDAC
        mov     al,20                   ;set video DAC color reg 20
        mov     cx,1*3
        call    setDAC
        mov     al,7                    ;set video DAC color reg 7
        mov     cx,1*3
        call    setDAC
        mov     al,56                   ;set video DAC color regs 56 thru 63
        mov     cx,8*3
        call    setDAC
endm



CGenModeSet     proc    near
        push    si
        push    ds
        push    cs                      ;set up addressibility for our data
        pop     ds
        ; Program the Sequencer
        cli                             ;disable interrupts
        mov     dx,3c4h                 ;Sequencer port address
        mov     si,offset @@SeqParms
        mov     cx,4
@@L01:
        lodsw                           ;ah=val. for Seq. reg.,  al=reg. num.
        out     dx,ax
        loop    @@L01
        sti                             ;enable interrupts
        ; Program the Graphics Controller
        mov     dl,0ceh                 ;dx=3ceh (Graphics Controller port address)
        mov     si,offset @@GCParms
        mov     cx,3
@@L02:
        lodsw
        out     dx,ax
        loop    @@L02
        pop     ds
        pop     si
        ret
@@SeqParms      dw      0100h           ;synchronous reset
                dw      0402h           ;CPU writes only to map 2
                dw      0704h           ;sequential addressing
                dw      0300h           ;clear synchronous reset
@@GCParms       dw      0204h           ;select map 2 for CPU reads
                dw      0005h           ;disable odd-even addressing
                dw      0006h           ;map starts at A000:0000
CGenModeSet     endp



CGenModeClear   proc    near
        push    si
        push    ds
        push    cs                      ;set up addressibility for our data
        pop     ds
        ; Program the Sequencer
        cli                             ;disable interrupts
        mov     dx,3c4h                 ;Sequencer port address
        mov     si,offset @@SeqParms
        mov     cx,4
@@L01:
        lodsw                           ;ah=val. for Seq. reg.,  al=reg. num.
        out     dx,ax
        loop    @@L01
        sti                             ;enable interrupts
        ; Program the Graphics Controller
        mov     dl,0ceh                 ;dx=3ceh (Graphics Controller port address)
        mov     si,offset @@GCParms
        mov     cx,3
@@L02:
        lodsw
        out     dx,ax
        loop    @@L02
        mov     ah,0fh                  ;get video mode
        int     10h
        cmp     al,7
        jne     @@L03
        mov     ax,0806h                ;program Graphics Controller
        out     dx,ax                   ;  to start map at B000:0000
@@L03:
        pop     ds
        pop     si
        ret
@@SeqParms      dw      0100h           ;synchronous reset
                dw      0302h           ;CPU writes to maps 0 and 1
                dw      0304h           ;odd-even addressing
                dw      0300h           ;clear synchronous reset
@@GCParms       dw      0004h           ;select map 0 for CPU reads
                dw      1005h           ;enable odd-even addressing
                dw      0e06h           ;map starts at B800:0000
CGenModeClear   endp



PixelAddr10     proc    near            ;gets address of pixel
;       ARGS:   AX = y-coordinate
;               BX = x-coordinate
;       RETS:   AH = bit mask
;               BX = byte offset in buffer
;               CL = number of bits to shift left
;               ES = video buffer segment
        mov     cl,bl                   ;cl = low-order byte of x
        push    dx                      ;preserve dx
        mov     dx,BytesPerLine         ;ax = y*BytesPerLine
        mul     dx
        pop     dx
        shr     bx,1
        shr     bx,1
        shr     bx,1                    ;bx = x/8
        add     bx,ax                   ;bx = y*BytesPerLine + x/8
;        add     bx,OriginOffset         ;bx = byte offset in video buffer
        mov     ax,VideoBufferSeg
        mov     es,ax                   ;es:bx = byte address of pixel
        and     cl,7                    ;cl = x&7
        xor     cl,7                    ;cl = number of bits to shift left
        mov     ah,1                    ;ah = unshifted bit mask
        ret
PixelAddr10     endp


                    
Line10  proc    near
        ARG     ARGx1, ARGy1, ARGx2, ARGy2, ARGn:BYTE = ARGS            ;declare arguments
        LOCAL   VARvertincr, VARincr1, VARincr2, VARroutine = VARS      ;declare local variables
        push    bp
        mov     bp,sp                   ;save stack context
        sub     sp,VARS                 ;allocate space for local variables
        push    si
        push    di
        ; configure the Graphics Controller
        mov     dx,3ceh                 ;dx = Graphics Controller port addr
        mov     ah,[ARGn]               ;ah = pixel value
        xor     al,al                   ;al = Set/Reset Register number
        out     dx,ax
        mov     ax,0f01h                ;ah = 1111b (bit plane mask for Enable Set/Reset)
        out     dx,ax                   ;al = Enable Set/Reset Register #
        mov     ah,RMWbits              ;bits 3 and 4 of ah = function
        mov     al,3                    ;al = Data Rotate/Func Select reg #
        out     dx,ax
        ; check for vertical line
        mov     si,BytesPerLine         ;increment for video buffer
        mov     cx,[ARGx2]
        sub     cx,[ARGx1]              ;cx = x2-x1
        jz      VertLine10              ;jump if vertical line
        ; force x1<x2
        jns     @@L01                   ;jump if x2>x1
        neg     cx                      ;cx = x1-x2
        mov     bx,[ARGx2]              ;exchange x1 and x2
        xchg    bx,[ARGx1]
        mov     [ARGx2],bx
        mov     bx,[ARGy2]              ;exchange y1 and y2   [check first??]
        xchg    bx,[ARGy1]              ;these are the two lines i missed
        mov     [ARGy2],bx
        ; calculate dy = ABS(y2-y1)
@@L01:
        mov     bx,[ARGy2]
        sub     bx,[ARGy1]              ;bx = y2-y1
        jz      HorizLine10             ;jump if horizontal line
        jns     @@L03                   ;jump if slope is positive
        neg     bx                      ;bx = y1-y2
        neg     si                      ;negate increment for buffer interleave
        ; select appropriate routine for slope of line
@@L03:
        mov     [VARvertincr],si        ;save vertical increment
        mov     [VARroutine],offset LoSlopeLine10
        cmp     bx,cx
        jle     @@L04                   ;jump if dy<=dx (slope<=1)
        mov     [VARroutine],offset HiSlopeLine10
        xchg    bx,cx                   ;exchange dy and dx
        ; calculate initial decision variable and increments
@@L04:
        shl     bx,1                    ;bx = 2*dy
        mov     [VARincr1],bx           ;incr1 = 2*dy
        sub     bx,cx
        mov     si,bx                   ;si = 2*dy-dx
        sub     bx,cx
        mov     [VARincr2],bx           ;incr2 = 2*(dy-dx)
        ; calculate first pixel address
        push    cx                      ;preserve register
        mov     ax,[ARGy1]              ;AX = y
        mov     bx,[ARGx1]              ;BX = x
        call    PixelAddr10             ;ah = bit mask
                                        ;es:bx -> buffer
                                        ;cl = # bits to shift left
        mov     di,bx                   ;es:di -> buffer
        shl     ah,cl                   ;ah = bit mask in proper position
        mov     bl,ah                   ;ah,bl = bit mask
        mov     al,8                    ;al = Bit Mask Register number
        pop     cx                      ;restore register
        inc     cx                      ;cx = # of pixels to draw
        jmp     [VARroutine]            ;jump to appropriate routine for slope

VertLine10:                             ;routine for vertical lines
        mov     ax,[ARGy1]              ;ax = y1
        mov     bx,[ARGy2]              ;bx = y2
        mov     cx,bx
        sub     cx,ax                   ;cx = dy
        jge     @@L31                   ;jump if dy>=0
        neg     cx                      ;force dy>=0
        mov     ax,bx                   ;ax = y2
@@L31:
        inc     cx                      ;cx = # of pixels to draw
        mov     bx,[ARGx1]              ;bx = x
        push    cx                      ;preserve register
        call    PixelAddr10             ;ah = bit mask
                                        ;es:bx -> buffer
                                        ;cl = # bits to shift left
        ; set up Graphics Controller
        shl     ah,cl                   ;ah = bit mask in proper position
        mov     al,8                    ;al = Bit Mask reg number
        out     dx,ax
        pop     cx                      ;restore register
        ; draw the line
@@L32:
        or      es:[bx],al              ;set pixel
        add     bx,si                   ;increment to next line
        loop    @@L32
        jmp     Lexit

HorizLine10:                            ;routine for horizontal lines (slope=0)
        push    ds                      ;preserve ds
        mov     ax,[ARGy1]
        mov     bx,[ARGx1]
        call    PixelAddr10             ;ah = bit mask
                                        ;es:bx -> buffer
                                        ;cl = # bits to shift left
        mov     di,bx                   ;es:di -> buffer
        mov     dh,ah                   ;dh = unshifted bit mask for leftmost byte
        not     dh
        shl     dh,cl                   ;dh = reverse bit make for first byte
        not     dh                      ;dh = bit mask for first byte
        mov     cx,[ARGx2]
        and     cl,7
        xor     cl,7                    ;cl = number of bits to shift left
        mov     dl,0ffh                 ;dl = unshifted bit mask for rightmost byte
        shl     dl,cl                   ;dl = bit mask for last byte
        ; determine byte offset of first and last pixel in the line
        mov     ax,[ARGx2]              ;ax = x2
        mov     bx,[ARGx1]              ;bx = x1
        mov     cl,ByteOffsetShift      ;number of bits to shift to convert pixels to bytes
        shr     ax,cl                   ;ax = byte offset of x2
        shr     bx,cl                   ;bx = byte offset of x1
        mov     cx,ax
        sub     cx,bx                   ;cx = (# bytes in line) -1
        ; get Graphics Controller port address into dx
        mov     bx,dx                   ;bh = bit mask for first byte
                                        ;bl = bit mask for last byte
        mov     dx,3ceh                 ;dx = Graphics Controller port
        mov     al,8                    ;al = Bit Mask Register number
        ; make video buffer addressable through ds:si
        push    es
        pop     ds
        mov     si,di                   ;ds:si -> video buffer
        ; set pixels in leftmost byte of the line
        or      bh,bh
        js      @@L43                   ;jump if byte-aligned (x1 is leftmost pixel in byte)
        or      cx,cx
        jnz     @@L42                   ;jump if more than one byte in the line
        and     bl,bh                   ;bl = bit mask for the line
        jmp     short @@L44
@@L42:
        mov     ah,bh                   ;ah = bit mask for 1st byte
        out     dx,ax                   ;update Graphics Controller
        movsb                           ;update bit planes
        dec     cx
        ; use a fast 8086 machine instruction to draw the remainder of the line
@@L43:
        mov     ah,11111111b            ;ah = bit mask
        out     dx,ax                   ;update Bit Mask Register
        rep     movsb                   ;update all pixels in the line
        ; set pixels in the rightmost byte of the line
@@L44:
        mov     ah,bl                   ;ah = bit mask for last byte
        out     dx,ax                   ;update Graphics Controller
        movsb                           ;update bit planes
        pop     ds                      ;restore ds
        jmp     short Lexit

                                        ;es:di -> video buffer
                                        ;al = Bit Mask Register number
                                        ;bl = bit mask for 1st pixel
                                        ;cx = # of pixels to draw
                                        ;dx = Graphics Controller port addr
                                        ;si = decision variable
LoSlopeLine10:                          ;routine for dy>=dx (slope<=1)
@@L10:
        mov     ah,bl                   ;ah = bit mask for next pixel
@@L11:
        or      ah,bl                   ;mask current pixel position
        ror     bl,1                    ;rotate pixel value
        jc      @@L14                   ;jump if bit mask rotated to leftmost position
        ; bit mask not shifted out
        or      si,si                   ;test sign of d
        jns     @@L12                   ;jump if d>=0
        add     si,[VARincr1]           ;d = d+incr1
        loop    @@L11
        out     dx,ax                   ;update Bit Mask Register
        or      es:[di],al              ;set remaining pixel(s)
        jmp     short Lexit
@@L12:
        add     si,[VARincr2]           ;d = d+incr2
        out     dx,ax                   ;update Bit Mask Register
        or      es:[di],al              ;update bit planes
        add     di,[VARvertincr]        ;increment y
        loop    @@L10
        jmp     short Lexit
        ; bit mask shifted out
@@L14:
        out     dx,ax                   ;update Bit Mask Register ...
        or      es:[di],al              ;update bit planes
        inc     di                      ;increment x
        or      si,si                   ;test sign of d
        jns     @@L15                   ;jump if non-negative
        add     si,[VARincr1]           ;d = d+incr1
        loop    @@L10
        jmp     short Lexit
@@L15:
        add     si,[VARincr2]           ;d = d+incr2
        add     di,[VARvertincr]        ;vertical increment
        loop    @@L10
        jmp     short Lexit

                                        ;es:di -> video buffer
                                        ;ah = bit mask for 1st pixel
                                        ;al = Bit Mask Register number
                                        ;cx = # of pixels to draw
                                        ;dx = Graphics Controller port addr
                                        ;si = decision variable
HiSlopeLine10:                          ;routine for dy<dx (slope>1)
        mov     bx,[VARvertincr]        ;bx = y-increment
@@L21:
        out     dx,ax                   ;update Bit Mask Register
        or      es:[di],al              ;update bit planes
        add     di,bx                   ;increment y
@@L22:
        or      si,si                   ;test sign of d
        jns     @@L23                   ;jump if d>=0
        add     si,[VARincr1]           ;d = d+incr1
        loop    @@L21
        jmp     short Lexit
@@L23:
        add     si,[VARincr2]           ;d = d+incr2
        ror     ah,1                    ;rotate bit mask
        adc     di,0                    ;increment di if when mask rotated to leftmost pixel position
        loop    @@L21

        ; restore default Graphics Controller state and return to caller
Lexit:  xor     ax,ax                   ;ah = 0, al = 0
        out     dx,ax                   ;restore Set/Reset Register
        inc     ax                      ;ah = 0, al = 1
        out     dx,ax                   ;restore Enable Set/Reset Register
        mov     al,3                    ;ah = 0, al = 3
        out     dx,ax                   ;al = Data Rotate/Func Select reg #
        mov     ax,0ff08h               ;ah = 11111111b, al = 8
        out     dx,ax                   ;restore Bit Mask Register
        pop     di                      ;restore registers and return
        pop     si
        mov     sp,bp                   ;deallocate local variables
        pop     bp                      ;restore stack context
        ret     ARGS                    ;return and pop arguments from stack
Line10  endp



copyfont        proc    near            ;al=0 to restore, 1 to save
        cmp     [fontblocks],0          ;do we save any character generator RAM
        jnz     @@yesfont
        jmp     @@nofont
@@yesfont:
        push    ds                      ;save ds
        push    ax
        mov     ax,4400h                ;map logical EMS pages to physical page frame
        mov     cl,[fontblocks]         ;number of blocks of font RAM to save
        xor     ch,ch
        inc     cl                      ;round up and
        shr     cl,1                    ;  convert to num. of EMS pages needed
        xor     bh,bh
        mov     bl,[useEMS]             ;al=logical page to start at
@@maploop:
        push    ax                      ;map the EMS pages
        push    bx
        mov     dx,[EMShandle]
        int     67h
        or      ah,ah
        jnz     @@maperror              ;@@maperror cleans up and returns with carry set, to indicate a failure
        pop     bx
        pop     ax
        inc     bl
        inc     al
        loop    @@maploop
        mov     bx,[storetext]
        xor     dx,dx
        pop     ax
        or      al,al                   ;copy from or to font RAM
        jz      @@restore
        mov     es,bx                   ;make pointer to save area
        mov     di,dx
        mov     bx,CGenRAMSeg           ;points to character RAM on map 2
        mov     ds,bx
        xor     si,si
        jmp     @@copyfont
@@restore:                              ;copy font RAM back
        mov     ds,bx
        mov     si,dx
        mov     bx,CGenRAMSeg           ;points to character RAM on map 2
        mov     es,bx
        xor     di,di
@@copyfont:
        call    CGenModeSet             ;program VGA card to allow r/w access to character RAM
        mov     ah,cs:[fontblocks]      ;number of blocks of font RAM to copy
        xor     al,al
        mov     cl,4
        shl     ah,cl
        mov     cx,ax
        rep     movsw                   ;copy font RAM
        call    CGenModeClear           ;program VGA card back to normal
        pop     ds                      ;restore ds
@@nofont:
        clc
        ret
@@maperror:
        pop     bx                      ;pop saved registers
        pop     ax
        pop     ax
        pop     ds
        call    freebuf
        stc
        ret
copyfont        endp



loadfont        proc                    ;loads a ROM font using a best-fit algorithm
        push    es
        mov     es,[keybuff]            ;set es=0000:0000
        mov     ax,word ptr es:[485h]
        cmp     ax,8                    ;8x8 font?
        ja      @@8x14
        mov     al,02h                          ; if font <= 8x8, load 8x8
        jmp     @@loadfont
@@8x14:
        cmp     ax,14                   ;8x14 font?
        ja      @@8x16
        mov     al,01h                          ; if font <= 8x14, load 8x14
        jmp     @@loadfont
@@8x16:
        mov     al,04h                          ; if font > 8x14, load 8x16
@@loadfont:
        mov     ah,11h                  ;load ROM font (al and bl are already set appropriately)
        int     10h
        pop     es
        ret
loadfont        endp



copytext        proc    near            ;copy text from buffer to buffer
        push    ax
        or      al,al
        jnz     @@store
        mov     ax,1c02h                ;restore video state
        mov     cx,7                    ;all video info
        mov     bx,[storetext]
        mov     es,bx
        mov     bx,[buffersize]         ;es:bx -> buffer for video state
        add     bx,[mousesize]          ;index past the mouse state save buffer
        push    bx                      ;store offset temporarily
        int     10h
        mov     ah,1bh
        xor     bx,bx                   ;   (don't need to set es because it retains its value through the previous int)
        pop     di                      ;reuse video state buffer to get some video info
        int     10h                     ;get some video info
        mov     bl,byte ptr es:[2bh]
        cmp     [fontblocks],bl         ;did we save the primary font block?
        jg      @@secondary             ;if so, check about the secondary font block
        call    loadfont                ;load the appropriate ROM font
@@secondary:
        cmp     bl,byte ptr es:[2ch]    ;if primary and secondary font blocks are the same
        je      @@store                 ;  then skip processing the block a second time
        mov     bl,byte ptr es:[2ch]
        cmp     fontblocks,bl           ;did we save the secondary font block?
        jg      @@store                 ;if so, we're all set
        call    loadfont                ;load the appropriate ROM font
@@store:
        pop     ax
        push    ds                      ;save ds
        push    [buffersize]            ;save video text buffer size
        push    [textbuff]              ;save textbuff
        mov     bx,[storetext]          ;buffer is at bx:dx
        xor     dx,dx
        or      al,al                   ;copy in which direction
        jz      @@restore
        push    cs                      ;set es = cs
        pop     es
        pop     ds                      ;ds = textbuff
        xor     si,si
        mov     es,bx                   ;into bx:dx = es:di
        mov     di,dx
        jmp     @@copytext
@@restore:
        push    cs                      ;set ds = cs
        pop     ds
        pop     es                      ;es = textbuff
        xor     di,di
        mov     ds,bx                   ;copy this buffer
        mov     si,dx
@@copytext:
        pop     cx                      ;cx = buffersize
        rep     movsb                   ;copy text
        pop     ds                      ;restore ds
        or      al,al
        jz      @@done
        mov     ax,1c01h                ;save video state
        mov     cx,7                    ;all video info
        mov     bx,[storetext]
        mov     es,bx
        mov     bx,[buffersize]         ;es:bx -> buffer for video state
        add     bx,[mousesize]          ;index past the mouse state save buffer
        int     10h
@@done:
        ret
copytext        endp



STORE   macro
        mov     al,1                    ;set al = 1 to
        call    copytext                ;  copy text from video area to our buffer
        mov     al,1                    ;set al = 1 to
        call    copyfont                ;  copy font RAM to our buffer
        jc      @@gofail
endm



SETMODE macro
        mov     ax,12h                  ;set graphics mode (VGA 640x480 16 color)
        int     10h                     ;  (seems to work w/EGA, too...)
endm



RESTORE macro
        ; try to restore from EMS, first, if [fontblocks] is set, but if not possible, do it the old-fashioned way
        xor     al,al                   ;set al = 0 to signal restore
        call    copyfont
        call    getbuf
        jc      @@fail                  ;if couldn't access buffer, we can't do anything more
        xor     al,al                   ;set al = 0 to signal restore
        call    copytext
        push    es
        mov     ax,17h                  ;restore mouse state
        push    [storetext]             ;get segment of save buffer
        pop     es
        mov     dx,[buffersize]         ;offset past stored video screen
        int     33h
        pop     es
        mov     ax,1                    ;show pointer (only actually does if it was showing before)
        int     33h
        call    freebuf                 ;restore EMS state if used
endm



public  ARGS
;public  ARGn
;public  ARGx1
;public  ARGx2
;public  ARGy1
;public  ARGy2
public  ByteOffsetShift
public  BytesPerLine
public  CGenModeClear
public  CGenModeSet
public  CGenRAMSeg
public  HiSlopeLine10
public  HorizLine10
public  Lexit
public  Line10
public  LoSlopeLine10
public  MaxBound
public  MaxX
public  MaxY
public  MinBound
public  OriginOffset
public  PixelAddr10
public  RMWbits
public  TextBufferSeg
;public  VARincr1
;public  VARincr2
;public  VARroutine
;public  VARvertincr
public  VertLine10
public  VideoBufferSeg
public  copyfont
public  copytext
public  getDAC
public  VARS
public  loadfont
public  refresh
public  setDAC

;______ eof ________________________________________________________ eof ______
