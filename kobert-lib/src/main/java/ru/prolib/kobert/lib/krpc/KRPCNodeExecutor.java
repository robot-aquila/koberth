package ru.prolib.kobert.lib.krpc;

import static ru.prolib.kobert.lib.KOBVec3D.*;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import ru.prolib.kobert.lib.KOBMath;
import ru.prolib.kobert.lib.KOBMathImpl;
import krpc.client.RPCException;
import krpc.client.StreamException;
import krpc.client.services.SpaceCenter.AutoPilot;
import krpc.client.services.SpaceCenter.Control;
import krpc.client.services.SpaceCenter.Node;
import krpc.client.services.SpaceCenter.ReferenceFrame;
import krpc.client.services.SpaceCenter.SASMode;
import krpc.client.services.SpaceCenter.Vessel;

public class KRPCNodeExecutor {
	private static final Logger logger;
	
	static {
		logger = LoggerFactory.getLogger(KRPCNodeExecutor.class);
	}
	
	private final KRPCFacade krpcf;
	private final KOBMath math;

	public KRPCNodeExecutor(KRPCFacade krpcf, KOBMath math) {
		this.krpcf = krpcf;
		this.math = math;
	}
	
	public KRPCNodeExecutor(KRPCFacade krpcf) {
		this(krpcf, KOBMathImpl.getInstance());
	}
	
	public void executeNode() throws InterruptedException {
		try {
			_executeNode();
		} catch ( RPCException|StreamException e ) {
			throw new IllegalStateException("Error executing node", e);
		}
	}
	
	private void _executeNode() throws RPCException, StreamException, InterruptedException {
		Node node = krpcf.getActiveVesselManeuverNode();
		Vessel vessel = krpcf.getActiveVessel();
		KRPCNodeExecutionContext context = new KRPCNodeExecutionContext(krpcf, vessel, node);
		
		Control control = vessel.getControl();
		AutoPilot ap = vessel.getAutoPilot();
		// TODO: check that burn is possible (fuel, thrust, etc)
		double bd = math.getBurnDuration(vessel.getSpecificImpulse(),
				vessel.getMass(),
				vessel.getAvailableThrust(),
				node.getDeltaV());
		float currentThrottle = 1.0f;
		double thrust = vessel.getAvailableThrust() / vessel.getMass();
		// Let's split the burn time on two phases:
		// 1) Active burn when we need to burn a big part of delta-V.
		// This phase starts the burn setting some initial throttle.
		// Prior to the last second of burn this phase finish.
		// 2) Finish the burn with enough precision.
		// This phase will sequentially reduce the throttle on half
		// while there is still remaining burn vector. When remaining
		// vector comes too small then the burn is finished.
		if ( bd < 2 ) {
			// Looks like we have too much thrust for this node.
			thrust = vessel.getAvailableThrust() / vessel.getMass();
			currentThrottle = (float)(node.getDeltaV() / 2 / thrust);
		}
		
		logger.debug("Burn duration: {}", bd);
		double burnStartAt = node.getUT() - bd / 2;
		logger.debug("Burn start at: {}", burnStartAt);
		// TODO: calculate max time to rotate to node direction
		double rd = 60; // simplified for 60 seconds to rotate
		double startAt = burnStartAt - rd;
		logger.debug("Maneuver start at: {}", startAt);
		if ( krpcf.getUT() > startAt ) {
			throw new IllegalStateException("Not enough time to execute the node");
		}
		
		krpcf.waitUntilUT(startAt);
		context.assertIsValid();
		ap.engage();
		ReferenceFrame rf = node.getReferenceFrame();
		try {
			ap.setReferenceFrame(rf);
			ap.setTargetDirection(triplet(0, 1, 0));
			ap.wait_();
			context.assertIsValid();
			ap.setSASMode(SASMode.STABILITY_ASSIST);
			
			krpcf.waitUntilUT(burnStartAt);
			context.assertIsValid();
			
			// Phase 1: Start the burn.
			control.setThrottle(currentThrottle);
			krpcf.waitUntilUT(burnStartAt + bd - 1);
			context.assertIsValid();
			
			// Phase 2: Finish the burn.
			double lastDeltaV, remDeltaV, threshold = 0.01d;
			lastDeltaV = remDeltaV = node.getRemainingDeltaV();
			for ( ;; ) {
				context.assertIsValid();
				remDeltaV = node.getRemainingDeltaV();
				if ( remDeltaV < threshold		// that's enough precision
				  || remDeltaV > lastDeltaV )	// something goes wrong
				{
					break;
				}
				lastDeltaV = remDeltaV;
				
				// Fine tune the throttle.
				// We want to burn half of remaining delta-V next second.
				thrust = vessel.getAvailableThrust() / vessel.getMass();
				currentThrottle = (float)(remDeltaV / 2 / thrust);
				logger.debug("Fine tune throttle for: deltaV={} thrust/kg={}", remDeltaV, thrust);
				logger.debug("Throttle to: {}", currentThrottle);
				control.setThrottle(currentThrottle);
			} 
			
			control.setThrottle(0.0f);
			node.remove();
			logger.debug("Burn done");
			
		} finally {
			ap.disengage();
		}
		logger.debug("AP disengaged");
		
		//ksc.getUT()
	}

}
