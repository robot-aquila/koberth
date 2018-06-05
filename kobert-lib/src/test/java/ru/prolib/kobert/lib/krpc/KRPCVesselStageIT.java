package ru.prolib.kobert.lib.krpc;

import static org.junit.Assert.*;

import java.util.ArrayList;
import java.util.List;

import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

import krpc.client.Connection;
import krpc.client.services.KRPC;
import krpc.client.services.KRPC.GameScene;
import krpc.client.services.SpaceCenter;
import krpc.client.services.SpaceCenter.Part;
import krpc.client.services.SpaceCenter.Vessel;
import krpc.client.services.SpaceCenter.VesselSituation;

public class KRPCVesselStageIT {
	private static Connection krpcConnection;
	private static KRPC krpc;
	private static SpaceCenter ksc;
	private static Vessel vessel;
	
	@BeforeClass
	public static void setUpBeforeClass() throws Exception {
		krpcConnection = Connection.newInstance();
		krpc = KRPC.newInstance(krpcConnection);
		if ( krpc.getCurrentGameScene() != GameScene.FLIGHT ) {
			throw new IllegalStateException("Should be in flight but: " + krpc.getCurrentGameScene());
		}
		ksc = SpaceCenter.newInstance(krpcConnection);
		vessel = ksc.getActiveVessel();
		if ( ! vessel.getName().equals("Brahe-1") ) {
			throw new IllegalStateException("Invalid vessel is currently loaded: " + vessel.getName());
		}
		if ( vessel.getSituation() != VesselSituation.PRE_LAUNCH ) {
			throw new IllegalStateException("Invalid current situation: " + vessel.getSituation());
		}
	}
	
	@AfterClass
	public static void tearDownAfterClass() throws Exception {
		if ( krpcConnection != null ) {
			krpcConnection.close();
		}
	}
	
	private KRPCVesselStageBuilder builder;

	@Before
	public void setUp() throws Exception {
		builder = new KRPCVesselStageBuilder(vessel);
	}
	
	private void assertHasPartByTag(List<Part> parts, String tagName) throws Exception {
		for ( Part part : parts ) {
			if ( part.getTag().equals(tagName) ) {
				return;
			}
		}
		fail("Part not exists: tagName=" + tagName);
	}
	
	private void assertPartsByTag(List<Part> parts, List<String> expectedTags) throws Exception {
		assertEquals(expectedTags.size(), parts.size());
		for ( String tagName : expectedTags ) {
			assertHasPartByTag(parts, tagName);
		}
	}
	
	private void assertPartsByTag(List<Part> parts, String tagPrefix, List<String> expectedTags)
		throws Exception
	{
		List<String> tags = new ArrayList<>();
		for ( String chunk : expectedTags ) {
			tags.add(tagPrefix + chunk);
		}
		assertPartsByTag(parts, tags);
	}

	@Test
	public void testStage0Consistency() throws Exception {
		KRPCVesselStage stage = builder.buildUsingStdTagScheme(0);
		
		List<String> expected = new ArrayList<>();
		expected.add("chute");
		expected.add("core");
		expected.add("strut");
		expected.add("rw");
		expected.add("batt");
		expected.add("hs");
		assertPartsByTag(stage.getAllParts(), "stage0.", expected);
		
		expected.clear();
		assertPartsByTag(stage.getEngines(), expected);
		assertPartsByTag(stage.getFuelTanks(), expected);
		assertPartsByTag(stage.getStageLoad(), expected);
		
		assertEquals(276d, stage.getMass(), 0.1d);
		assertEquals(276d, stage.getDryMass(), 0.1d);
		assertEquals(0.0d, stage.getVacuumISP(), 0.1d);
		assertEquals(0.0d, stage.getVacuumMaxThrust(), 0.1d);
		assertEquals(0.0d, stage.getVacuumDeltaV(), 0.1d);
	}
	
	@Test
	public void testStage1Consistency() throws Exception {
		KRPCVesselStage stage0 = builder.buildUsingStdTagScheme(0);
		KRPCVesselStage stage1 = builder.buildUsingStdTagScheme(1);
		
		List<String> expected = new ArrayList<>();
		expected.add("engine1");
		expected.add("engine2");
		assertPartsByTag(stage1.getEngines(), "stage1.", expected);
		
		expected.clear();
		expected.add("fueltank");
		assertPartsByTag(stage1.getFuelTanks(), "stage1.", expected);
		
		expected.clear();
		for ( Part part : stage0.getAllParts() ) {
			expected.add(part.getTag());
		}
		assertPartsByTag(stage1.getStageLoad(), expected);
		
		expected.clear();
		expected.add("stage1.decoupler");
		expected.add("stage1.engine1");
		expected.add("stage1.engine2");
		expected.add("stage1.sp1");
		expected.add("stage1.sp2");
		expected.add("stage1.fueltank");
		for ( Part part : stage0.getAllParts() ) {
			expected.add(part.getTag());
		}
		assertPartsByTag(stage1.getAllParts(), expected);
		
		assertEquals(561d, stage1.getMass(), 0.1d);
		assertEquals(361d, stage1.getDryMass(), 0.1d);
		assertEquals(290d, stage1.getVacuumISP(), 0.1d);
		assertEquals(4000d, stage1.getVacuumMaxThrust(), 0.1d);
		assertEquals(1254.2d, stage1.getVacuumDeltaV(), 0.1d);
	}
	
