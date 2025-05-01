.model small
.stack 100h
.data
score db 'Score: $'
scoreCount dw 0
lives db '              Lives: '
livesCount db 51
ending db ' $'

ballY dw 163
ballX dw 158
ballLeft db 1
ballUp db 1
color db ?
startx dw ?
starty dw ?
endx dw ?
endy dw ?       
begin db 0
strikerX dw 140
strikerY dw 170
innerDelay db 0
boundaryEnd dw 250
boundaryStart dw 30

brick1x dw 45
brick1y dw 25
brick2x dw 85
brick2y dw 25
brick3x dw 125
brick3y dw 25
brick4x dw 165
brick4y dw 25
brick5x dw 205
brick5y dw 25
brick6x dw 245
brick6y dw 25


brick7x dw 45
brick7y dw 45
brick8x dw 85
brick8y dw 45
brick9x dw 125
brick9y dw 45
brick10x dw 165
brick10y dw 45
brick11x dw 205
brick11y dw 45
brick12x dw 245
brick12y dw 45

brick13x dw 45
brick13y dw 65
brick14x dw 85
brick14y dw 65
brick15x dw 125
brick15y dw 65
brick16x dw 165
brick16y dw 65
brick17x dw 205
brick17y dw 65
brick18x dw 245
brick18y dw 65

var1 db 'Enter your name: $'
id db 'Enter your ID: $'
welcome db 'Welcome to Brick Breaker Game!$'
pressEnter db 'Press Enter to start the game...$'
playerName db 20 dup('$')
playerID db 10 dup('$')
winMsg db 'Congratulations, you won!$'
loseMsg db 'Game over, you lost!$'

.code
redrawStriker macro visColor

mov color, visColor
call drawStriker
endm

redrawBall macro visColor
    mov color, visColor
    call drawball
endm

BuildBrick macro  A, B
    push ax
    push bx
    mov ax, A
    mov bx, B
    call AddBrick
    pop bx
    pop ax
endm

DestroyBrick macro  A, B
    push ax
    push bx
    mov ax, A
    mov bx, B
    call RemoveBrick
    call beep     
    inc scoreCount
    call DrawLivesScores
    pop bx
    pop ax
endm

BrickCollision MACRO X, Y
local copper
    push ax
    push bx
    push cx
    push dx
    mov ax, ballY
    mov bx, ballX
    mov cx, X
    mov dx, Y
    
    cmp dx, ballY
    jl copper
    sub dx, 7
    
    cmp ballY, dx
    jl copper
    
    mov dx, X 
    cmp ballX, dx
    jl copper
    add dx, 30
    cmp dx, ballX
    jl copper
    
    call switcher
    DestroyBrick X, Y
    mov Y, 300
    cmp scoreCount, 18
    jne copper
    
    ; Clear the screen
    mov ah, 0
    mov al, 3
    int 10h
    
    ; Display win message
    mov ah, 2
    mov dh, 5
    mov dl, 20
    int 10h
    mov ah, 9
    lea dx, winMsg
    int 21h
    
    ; Move to the next line
    mov ah, 2
    mov dh, 7
    mov dl, 20
    int 10h
    
    
    ; Display press enter message
    mov ah, 9
    lea dx, pressEnter
    int 21h
    
    ; Wait for enter key press
    call waitForEnter
    call restartGame
    
    copper:
    pop dx
    pop cx
    pop bx
    pop ax                      
    
endm
main proc
    mov ax,@data
    mov ds,ax
    
    ; Clear the screen
    mov ah, 0
    mov al, 3
    int 10h
    
    ; Display welcome message
    mov ah, 2
    mov dh, 5
    mov dl, 20
    int 10h
    mov ah, 9
    lea dx, welcome
    int 21h
    
    ; Move to the next line
    mov ah, 2
    mov dh, 7
    mov dl, 20
    int 10h
    
    ; Get player name
    mov ah, 9
    lea dx, var1
    int 21h
    mov ah, 0Ah
    lea dx, playerName
    int 21h
    
    ; Move to the next line
   
    mov ah, 2
    mov dh, 9
    mov dl, 20
    int 10h
    
    ; Get player ID
    mov ah, 9
    lea dx, id
    int 21h
    mov ah, 0Ah
    lea dx, playerID
    int 21h
    
    ; Move to the next line
    mov ah, 2
    mov dh, 11
    mov dl, 20
    int 10h
    
    ; Display press enter message
    mov ah, 9
    lea dx, pressEnter
    int 21h
    
    ; Wait for enter key press
    mov ah, 0
    int 16h
    
     call setVideoMode
    call drawBoundary

    ; Draw first row of bricks (Red Rectangle)
    BuildBrick brick1x brick1y
    BuildBrick brick2x brick2y
    BuildBrick brick3x brick3y
    BuildBrick brick4x brick4y
    BuildBrick brick5x brick5y
    BuildBrick brick6x brick6y

    ; Draw second row of bricks (Yellow Square)
    BuildBrick brick7x brick7y
    BuildBrick brick8x brick8y
    BuildBrick brick9x brick9y
    BuildBrick brick10x brick10y
    BuildBrick brick11x brick11y
    BuildBrick brick12x brick12y

    ; Draw third row of bricks (Light Blue Wide Rectangle)
   BuildBrick brick13x brick13y
