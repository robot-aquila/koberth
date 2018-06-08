package ru.prolib.kobert.lib;

import static ru.prolib.kobert.lib.KOBVec3D.*;

import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;

public class KOBNodeImpl implements KOBNode {
	private final KOBVessel vessel;
	private final double ut;
	private final KOBVec3D vector;
	private final KOBMath math;
	
	/**
	 * Constructor.
	 * <p>
	 * @param vessel - a space vessel to execute node
	 * @param vector - node vector: X - anti-radial, Y - prograde, Z - normal
	 * @param ut - universal time seconds
	 * @param math - math utility 
	 */
	public KOBNodeImpl(KOBVessel vessel, KOBVec3D vector, double ut, KOBMath math) {
		this.vessel = vessel;
		this.vector = vector;
		this.ut = ut;
		this.math = math;
	}
	
	/**
	 * Constructor.
	 * <p>
	 * @param vessel - a space vessel to execute node
	 * @param vector - node vector: X - anti-radial, Y - prograde, Z - normal
	 * @param ut - universal time seconds
	 */
	public KOBNodeImpl(KOBVessel vessel, KOBVec3D vector, double ut) {
		this(vessel, vector, ut, KOBMathImpl.getInstance());
	}
	
	public KOBNodeImpl(KOBVessel vessel, KOBVec3D vector) {
		this(vessel, vector, 0);
	}
	
	public KOBNodeImpl(KOBVessel vessel, double prograde, double radial, double normal, double ut) {
		this(vessel, vec(-radial, prograde, normal), ut);
	}

	@Override
	public KOBVessel getVessel() {
		return vessel;
	}

	@Override
	public double getDeltaV() {
		return vector.length();
	}

	@Override
	public double getPrograde() {
		return vector.getY();
	}

	@Override
	public double getNormal() {
		return vector.getZ();
	}

	@Override
	public double getRadial() {
		return -vector.getX();
	}
	
	@Override
	public double getUT() {
		return ut;
	}

	@Override
	public double getBurnDuration() {
		return math.getBurnDuration(vessel, getDeltaV());
	}
	
	@Override
	public String toString() {
		return new ToStringBuilder(this, ToStringStyle.SHORT_PREFIX_STYLE)
			.append("prograde", getPrograde())
			.append("normal", getNormal())
			.append("radial", getRadial())
			.append("deltaV", getDeltaV())
			.append("ut", getUT())
			.build();
	}

}
