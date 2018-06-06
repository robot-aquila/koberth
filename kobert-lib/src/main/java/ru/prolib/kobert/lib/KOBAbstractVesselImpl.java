package ru.prolib.kobert.lib;

public abstract class KOBAbstractVesselImpl implements KOBVessel {

	@Override
	public double getVacuumDeltaV() {
		double dryMass = getDryMass();
		if ( dryMass <= 0 ) {
			return 0;
		}
		return Math.log(getMass() / dryMass) * getVacuumISP() * KOBConst.KERBIN_G;
	}

}
