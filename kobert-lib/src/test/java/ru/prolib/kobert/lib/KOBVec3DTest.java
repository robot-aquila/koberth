package ru.prolib.kobert.lib;

import static org.junit.Assert.*;

import org.javatuples.Triplet;
import org.junit.Before;
import org.junit.Test;

public class KOBVec3DTest {

	@Before
	public void setUp() throws Exception {
		
	}
	
	public static void assertVectorEquals(String msg, KOBVec3D expected, KOBVec3D actual, double epsilon) {
		assertEquals(msg, expected.getX(), actual.getX(), epsilon);
		assertEquals(msg, expected.getY(), actual.getY(), epsilon);
		assertEquals(msg, expected.getZ(), actual.getZ(), epsilon);
	}
	
	public static void assertVectorEquals(KOBVec3D expected, KOBVec3D actual, double epsilon) {
		assertEquals(expected.getX(), actual.getX(), epsilon);
		assertEquals(expected.getY(), actual.getY(), epsilon);
		assertEquals(expected.getZ(), actual.getZ(), epsilon);
	}
	
	@Test
	public void testVec_1Triplet() {
		KOBVec3D actual = KOBVec3D.vec(new Triplet<>(5d, -10d, 96d));
		
		KOBVec3D expected = new KOBVec3D(5, -10, 96);
		assertVectorEquals(expected, actual, 1E-10);
	}
	
	@Test
	public void testVec_3D() {
		KOBVec3D actual = KOBVec3D.vec(-17.5, 24.1, -85.9);
		
		KOBVec3D expected = new KOBVec3D(-17.5, 24.1, -85.9);
		assertVectorEquals(expected, actual, 1E-10);
	}
	
	@Test
	public void testTriplet_1Vec() {
		double epsilon = 1E-10;
		Triplet<Double, Double, Double> actual = KOBVec3D.triplet(new KOBVec3D(12, 24, 36));
		
		assertEquals(12, actual.getValue0(), epsilon);
		assertEquals(24, actual.getValue1(), epsilon);
		assertEquals(36, actual.getValue2(), epsilon);
	}
	
	@Test
	public void testTriplet_3D() {
		double epsilon = 1E-10;
		Triplet<Double, Double, Double> actual = KOBVec3D.triplet(12, 24, 36);

		assertEquals(12, actual.getValue0(), epsilon);
		assertEquals(24, actual.getValue1(), epsilon);
		assertEquals(36, actual.getValue2(), epsilon);
	}
	
	@Test
	public void testCtor3() {
		KOBVec3D v = new KOBVec3D(100, -15, 3.4);
		assertEquals(100d, v.getX(), 0.001d);
		assertEquals(-15d, v.getY(), 0.001d);
		assertEquals(3.4d, v.getZ(), 0.001d);
	}
	
	@Test
	public void testCtor1() {
		KOBVec3D u = new KOBVec3D(29.564, 98.1, -6.982);
		KOBVec3D v = new KOBVec3D(u);
		assertEquals(29.564d, v.getX(), 0.001d);
		assertEquals(98.1d,   v.getY(), 0.001d);
		assertEquals(-6.982d, v.getZ(), 0.001d);
	}
	
	@Test
	public void testMult() {
		KOBVec3D v = new KOBVec3D(28.14, -5d, -2.119d);
		KOBVec3D actual = v.mult(-3);
		KOBVec3D expected = new KOBVec3D(-84.42, 15d, 6.357d);
		assertVectorEquals(expected, actual, 0.001d);
	}
	
	@Test
	public void testLength() {
		assertEquals(1, new KOBVec3D(1, 0, 0).length(), 0.01d);
		assertEquals(1, new KOBVec3D(0, 1, 0).length(), 0.01d);
		assertEquals(1, new KOBVec3D(0, 0, 1).length(), 0.01d);
		assertEquals(30.083217, new KOBVec3D(15, -2, -26).length(), 0.000001d);
	}
	
	@Test
	public void testNorm() {
		assertVectorEquals(new KOBVec3D(1, 0, 0), new KOBVec3D(1, 0, 0).norm(), 0.01d);
		
		KOBVec3D v = new KOBVec3D(15, -2, -26);
		
		KOBVec3D actual = v.norm();
		
		KOBVec3D expected = new KOBVec3D(0.498616, -0.066482, -0.864269);
		assertVectorEquals(expected, actual, 0.000001);
	}
	
