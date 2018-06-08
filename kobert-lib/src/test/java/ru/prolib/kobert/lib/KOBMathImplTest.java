package ru.prolib.kobert.lib;

import static org.junit.Assert.*;

import org.junit.Before;
import org.junit.Test;

public class KOBMathImplTest {
	private KOBMath service;

	@Before
	public void setUp() throws Exception {
		service = KOBMathImpl.getInstance();
	}
	
	@Test
	public void testGetBurnDuration4() {
		double epsilon = 1E-5, isp = 345, mass = 1641, thrust = 6E+4;
		
		assertEquals(2.4477, service.getBurnDuration(isp, mass, thrust, 90.7), epsilon); // AP 80km -> 200km
		assertEquals(14.8197645, service.getBurnDuration(isp, mass, thrust, 590.5), epsilon); // AP 80km -> 2000km
		assertEquals(22.2774908, service.getBurnDuration(isp, mass, thrust, 931.8), epsilon); // AP 80km -> eject Kerbin SOI
	}
	
	@Test
	public void testGetBurnDuration2() {
		double epsilon = 1E-5;
		KOBVessel vessel = new KOBVesselImpl(345, 6E+4, 1641, 1641);
		
		// Brahe-1 KLEO 80km
		assertEquals(2.4477, service.getBurnDuration(vessel, 90.7), epsilon); // AP 80km -> 200km
		assertEquals(14.8197645, service.getBurnDuration(vessel, 590.5), epsilon); // AP 80km -> 2000km
		assertEquals(22.2774908, service.getBurnDuration(vessel, 931.8), epsilon); // AP 80km -> eject Kerbin SOI
	}

	@Test
	public void test() {
		fail("Not yet implemented");
	}

}
