;------ VGAMoire --------------------------------------------------------------
;
;       A text mode screen saver which saves the text display and draws a
;       pretty, moving graphic design on the screen.
;
;   ÚÄÄ
;   ³   moi³re (mw„r, m“r) n. [Fr, watered silk < MOHAIR] a fabric, esp. silk,
;   ³      rayon, or acetate, having a watered, or wavy, pattern.
;   ³                 _            _
;   ³   moi³r‚ (mw„r ra', m“-; m“r'a) adj. [Fr, pp. of /moirer/, to
;   ³      water < /moire/: see prec.] having a watered, or wavy, pattern,
;   ³      as certain fabrics, stamps, or metal surfaces --n.  1 a watered
;   ³      pattern pressed into cloth, etc. with engraved rollers  2 MOIRE
;   ÀÂÄ
;    ÀÄÄÄÄÄÄÄÄÄ From Webster's New World Dictionary, Third College Edition,
;               Copyright (C) 1988 by Simon & Schuster, Inc.
;
;------ CREDITS ---------------------------------------------------------------
;
;       Moire pattern generator for the VGA.
;       Written by Christopher Antos, July 1990.
;       Copyright (C) 1990 by Christopher Antos.
;
;       Inspired by seeing MAGIC for Windows.  Also inspired by a lack of
;       intelligent, small, pretty screen savers that restored the video and
;       mouse states correctly.
;
;       Linedraw routines are from "Programmer's Guide to PC & PS/2 Video
;       Systems", from Microsoft Press.
;
;       If you have any questions or comments, please contact me at:
;
;               Christopher Antos
;               2115 Windsor Drive
;               Ann Arbor, MI  48103-5652
;               (313)663-7912
;
;       I'm not too picky about people using this source code.  It is not,
;       however, public domain.  It is copyrighted.  If you use this source
;       code at all, then you are using the program, and should feel obligated
;       to send a donation just as if you were using the program itself.  See
;       the documentation for more information.
;
;------ COMPILING -------------------------------------------------------------
;
;       VGAMoire is written for Turbo Assembler 2.0 and uses "SMART" mode for
;       maximum code optimization.
;
;       To compile:
;
;               tasm /zi vgamoire
;               tlink /v /s /l vgamoire
;               del vgamoire.obj
;               tdstrip -s -c vgamoire
;
;       This creates the excutable file, VGAMOIRE.COM; the debugger symbol
;       table file, VGAMOIRE.TDS; and the map file, VGAMOIRE.MAP.
;
;------ PLANS FOR REVISION ----------------------------------------------------
;
;       - Display new settings when N is used.
;       - Possibly some more code compaction.
;       - Possibly rearrange routines and only keep large routines (ie,
;         character RAM save/restore routines) resident if they will be used.
;       - Possibly implement XMS support, if in demand enough.
;
;------ VERSION HISTORY -------------------------------------------------------
;
;       v1.0    7/14/90
;               þ       Original version.
;               þ       Details:
;                         - Works with monochrome or color VGA cards only.
;                           VGAMoire will not work on EGA or MCGA, but it
;                           should work on just about any VGA card.  It uses
;                           the VGA 640x480x16 mode 12h, and uses 15 colors.
;                           It directly accesses the video DAC color registers
;                           and reprograms them to display different colors.
;                         - Will not work in graphics modes.  It is highly
;                           unlikely this will change, though someday, if
;                           the idea is popular and in demand enough, support
;                           *may* be added to save the graphics screen to EMS,
;                           allowing VGAMoire to be able to work even in
;                           graphics modes (though it still would conflict with
;                           most games or other "poorly behaved" programs).  I
;                           just don't see the point in it, especially since
;                           graphical applications are leaning towards
;                           Microsoft Windows as a standard.  Real-mode DOS
;                           TSRs like VGAMoire would not function, anyhow.
;                         - Does not beep if it times out in graphics mode, but
;                           beeps any other time it cannot pop up, including
;                           if the user hits Ctrl-Alt-Shift while in graphics
;                           mode.
;                         - Respects serial (and some parallel) communications,
;                           and restarts its countdown while any data transfer
;                           is going on.  It will not break carrier when it
;                           pops up or down (unless the remote host times out).
;                         - Saves and restores the complete mouse state.
;                         - Restores the display when mouse movement or a
;                           keypress is detected.  Note that VGAMoire suspends
;                           the current process.  It is NOT a background
;                           process.
;                         - With EMS memory installed, VGAMoire can save the
;                           *entire* video state, including the character
;                           generator RAM.  If this feature is not used, or EMS
;                           memory is not available, then VGAMoire just saves
;                           and restores the video mode, page, cursor positions
;                           (for each of the 8 video pages), and the cursor
;                           shape.  It will reset the screen to 25 lines.  No
;                           video data is lost besides the character generator
;                           RAM and the screen size.
;                           NOTE:  saving the character generator RAM adds an
;                           extra 64k to the total EMS memory that VGAMoire
;                           uses, in order to save all 8 character generator
;                           RAM banks (at 8k each).
;                         - VGAMoire should never pop up when it might damage
;                           the system or cause errors.  It monitors a number
;                           of I/O interrupts and restarts its countdown if any
;                           I/O is detected.  If you need an ABSOLUTE guarantee
;                           that it will not disrupt the system during a vital
;                           operation, you can turn it off by pressing
;                           Ctrl-Alt-E (press Ctrl-Alt-B to turn it on again).
;                           If you press Ctrl-Alt-Shift to pop VGAMoire up, it
;                           WILL pop up, even if a vital system operation is in
;                           progress (eg, disk I/O).  Because this can cause
;                           errors or even crash the system, you should be
;                           careful about when you pop VGAMoire up manually.
;                           The only times VGAMoire will not pop up is if the
;                           display is in a graphics mode or if you are using
;                           EMS and there is an error while trying to use EMS.
;                         - Cannot (as yet) detect mouse movement except when
;                           popped up, so mouse movement will not restart the
;                           countdown.
;
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;
;       v1.1    8/2/90
;               þ       Now deallocates its environment block.
;               þ       Can now select how many character generator RAM blocks
;                       to save, from 1 to 8.  Allocates an extra one EMS page
;                       (16k) per every two character generator RAM blocks that
;                       are saved, so to save 1 or 2 blocks, it takes 16k of
;                       EMS; for 3 or 4, it takes 32k; etc.
;               þ       At Karen's request, VGAMoire can now mirror the
;                       pattern in one of four ways:  no mirror, horizontally,
;                       vertically, or both horizontally and vertically.
;               þ       Now detects both mouse movement and mouse button
;                       activity and will reset its countdown.  A new option
;                       has also been added to disable this feature, in case
;                       a mouse is not present or an old mouse driver causes
;                       problems with this feature.
;               þ       Bug fix:  might not have worked correctly before if no
;                       mouse driver were installed (it might have allocated
;                       an unpredictably-too-large block of memory).
;               þ       Bug fix:  when only using conventional memory, the
;                       keyboard would lock up once a key was pressed to
;                       return from the moire design.  I don't remember quite
;                       what I did to fix it, although I know I tried a number
;                       of things.
;               þ       Now only keeps one color set resident.  When a color
;                       set is picked, it is copied to the resident copy's
;                       run-time colorset array (assuming we are changing the
;                       color set for the resident copy.  It does the same
;                       thing the first time it is installed, except that of
;                       course it copies the selected color set into the main
;                       run-time colorset array).
;               þ       Frost colors added.
;
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;
;       v1.2    8/7/90
;               þ       Bug fix:  forgot to use a CS: segment override when
;                       determining how many font blocks to save/restore, and
;                       the result was that essentially no fonts were restored.
;                       VGAMoire now restores fonts correctly.
;               þ       Also, to avoid some nasty screen flickering during
;                       some of the special video accesses, we disable the
;                       video display while operating on video memory, and
;                       then reenable it after we're done screwing with video
;                       memory (only when starting up the moire design or
;                       returning to text mode).
;               þ       Before, we only redefined 15 colors.  It occured to me
;                       that VGAMoire should also reprogram the color
;                       definition for BLACK, to make sure that the black is
;                       really black.  This is necessary because there are a
;                       number of programs out that play with the VGA palette,
;                       and we can't assume that black is really black--we've
;                       got to MAKE it be black.  The whole purpose of VGAMoire
;                       is to prevent the monitor from burning out!  If the
;                       background were always, oh, say WHITE, then VGAMoire
;                       wouldn't be much use, now would it?  So, anyway, we
;                       took care of that possibility in this version.
;
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;
;       v1.3    8/14/90
;               þ       OOPS!  I apologize.  I made a stupid error.
;                       The [N] option didn't work right.
;                       Sigh.  This should now be a solid version, w/o
;                       version changes for a while.  Sigh.
;
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;
;       v1.4    9/4/90
;               þ       Improved mouse state saving and restoring.  Works
;                       even with programs making very sophisticated use of
;                       the mouse driver (for instance, Norton Advanced
;                       Utilities 5.0).
;               þ       New method of reading the keyboard and mouse while
;                       the screen saver is working.  This ensures that
;                       VGAMoire doesn't receive any "false alerts" and
;                       refuse to pop up even when it's supposed to.
;               þ       VGAMoire will now blank out the screen if a graphics
;                       mode is active.  The moire design will not appear, but
;                       at least VGAMoire can still function as a screen saver
;                       even in graphics modes.  Special care was taken so that
;                       THE PROGRAM CAN STILL RUN IN THE BACKGROUND WHILE THE
;                       SCREEN IS BLANKED OUT.  The screen will come back if
;                       VGAMoire detects any activity--mouse, keyboard, serial
;                       communications, parallel communications (via int 17h),
;                       video activity (via int 10h), or disk activity.  It
;                       can be configured to blank the screen in text mode,
;                       too.
;
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;
;       v1.4b   9/21/90
;               þ       Source code was reorganized to facilitate future
;                       support for video cards besides the VGA.  Enough
;                       people indicated an interest that I decided to
;                       look into adding support for MDA, CGA, MCGA, EGA,
;                       VGA, Hercules, and InColor cards.  Note that this is
;                       NOT a guarantee for support, just a guarantee I'll
;                       look into it!  Even if I do add support for multiple
;                       cards, not all of the above cards may be implemented.
;               þ       Improved video state save/restore routines mean that
;                       the entire video state is always saved and restored,
;                       even if EMS memory is not used.  If a non-standard RAM
;                       font is loaded and active, and the [Fn] option is not
;                       in effect, then the display will revert to the 8x16
;                       ROM font.  If one of the ROM fonts was being used
;                       before VGAMoire took over, then that font will be
;                       restored.
;                    ** This also remedies a problem with MS Word (or any
;                       program that used bright background colors) when the
;                       [E] option was not used.  Before, VGAMoire was unable
;                       restore the bright mode, but now it does.
;               þ       Bug fix:  I forgot to use a CS: segment override when
;                       dereferencing the "useEMS" flag when popping up
;                       VGAMoire.  In most situations, this meant VGAMoire
;                       would nuke any data a program had in the EMS page
;                       frame (OOPS!).  This has been fixed.
;
;------------------------------------------------------------------------------


