package ru.prolib.kobert.lib.krpc;

import krpc.client.RPCException;
import krpc.client.services.SpaceCenter.Part;

public class KRPCPartSelectorByTagPattern implements KRPCPartSelector {
	private final String tagPattern;
	
	public KRPCPartSelectorByTagPattern(String tagPattern) {
		this.tagPattern = tagPattern;
	}

	@Override
	public boolean validate(Part part) {
		String tag = null;
		try {
			tag = part.getTag();
		} catch ( RPCException e ) {
			throw new IllegalStateException("Error obtaining tag of the part", e);
		}
		if ( tag != null && tag.matches(tagPattern) ) {
			return true;
		}
		return false;
	}

}