BuildBrick brick14x brick14y
BuildBrick brick15x brick15y
BuildBrick brick16x brick16y
BuildBrick brick17x brick17y
BuildBrick brick18x brick18y


    redrawStriker 7
    redrawBall 3                
    call DrawLivesScores
    call gameLoop      
    
    mov ah,4ch
    int 21h
main endp
DrawLivesScores proc
    push dx
    push ax
                 
    mov dh, 23 ;row
    mov dl, 5 ;col
    mov ah, 2 
    int 10h
    
    lea dx, score
    mov ah, 9
    int 21h
    
    call printScore
    
    lea dx,lives
    mov ah,9
    int 21h  

    pop ax
    pop dx
    ret
    DrawLivesScores endp

printScore proc
    push ax
    push bx
    push cx
    push dx
    
    mov cx,0
    
    mov ax,scoreCount
    ll:
    mov bx,10
    mov dx,0
    div bx
    push dx
    inc cx
    cmp ax,0
    jne ll
    
    l2:
    pop dx
    mov ah,2
    add dl,'0'
    int 21h
    loop l2
    
    pop dx
    pop cx
    pop bx
    pop ax
    
    ret
    printScore endp

sleep proc
    mov cx, 111111b 
l:
    loop l
    ret
sleep endp

drawball proc
    push bx
    mov bx, ballX
    mov startx, bx
    add bx, 4 
    mov endx,   bx
    mov bx, ballY
    mov starty, bx
    add bx, 4
    mov endy,   bx
    
    pop bx
    
    call draw
ret
drawball endp
CollisionStriker proc    
    push ax
    push bx
    push cx
    push dx
    
    mov dx, ballY
    cmp dx, 165 ; striker surface check
    jl bhaag
    cmp dx, 170 ; striker missed
    jg fail 
    
    mov cx,strikerX   
    mov ax, ballX   
    cmp ax, cx  
    jl bhaag
    add cx , 40 
    cmp ax, cx
    jg bhaag
    
    mov ballUp, 1
    jmp bhaag
    
fail:
    mov begin,0 
    dec livesCount
    cmp livesCount,48
    je khatam
    push ax
    push bx
    push cx
    push dx
    
    redrawBall 0
    
    mov ax, strikerX
    mov ballX,ax
    add ballX,18
    
    mov ballY,  163
    
    redrawBall 3
    mov ballUp, 1     ;monis
    mov ballLeft,0
    
    pop dx
    pop cx
    pop bx
    pop ax
    
    call DrawLivesScores
    jmp bhaag
    
khatam:             
    ; Clear the screen
    call setTextMode ; Set to text mode to clear the screen
    mov ah, 9
    lea dx, pressEnter
    int 21h

    mov dl, 10
    mov ah, 2
    int 21h

    
    
    call waitForEnter
    call restartGame
    
bhaag:  
    pop dx
    pop cx
    pop bx
    pop ax
    ret
CollisionStriker endp

; Procedure to set the text mode (clear screen)
setTextMode proc
    mov ah, 0
    mov al, 3  ; Set to text mode 3 (80x25 color text)
    int 10h
    ret
setTextMode endp

CenterText proc
    push ax
    push bx
    push dx
    
    mov ah, 2      ; Set cursor position
    mov bh, 0      ; Page number
    mov dh, 12     ; Row 12 (middle)
    mov dl, 35     ; Column 35 (middle)
    int 10h
    
    mov ah, 9      ; Display string
    lea dx, var1   ; Load message
    int 21h
    
    pop dx
    pop bx
    pop ax
    ret
CenterText endp

switcher:
    cmp ballUp, 1
    je DownT
    jne UpT
    UpT:
    inc ballUp
    ret
    DownT:
    dec ballUp
    ret