LOCALS                                  ;allow local labels in procedures (@@xxx)
SMART                                   ;enable maximum code optimization


__DeallocateEnvironment         equ     1       ;1=kill env. block, 0=keep env. block so map pgms can ID us


VERSION         equ     '1.4b'                  ;current version of VGAMoire
DATE            equ     'September 1990'        ;date of this version


MaxRev          equ     6               ;max times an endpoint direction can reverse before a new random velocity is picked--must be at least 1
MaxLines        equ     50              ;maximum number of lines in the moire pattern




cseg    segment para    public  'CODE'
        assume  cs:cseg,ds:cseg,ss:nothing,es:nothing
        org 100h



main    proc    near
        jmp     setup                   ;go to end of program
main    endp



oldmx           dw      0               ;old mouse x-coordinate
oldmy           dw      0               ;old mouse y-coordinate
mouse           db      1               ;flag:  1=check mouse, 0=ignore mouse
delay           db      0               ;delay factor
mirror          db      0               ;mirror setting
length          db      20              ;number of lines in the moire pattern
colorspeed      db      1               ;# of lines to draw before changing color
wait            dw      0               ;number of int 08h's to wait before popping up
buffersize      dw      1000h           ;size of video text save buffer
mousesize       dw      0800h           ;size of mouse state save buffer
fontblocks      db      0               ;number of font RAM blocks to save (0=no font saving, 1-8=that many blocks)
onoff           db      1               ;onoff:  1=on, 0=off
useEMS          db      0               ;useEMS:  1=yes, 0=no
EMShandle       dw      ?               ;our EMS block's handle
counter         dw      0               ;count since a key was pressed etc.
videomode       db      ?               ;previous video mode
storetext       dw      ?               ;where to store text (default for conventional memory)
textbuff        dw      ?               ;store address of text buffer
keybuff         dw      0               ;keyboard buffer
gonow           db      0               ;delay when Ctrl-Alt-Shift is pressed
colorwait       db      0               ;countdown to changing color
curcolor        db      1               ;color of current line
gfxmode         db      0               ;flag:  non-zero indicates we are performing a cop-out version of a screen saver because we're in graphics mode
gfxcopout       db      0               ;flag:  non-zero means always do the cop-out, never draw the moire design
gfxinstalled    db      0               ;flag:  was this copy of VGAMoire installed with the [Bn] option?
timeout         db      1               ;popped up because:  0 if ctrl-alt-shift was hit, 1 if timed out
blackcolor      db      0,0,0           ;video DAC color definition for black
colorset        label   byte            ;run-time array holding color set for moire design--color reg values are loaded in at install time, or these defaults are used
                db      63,  0,  0      ;color #1       [red]
                db      63, 30,  0      ;
                db      63, 45,  0      ;
                db      63, 63,  0      ;               [yellow]
                db      42, 63,  0      ;
                db       0, 63,  0      ;               [green]
                db       0, 63, 42      ;
                db       0, 63, 63      ;               [cyan]
                db       0, 45, 63      ;
                db       0, 31, 63      ;
                db       0,  0, 63      ;               [blue]
                db      30,  0, 63      ;
                db      45,  0, 63      ;
                db      63,  0, 63      ;               [violet]
                db      63,  0, 47      ;color #15
maxcolor        db      15              ;highest defined color number
index           dw      0               ;index to last line in moire pattern
; current line endpoint data
; data for each coordinate is grouped so loop at [revdir] works w/offsets
xv1             dw      ?               ;x1 endpoint velocity
x1              dw      ?               ;endpoint of current line
x1rev           db      MaxRev          ;times endpoint direction has reversed
xv2             dw      ?               ;x2 endpoint velocity
x2              dw      ?               ;endpoint of current line
x2rev           db      MaxRev          ;times endpoint direction has reversed
yv1             dw      ?               ;y1 endpoint velocity
y1              dw      ?               ;endpoint of current line
y1rev           db      MaxRev          ;times endpoint direction has reversed
yv2             dw      ?               ;y2 endpoint velocity
y2              dw      ?               ;endpoint of current line
y2rev           db      MaxRev          ;times endpoint direction has reversed
switchdir       dw      0               ;# lines to draw before changing to new random velocities
linesx1         dw      MaxLines dup (?)        ;arrays holding endpoints of last MaxLines lines
linesy1         dw      MaxLines dup (?)
linesx2         dw      MaxLines dup (?)
linesy2         dw      MaxLines dup (?)
old08h          dw      ?               ;hold addresses of original interrupts
                dw      ?
old09h          dw      ?
                dw      ?
old10h          dw      ?
                dw      ?
old13h          dw      ?
                dw      ?
;old14h          dw      ?
                 dw      ?
old17h          dw      ?
                dw      ?
int10hOK        db      0               ;0 if we should reset [counter] on calls to int 10h -- while our program is running, this is 0ffh (-1)
sax             dw      ?               ;saves ax
sbx             dw      ?               ;saves bx
scx             dw      ?               ;saves cx
sdx             dw      ?               ;saves dx
sdi             dw      ?               ;saves di
ssi             dw      ?               ;saves si
sbp             dw      ?               ;saves bp
ses             dw      ?               ;saves es
sds             dw      ?               ;saves ds
sip             dw      ?               ;saves ip
scs             dw      ?               ;saves cs
sfl             dw      ?               ;saves flags
sax2            dw      ?               ;saves ax in our08h
sbx2            dw      ?               ;saves bx in out08h
scx2            dw      ?               ;saves cx in our08h
sdx2            dw      ?               ;saves dx in our08h
sds2            dw      ?               ;saves ds in out08h



reset   proc    near                    ;resets countdown, restores screen if in "gfx cop-out" mode
        push    cs:[wait]
        pop     cs:[counter]
        cmp     cs:[gfxmode],0
        je      @@done
        mov     cs:[gfxmode],0
        xor     al,al                   ;restore screen if gfx cop-out mode was active
        call    refresh
@@done:
        ret
reset   endp



our08h  proc    near                    ;our int 08h handler
        cmp     cs:[gonow],0            ;gonow > 0 if Ctrl-Alt-Shift was pressed
        jz      @@deccnt
        dec     cs:[gonow]              ;subtract 1 from gonow if it is > 0
        jg      @@deccnt
        mov     cs:[counter],1          ;if gonow=0 set counter=1 to trigger fireworks
@@deccnt:
        dec     cs:[counter]            ;decrement counter
        jz      @@moire                 ;if counter = 0 draw moire pattern
        jg      @@checkMS
        inc     cs:[counter]            ;if counter was 0 set it 0 again
