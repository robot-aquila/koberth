package ru.prolib.kobert.lib;

import org.apache.commons.lang3.builder.EqualsBuilder;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import org.javatuples.Triplet;

public class KOBVec3D {
	private final double x, y, z;
	
	public static KOBVec3D vec(Triplet<Double, Double, Double> triplet) {
		return new KOBVec3D(triplet.getValue0(), triplet.getValue1(), triplet.getValue2());
	}
	
	public static KOBVec3D vec(double x, double y, double z) {
		return new KOBVec3D(x, y, z);
	}
	
	public static Triplet<Double, Double, Double> triplet(KOBVec3D vector) {
		return new Triplet<>(vector.getX(), vector.getY(), vector.getZ());
	}
	
	public static Triplet<Double, Double, Double> triplet(double x, double y, double z) {
		return new Triplet<>(x, y, z);
	}
	
	public KOBVec3D(double x, double y, double z) {
		this.x = x;
		this.y = y;
		this.z = z;
	}
	
	public KOBVec3D(KOBVec3D u) {
		this(u.getX(), u.getY(), u.getZ());
	}
	
	public double getX() {
		return x;
	}
	
	public double getY() {
		return y;
	}
	
	public double getZ() {
		return z;
	}
	
	public KOBVec3D mult(double scalar) {
		return new KOBVec3D(x * scalar, y * scalar, z * scalar);
	}
	
	public double length() {
		return Math.sqrt(x * x + y * y + z * z);
	}
	
	public KOBVec3D norm() {
		return mult(1 / length());
	}
	
	public KOBVec3D add(KOBVec3D other) {
		return new KOBVec3D(x + other.x, y + other.y, z + other.z);
	}
	
	public KOBVec3D sub(KOBVec3D other) {
		return new KOBVec3D(x - other.x, y - other.y, z - other.z);
	}
	
	public double dot(KOBVec3D other) {
		return x * other.x + y * other.y + z * other.z;
	}
	
	public KOBVec3D rcross(KOBVec3D other) {
		return new KOBVec3D(y * other.z - z * other.y,
							z * other.x - x * other.z,
							x * other.y - y * other.x);
	}
	
	public KOBVec3D lcross(KOBVec3D other) {
		return new KOBVec3D(z * other.y - y * other.z,
							x * other.z - z * other.x,
							y * other.x - x * other.y);
	}
	
	public KOBVec3D neg() {
		return new KOBVec3D(x * -1, y * -1, z * -1);
	}
	
	public double rangle(KOBVec3D other) {
		return Math.acos(dot(other) / (length() * other.length()));
	}
	
	public double angle(KOBVec3D other) {
		return Math.toDegrees(rangle(other));
	}
	
	@Override
	public String toString() {
		return new ToStringBuilder(this, ToStringStyle.SHORT_PREFIX_STYLE)
				.append("x", x)
				.append("y", y)
				.append("z", z)
				.build();
	}
	
	@Override
	public boolean equals(Object other) {
		if ( other == this ) {
			return true;
		}
		if ( other == null || other.getClass() != KOBVec3D.class ) {
			return false;
		}
		KOBVec3D o = (KOBVec3D) other;
		return new EqualsBuilder()
			.append(o.x, x)
			.append(o.y, y)
			.append(o.z, z)
			.isEquals();
	}

}
