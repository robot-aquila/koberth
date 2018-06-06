package ru.prolib.kobert.lib;

import org.apache.commons.lang3.builder.EqualsBuilder;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;

/**
 * Simplified representation of a space vessel.
 */
public class KOBVesselImpl extends KOBAbstractVesselImpl {
	private final double isp, thrust, mass, dryMass;
	
	public KOBVesselImpl(double isp, double thrust, double mass, double dryMass) {
		this.isp = isp;
		this.thrust = thrust;
		this.mass = mass;
		this.dryMass = dryMass;
	}

	@Override
	public double getVacuumISP() {
		return isp;
	}

	@Override
	public double getVacuumMaxThrust() {
		return thrust;
	}

	@Override
	public double getMass() {
		return mass;
	}

	@Override
	public double getDryMass() {
		return dryMass;
	}
	
	@Override
	public boolean equals(Object other) {
		if ( other == this ) {
			return true;
		}
		if ( other == null || other.getClass() != KOBVesselImpl.class ) {
			return false;
		}
		KOBVesselImpl o = (KOBVesselImpl) other;
		return new EqualsBuilder()
				.append(isp, o.isp)
				.append(thrust, o.thrust)
				.append(mass, o.mass)
				.append(dryMass, o.dryMass)
				.isEquals();
	}
	
	@Override
	public String toString() {
		return new ToStringBuilder(this, ToStringStyle.SHORT_PREFIX_STYLE)
				.append("isp", isp)
				.append("thrust", thrust)
				.append("mass", mass)
				.append("dryMass", dryMass)
				.build();
	}

}