@@checkMS:
        cmp     cs:[mouse],0
        je      @@chain
        mov     cs:[sds2],ds            ;save ds
        push    cs
        pop     ds                      ;set up addressability
        mov     [sax2],ax               ;save ax
        mov     [sbx2],bx               ;save bx
        mov     [scx2],cx               ;save cx
        mov     [sdx2],dx               ;save dx
        mov     ax,3
        xor     bx,bx                   ;in case no mouse driver, zero all regs that would hold return values
        xor     cx,cx
        xor     dx,dx
        int     33h
        cmp     bx,0                    ;is mouse button pressed
        jne     @@reset
        cmp     cx,[oldmx]
        jne     @@reset
        cmp     dx,[oldmy]
        je      @@doneMS
@@reset:
        mov     [oldmx],cx
        mov     [oldmy],dx
        call    reset                   ;reset countdown
@@doneMS:
        mov     dx,[sdx2]
        mov     cx,[scx2]
        mov     bx,[sbx2]
        mov     ax,[sax2]
        mov     ds,[sds2]
@@chain:
        jmp     DWord Ptr cs:[old08h]   ;chain to old int 08h handler
@@moire:
        mov     cs:[sds],ds             ;save ds first, so we can
        push    cs                      ;  point ds to us to crunch code by
        pop     ds                      ;  avoiding segment overrides
        mov     [sax],ax                ;save ax
        mov     [sbx],bx                ;save bx
        mov     [scx],cx                ;save cx
        mov     [sdx],dx                ;save dx
        mov     [sdi],di                ;save di
        mov     [ssi],si                ;save si
        mov     [sbp],bp                ;save bp
        mov     [ses],es                ;save es
        pop     [sip]                   ;save ip
        pop     [scs]                   ;save cs
        pop     [sfl]                   ;save flags
        push    [sfl]                   ;push flags back on stack
        push    cs                      ;push new cs on stack
        mov     cx,offset runthis       ;return to here
        push    cx                      ;save offset of runthis
        jmp     @@chain                 ;return to do int 8
our08h  endp



our09h  proc    near                    ;process keyboard interrupt
        push    ax                      ;save ax
        push    es                      ;save ds
        mov     es,cs:[keybuff]         ;set es = 0
        mov     al,byte ptr es:[417h]   ;get keyboard status byte
        pop     es
        and     al,0fh                  ;mask off top 4 bits
        cmp     al,12                   ;if Ctrl-Alt is pressed
        jg      @@signal                ;if Ctrl-Alt-Shift is pressed
        jnz     @@chain
        in      al,60h                  ;get extended key code
        cmp     al,18                   ;is it Ctrl-Alt-E
        jnz     @@enable
        mov     cs:[onoff],0            ;turn off screen saver
@@enable:
        cmp     al,48                   ;is key Ctrl-Alt-B
        jnz     @@chain
        mov     cs:[onoff],1            ;turn on screen saver
        jmp     @@chain
@@signal:
        mov     cs:[gonow],6            ;delay half a second then invoke screen saver
        mov     cs:[timeout],0          ;say we're popping up because of user request (ctrl-alt-shift)
@@chain:
        call    reset                   ;reset countdown
        pop     ax                      ;restore ax
        jmp     DWord Ptr cs:[old09h]   ;chain to old int 09h handler
our09h  endp



our10h  proc    near                    ;new video interrupt
        cmp     ax,0caffh               ;CA are my initials - check if we're installed
        jne     @@norm10h
        mov     bx,cs                   ;return our PSP
        mov     ax,0faceh               ;return code
        iret
@@norm10h:
        cmp     cs:[int10hOK],0         ;is it us requesting an interrupt
        jne     @@pass                  ;if so, don't reset counter, or we'll exit!
        call    reset                   ;reset countdown
        @@pass:
        jmp     DWord Ptr cs:[old10h]   ;chain to old int 10h handler
our10h  endp



our13h  proc    near                    ;new disk drive interrupt
        call    reset                   ;reset countdown
        jmp     DWord Ptr cs:[old13h]   ;chain to old int 13h handler
our13h  endp



;our14h  proc    near                    ;new modem interrupt
;        call    reset                   ;reset countdown
;        jmp     DWord Ptr cs:[old14h]   ;chain to old int 14h handler
;our14h  endp



our17h  proc    near                    ;new printer interrupt
        call    reset                   ;reset countdown
        jmp     DWord Ptr cs:[old17h]   ;chain to old int 17h handler
our17h  endp



;------------------------------------------------------------------------------
;
;       CARD-SPECIFIC CODE
;
;       any include file used here must declare the following items so it
;       can link itself with this VGAMOIRE.ASM module:
;
;               SETCOLORS       (macro) sets the colors
;               STORE           (macro) stores the current video state
;               SETMODE         (macro) sets the graphics mode
;               RESTORE         (macro) restores the saved video state
;               Line10          (proc)  draws a line in graphics mode
;
;               MinBound        equ     [minimum endpoint velocity]
;               MaxBound        equ     [maximum endpoint velocity]
;
;               MaxX            dw      [maximum x coordinate]
;               MaxY            dw      [maximum y coordinate]
;
include vga.inc
;
;------------------------------------------------------------------------------



getbuf  proc    near
        cmp     cs:[useEMS],0
        jz      @@done
        mov     ah,47h                  ;save page map
        mov     dx,cs:[EMShandle]
        int     67h
        or      ah,ah
        jnz     @@error
        mov     ah,44h                  ;map our logical pages to physical page frame
        mov     al,cs:[useEMS]          ;al=number of pages we reserved
        dec     al                      ;al=number of highest logical page
@@maploop:
        push    ax
        xor     bh,bh
        mov     bl,al                   ;map logical page to same physical page number
        mov     dx,cs:[EMShandle]
        int     67h
        or      ah,ah
        jnz     @@error3                ;@@error3 makes sure to pop ax, too
        pop     ax
        or      al,al
        jz      @@getframe
        dec     al
        jmp     @@maploop
@@getframe:
        mov     ah,41h                  ;get page frame address
        int     67h
        or      ah,ah
        jnz     @@error2
        mov     cs:[storetext],bx
@@done:
        clc                             ;success
        ret
@@error3:
        pop     ax
@@error2:
        call    freebuf                 ;uh, oh, better restore page map...
@@error:
        stc                             ;failure
        ret
getbuf  endp



freebuf proc    near
        cmp     cs:[useEMS],0
        jz      @@done
        mov     ah,48h                  ;restore page map
        mov     dx,cs:[EMShandle]
        int     67h
        or      ah,ah
@@done:
        ret
freebuf endp



rndcnt          dw      ?               ;ceiling of random number range
seed            dw      ?               ;seed for random number generator
aval            equ     2743            ;for pseudorandom generator
cval            equ     5923            ;for pseudorandom generator
rnum            dw      rval            ;number of times the generator was used
rval            equ     200             ;how high rnum can get before getting a new seed and reseting rnum

rnd     proc    near                    ;return pseudorandom number in range [0,rndcnt], uses a standard algorithm
        push    cx
        push    dx
        inc     [rnum]
        cmp     [rnum],rval             ;is it time to get a new seed
        jl      @@getrnd
        push    es
        push    bx
        xor     ax,ax
        mov     es,ax
        mov     bx,46ch
        push    es:[bx]                 ;read timer
        pop     [seed]                  ;store it to seed
        mov     [rnum],ax
        pop     bx
        pop     es
