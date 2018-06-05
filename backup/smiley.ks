@ lazyglobal off.
run once kobertlib.
runoncepath("class/kobert/kob_atm_ascent").
runoncepath("class/kobert/kob_atm_ascent_table").

smiley_test().

function smiley_test {
	if not kob_test_all_parts_tagged("^stage(0|1|2)(\.(engine|fuel))?$") {
		return false.
	}
	print "Stage0 Delta-V: " + kob_stage_delta_v_vacuum("^stage0.*",       "^stage0\.engine$", "^stage0\.fuel").
	print "Stage1 Delta-V: " + kob_stage_delta_v_vacuum("^stage(0|1).*",   "^stage1\.engine$", "^stage1\.fuel").
	print "Stage2 Delta-V: " + kob_stage_delta_v_vacuum("^stage(0|1|2).*", "^stage2\.engine$", "^stage2\.fuel").


	// 1) Вертикальное восхождение
	// 2) Плавный выход на угол атаки 45 градусов
	// 3) Дожигаем ускорительную первую ступень с учетом Q
	// 4) Поднимаем АП до установленного
	// 5) Ожидаем границы атмосферы
	// 6) Создаем ноду циркуляризации
	// 7) Исполняем ноду цикруляризации


	local ascent is kob_atm_ascent(15).	
	local ascent_table1 is kob_atm_ascent_table(ascent, 0, 20).
	local ascent_table2 is kob_atm_ascent_table(ascent, 5, 0).
	until ship:altitude < 60 {
		ascent#update().
		ascent_table1#update().
		ascent_table2#update().

		wait 1.
	}
	wait until ship:altitude > 70000.

	return true.
}

// Calculate Delta-V for specified stage.
// Keep in mind that the stage is not equal to KSP stage.
// This "stage" is combination of tagged parts.
// Tag your ship properly!
// Param1: tag pattern of all parts belonging to the stage
// Param2: tag pattern of engines to move the stage parts
// Param3: tag pattern of fuel tanks which will be emptied during engine working
// Return: delta-V
function kob_stage_delta_v_vacuum {
	declare local parameter myStagePartPattern.
	declare local parameter myStageEnginePattern.
	declare local parameter myStageTankPattern.
	local myStagePartList is ship:partstaggedpattern(myStagePartPattern).
	local myStageEngineList is ship:partstaggedpattern(myStageEnginePattern).
	local myStageISP is kob_get_combined_visp(myStageEngineList).
	local myStageWetMass is kob_count_total_mass(myStagePartList, "").
	local myStageDryMass is kob_count_total_mass(myStagePartList, myStageTankPattern).
	return ln(myStageWetMass / myStageDryMass) * myStageISP * 9.81.
}

// Count total mass of specified parts.
// Param1: list of parts
// Param2: tag pattern of parts which should be counted with dry-mass (pass "" to disable)
// Return: mass
function kob_count_total_mass {
	declare local parameter myPartList.
	declare local parameter myDryMassTagPattern.
	local myPart is 0.
	local myTotalMass is 0.
	for myPart in myPartList {
		if myDryMassTagPattern and myPart:tag:matchespattern(myDryMassTagPattern) {
			set myTotalMass to myTotalMass + myPart:drymass.
		} else {
		    set myTotalMass to myTotalMass + myPart:mass.
		}
	}
	return myTotalMass.
}


// Get combined ISP (vacuum) for set of engines.
// Param1: list of engines
// Return: combined ISP (vacuum)
function kob_get_combined_visp {
	declare local parameter myEngineList.
	local myDivisible is 0.
	local myDivisor is 0.
	local myEngine is 0.
	local myEngineThrust is 0.
	local myEngineISP is 0.
	for myEngine in myEngineList {
		set myEngineThrust to kob_get_engine_max_thrust_vacuum(myEngine).
		set myEngineISP to myEngine:VISP.
		set myDivisible to myDivisible + myEngineThrust.
		if myEngineISP > 0 {
			set myDivisor to myDivisor + (myEngineThrust / myEngineISP).
		}
	}
	if myDivisor = 0 {
		//kob_error("Unable to determine combined ISP. All engines are broken?").
		return 0.
	}
	return myDivisible / myDivisor.
}

// Get max. thrust of the engine in vacuum.
// Why? Unfortunately KOS does not provide a max. thrust for inactive engines.
// And we cannot activate it temporarily because in case of solid fuel booster
// we can not shutdown it. And big bada boom will occur. 
// Param1: engine
// Return: max thrust for the engine
function kob_get_engine_max_thrust_vacuum {
	declare local parameter myEngine.
	local myDB is readjson("data/kobert/kob-engine-thrust-db.json").
	local myKey is 0.
	for myKey in myDB:keys {
		if myEngine:title:startswith(myKey) {
			return myDB[myKey].
		}
	}
	kob_error("Engine " + myEngine:title + "  is not listed in KOB database").
	return 0.	
}

// Test that this value in the list.
// Param1: value
// Param2: list
// Return: true/false
function kob_in_list {
	declare local parameter myVal.
	declare local parameter myList.
	local x is 0.
	for x in myList {
		if x = myVal {
			return true.
		}
	}
	return false.
}

// Test that all vessel parts are well tagged.
// Param1: pattern of all possible tags
// Return: true/false
function kob_test_all_parts_tagged {
	declare local parameter myTagPattern.
	local myPart is 0.
	local myParts is ship:parts.
	local myResult is true.
	for myPart in myParts {
		if not myPart:tag:matchespattern(myTagPattern) {
			kob_error("part " + myPart:name + " is not taggeg or has bad tag: " + myPart:tag).
			set myResult to false.
		}
	}
	if not myResult {
		kob_error("Allowed tag names: " + myTagPattern).
	}
	return myResult.
}

// Handle error message.
// Param1: message text
function kob_error {
	declare local parameter myMessage.
	print "KOB-ERR: " + myMessage.
}
