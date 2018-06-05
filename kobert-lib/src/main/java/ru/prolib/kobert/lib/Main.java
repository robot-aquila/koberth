package ru.prolib.kobert.lib;

import krpc.client.Connection;
import krpc.client.services.KRPC;
import krpc.client.services.SpaceCenter;
import krpc.client.services.SpaceCenter.Part;
import krpc.client.services.SpaceCenter.Parts;
import krpc.client.services.SpaceCenter.Vessel;
import ru.prolib.kobert.lib.krpc.KRPCVesselStage;
import ru.prolib.kobert.lib.krpc.KRPCVesselStageBuilder;

public class Main {

	public static void main(String[] args) throws Exception {
		Connection connection = Connection.newInstance();
		KRPC krpc = KRPC.newInstance(connection);
		SpaceCenter ksc = SpaceCenter.newInstance(connection);
		System.out.println("Connected to kRPC version " + krpc.getStatus().getVersion());
		Vessel vessel = ksc.getActiveVessel();
		System.out.println("Name: " + vessel.getName());
		
		//for ( Part part : vessel.getParts().getAll() ) {
		//	System.out.println("Part: " + part.getName() + " tag=" + part.getTag());
		//}
		KRPCVesselStageBuilder builder = new KRPCVesselStageBuilder(vessel);
		KRPCVesselStage stage0 = builder.buildUsingStdTagScheme(0);
		KRPCVesselStage stage1 = builder.buildUsingStdTagScheme(1);
		KRPCVesselStage stage2 = builder.buildUsingStdTagScheme(2);
		KRPCVesselStage stage3 = builder.buildUsingStdTagScheme(3);
		KRPCVesselStage stage4 = builder.buildUsingStdTagSchemeBoosters(4);
		
		System.out.println("stage4 mass=" + stage4.getMass());
		System.out.println("stage4 dry mass=" + stage4.getDryMass());
		for ( Part part : stage4.getEngines() ) {
			System.out.println("stage4 engine: " + part.getName() + " tag=" + part.getTag());
		}
		for ( Part part : stage4.getFuelTanks() ) {
			System.out.println("stage4 fuel tank: " + part.getName() + " tag=" + part.getTag());
		}

		connection.close();
	}

}
