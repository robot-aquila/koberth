package ru.prolib.kobert.lib;

import static org.junit.Assert.*;

import org.junit.Before;
import org.junit.Test;

public class KOBVesselImplTest {
	private KOBVesselImpl service;

	@Before
	public void setUp() throws Exception {
		service = new KOBVesselImpl(345, 60000, 5000, 2500);
	}

	@Test
	public void testGetters() {
		double epsilon = 1E-10;
		assertEquals(345, service.getVacuumISP(), epsilon);
		assertEquals(60000, service.getVacuumMaxThrust(), epsilon);
		assertEquals(5000, service.getMass(), epsilon);
		assertEquals(2500, service.getDryMass(), epsilon);
	}
	
	@Test
	public void testGetVacuumDeltaV() {
		double actual = service.getVacuumDeltaV();
		
		double expected = 2345.921975d;
		assertEquals(expected, actual, 1E-6);
	}
	
	@Test
	public void testEquals() {
		assertTrue(service.equals(service));
		assertFalse(service.equals(null));
		assertFalse(service.equals(this));
		assertTrue(service.equals(new KOBVesselImpl(345, 60000, 5000, 2500)));
		assertFalse(service.equals(new KOBVesselImpl(120, 60000, 5000, 2500)));
		assertFalse(service.equals(new KOBVesselImpl(345, 90000, 5000, 2500)));
		assertFalse(service.equals(new KOBVesselImpl(345, 60000, 5001, 2500)));
		assertFalse(service.equals(new KOBVesselImpl(345, 60000, 5000, 2501)));
	}
	
	@Test
	public void testToString() {
		String actual = service.toString();
		
		String expected = "KOBVesselImpl[isp=345.0,thrust=60000.0,mass=5000.0,dryMass=2500.0]";
		assertEquals(expected, actual);
	}

}
