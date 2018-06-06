package ru.prolib.kobert.lib.krpc;

import java.util.ArrayList;
import java.util.List;

import krpc.client.RPCException;
import krpc.client.services.SpaceCenter.Engine;
import krpc.client.services.SpaceCenter.Part;
import krpc.client.services.SpaceCenter.Vessel;
import ru.prolib.kobert.lib.KOBAbstractVesselImpl;

public class KRPCVesselStage extends KOBAbstractVesselImpl {
	private final Vessel vessel;
	private final KRPCPartSelector isSignificant, isEngine, isFuelTank, isLoad;
	private final List<Part> allParts, engines, fuelTanks, stageLoad;
	
	public KRPCVesselStage(Vessel vessel,
			KRPCPartSelector isSignificant,
			KRPCPartSelector isEngine,
			KRPCPartSelector isFuelTank,
			KRPCPartSelector isLoad)
	{
		this.vessel = vessel;
		this.isSignificant = isSignificant;
		this.isEngine = isEngine;
		this.isFuelTank = isFuelTank;
		this.isLoad = isLoad;
		this.allParts = new ArrayList<>();
		this.engines = new ArrayList<>();
		this.fuelTanks = new ArrayList<>();
		this.stageLoad = new ArrayList<>();
		refresh();
	}
	
	/**
	 * Refresh parts data.
	 */
	public void refresh() {
		allParts.clear();
		engines.clear();
		fuelTanks.clear();
		stageLoad.clear();
		try {
			for ( Part part : vessel.getParts().getAll() ) {
				if ( isSignificant.validate(part) ) {
					allParts.add(part);
					if ( isEngine.validate(part) ) {
						engines.add(part);
					}
					if ( isFuelTank.validate(part) ) {
						fuelTanks.add(part);
					}
					if ( isLoad.validate(part) ) {
						stageLoad.add(part);
					}
				}
			}
		} catch ( RPCException e ) {
			throw new IllegalStateException("Error refreshing stage data", e);
		}
	}
	
	public List<Part> getAllParts() {
		return allParts;
	}
	
	public List<Part> getEngines() {
		return engines;
	}
	
	public List<Part> getFuelTanks() {
		return fuelTanks;
	}
	
	public List<Part> getStageLoad() {
		return stageLoad;
	}

	@Override
	public double getVacuumISP() {
		double totalThrust = 0d, ispPerN = 0d;
		for ( Part part : engines ) {
			try {
				Engine engine = part.getEngine();
				double thrust = engine.getMaxVacuumThrust();
				double isp = engine.getVacuumSpecificImpulse();
				totalThrust += thrust;
				if ( isp > 0 ) {
					ispPerN += (engine.getMaxVacuumThrust() / isp);
				}
			} catch ( RPCException e ) {
				throw new IllegalStateException("Error calculating ISP", e);
			}
		}
		return ispPerN > 0 ? totalThrust / ispPerN : 0;
	}

	@Override
	public double getVacuumMaxThrust() {
		double totalThrust = 0d;
		for ( Part part : engines ) {
			try {
				Engine engine = part.getEngine();
				totalThrust += engine.getMaxVacuumThrust();
			} catch ( RPCException e ) {
				throw new IllegalStateException("Error calculation max thrust", e);
			}
		}
		return totalThrust;
	}

	@Override
	public double getMass() {
		double total = 0d;
		for ( Part part : allParts ) {
			try {
				total += part.getMass();
			} catch ( RPCException e ) {
				throw new IllegalStateException("Error obtaining mass of the part", e);
			}
		}
		return total;
	}

	@Override
	public double getDryMass() {
		double total = 0d;
		for ( Part part : allParts ) {
			try {
				total += isFuelTank.validate(part) ? part.getDryMass() : part.getMass();
			} catch ( RPCException e ) {
				throw new IllegalStateException("Error obtaining dry mass of the part", e);
			}
		}
		return total;
	}

}
