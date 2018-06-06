package ru.prolib.kobert.lib;

import static org.junit.Assert.*;

import org.junit.Before;
import org.junit.Test;

public class KOBMathTest {
	private KOBMath service;

	@Before
	public void setUp() throws Exception {
		service = new KOBMath();
	}

	@Test
	public void testGetBurnDuration() {
		double epsilon = 1E-5;
		KOBVesselImpl vessel = new KOBVesselImpl(345, 60000, 1641, 1641);
		
		double actual = service.getBurnDuration(vessel, 90.7); // Brahe-1 KLEO 80km -> 200
		
		double expected = 2.4477; // seconds to burn
		assertEquals(expected, actual, epsilon);
		
		actual = service.getBurnDuration(vessel, 590.5); // Brahe-1 KLEO 80km -> 2000km
		
		expected = 14.8197645;
		assertEquals(expected, actual, epsilon);
		
		actual = service.getBurnDuration(vessel, 931.8); // Brahe-1 KLEO 80 -> eject Kerbin SOI
		
		expected = 22.2774908;
		assertEquals(expected, actual, epsilon);
	}

}
