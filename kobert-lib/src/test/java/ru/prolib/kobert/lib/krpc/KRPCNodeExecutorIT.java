package ru.prolib.kobert.lib.krpc;

import static org.junit.Assert.*;

import krpc.client.services.SpaceCenter.Orbit;
import krpc.client.services.SpaceCenter.Vessel;

import org.apache.log4j.BasicConfigurator;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

public class KRPCNodeExecutorIT {
	private static KRPCFacade krpcf;
	private static Vessel vessel;

	@BeforeClass
	public static void setUpBeforeClass() throws Exception {
		BasicConfigurator.resetConfiguration();
		BasicConfigurator.configure();
		krpcf = new KRPCFacadeImpl();
		krpcf.assertCurrentGameSceneIsFlight();
		vessel = krpcf.getActiveVessel();
	}
	
	@AfterClass
	public static void tearDownAfterClass() throws Exception {
		if ( krpcf != null ) {
			krpcf.close();
		}
	}
	
	
	private void assertInitialState() throws Exception {
		krpcf.assertActiveVesselNamePattern("Brahe-1MJ");
		Orbit obt = vessel.getOrbit();
		assertTrue("Unexpected eccentricity", obt.getEccentricity() <= 0.001);
		assertTrue("Expected altitude is 70-90km", Math.abs(80000 - obt.getApoapsisAltitude()) <= 10000);
	}


	@Before
	public void setUp() throws Exception {
		krpcf.getKSC().load("Brahe-1MJ LKO");
		assertInitialState();
	}
	
	@Test
	public void testExecuteNode_UpAP() throws Exception {
		Orbit obt = vessel.getOrbit();
		double mu = obt.getBody().getGravitationalParameter();
		double r1 = obt.getApoapsis(), r2 = obt.getApoapsis() + obt.getApoapsisAltitude();
		double deltaV = Math.sqrt(mu / r1) * (Math.sqrt(2 * r2 / (r1 + r2)) - 1);
		double expectedIncl = obt.getInclination();
		
		vessel.getControl().addNode(krpcf.getUT() + 75, (float)deltaV, 0, 0);
		
		KRPCNodeExecutor executor = new KRPCNodeExecutor(krpcf);
		executor.executeNode();
		
		obt = vessel.getOrbit();
		assertEquals(r2, obt.getApoapsis(), 100.0d); // max 100m error
		assertEquals(0.056, obt.getEccentricity(), 0.001d);
		assertEquals(expectedIncl, obt.getInclination(), 0.001d);
	}

}