@@getrnd:
        mov     ax,[seed]               ;seed = (seed*aval + cval) mod mval
        mov     cx,aval
        mul     cx
        add     ax,cval
        mov     [seed],ax
        xor     dx,dx
        mov     cx,[rndcnt]
        inc     cx
        or      cx,cx
        jz      @@nomod                 ;if modulus 65536 (which is effectively mod 0 and thusly divide-by-zero because we're using word values)
        div     cx
        mov     ax,dx                   ;ax in [0,rndcnt]
@@nomod:                                ;jump point if rndcnt=65535 to avoid divide by zero interrupt
        pop     dx
        pop     cx
        ret
rnd     endp



randvel proc    near                    ;pick a random endpoint velocity
;       ARGS:   none
;       RETS:   ax = velocity
        mov     rndcnt,MaxBound*2       ;random number range [0,MaxBound*2]
@@rv1:
        call    rnd                     ;get random number in ax
        sub     ax,MaxBound             ;ax in [-MaxBound,MaxBound]
        cmp     ax,MinBound
        jb      @@rv1
        cmp     ax,-MinBound
        ja      @@rv1
        ret                             ;return w/ax
randvel endp



getcoords       proc    near            ;load coordinates into regs
        cmp     [curcolor],0
        je      @@erase
        mov     ax,[y2]
        mov     bx,[x2]
        mov     cx,[y1]
        mov     dx,[x1]
        ret
@@erase:
        mov     di,[index]              ;get index to last line in moire pattern
        shl     di,1                    ;convert to word index
        mov     ax,linesy2[di]
        mov     bx,linesx2[di]
        mov     cx,linesy1[di]
        mov     dx,linesx1[di]
        ret
getcoords       endp



doline  proc    near                    ;draw a line from dx,cx to bx,ax
        push    word ptr [curcolor]     ;pass parameters for line to Line10
        push    ax
        push    bx
        push    cx
        push    dx
        call    Line10
        ret
doline  endp



alllines        proc    near            ;draw all lines, including mirroring
        call    getcoords
        call    doline                  ;draw normal first line
        test    [mirror],1              ;mirror right/left?
        jz      @@noRL
        call    getcoords
        neg     bx
        add     bx,[MaxX]
        neg     dx
        add     dx,[MaxX]
        call    doline
@@noRL:
        test    [mirror],2              ;mirror top/bottom?
        jz      @@noTB
        call    getcoords
        neg     ax
        add     ax,[MaxY]
        neg     cx
        add     cx,[MaxY]
        call    doline
@@noTB:
        cmp     [mirror],3              ;mirror left/right/top/bottom?
        jne     @@noBTH
        call    getcoords
        neg     ax
        add     ax,[MaxY]
        neg     cx
        add     cx,[MaxY]
        neg     bx
        add     bx,[MaxX]
        neg     dx
        add     dx,[MaxX]
        call    doline
@@noBTH:
        ret
alllines        endp



drawmoire       proc    near            ;draw moire pattern
        mov     [counter],0             ;zero the counter to avoid "false alerts"
        ; reset tables holding old line coordinates
        push    cs
        pop     es
        mov     di,offset linesx1
        mov     cx,MaxLines*4           ;full table size (4 coordinates per line)
        mov     ax,-1
        rep     stosw                   ;set all elements in tables to -1 (word size)
        ; get random directions, velocities, and coordinates to start the pattern
        mov     [rndcnt],400
        call    rnd
        add     ax,200
        mov     [switchdir],ax          ;store new # of lines to draw before randomly changing endpoint velocities
        mov     di,(offset xv2 - offset xv1)*4  ;di is offset
randir:
        or      di,di
        jz      ranex
        sub     di,(offset xv2 - offset xv1)
        cmp     di,(offset xv2 - offset xv1)*2  ;is it doing x or y?
        jb      dox
        mov     cx,[MaxY]
        jmp     doxy
dox:
        mov     cx,[MaxX]
doxy:
        call    randvel                 ;get random endpoint velocity
        mov     xv1[di],ax              ;store it
        mov     [rndcnt],cx
        call    rnd                     ;pick random endpoint coordinate
        mov     x1[di],ax               ;store it
        jmp     randir
ranex:

di1:
        cmp     [delay],0               ;if no delay factor requested
        jz      de1
        push    cx                      ;save cx
        mov     ch,[delay]              ;set cx = 100h * delay
        xor     cl,cl
de0:
        cmp     [counter],0             ;do this to waste time
        cmp     [counter],0
        loop    de0                     ;repeat cx times
        pop     cx                      ;restore cs
de1:
        cmp     [counter],0             ;if a key was pressed counter > 0
        jng     di4
        jmp     ex1
di4:

        ; is it time to randomly switch directions yet?
        cmp     [switchdir],0
        jnz     @@sdex
        mov     [rndcnt],400            ;pick new random number of lines to draw before changing velocities
        call    rnd
        add     ax,200                  ;ax in [200,600]
        mov     [switchdir],ax          ;store new limit
        mov     di,(offset xv2 - offset xv1)*4  ;di is offset & counter in one
@@sd1:
        or      di,di
        jz      @@sdex
        sub     di,(offset xv2 - offset xv1)
        call    randvel                 ;pick a random velocity
        mov     xv1[di],ax              ;ax in [-MaxBound,-MinBound] or [MinBound,MaxBound]
        jmp     @@sd1
@@sdex:
        dec     [switchdir]

        ; reverse directions if hit edges of screen -- loop crunches 4 essentially duplicate blocks of code into one
        mov     di,(offset xv2 - offset xv1)*4  ;di is offset & counter in one
revdir:
        or      di,di
        jz      revex
        sub     di,(offset xv2 - offset xv1)
        mov     ax,x1[di]
        add     ax,xv1[di]
        cmp     di,(offset xv2 - offset xv1)*2  ;is it checking x or y?
        jb      checkx
        cmp     ax,[MaxY]
        jmp     checkxy
checkx:
        cmp     ax,[MaxX]
checkxy:
        jbe     revdir
        cmp     x1rev[di],0             ;has xv_ reversed directions too many times?
        jnz     rd1
        mov     [rndcnt],MaxRev-1       ;pick new random limit for how many times to reverse
        call    rnd
        inc     al
        mov     x1rev[di],al            ;store new limit
        call    randvel                 ;pick a random velocity
        mov     bx,xv1[di]              ;grab current velocity value
        mov     bl,ah
        and     bx,1000000010000000b    ;compare signs (directions) of current and new values of velocities
        cmp     bh,bl
        je      rb20
        neg     ax                      ;if different, make same
rb20:
        mov     xv1[di],ax              ;ax in [-MaxBound,-MinBound] or [MinBound,MaxBound]
rd1:
        dec     x1rev[di]
        neg     xv1[di]                 ;reverse the direction
        jmp     revdir
revex:

        mov     di,[index]              ;get index into saved line positions
        shl     di,1                    ;convert to word index
        mov     ax,[x1]
        mov     linesx1[di],ax          ;put x1 into array
        mov     ax,[x2]
        mov     linesx2[di],ax          ;put x2 into array
        mov     ax,[y1]
        mov     linesy1[di],ax          ;put y1 into array
        mov     ax,[y2]
        mov     linesy2[di],ax          ;put y2 into array
        ; increment index - this gives us the line to erase
        inc     [index]                 ;index = index+1
        xor     ah,ah
        mov     al,[length]
        cmp     [index],ax              ;is it time to wrap around
        jl      nw1
        xor     ax,ax
        mov     [index],ax              ;reset index to 0
nw1:
        ; get color
        cmp     [colorwait],0           ;is it time to change color
        ja      @@samecolor             ;if not, jump
        mov     al,[colorspeed]
        mov     [colorwait],al
        mov     al,[maxcolor]
        cmp     [curcolor],al
        jb      @@nowrap
        mov     [curcolor],0            ;wrap around
@@nowrap:
        inc     [curcolor]              ;get next color
@@samecolor:
        dec     [colorwait]             ;get closer to time to change color
        mov     ax,[yv2]
        add     [y2],ax                 ;add yv2 to y2
        mov     ax,[xv2]
        add     [x2],ax                 ;add xv2 to x2
        mov     ax,[yv1]
        add     [y1],ax                 ;add yv1 to y1
        mov     ax,[xv1]
        add     [x1],ax                 ;add xv1 to x1
        call    alllines                ;draw lines, including mirroring
        ; erase last line(s)
        mov     di,[index]              ;get index to last line in moire pattern
        shl     di,1                    ;convert to word index
        cmp     linesx1[di],-1          ;is there really a line to erase yet
        je      di2
        push    word ptr [curcolor]     ;save current color value
        mov     [curcolor],0            ;color for erasing
        call    alllines                ;clear last line(s) in pattern, including mirroring
        pop     ax
        mov     [curcolor],al           ;restore current color
di2:
        jmp     di1                     ;next iteration
ex1:
;        mov     dx,3ceh                 ;dx = graphics controller port address
;        xor     ax,ax                   ;restore set/reset register
;        out     dx,ax
;        inc     ax                      ;restore enable set/reset register
;        out     dx,ax
;        mov     al,3                    ;data rotate/func select register #
;        out     dx,ax
;        mov     ax,0ff08h               ;restore bit mask register
;        out     dx,ax
        ret
drawmoire       endp



moire   proc    near
        ; store text video screen
        cmp     [gfxcopout],0           ;if gfx cop-out mode is set to "always", then jump to the cop-out routine
        jne     @@gfxcopout
        mov     [textbuff],TextBufferSeg+800h   ;address of text
        mov     es,[keybuff]            ;set es = 0
        mov     bl,byte ptr es:[449h]   ;get byte at 449h
        cmp     bl,4                    ;what video mode are we in
        jl      @@go                    ;if we are in text mode, go!
        cmp     bl,7                    ;are we at mode 7, possibly ega
        jz      @@mono
@@gfxcopout:
        mov     al,1                    ;in graphics mode, so just blank the screen
        call    refresh
        mov     [gfxmode],1             ;set flag that we're doing our graphics mode cop-out version of a screen saver
        ret                             ;return to previous program
@@gofail:
        jmp     @@fail                  ;jump point if something goes wrong
@@mono:
        mov     [textbuff],TextBufferSeg        ;set textbuff to b000h if mono
@@go:
        mov     al,1                    ;disable screen refresh (avoid flickering during mode change, etc)
        call    refresh
        call    getbuf                  ;set up EMS page map if using EMS
        jc      @@gofail                ;if we can't
        mov     ax,2                    ;hide pointer, in case it's showing
        int     33h
        push    es
        mov     ax,16h                  ;save mouse state
        push    [storetext]             ;get segment of save buffer
        pop     es
        mov     dx,[buffersize]         ;offset past stored video screen
        int     33h
        mov     ax,21h                  ;reset the mouse
        int     33h
        pop     es
        mov     bl,byte ptr es:[449h]   ;save video mode
        mov     [videomode],bl
        STORE                           ;[macro] save current video state
        call    freebuf                 ;restore EMS page map (if using EMS)
        SETMODE                         ;[macro] sets the graphics video mode
        push    cs                      ;set ds = cs
        pop     ds
        SETCOLORS                       ;[macro] set new video DAC color registers
        xor     al,al                   ;reenable video refresh (the BIOS should have taken care of this when we set the graphics mode, but we do it, too, just in case)
        call    refresh
        call    drawmoire               ;draw moire pattern
        mov     al,1                    ;disable screen refresh (avoid flickering during mode change, etc)
        call    refresh
        push    cs
        pop     ds
        xor     ah,ah                   ;reset to saved mode
        mov     al,[videomode]          ;  must do this, even if we're restoring the video state afterwards, otherwise the
        int     10h                     ;  mouse driver thinks we're still in gfx mode and the mouse pointer gets mangled.
        mov     al,1                    ;disable screen refresh (avoid flickering during mode change, etc)
        call    refresh
        RESTORE                         ;[macro] restore saved video state
@@done:
        xor     al,al                   ;reenable video refresh
        call    refresh
        push    cs
        pop     ds
        call    reset                   ;reset the countdown
        ret
@@fail:
        cmp     [timeout],0             ;if failed but we timed out, don't do anything
        jnz     @@done
        mov     ah,0eh
        mov     al,7                    ;cheapie way to sound a bell
        xor     bx,bx
        int     10h
        jmp     @@done
moire   endp



runthis proc    near                    ;run graphics then restore to program
        mov     ax,cs                   ;set ds = cs
        mov     ds,ax
        not     [int10hOK]              ;tell our int 10h handler we're calling it
        cmp     [onoff],0               ;was VGAMoire turned off
        jz      @@nope
        call    moire                   ;save screen, draw moire pattern, restore screen
@@nope:
        mov     ax,[sax]                ;restore ax
        mov     bx,[sbx]                ;restore bx
        mov     cx,[scx]                ;restore cx
        mov     dx,[sdx]                ;restore dx
        mov     di,[sdi]                ;restore di
        mov     si,[ssi]                ;restore si
        mov     bp,[sbp]                ;restore bp
        mov     es,[ses]                ;restore es
        push    [sfl]                   ;put flags on stack
        push    [scs]                   ;put cs on stack
        push    [sip]                   ;put ip on stack
        mov     ds,[sds]                ;restore ds
        not     cs:[int10hOK]           ;tell our int 10h handler to reset [counter] on int requests
        mov     cs:[timeout],1          ;reset timeout indicator to say true timeout, not ctrl-alt-shift hit
        iret                            ;return to previous program
runthis endp



        align   16                      ;paragraph aligned so we can store just a segment address
EndOfResident   label   byte



_mypsp          dw      ?

deinstall       proc    near
;       This could be done by simply deallocating our PSP block and environment
;       block (if not deallocated at installation), but this is more
;       "well-behaved", in that if a DOS extender allocates an extra info block
;       per program, this will also deallocate that block, because it simply
;       deallocates anything that belongs to us.
;       This isn't resident code, so we might as well take the extra effort.
        mov     ax,0caffh               ;are we installed yet
        int     10h
        cmp     ax,0faceh
        je      @@deinstall
        mov     ah,9                    ;if not, print error message and abort
        mov     dx,offset nomsg
        int     21h
        mov     ax,4c01h
        int     21h
@@deinstall:
        mov     cs:[_mypsp],bx          ;save the PSP of the resident copy
        mov     es,bx
        mov     bl,es:[useEMS]          ;find out if resident copy is using EMS
        mov     cs:[useEMS],bl
        mov     bx,es:[EMShandle]       ;get EMS handle resident copy is using
        mov     cs:[EMShandle],bx
        mov     ax,3508h                ;check if another program covered us
        int     21h
        mov     ax,es
        cmp     ax,cs:[_mypsp]
        jne     @@yousureb
        cmp     bx,offset our08h
        jne     @@yousureb
        mov     ax,3509h
        int     21h
        mov     ax,es
        cmp     ax,cs:[_mypsp]
        jne     @@yousureb
        cmp     bx,offset our09h
        jne     @@yousureb
        mov     ax,3510h
        int     21h
        mov     ax,es
        cmp     ax,cs:[_mypsp]
        jne     @@yousureb
        cmp     bx,offset our10h
        jne     @@yousureb
        mov     ax,3513h
        int     21h
        mov     ax,es
        cmp     ax,cs:[_mypsp]
        jne     @@yousureb
        cmp     bx,offset our13h
        jne     @@yousureb
;        mov     ax,3514h
;        int     21h
;        mov     ax,es
;        cmp     ax,cs:[_mypsp]
;        jne     @@yousureb
;        cmp     bx,offset our14h
;        jne     @@yousureb
        mov     ax,3517h
        int     21h
        mov     ax,es
        cmp     ax,cs:[_mypsp]
        jne     @@yousureb
        cmp     bx,offset our17h
        jne     @@yousureb
        jmp     @@yessure
        @@yousureb:
        jmp     @@yousure
        @@yessure:
        mov     bx,cs:[_mypsp]
        mov     es,bx
        mov     dx,word ptr es:[old08h]         ; get old 8h vector
        mov     ds,word ptr es:[old08h+2]
        mov     ax,2508h                        ; restore old 8h vector
        int     21h
        mov     dx,word ptr es:[old09h]         ; get old 9h vector
        mov     ds,word ptr es:[old09h+2]
        mov     ax,2509h                        ; restore old 9h vector
        int     21h
        mov     dx,word ptr es:[old10h]         ; get old 10h vector
        mov     ds,word ptr es:[old10h+2]
        mov     ax,2510h                        ; restore old 10h vector
        int     21h
        mov     dx,word ptr es:[old13h]         ; get old 13h vector
        mov     ds,word ptr es:[old13h+2]
        mov     ax,2513h                        ; restore old 13h vector
        int     21h
;        mov     dx,word ptr es:[old14h]         ; get old 14h vector
;        mov     ds,word ptr es:[old14h+2]
;        mov     ax,2514h                        ; restore old 14h vector
;        int     21h
        mov     dx,word ptr es:[old17h]         ; get old 17h vector
        mov     ds,word ptr es:[old17h+2]
        mov     ax,2517h                        ; restore old 17h vector
        int     21h
        push    cs
        pop     ds
        mov     ah,52h
        int     21h
        mov     ax,word ptr es:[bx-2]
        mov     es,ax
        @@looptop:
        cmp     byte ptr es:[0],4dh
        jne     @@end
        mov     ax,word ptr es:[1]
        cmp     ax,word ptr cs:[_mypsp]
        jne     @@notourblock
        push    es
        mov     ax,es
        inc     ax
        mov     es,ax
        mov     ah,49h
        int     21h
        pop     es
        @@notourblock:
        mov     cx,word ptr es:[3]
        inc     cx
        mov     ax,es
        add     ax,cx
        mov     es,ax
        jmp     @@looptop
        @@end:
        cmp     cs:[useEMS],0
        jz      @@noEMS
        mov     ah,45h                  ;release resident copy's EMS block, if present
        mov     dx,cs:[EMShandle]
        int     67h                     ;if there was an error, it's out of our hands
        @@noEMS:
        mov     ah,9                    ;print deinstallation msg
        mov     dx,offset demsg
        int     21h
        mov     ax,4c00h
        int     21h
        @@yousure:
        mov     dx,offset suremsg
        call    @@str29
        @@getch:
        mov     ah,8
        int     21h
        cmp     al,'y'
        je      @@dok
        cmp     al,'Y'
        je      @@dok
        cmp     al,'n'
        je      @@dok
        cmp     al,'N'
        je      @@dok
        cmp     al,27
        je      @@dok
        jmp     @@getch
        @@dok:
        push    ax
        cmp     al,27
        je      @@nopr
        int     29h                     ;undocumented character output routine
        @@nopr:
        mov     al,13                   ;go to next line
        int     29h
        mov     al,10
        int     29h
        pop     ax
        cmp     al,'y'
        je      @@yes
        cmp     al,'Y'
        je      @@yes
        mov     dx,offset stilmsg
        call    @@str29
        pop     es
        pop     di
        mov     ax,4c01h                ;exit, return ERRORLEVEL 1
        int     21h
        @@yes:
        jmp     @@yessure
        @@str29:
        mov     di,dx
        @@sloop:                        ;output routine emulates int 21h fnc 9h
        mov     al,cs:[di]
        inc     di
        cmp     al,'$'
        je      @@sexit
        int     29h                     ;undocumented character output routine
        jmp     @@sloop
        @@sexit:
        ret
deinstall       endp



newopts proc    near
        push    ax
        push    bx
        push    dx
        mov     ax,0caffh               ;are we installed yet
        int     10h                     ;returns bx=resident PSP if installed, and ax=0faceh
        cmp     ax,0faceh
        je      @@setnew
        mov     ah,9                    ;if not, print error message and abort
        mov     dx,offset nomsg
        int     21h
        mov     ax,4c01h
        int     21h
@@setnew:
        mov     es,bx                   ;set up to write subsequent params to resident copy
        pop     dx
        pop     bx
        pop     ax
        ret
newopts endp



setminutes      proc    near
        call    finddigit               ;convert string to digit
        jc      @@done
        cmp     cl,30                   ;make sure it is less than 30 minutes
        ja      @@done
        mov     ax,444h                 ;multiply digit by 444h
        mul     cx
        mov     es:[wait],ax            ;save, this is # of int 8's performed in x mins
@@done:
        ret
setminutes      endp



setdelay        proc    near
        call    finddigit               ;convert string to digit
        jc      @@done
        mov     es:[delay],cl           ;save digit as a delay factor
@@done:
        ret
setdelay        endp



setlines        proc    near
        call    finddigit               ;get digit
        jc      @@done
        cmp     cl,MaxLines             ;was number less than MaxLines
        ja      @@done
        mov     es:[length],cl          ;save number of lines
@@done:
        ret
setlines        endp



setpages        proc    near
        call    finddigit               ;get value specified
        jc      @@done
        cmp     cl,8                    ;if greater than 8 ignore it
        ja      @@done
        mov     ax,1000h
        xor     ch,ch
        mul     cx                      ;number of bytes to save = 1000h * cx = ax
        mov     [buffersize],ax         ;save number of bytes to save
@@done:
        ret
setpages        endp



setEMS  proc    near
        mov     cs:[useEMS],1
        ret
setEMS  endp



setsavfon       proc    near
        call    finddigit               ;get value specified
        jc      @@done
        cmp     cl,8                    ;if greater than 8 ignore it
        ja      @@done
        mov     cs:[fontblocks],cl
@@done:
        ret
setsavfon       endp



setvidact       proc    near
        call    finddigit               ;get value specified
        jc      @@done
        cmp     cl,2                    ;if greater than 2 ignore it
        ja      @@done
        dec     cl
        mov     es:[int10hOK],cl        ;set video activity monitor
@@done:
        ret
setvidact       endp



setmouse        proc    near
        call    finddigit               ;get value specified
        jc      @@done
        cmp     cl,2                    ;if greater than 2 ignore it
        ja      @@done
        dec     cl
        mov     es:[mouse],cl           ;set mouse activity monitor
@@done:
        ret
setmouse        endp



setblank        proc    near
        cmp     es:[gfxinstalled],0     ;was VGAMoire installed with the [Bn] option?
        jne     @@done                  ;yep, tough luck, can't change it then
        call    finddigit               ;get value specified
        jc      @@done
        cmp     cl,2                    ;if greater than 2 ignore it
        ja      @@done
        dec     cl
        mov     es:[gfxcopout],cl       ;set blank mode (graphics "cop-out" mode)
        mov     cs:[gfxinstalled],cl    ;set [gfxinstalled] to 1 if B2 is used
@@done:
        ret
setblank        endp



setmirror       proc    near
        call    finddigit               ;get value specified
        jc      @@done
        cmp     cl,4                    ;if greater than 4 ignore it
        ja      @@done
        dec     cl
        mov     es:[mirror],cl          ;set mirror setting
@@done:
        ret
setmirror       endp



setspeed        proc    near
        call    finddigit               ;get value specified
        jc      @@done
        mov     es:[colorspeed],cl      ;store speed
@@done:
        ret
setspeed        endp



setcolor        proc    near
        call    finddigit               ;get value specified
        jc      @@done
        cmp     cl,numsets              ;if greater than number of color sets we know of, ignore it
        ja      @@done
        push    di                      ;save di & si
        push    si
        mov     si,offset rainbow       ;get base address of color sets
        dec     cl                      ;zero-based for indexing
        xor     ah,ah
        mov     al,cl
        mov     cl,(15*3)+1             ;calc offset from [rainbow] to color set
        mul     cl
        add     si,ax                   ;calc pointer to color set to use
        mov     cx,(15*3)+1             ;number of colors to copy + maxcolor descriptor
        mov     di,offset colorset      ; es:di -> location of colorset array (where to copy to)
        rep     movsb                   ;copy color set from list of color sets into the run-time array
        pop     si
        pop     di                      ;restore di & si
@@done:
        ret
setcolor        endp



seton   proc    near
        mov     es:[onoff],1
        ret
seton   endp



setoff  proc    near
        mov     es:[onoff],0
        ret
setoff  endp



getEMS  proc    near
        push    di
        push    si
        mov     ax,3567h                ;test for presense of EMS
        int     21h                     ;returns es=segment ptr
        mov     di,10                   ;es:di -> byte at offset 10 in device header
        mov     si,offset emmname
        mov     cx,8
        cld
        repz    cmpsb                   ;compare strings
        jz      @@EMSthere
        mov     ah,9                    ;print message saying no EMS m.m.
        mov     dx,offset noEMS
        int     21h
        jmp     @@error
@@EMSthere:
        mov     ah,46h                  ;get version, if lower than 3.0, can't use (actually, it might work, but since i'm not sure...)
        int     67h
        cmp     al,30h
        jae     @@EMS30
        mov     ah,9                    ;print message saying we need at least EMS 3.0
        mov     dx,offset EMS30
        int     21h
        jmp     @@error
