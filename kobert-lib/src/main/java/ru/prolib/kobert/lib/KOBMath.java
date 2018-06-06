package ru.prolib.kobert.lib;

public class KOBMath {
	
	/**
	 * Get duration to burn specified delta-v.
	 * <p>
	 * http://forum.kerbalspaceprogram.com/threads/40053-Estimate-the-duration-of-a-burn (RIP)
	 * <p>
	 * @param vessel - a space vessel
	 * @param deltaV - deltaV to burn
	 * @return duration in seconds
	 */
	public double getBurnDuration(KOBVessel vessel, double deltaV) {
		double ve = vessel.getVacuumISP() * KOBConst.KERBIN_G;
		return (vessel.getMass() * ve / vessel.getVacuumMaxThrust()) * (1 - Math.pow(KOBConst.E, -deltaV / ve));
	}

}