AddBrick proc
    push ax
    push bx    
    mov startx, ax
    mov ax, bx
    mov bx, startx
    
    ; Set a consistent size for all bricks
    mov bx, startx
    add bx, 30       ; Consistent width for all bricks
    mov endx, bx
    mov starty, ax 
    mov bx, starty
    add bx, 7        ; Consistent height for all bricks
    mov endy, bx

    ; Set color based on row
    cmp starty, 25      ; First row
    je row1
    cmp starty, 45      ; Second row
    je row2
    cmp starty, 65      ; Third row
    je row3

    row1:
        mov color, 13    ; Red color
        jmp drawBrick

    row2:
        mov color, 14    ; Yellow color
        jmp drawBrick

    row3:
        mov color, 11    ; Light Blue color
        jmp drawBrick

    drawBrick:
    call draw
    pop bx
    pop ax 
    ret
AddBrick endp

RemoveBrick proc 
    push ax
    push bx
    push cx
    push dx
       
    mov startx, ax
    mov color, 0  
    mov ax, bx
    mov bx, startx
    
    ; Use consistent size for removing bricks
    add bx, 30
    mov endx, bx
    mov starty, ax 
    mov bx, starty
    add bx, 7
    mov endy, bx
     
    call draw 
    pop dx
    pop cx
    pop bx
    pop ax
    ret
RemoveBrick endp

Collisionwall proc     
    
    mov bx, ballX
    mov cx, ballY
    
    checkLeftRight:
    cmp bx, 25; max left
    jl goRight
    cmp bx, 290; Max Right
    jg goLeft
    jmp checkUpDown
    goRight:
    mov ballLeft, 0 
    jmp checkUpDown;
    goLeft:
    mov ballLeft, 1
    checkUpDown:
    
    cmp cx, 13;max top
    jl goDown
    cmp cx, 184;max bottom
    jg goUp
    
    
    jmp noInput
    goUp:                                            
    mov ballUp,1
    jmp noInput
    goDown: 
    mov ballUp, 0
  
    ret
    Collisionwall endp

gameOver proc
    
    mov ah,4ch
    int 21h
    gameOver endp

ajeebse:
ret
baller proc  
    
	inc innerDelay
EXTERNDELAY EQU 5  ; You can adjust this value as needed
	jne ajeebse 
	mov innerDelay, 0
    redrawBall 0  
    
	mov bx,ballX 
	cmp ballLeft, 1
	je Left
	jne Right
	
	Left:   
	sub bx, 2
	jmp P2;  
	Right:   
	add bx, 2
	
	P2:
	mov ballX,  bx
	mov bx, ballY
	cmp ballUp, 1   
	je Up
	jne Down
	Up:
    sub bx, 2
	jmp P3
	Down:
    add bx, 2
	P3:
    mov ballY,  bx
   
    redrawBall 3
    
ret
baller endp   


repeat:
gameLoop:        
    CALL    checkKeyboard
    cmp begin,1
    jne repeat
   
    call Collisionwall
    call CollisionStriker 
    call checkBricks
    
    CALL baller  
    CALL sleep
    JMP     gameLoop 

checkBricks proc
    BrickCollision Brick1x, Brick1y
    BrickCollision Brick2x, Brick2y
    BrickCollision Brick3x, Brick3y
    BrickCollision Brick4x, Brick4y
    BrickCollision Brick5x, Brick5y
    BrickCollision Brick6x, Brick6y 
    BrickCollision Brick7x, Brick7y
    BrickCollision Brick8x, Brick8y
    BrickCollision Brick9x, Brick9y
    BrickCollision Brick10x, Brick10y
    BrickCollision Brick11x, Brick11y
    BrickCollision Brick12x, Brick12y
    BrickCollision Brick13x, Brick13y
    BrickCollision Brick14x, Brick14y
    BrickCollision Brick15x, Brick15y
    BrickCollision Brick16x, Brick16y
    BrickCollision Brick17x, Brick17y
    BrickCollision Brick18x, Brick18y
    ret
checkBricks endp
    
exit:
    mov ah, 4ch
    int 21h

