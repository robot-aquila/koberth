package ru.prolib.kobert.lib.krpc;

import ru.prolib.kobert.lib.KOBMath;
import ru.prolib.kobert.lib.KOBMathImpl;
import krpc.client.services.SpaceCenter.Node;
import krpc.client.services.SpaceCenter.Vessel;

public class KRPCNodeExecutionContext {
	private final KRPCFacade krpcf;
	private final Vessel vessel;
	private final Node node;
	private final KOBMath math;
	private double lastUT;
	
	public KRPCNodeExecutionContext(KRPCFacade krpcf, Vessel vessel, Node node, KOBMath math) {
		this.krpcf = krpcf;
		this.vessel = vessel;
		this.node = node;
		this.math = math;
		this.lastUT = krpcf.getUT();
	}
	
	public KRPCNodeExecutionContext(KRPCFacade krpcf, Vessel vessel, Node node) {
		this(krpcf, vessel, node, KOBMathImpl.getInstance());
	}
	
	public void assertIsValid() {
		double ut = krpcf.getUT();
		if ( ut < lastUT ) {
			throw new IllegalStateException("Current time in the past (saved game was loaded?)");
		}
		lastUT = ut;
		krpcf.assertVesselInFlight(vessel);
		Node actual = krpcf.getActiveVesselManeuverNode();
		if ( ! actual.equals(node) ) {
			throw new IllegalStateException("Node changed");
		}
		
	}

}
