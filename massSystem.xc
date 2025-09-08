
;-- GLOBAL SCOPE
; Dashboard(alias) with HDscreen
var $screen = screen("scrn", 0)
var $weights : text
;EDIT ogMass to match your builds original mass, to be used as reference point
var $ogMass = "331" ; value in kg

;===========================================================
; FUNCTION: build key-values for cargo weights (grams per unit)
;===========================================================
function @CargoWeights_New():text
	var $w = ""
	$w.Rock = 1000
	$w.Silicon = 1
	$w.Iron = 1
	$w.Carbon = 1
	$w.Copper = 1
	$w.Aluminium = 1
	$w.Nickel = 1
	$w.Silver = 1
	$w.Tin = 1
	$w.Chrome = 1
	$w.Titanium = 1
	$w.Gold = 1
	$w.Lead = 1
	$w.Tungsten = 1
	$w.Uranium = 1
	$w.Fluorite = 1
	
	return $w

;===========================================================
; FUNCTION: compute cargo weight from cargo string (Foreach Code Modification - Lith)
;===========================================================
function @getCargoWeight($cargoStr:text, $weightsObj:text):number
	var $total = 0 
	var $perUnit = 0 

	foreach $cargoStr ($name, $qty)
		;# Get per-unit weight from weights object
		$perUnit = $weightsObj.$name
		if $perUnit == 0
			$perUnit = 0
			print("WARNING: No weight found for ", $name, ", using 0")
		else
			$perUnit = mul($perUnit, 1) ; Ensure numeric

		$total += mul($qty, $perUnit)

	return $total

;-- INIT
init
	; Build cargo weights and store it
	$weights = @CargoWeights_New()


;-- UPDATE
update
	$screen.blank()
	$screen.text_size(2)

	; VehiclePhysicsSensor(alias)
	var $pSense = input_number("physSensor",1)

	$screen.write(30, $screen.char_h*1.1, Yellow, "Mass Checker")
	;Adjust original Value to effect
	$screen.write(30, $screen.char_h*3.3, white, text("Original Mass = {}kg", $ogMass))
	$screen.write(30, $screen.char_h*2.2, white, text("Total Mass = {0.000}kg", $pSense))
	$screen.write(30, $screen.char_h*4.4, red, text("Added Mass = {0.000}kg", ($pSense - 331)))

	; -------------------------------------------------
	; cargo string from input_text (expected format: Iron{2}.Rock{1}.Silicon{1000}.Uranium{589})
	; -------------------------------------------------
	; Container(alias)
	var $cargoStr = input_text("cargoContainer",0)

	; Cargo weight (grams)
	var $grams = @getCargoWeight($cargoStr, $weights)
	var $kg = div($grams, 1000)

	$screen.write(30, $screen.char_h*6.1, white, text("Cargo Mass = {0.000}kg", $kg))

	; Display list of each block mass
	$screen.text_size(2)
	$screen.write(30, $screen.char_h*10.1, Yellow, "Block Mass")
	$screen.write(30, $screen.char_h*11.2, white, "Composite = 0.2kg")
	$screen.write(30, $screen.char_h*12.3, white, "Lead = 150kg")
	$screen.write(30, $screen.char_h*13.4, white, "Glass = 1kg")
	$screen.write(30, $screen.char_h*14.5, white, "Aluminium = 0.5kg")
	$screen.write(30, $screen.char_h*15.6, white, "Steel = 1kg")
	$screen.write(30, $screen.char_h*16.7, white, "Concrete = 10kg")

;-- Debug prints
	;print("$cargoStr = ", $cargoStr)
	;print("weights = ", $weights)