package ru.prolib.kobert.lib.krpc;

import java.io.Closeable;

import krpc.client.Connection;
import krpc.client.Stream;
import krpc.client.services.KRPC;
import krpc.client.services.KRPC.GameScene;
import krpc.client.services.SpaceCenter;
import krpc.client.services.SpaceCenter.Node;
import krpc.client.services.SpaceCenter.Vessel;
import krpc.client.services.SpaceCenter.VesselSituation;

public interface KRPCFacade extends Closeable {

	Connection getConnection();
	KRPC getKRPC();
	SpaceCenter getKSC();
	void close(Stream<?> stream);
	double getUT();
	void waitUntilUT(double ut) throws InterruptedException;
	void assertCurrentGameScene(GameScene expected);
	void assertCurrentGameSceneIsFlight();
	Vessel getActiveVessel();
	String getActiveVesselName();
	void assertVesselInFlight(Vessel vessel);
	void assertActiveVesselName(String expected);
	void assertActiveVesselNamePattern(String pattern);
	void assertActiveVesselSituation(VesselSituation expected);
	
	/**
	 * Get maneuver node of active vessel.
	 * <p>
	 * @return the next maneuver node
	 * @throws IllegalStateException if there was not active vessel or it didn't has any node ahead
	 */
	Node getActiveVesselManeuverNode();
	
}