checkKeyboard proc
    mov     ah,     1h
    int     16h         ; check keypress
    jz      noInput     ; no keypress
    mov     ah,     0h
    int     16h
    cmp     ax,     4D00h
    je      rightKey
    cmp     ax,     4B00h
    je      leftKey
    cmp     al,     27D
    je      exit
    cmp     ax,     3920h;space to begin
    je      beg
    jne     noInput
    
    beg:
    mov begin,1
    
    noInput:
    ret  

    rightKey:     
    mov bx, boundaryEnd
    cmp     strikerX, bx ;max right limit
    jg      noInput
    redrawStriker 0
    add     strikerX, 5
    redrawStriker 7
    cmp begin,0
    jz moveBallRight
    jmp     noInput
    
    
    leftKey:   
    mov bx, boundaryStart                            
    cmp     strikerX, bx ;max left limit
    jl      noInput
    redrawStriker 0
    sub     strikerX, 5
    redrawStriker 7
    cmp begin,0
    jz moveBallLeft
    jmp     noInput
    
    
    moveBallLeft:
    redrawBall 0
    sub     ballX, 5
    redrawBall 3
    jmp     noInput
    
    
    moveBallRight:
    redrawBall 0
    add     ballX, 5
    redrawBall 3
    jmp     noInput

checkKeyboard endp

draw proc
    push ax
    push cx
    push dx
     
    mov dx,starty
    mov cx,startx
    mov ah,0ch
    mov al,color
c:
    inc cx
    int 10h
    cmp cx,endx
    jne c

    mov cx,startx
    inc dx
    cmp dx,endy
    jne c 
    
    pop dx
    pop cx
    pop ax
    ret
draw endp


drawStriker proc
    push bx
    push cx
        
    mov bx, strikerX
    mov cx, strikerY   
    mov startx,bx
    add bx, 40
    mov endx,bx
    mov starty,cx
    mov endy,175
    call draw
    
    pop cx
    pop bx
    ret
    drawStriker endp

drawBoundary proc
    mov color,6    
    ;------TOP------------
    mov startx,20
    mov endx,300
    mov starty,5
    mov endy,8
    call draw
    ;------RIGHT------------
    mov startx,297
    mov endx,300
    mov starty,7
    mov endy,180
    call draw
    ;------LEFT------------
    mov startx,20
    mov endx,23
    mov starty,7
    mov endy,180
    call draw
    ;------BOTTOM------------
    mov startx,20
    mov endx,300
    mov starty,177
    mov endy,180
    call draw 
   
    ret
    drawBoundary endp


setVideoMode proc
    
    mov ah, 0   ; set display mode function.
    mov al, 13h ; mode 13h = 320x200 pixels, 256 colors.
    int 10h     
    
    ret
    setVideoMode endp

beep proc
        push ax
        push bx
        push cx
        push dx
        mov     al, 182         ; Prepare the speaker for the
        out     43h, al         ;  note.
        mov     ax, 400        ; Frequency number (in decimal)
                                ;  for middle C.
        out     42h, al         ; Output low byte.
        mov     al, ah          ; Output high byte.
        out     42h, al 
        in      al, 61h         ; Turn on note (get value from
                                ;  port 61h).
        or      al, 00000011b   ; Set bits 1 and 0.
        out     61h, al         ; Send new value.
        mov     bx, 2          ; Pause for duration of note.
.pause1:
        mov     cx, 65535
.pause2:
        dec     cx
        jne     .pause2
        dec     bx
        jne     .pause1
        in      al, 61h         ; Turn off note (get value from
                                ;  port 61h).
        and     al, 11111100b   ; Reset bits 1 and 0.
        out     61h, al         ; Send new value.

        pop dx
        pop cx
        pop bx
        pop ax

ret
beep endp

waitForEnter proc
    mov ah, 0
    int 16h
    ret
waitForEnter endp

resetBricks proc
    ; Reset brick positions
    mov brick1x, 45
    mov brick1y, 25
    mov brick2x, 85
    mov brick2y, 25
    mov brick3x, 125
    mov brick3y, 25
    mov brick4x, 165
    mov brick4y, 25
    mov brick5x, 205
    mov brick5y, 25
    mov brick6x, 245
    mov brick6y, 25

    mov brick7x, 45
    mov brick7y, 45
    mov brick8x, 85
    mov brick8y, 45
    mov brick9x, 125
    mov brick9y, 45
    mov brick10x, 165
    mov brick10y, 45
    mov brick11x, 205
    mov brick11y, 45
    mov brick12x, 245
    mov brick12y, 45

    mov brick13x, 45
    mov brick13y, 65
    mov brick14x, 85
    mov brick14y, 65
    mov brick15x, 125
    mov brick15y, 65
    mov brick16x, 165
    mov brick16y, 65
    mov brick17x, 205
    mov brick17y, 65
    mov brick18x, 245
    mov brick18y, 65
    ret
resetBricks endp

restartGame proc
    mov scoreCount, 0
    mov livesCount, 51
    call resetBricks
    ; Reset ball position and direction
    mov ballX, 158
    mov ballY, 163
    mov ballLeft, 1
    mov ballUp, 1
    call main
    ret
restartGame endp

end main