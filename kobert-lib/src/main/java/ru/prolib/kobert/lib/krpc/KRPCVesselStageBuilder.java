package ru.prolib.kobert.lib.krpc;

import krpc.client.services.SpaceCenter.Vessel;

/**
 * Utility class to help build vessel stages.
 */
public class KRPCVesselStageBuilder {
	private final Vessel vessel;
	
	public KRPCVesselStageBuilder(Vessel vessel) {
		this.vessel = vessel;
	}
	
	public KRPCVesselStage buildUsingTagPatterns(String significantPartTagPattern,
			String enginePartTagPattern,
			String fuelTankTagPattern,
			String stageLoadTagPattern)
	{
		return new KRPCVesselStage(vessel,
				new KRPCPartSelectorByTagPattern(significantPartTagPattern),
				new KRPCPartSelectorByTagPattern(enginePartTagPattern),
				new KRPCPartSelectorByTagPattern(fuelTankTagPattern),
				new KRPCPartSelectorByTagPattern(stageLoadTagPattern));
	}
	
	public KRPCVesselStage buildUsingStdTagScheme(int stage, String engineSubpattern, String fuelTankSubpattern) {
		if ( stage == 0 ) {
			return buildUsingTagPatterns(
					"^stage0.*",
					"^stage0\\." + engineSubpattern,
					"^stage0\\." + fuelTankSubpattern,
					"^$"
				);
		} else {
			return buildUsingTagPatterns(
					"^stage[0-" + stage + "].*",
					"^stage" + stage + "\\." + engineSubpattern,
					"^stage" + stage + "\\." + fuelTankSubpattern,
					stage == 1 ? "^stage0.*" : "^stage[0-" + (stage - 1) + "].*"
				);
		}
	}
	
	public KRPCVesselStage buildUsingStdTagScheme(int stage) {
		return buildUsingStdTagScheme(stage, "engine.*", "fueltank.*");
	}
	
	public KRPCVesselStage buildUsingStdTagSchemeBoosters(int stage) {
		return buildUsingStdTagScheme(stage, "booster.*", "booster.*");
	}

}
