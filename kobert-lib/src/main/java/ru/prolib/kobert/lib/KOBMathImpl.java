package ru.prolib.kobert.lib;

public class KOBMathImpl implements KOBMath {
	private static final KOBMathImpl instance = new KOBMathImpl();
	
	public static KOBMath getInstance() {
		return instance;
	}

	@Override
	public double getBurnDuration(double isp, double mass, double thrust, double deltaV) {
		double ve = isp * KOBConst.KERBIN_G;
		return (mass * ve / thrust) * (1 - Math.pow(KOBConst.E,  -deltaV / ve));
	}

	@Override
	public double getBurnDuration(KOBVessel vessel, double deltaV) {
		return getBurnDuration(vessel.getVacuumISP(), vessel.getMass(), vessel.getVacuumMaxThrust(), deltaV);
	}

}