@@EMS30:
        mov     ah,43h                  ;allocate an EMS handle to use
        mov     bx,1
        cmp     cs:[buffersize],3000h   ;three vid pages or less, just one EMS page
        jbe     @@getpages
        inc     bx
        cmp     cs:[buffersize],7000h   ;seven or less, two EMS pages
        jbe     @@getpages
        inc     bx                      ;eight vid pages needs three EMS pages
@@getpages:
        mov     cs:[useEMS],bl          ;store number of pages we're allocating for video text save area
        cmp     cs:[fontblocks],0       ;should we save character RAM also
        jz      @@nochr
        xor     dh,dh
        mov     dl,cs:[fontblocks]      ;how many font blocks do we need to save
        inc     dl                      ;round up and
        shr     dl,1                    ;  convert to EMS pages
        add     bx,dx                   ;add in pages for font RAM
@@nochr:
        int     67h
        or      ah,ah
        jz      @@gotEMS
        mov     ah,9                    ;error allocating EMS, so just use conventional
        mov     dx,offset EMSerr
        int     21h
        jmp     @@error
@@gotEMS:
        mov     cs:[EMShandle],dx
        mov     ah,46h                  ;get version, if 4.0 or higher, we're going to name our block
        int     67h
        cmp     al,40h
        jb      @@done
        mov     ax,5301h                ;give our handle a name
        mov     dx,cs:[EMShandle]
        mov     si,offset EMSname
        int     67h
