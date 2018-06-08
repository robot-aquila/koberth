package ru.prolib.kobert.lib;

public interface KOBMath {
	
	double getBurnDuration(double isp, double mass, double thrust, double deltaV);
	double getBurnDuration(KOBVessel vessel, double deltaV);

}
