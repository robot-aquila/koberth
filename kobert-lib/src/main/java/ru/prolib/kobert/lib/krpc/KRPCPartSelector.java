package ru.prolib.kobert.lib.krpc;

import krpc.client.services.SpaceCenter.Part;

public interface KRPCPartSelector {

	/**
	 * Validate that kRPC part meets specific conditions.
	 * <p>
	 * @param part - part
	 * @return true if part meets conditions, false - otherwise
	 */
	boolean validate(Part part);
	
}