@@done:
        pop     si
        pop     di
        ret
@@error:
        mov     ah,9                    ;say we'll use conventional memory instead
        mov     dx,offset cnvmsg
        int     21h
        mov     cs:[useEMS],0
        mov     cs:[fontblocks],0       ;can't save fonts anymore!!
        jmp     @@done
emmname db      'EMMXXXX0'
EMSname db      'VGAMoire'
noEMS   db      'EMS memory manager not found.',13,10,'$'
EMS30   db      'VGAMoire requires EMS 3.0 or higher.',13,10,'$'
EMSerr  db      'Error allocating EMS memory.',13,10,'$'
cnvmsg  db      'Using conventional memory instead.',13,10,'$'
getEMS  endp



reznew          db      0               ;flag:  are we setting new params for resident copy

setup   proc    near                    ;main procedure for setting up program
        mov     ah,9                    ;print id string
        mov     dx,offset msg
        int     21h
        ; process the command line
        mov     di,80h                  ;set si and di to command tail
        mov     si,81h
@@nextchr:
        lodsb                           ;get next character
        cmp     al,' '                  ;is it a whitespace, space or tab or enter
        jz      @@nextchr
        cmp     al,9
        jz      @@nextchr
        cmp     al,0dh                  ;if enter quit processing
        jz      @@endln
        dec     si                      ;adjust si
        xor     al,al                   ;mark end of string with 0
        stosb
@@getchr:
        lodsb                           ;get character
        cmp     al,' '                  ;is it a whitespace
        jz      @@nextchr
        cmp     al,9
        jz      @@nextchr
        cmp     al,0dh
        jz      @@endln
        cmp     al,'a'                  ;is the character a small letter
        jl      @@storchr
        cmp     al,'z'
        jg      @@storchr
        and     al,223                  ;if so capitalize it
        cmp     al,'N'                  ;send new params?
        jne     @@storchr
        mov     [reznew],1
