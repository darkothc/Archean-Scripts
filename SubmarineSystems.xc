;Included Source Files
include "libColor.xc"	;Wider list of color variables include e.g. $dark_gray, $olive, $teal

;-- GLOBAL SCOPE

;Screens 
var $screenTR = screen("OpScreenTR", 0)	;Top Right Screen
var $screenBR = screen("OpScreenBR", 0)	;Bottom Right Screen
var $screenTL = screen("OpScreenTL", 0)	;Top Left Screen
var $screenBL = screen("OpScreenBL", 0)	;Bottom Left Screen


const $screenIDPretext = "Screen ID: "

;Gauge Fill Levels
var $gF1 = 90	;Fill Level
var $gX1 = 20	;x Position
var $gY1 = 140	;y Position

var $screenOpaque = 0

;# PLACEHOLDER PUMP VARIABLES
var $toggleIn:number
var $toggleOut:number

;# Valve Override
var $override = 1	;MANUAL OVERRIDE
var $valvesInit = 0
array $valves : text

;-- FUNCTION: Writes a centered label on screen
function @writeScreenHeader($screen:screen, $id:text, $color:number)
	var $textLen = size($screenIDPretext & $id)
	var $x = ($screen.width / 2) - ($screen.char_w * $textLen / 2)
	var $y = 1 ;Single pixel buffer from top of screen
	$screen.write($x, $y, $color, text("{}{}", $screenIDPretext, $id))

;-- FUNCTION: Draws a Gauge at x, y
function @drawGauge($screen:screen, $x:number, $y:number, $fill:number)
	var $w = 20		;Def Width: 20
	var $h = 100	;Def Height: 100
	
	;Gauge Base Background
	$screen.draw_rect($x+$w, $y-$h, $x, $y, black, gray)
	
	;Guage Fill Level
	var $fillHeight = $fill
	$fillHeight = clamp($fill, 0, 100)
	if $fillHeight > 0
		$screen.draw_rect($x+$w, $y-($fillHeight), $x, $y, black, cyan)
		
;-- #DEBUG GAUGE FUNCTION: Draws a Gauge Button at x, y
function @drawGaugeButtons($screen:screen, $x:number, $y:number, $fill:number)
	var $gBX = 20	;Guage button size x
	var $gBY = 10	;Guage button size y
	var $pressedColor = color(0,0,0,125)
	var $bUpColor = $pressedColor
	var $bDownColor = $pressedColor
	var $downPressed = 0
	var $upPressed = 0
	
	if $screen.button_rect($x, $y, $x+$gBX, $y+$gBY, black, gray)
		$bUpColor = $pressedColor
		$gF1 += 1
		$upPressed = 1

	if $screen.button_rect($x, $y+10, $x+$gBX, $y+$gBY+10, black, gray)
		$bDownColor = $pressedColor
		$gF1 -= 1
		$downPressed = 1

	$screenTR.draw_triangle($x+5,$y+7, $x+15,$y+7, $x+10,$y+1, black, white)	;Up Arrow
	$screenTR.draw_triangle($x+5,$y+12, $x+15,$y+12, $x+10,$y+18, black, white)	;Down Arrow
	
	;Pressed Visual
	if $upPressed == 1
		$screen.draw_rect($x, $y, $x+$gBX, $y+$gBY, $bUpColor, $bUpColor)
	if $downPressed == 1
		$screen.button_rect($x, $y+10, $x+$gBX, $y+$gBY+10, $bDownColor, $bDownColor)
	
;-- FUNCTION: Sytstem for setting screen as transparent/opaque
function @screenBackground($screen:screen, $x:number, $y:number)
	if $screenOpaque
		$screen.blank()
	else
		$screen.blank(0)
	if $screen.button_rect($x, $y, $x+8, $y+8, gray, white)
		$screenOpaque = 1-$screenOpaque


;-- FUNCTION: Override for opening all valves TESTING PURPOSES
function @valveOverride($toggle:number)
	if $valvesInit == 0
		$valves.append("vIF", "vOF", "vIB", "vOB", "vIR", "vOR", "vIL", "vOL")
		$valvesInit = 1	
	foreach $valves ($i, $valve)
		output_number($valve,0,$toggle)

;-- INIT
init
	@valveOverride($override)

	;$screenTR.blank(0)
	;$screenBR.blank()
	;$screenTL.blank(0)
	;$screenBL.blank()

;-- UPDATE
update
	var $balLevel = input_number("ballastR",0)
	var $bX1 = 60
	var $bY1 = 140

	@screenBackground($screenTR, 1, 1)
	
	
	;# DEBUG CONSOLE OUTPUTS
	print(text("{}(in) {}(out) {}(gF1) {00.00}%",$toggleIn, $toggleOut, $gF1, mul($balLevel,100)))
	print(text("{00.00}(in) {00.00}(out) FLOW RATE", input_number("pumpIn",0), input_number("pumpOut",0)))

	
	@writeScreenHeader($screenTR, "OpScreenTR", red)
	@writeScreenHeader($screenBR, "OpScreenBR", green)
	@writeScreenHeader($screenTL, "OpScreenTL", yellow)
	@writeScreenHeader($screenBL, "OpScreenBL", cyan)
	
	
	;Debug Guage
	@drawGauge($screenTR, $gX1, $gY1, $gF1)
	@drawGaugeButtons($screenTR, $gX1, $gY1, $gF1)
	
	
	;# Ballast Test
	@drawGauge($screenTR, $bX1, $bY1, mul($balLevel,100))
	
	
	
	;# Pump Controller
	if $screenTR.button_rect(20, 180, 40, 200, black, green)
		$toggleIn++
		
	if $toggleIn > 1
		$toggleIn = 0
	if $toggleIn == 1
		output_number("pumpIn", 0, 1)
		;output_number("PumpOut", 0, -1) ;FOR TESTING ONLY
		else
	if $toggleIn == 0
		output_number("pumpIn", 0, 0)
		
		
	if $screenTR.button_rect(40, 180, 60, 200, black, Red)
		$toggleOut++
		
	if $toggleOut > 1
		$toggleOut = 0
	if $toggleOut == 1
		output_number("pumpOut", 0, 1)
		;output_number("PumpIn", 0, -1) ;FOR TESTING ONLY
		else
	if $toggleOut == 0
		output_number("pumpOut", 0, 0)	


	;--- DEBUG INFO ---
	
	;var $testText = "This is Test Text! it is 37 char long"
	
	;var $g1Mark = "]^|^["	;Custom marker for alignment
	
	;Code for position and alignment of Custom Marker
	;$screenTR.write($g1X - $screenTR.char_w*(size($g1Mark)/2)+($gX1/2), $g1Y + $screenTR.char_h/4, white, $g1Mark) 
	
	;Marker to for x,y coords (Originally for confirming gauge corners)
	;$screenTR.draw_point($g1X+$gX1, $g1Y-$gY1, white)	;Top Right of Gauge1
	;$screenTR.draw_point($g1X, $g1Y, cyan)				;Bottom Left of Gauge1
	;$screenTR.draw_point($g1X+$gBX, $g1Y+$gBY, red)	;Bottom Right of Gauge1 Button