	@Test
	public void testAdd() {
		KOBVec3D u = new KOBVec3D(1, 2, 3);
		KOBVec3D v = new KOBVec3D(2, 3, 4);
		
		KOBVec3D actual = u.add(v);
		
		KOBVec3D expected = new KOBVec3D(3, 5, 7);
		assertVectorEquals(expected, actual, 0.01d);
	}
	
	@Test
	public void testSub() {
		KOBVec3D u = new KOBVec3D(1, 2, 3);
		KOBVec3D v = new KOBVec3D(5, 7, 9);
		
		KOBVec3D actual = u.sub(v);
		
		KOBVec3D expected = new KOBVec3D(-4, -5, -6);
		assertVectorEquals(expected, actual, 0.01d);
	}
	
	@Test
	public void testDot() {
		KOBVec3D u = new KOBVec3D(1, 2, 3);
		KOBVec3D v = new KOBVec3D(2, 3, 4);
		
		double actual = u.dot(v);
		
		double expected = 20;
		assertEquals(expected, actual, 0.01d);
		
		u = new KOBVec3D(1,  3, -5);
		v = new KOBVec3D(4, -2, -1);
		
		actual = u.dot(v);
		
		expected = 3;
		assertEquals(expected, actual, 0.01d);
	}
	
	@Test
	public void testRcross() {
		KOBVec3D u = new KOBVec3D(1, 2, 3);
		KOBVec3D v = new KOBVec3D(2, 3, 4);

		KOBVec3D actual = u.rcross(v);
		
		KOBVec3D expected = new KOBVec3D(-1, 2, -1);
		assertVectorEquals(expected, actual, 0.01d);
		
		u = new KOBVec3D(5, 7, 12);
		v = new KOBVec3D(14, 27, 96);
		
		actual = u.rcross(v);
		
		expected= new KOBVec3D(348, -312, 37);
		assertVectorEquals(expected, actual, 0.01d);
	}
	
	@Test
	public void testLcross() {
		KOBVec3D u = new KOBVec3D(5, 7, 12);
		KOBVec3D v = new KOBVec3D(14, 27, 96);
		
		KOBVec3D actual = u.lcross(v);
		
		KOBVec3D expected = new KOBVec3D(-348, 312, -37);
		assertVectorEquals(expected, actual, 0.01d);
		assertVectorEquals(u.rcross(v).mult(-1), actual, 0.01d);
	}
	
	@Test
	public void testNeg() {
		KOBVec3D u = new KOBVec3D(5, -7, 12);

		KOBVec3D actual = u.neg();
		
		KOBVec3D expected = new KOBVec3D(-5, 7, -12);
		assertVectorEquals(expected, actual, 0.01d);
	}
	
	@Test
	public void testRangle() {
		KOBVec3D u = new KOBVec3D(5, -7, 12);
		KOBVec3D v = new KOBVec3D(14, 27, 96);

		double actual = u.rangle(v);
		
		double expected = 0.80271711;
		assertEquals(expected, actual, 0.0000001);
	}
	
	@Test
	public void testAngle() {
		KOBVec3D u = new KOBVec3D(5, -7, 12);
		KOBVec3D v = new KOBVec3D(14, 27, 96);
		
		double actual = u.angle(v);
		
		double expected = 45.9923026;
		assertEquals(expected, actual, 0.0000001);
	}
	
	@Test
	public void testToString() {
		KOBVec3D u = new KOBVec3D(5, -7, 12);
		
		String expected = "KOBVec3D[x=5.0,y=-7.0,z=12.0]";
		
		assertEquals(expected, u.toString());
	}
	
	@Test
	public void testEquals() {
		KOBVec3D u = new KOBVec3D(5, -7, 12);
		
		assertTrue(u.equals(u));
		assertFalse(u.equals(null));
		assertFalse(u.equals(this));
		assertTrue(u.equals(new KOBVec3D(5, -7, 12)));
		assertFalse(u.equals(new KOBVec3D(8, -7, 12)));
		assertFalse(u.equals(new KOBVec3D(5,  8, 12)));
		assertFalse(u.equals(new KOBVec3D(5, -7, 8)));
	}

}