@@storchr:
        stosb                           ;store character again
        jmp     @@getchr
@@endln:
        xor     ax,ax                   ;put double zero in tail to mark end of buffer
        stosw
        cmp     [reznew],1              ;should we set options for resident copy?
        jne     @@parse
        call    newopts
@@parse:
        ; parse the command line and act on parameters
        mov     si,80h                  ;start reading here
        cmp     word ptr [si+1],'?'     ;was '?' input
        jnz     @@findnull
        mov     ah,9                    ;then print message describing switches
        mov     dx,offset usage
        int     21h
        mov     ax,4c00h                ;and quit with error level 0
        int     21h
@@findnull:
        lodsb                           ;read character until we get a 0
        or      al,al
        jnz     @@findnull
        cmp     byte ptr [si],al        ;is next character a 0, are we finished ?
        jnz     @@continue
        jmp     @@donepar
@@continue:
        lodsb                           ;get character
        xor     bp,bp                   ;compare to valid options
@@nextone:
        mov     ah,cs:[bp + offset options]
        or      ah,ah
        jz      @@findnull
        cmp     ah,al
        je      @@gotone
        inc     bp
        jmp     @@nextone
@@gotone:
        shl     bp,1                    ;convert to word index
        call    word ptr cs:[bp + offset optaddr]
        jmp     @@findnull
@@donepar:
        cmp     [useEMS],0
        jnz     @@possiblefont
        mov     [fontblocks],0
@@possiblefont:
;        push    cs
;        pop     es
        cmp     [reznew],0
        jz      @@start
        ; -- possible enhancement: display current settings before exitting
        mov     ah,9                    ;display msg that params have been updated
        mov     dx,offset newmsg
        int     21h
        mov     ax,4c00h
        int     21h
@@start:
        ; start the moire pattern without going resident
        call    noresident
        cmp     [useEMS],0
        jz      @@noEMS
        call    getEMS
@@noEMS:
        mov     ax,0caffh               ;are we installed yet
        int     10h
        cmp     ax,0faceh
        jne     @@storevec
        mov     ah,9                    ;if so, print error message and abort
        mov     dx,offset ainmsg
        int     21h
        mov     ax,4c01h
        int     21h
@@storevec:
        ; store interrupt vectors
        mov     ax,3508h                ;save int 08h vector
        int     21h
        mov     word ptr [old08h],bx
        mov     word ptr [old08h+2],es
        mov     ah,25h                  ;install our int 08h
        mov     dx,offset our08h
        int     21h
        mov     ax,3509h                ;save int 09h vector
        int     21h
        mov     word ptr [old09h],bx
        mov     word ptr [old09h+2],es
        mov     ah,25h                  ;install our int 09h
        mov     dx,offset our09h
        int     21h
        mov     ax,3510h                ;save int 10h vector
        int     21h
        mov     word ptr [old10h],bx
        mov     word ptr [old10h+2],es
        mov     ah,25h                  ;install our int 10h
        mov     dx,offset our10h
        int     21h
        mov     ax,3513h                ;save int 13h vector
        int     21h
        mov     word ptr [old13h],bx
        mov     word ptr [old13h+2],es
        mov     ah,25h                  ;install our int 13h
        mov     dx,offset our13h
        int     21h
;        mov     ax,3514h                ;save int 14h vector
;        int     21h
;        mov     word ptr [old14h],bx
;        mov     word ptr [old14h+2],es
;        mov     ah,25h                  ;install our int 14h
;        mov     dx,offset our14h
;        int     21h
        mov     ax,3517h                ;save int 17h vector
        int     21h
        mov     word ptr [old17h],bx
        mov     word ptr [old17h+2],es
        mov     ah,25h                  ;install our int 17h
        mov     dx,offset our17h
        int     21h
if __DeallocateEnvironment
        mov     ax,word ptr ds:[2ch]    ; deallocate our environment block
        mov     es,ax
        mov     ah,49h
        int     21h
endif
        mov     ah,9                    ;print install message
        mov     dx,offset inmsg
        int     21h
        ; set up and install VGAMoire
        push    [wait]                  ;set counter = wait
        pop     [counter]
        xor     dx,dx
        cmp     [useEMS],0
        jnz     @@yesEMS
        mov     [storetext],cs          ;make pointer to video save area
        mov     ax,offset EndOfResident
        mov     cl,4
        shr     ax,cl
        add     [storetext],ax          ;got new address for conventional memory video save buffer
        xor     bx,bx                   ;set bx=0 in case no mouse driver!!!
        mov     ax,15h                  ;find size of mouse state buffer
        int     33h
        mov     [mousesize],bx          ;store size of mouse buffer
        push    bx
;+*VGA
        mov     ax,1c00h                ;get size of video state save buffer
        mov     cx,7
        int     10h
        mov     cl,6                    ;multiple by 64
        shl     bx,cl
        mov     dx,bx
;-*VGA
        pop     bx
        cmp     [gfxcopout],0           ;if gfx cop-out mode is in effect, don't reserve any memory
        jne     @@yesEMS
        add     dx,[buffersize]         ;plus space to reserve for text buffer
        add     dx,bx                   ;and for mouse state buffer
@@yesEMS:
        add     dx,offset EndOfResident ;actual program code to reserve
        inc     dx                      ;for int 27h, dx = (offset last_byte) + 1
        int     27h
setup endp



finddigit       proc    near            ;convert string to digit
        xor     ax,ax                   ;set ax = 0 = cx, bx = 10
        mov     bx,10
        mov     cx,ax
@@nextdigit:
        lodsb                           ;get next character
        or      al,al                   ;are we at end
        jz      @@done
        cmp     al,'9'                  ;was character bigger than 9
        jg      @@fail
        sub     al,'0'                  ;or less than zero
        jl      @@fail
        xchg    ax,cx                   ;cx = cx * 10 + ax
        mul     bx
        add     cx,ax
        or      ch,ch                   ;is cx > 255
        jz      @@nextdigit
@@fail:
        dec     si                      ;return with failure
        stc
        ret
@@done:
        or      cx,cx                   ;is cx = 0 then return failure
        jz      @@fail
        dec     si                      ;return with success
        clc
        ret
finddigit       endp



;memprob         db      'Memory allocation error.',13,10,'$'

noresident      proc    near            ;run graphics w/o staying resident
        cmp     [wait],0                ;was wait time specified
        jz      nr1
        ret                             ;if so, return and install
nr1:
;        mov     ah,4ah                  ;free unneeded memory
;        mov     bx,sp
;        mov     cl,4
;        shr     bx,cl
;        inc     bx                      ;extra paragraph
;        push    cs
;        pop     es
;        int     21h
;        jnc     @@nonres_ok
;        mov     ah,9
;        mov     dx,offset memprob
;        int     21h
;        mov     ax,4c01h
;        int     21h
;@@nonres_ok:
        mov     [buffersize],8000h      ;save all video text RAM
        cmp     [useEMS],0
        jz      @@noEMS1
        call    getEMS
@@noEMS1:
        mov     [wait],444h             ;give wait a value so we don't loop endlessly!
        mov     [counter],444h
        cmp     [useEMS],0
        jnz     @@yesEMS
        mov     [storetext],cs          ;make our video save buffer be after all important code
        mov     ax,offset EndOfNonresident
        mov     cl,4
        shr     ax,cl
        add     [storetext],ax          ;got new address for conventional memory video save buffer
        @@yesEMS:
        mov     ax,3509h                ;save int 09h vector
        int     21h
        mov     word ptr [old09h],bx
        mov     word ptr [old09h+2],es
        mov     ax,2509h                ;install our int 09h
        mov     dx,offset our09h
        int     21h
        mov     ax,3508h                ;save int 08h vector
        int     21h
        mov     word ptr [old08h],bx
        mov     word ptr [old08h+2],es
        mov     ax,2508h                ;install our int 08h
        mov     dx,offset our08h
        int     21h
        push    es                      ;timer-based pause loop
        mov     es,[keybuff]
        mov     bx,46ch
        mov     cx,es:[bx]              ;read timer
@@tryagain:
        mov     dx,es:[bx]              ;read timer
        sub     dx,cx                   ;find difference
        test    dx,8000h                ;negative?
        jz      @@pos
        neg     dx                      ;take absolute value
