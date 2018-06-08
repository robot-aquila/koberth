package ru.prolib.kobert.lib;

import static org.junit.Assert.*;
import static org.easymock.EasyMock.*;
import static ru.prolib.kobert.lib.KOBVec3D.*;

import org.easymock.IMocksControl;
import org.junit.Before;
import org.junit.Test;

public class KOBNodeImplTest {
	private static final double epsilon = 1E-12;
	private IMocksControl control;
	private KOBMath mathMock;
	private KOBVessel vessel;
	private KOBNodeImpl service;

	@Before
	public void setUp() throws Exception {
		control = createStrictControl();
		mathMock = control.createMock(KOBMath.class);
		vessel = new KOBVesselImpl(345, 6E+4, 1641, 1641);
		service = new KOBNodeImpl(vessel, vec(30, 50, 0), 5d, mathMock); // 58.309518948453004 dV
	}
	
	@Test
	public void testCtor4() {
		assertSame(vessel, service.getVessel());
		assertEquals( 50, service.getPrograde(), epsilon);
		assertEquals(-30, service.getRadial(), epsilon);
		assertEquals(  0, service.getNormal(), epsilon);
		assertEquals(5d, service.getUT(), epsilon);
	}
	
	@Test
	public void testCtor3() {
		service = new KOBNodeImpl(vessel, vec(-40, 0, 15), 25d);
		assertSame(vessel, service.getVessel());
		assertEquals( 0, service.getPrograde(), epsilon);
		assertEquals(40, service.getRadial(), epsilon);
		assertEquals(15, service.getNormal(), epsilon);
		assertEquals(25d, service.getUT(), epsilon);
	}
	
	@Test
	public void testCtor2() {
		service = new KOBNodeImpl(vessel, vec(-40, 0, 15));
		assertSame(vessel, service.getVessel());
		assertEquals( 0, service.getPrograde(), epsilon);
		assertEquals(40, service.getRadial(), epsilon);
		assertEquals(15, service.getNormal(), epsilon);
		assertEquals(0d, service.getUT(), epsilon);
	}
	
	@Test
	public void testCtor5() {
		service = new KOBNodeImpl(vessel, 0, 40, 15, 45d);
		assertSame(vessel, service.getVessel());
		assertEquals( 0, service.getPrograde(), epsilon);
		assertEquals(40, service.getRadial(), epsilon);
		assertEquals(15, service.getNormal(), epsilon);
		assertEquals(45d, service.getUT(), epsilon);
	}

	@Test
	public void testGetBurnDuration() {
		expect(mathMock.getBurnDuration(vessel, 58.309518948453004)).andReturn(567d);
		control.replay();
		
		assertEquals(567d, service.getBurnDuration(), epsilon);

		control.verify();
	}
	
	@Test
	public void testToString() {
		String expected = "KOBNodeImpl[prograde=50.0,normal=0.0,radial=-30.0,deltaV=58.309518948453004,ut=5.0]";
		
		assertEquals(expected, service.toString());
	}

}