	@Test
	public void testStage2Consistency() throws Exception {
		KRPCVesselStage stage_prev = builder.buildUsingStdTagScheme(1);
		KRPCVesselStage stage = builder.buildUsingStdTagScheme(2);

		List<String> expected = new ArrayList<>();
		expected.add("engine");
		assertPartsByTag(stage.getEngines(), "stage2.", expected);

		expected.clear();
		expected.add("fueltank");
		assertPartsByTag(stage.getFuelTanks(), "stage2.", expected);

		expected.clear();
		for ( Part part : stage_prev.getAllParts() ) {
			expected.add(part.getTag());
		}
		assertPartsByTag(stage.getStageLoad(), expected);

		expected.clear();
		expected.add("stage2.decoupler");
		expected.add("stage2.adapt");
		expected.add("stage2.rw");
		expected.add("stage2.sp1");
		expected.add("stage2.sp2");
		expected.add("stage2.sp3");
		expected.add("stage2.sp4");
		expected.add("stage2.fueltank");
		expected.add("stage2.engine");
		for ( Part part : stage_prev.getAllParts() ) {
			expected.add(part.getTag());
		}
		assertPartsByTag(stage.getAllParts(), expected);

		assertEquals(2406d, stage.getMass(), 0.1d);
		assertEquals(1406d, stage.getDryMass(), 0.1d);
		assertEquals(345d, stage.getVacuumISP(), 0.1d);
		assertEquals(60000d, stage.getVacuumMaxThrust(), 0.1d);
		assertEquals(1818.1d, stage.getVacuumDeltaV(), 0.1d);
	}
	
	@Test
	public void testStage3Consistency() throws Exception {
		KRPCVesselStage stage_prev = builder.buildUsingStdTagScheme(2);
		KRPCVesselStage stage = builder.buildUsingStdTagScheme(3);

		List<String> expected = new ArrayList<>();
		expected.add("engine");
		assertPartsByTag(stage.getEngines(), "stage3.", expected);

		expected.clear();
		expected.add("fueltank");
		assertPartsByTag(stage.getFuelTanks(), "stage3.", expected);

		expected.clear();
		for ( Part part : stage_prev.getAllParts() ) {
			expected.add(part.getTag());
		}
		assertPartsByTag(stage.getStageLoad(), expected);

		expected.clear();
		expected.add("stage3.decoupler");
		expected.add("stage3.fueltank");
		expected.add("stage3.engine");
		for ( Part part : stage_prev.getAllParts() ) {
			expected.add(part.getTag());
		}
		assertPartsByTag(stage.getAllParts(), expected);

		assertEquals(8446d, stage.getMass(), 0.1d);
		assertEquals(4446d, stage.getDryMass(), 0.1d);
		assertEquals(320d, stage.getVacuumISP(), 0.1d);
		assertEquals(215000d, stage.getVacuumMaxThrust(), 0.1d);
		assertEquals(2014.3d, stage.getVacuumDeltaV(), 0.1d);
	}
	
	@Test
	public void testStage4Consistency() throws Exception {
		KRPCVesselStage stage_prev = builder.buildUsingStdTagScheme(3);
		KRPCVesselStage stage = builder.buildUsingStdTagSchemeBoosters(4);
		
		List<String> expected = new ArrayList<>();
		expected.add("stage4.booster");
		assertPartsByTag(stage.getEngines(), expected);
		assertPartsByTag(stage.getFuelTanks(), expected);
		
		expected.clear();
		for ( Part part : stage_prev.getAllParts() ) {
			expected.add(part.getTag());
		}
		assertPartsByTag(stage.getStageLoad(), expected);

		expected.clear();
		expected.add("stage4.decoupler");
		expected.add("stage4.booster");
		for ( Part part : stage_prev.getAllParts() ) {
			expected.add(part.getTag());
		}
		assertPartsByTag(stage.getAllParts(), expected);

		assertEquals(16136d, stage.getMass(), 0.1d);
		assertEquals(9986d, stage.getDryMass(), 0.1d);
		assertEquals(210d, stage.getVacuumISP(), 0.1d);
		assertEquals(300000, stage.getVacuumMaxThrust(), 0.1d);
		assertEquals(988.5d, stage.getVacuumDeltaV(), 0.1d);
	}

}