@@pos:
        cmp     dx,3                    ;wait a smidgen
        jb      @@tryagain
        pop     es
        mov     [timeout],1
        mov     [counter],1
        @@untildone:
        cmp     [counter],10            ;wait until counter gets reset (ie, mouse or keyboard activity)
        jb      @@untildone
        mov     ax,2508h                ;restore old int 08h handler
        mov     dx,word ptr [old08h]    ;  (don't need to use a CS: override yet)
        mov     ds,word ptr [old08h+2]
        int     21h
        mov     ax,2509h                ;restore old int 09h handler
        mov     dx,word ptr cs:[old09h] ;  (from here on we need CS: overrides)
        mov     ds,word ptr cs:[old09h+2]
        int     21h
        push    cs                      ;restore DS: addressability
        pop     ds
        cmp     [useEMS],0
        jz      @@noEMS2
        mov     ah,45h                  ;release EMS block, if present
        mov     dx,[EMShandle]
        int     67h                     ;if there was an error, it's out of our hands
        @@noEMS2:
        mov     ax,4c00h                ;exit, errorlevel 0
        int     21h
noresident endp



        align   16                      ;paragraph aligned so we can just store a segment address
EndOfNonresident        label   byte



options         db      'BCDEFLMPRSUVW-+',0
optaddr         label   word
                dw      setblank
                dw      setcolor
                dw      setdelay
                dw      setEMS
                dw      setsavfon
                dw      setlines
                dw      setmouse
                dw      setpages
                dw      setmirror
                dw      setspeed
                dw      deinstall
                dw      setvidact
                dw      setminutes
                dw      setoff
                dw      seton

msg             db      13,10
                db      'VGAMoire ',VERSION,',  by Christopher Antos,  ',DATE,',  (C)1990',13,10,'$'
inmsg           db      '++ VGAMoire now installed.',13,10,'$'
nomsg           db      '** VGAMoire has not been installed yet.',13,10,'$'
ainmsg          db      '** VGAMoire is already installed.',13,10
                db      '   Use VGAMOIRE U to deinstall.',13,10
                db      '   Use VGAMOIRE N to set new parameters.',13,10,'$'
demsg           db      '-- VGAMoire now deinstalled.',13,10,'$'
suremsg         db      13,10
                db      'Another program has captured VGAMoire''s interrupt vectors.',13,10
                db      'Deinstalling VGAMoire may cause a system crash.',13,10
                db      'Are you sure you want to deinstall VGAMoire? $'
stilmsg         db      '** VGAMoire is still installed.',13,10,'$'
newmsg          db      '++ New parameters sent to resident VGAMoire.',13,10,'$'
usage           db      13,10
                db      'Usage:  VGAMOIRE [Bn] [Cn] [Dn] [E] [Fn] [Ln] [Mn] [N]',13,10
                db      '                 [Pn] [Rn] [Sn] [U] [Vn] [Wn] [-] [+]',13,10
                db      10
                db      'Summary of options:                      * = invalid if used with [N]',13,10
                db      '  Bn    blank:  1-graphics, 2-always     Pn  * save <n> video pages (1-8)',13,10
                db      '  Cn    colors:  1-rainbow, 2-fire,      Rn    mirror:  1-none, 2-H, 3-V, 4-H/V',13,10
                db      '        3-frost, 4-pastel                Sn    color speed:  (1-255)',13,10
                db      '  Dn    delay:  (1-255)                  U     uninstall',13,10
                db      '  E   * use EMS                          Vn    video:  1-monitor, 2-ignore',13,10
                db      '  Fn  * save <n> font blocks (1-8)       Wn    wait <n> minutes (1-30)',13,10
                db      '  Ln    lines:  (1-50)                   -     turn off',13,10
                db      '  Mn    mouse:  1-monitor, 2-ignore      +     turn on',13,10
                db      '  N     send options to resident copy    ',13,10
                db      10
                db      '    Press Ctrl-Alt-Shift to pop up screen saver.  The screen saver may be',13,10
                db      '    disabled by pressing Ctrl-Alt-E and reenabled by pressing Ctrl-Alt-B.',13,10
                db      '    Use  VGAMOIRE - N  to turn off resident copy (or  + N  to turn back on).',13,10
                db      '$'



numsets         equ     5               ;number of color sets defined

; R,G,B values for video DAC color registers

rainbow         db      63,  0,  0      ;color #1       [red]
                db      63, 30,  0      ;
                db      63, 45,  0      ;
                db      63, 63,  0      ;               [yellow]
                db      42, 63,  0      ;
                db       0, 63,  0      ;               [green]
                db       0, 63, 42      ;
                db       0, 63, 63      ;               [cyan]
                db       0, 45, 63      ;
                db       0, 31, 63      ;
                db       0,  0, 63      ;               [blue]
                db      30,  0, 63      ;
                db      45,  0, 63      ;
                db      63,  0, 63      ;               [violet]
                db      63,  0, 47      ;color #15
                db      15

fire            db      63,  0,  0      ;color #1       [red]
                db      63,  7,  0
                db      63, 13,  0
                db      63, 22,  0
                db      63, 27,  0
                db      63, 32,  0
                db      63, 36,  0
                db      63, 42,  0
                db      63, 48,  0
                db      63, 52,  0
                db      63, 58,  0
                db      63, 63,  0      ;color #13      [yellow]
                db      63, 49,  0
                db      63, 40,  0
                db      63, 30,  0
                db      15

frost           db      63, 21, 63      ;color #1       [purple]
                db      52, 21, 63
                db      42, 21, 63
                db      31, 21, 63
                db      21, 21, 63      ;color #5       [blue]
                db      21, 29, 63
                db      21, 38, 63
                db      21, 46, 63
                db      21, 54, 63
                db      21, 63, 63      ;color #10      [cyan]
                db      35, 63, 63
                db      49, 63, 63
                db      63, 63, 63      ;color #13      [white]
                db      63, 49, 63
                db      63, 35, 63
                db      15

pastel          db      63, 47, 47      ;color #1       [red]
                db      63, 50, 47      ;
                db      63, 54, 47      ;
                db      63, 58, 47      ;
                db      63, 63, 47      ;               [orange]
                db      59, 63, 47      ;
                db      55, 63, 47      ;               [yellow]
                db      47, 63, 49      ;
                db      47, 63, 58      ;               [green]
                db      47, 62, 63      ;
                db      47, 57, 63      ;               [cyan]
                db      47, 50, 63      ;
                db      51, 47, 63      ;
                db      58, 47, 63      ;               [violet]
                db      63, 47, 57      ;color #15
                db      15

test            db      63, 63, 63      ;
                db      33, 33, 33      ;
                db      63, 63, 63      ;
                db      33, 33, 33      ;
                db      63, 63, 63      ;
                db      33, 33, 33      ;
                db      63, 63, 63      ;
                db      63, 63, 63      ;
                db      33, 33, 33      ;
                db      63, 63, 63      ;
                db      33, 33, 33      ;
                db      63, 63, 63      ;
                db       0,  0,  0      ;
                db       0,  0,  0      ;
                db       0,  0,  0      ;
                db      12

cseg    ends



public  EMS30
public  EMSerr
public  EMShandle
public  EMSname
public  EndOfNonresident
public  EndOfResident
public  MaxLines
public  MaxRev
public  _mypsp
public  ainmsg
public  alllines
public  aval
public  blackcolor
public  buffersize
public  checkx
public  checkxy
public  cnvmsg
public  colorset
public  colorspeed
public  colorwait
public  counter
public  curcolor
public  cval
public  de0
public  de1
public  deinstall
public  delay
public  demsg
public  di1
public  di2
public  di4
public  doline
public  dox
public  doxy
public  drawmoire
public  emmname
public  ex1
public  finddigit
public  fire
public  fontblocks
public  freebuf
public  frost
public  getEMS
public  getbuf
public  getcoords
public  gfxcopout
public  gfxinstalled
public  gfxmode
public  gonow
public  index
public  inmsg
public  int10hOK
public  keybuff
public  length
public  linesx1
public  linesx2
public  linesy1
public  linesy2
public  main
public  maxcolor
public  mirror
public  moire
public  mouse
public  mousesize
public  msg
public  newmsg
public  newopts
public  noEMS
public  nomsg
public  noresident
public  nr1
public  numsets
public  nw1
public  old08h
public  old09h
public  old10h
public  old13h
public  old17h
public  oldmx
public  oldmy
public  onoff
public  optaddr
public  options
public  our08h
public  our09h
public  our10h
public  our13h
public  our17h
public  pastel
public  rainbow
public  randir
public  randvel
public  ranex
public  rb20
public  rd1
public  reset
public  revdir
public  revex
public  reznew
public  rnd
public  rndcnt
public  rnum
public  runthis
public  rval
public  sax
public  sax2
public  sbp
public  sbx
public  sbx2
public  scs
public  scx
public  scx2
public  sdi
public  sds
public  sds2
public  sdx
public  sdx2
public  seed
public  ses
public  setEMS
public  setblank
public  setcolor
public  setdelay
public  setlines
public  setminutes
public  setmirror
public  setmouse
public  setoff
public  seton
public  setpages
public  setsavfon
public  setspeed
public  setup
public  setvidact
public  sfl
public  sip
public  ssi
public  stilmsg
public  storetext
public  suremsg
public  switchdir
public  textbuff
public  timeout
public  usage
public  useEMS
public  videomode
public  wait
public  x1
public  x1rev
public  x2
public  x2rev
public  xv1
public  xv2
public  y1
public  y1rev
public  y2
public  y2rev
public  yv1
public  yv2



        end     main

;______ EOF ___________________________________________________________________
