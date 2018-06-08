package ru.prolib.kobert.lib.krpc;

import java.io.IOException;
import java.util.List;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.function.Consumer;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import krpc.client.Connection;
import krpc.client.RPCException;
import krpc.client.Stream;
import krpc.client.StreamException;
import krpc.client.services.KRPC;
import krpc.client.services.SpaceCenter;
import krpc.client.services.KRPC.GameScene;
import krpc.client.services.SpaceCenter.Node;
import krpc.client.services.SpaceCenter.Vessel;
import krpc.client.services.SpaceCenter.VesselSituation;

public class KRPCFacadeImpl implements KRPCFacade {
	private static final Logger logger;
	
	static {
		logger = LoggerFactory.getLogger(KRPCFacadeImpl.class);
	}
	
	private final Connection connection;
	private KRPC krpc;
	private SpaceCenter ksc;

	public KRPCFacadeImpl(Connection connection) {
		this.connection = connection;
	}
	
	public KRPCFacadeImpl() throws IOException {
		this(Connection.newInstance());
	}
	
	@Override
	public void close() throws IOException {
		connection.close();
	}
	
	@Override
	public Connection getConnection() {
		return connection;
	}
	
	@Override
	public synchronized KRPC getKRPC() {
		if ( krpc == null ) {
			krpc = KRPC.newInstance(connection);
		}
		return krpc;
	}
	
	@Override
	public synchronized SpaceCenter getKSC() {
		if ( ksc == null ) {
			ksc = SpaceCenter.newInstance(connection);
		}
		return ksc;
	}
	
	@Override
	public double getUT() {
		try {
			return getKSC().getUT();
		} catch ( RPCException e ) {
			throw new IllegalStateException("Error obtaining time", e);
		}
	}
	
	@Override
	public void waitUntilUT(double expected) throws InterruptedException {
		double actual = getUT();
		logger.debug("Wait until UT: expected={} actual={}", expected, actual);
		if ( actual >= expected ) {
			logger.debug("Exit immediately ");
			return;
		}
		if ( expected - actual > 1 ) {
			_waitUntilUT_MUR(expected);
		}
		_waitUntilUT_FUR(expected);
	}
	
	private Stream<Double> createStreamUpdateUT() {
		try {
			return connection.addStream(SpaceCenter.class, "getUT");
		} catch ( Exception e ) {
			throw new IllegalStateException("Error creating stream", e);
		}
	}
	
	@Override
	public void close(Stream<?> stream) {
		if ( stream != null ) {
			try {
				stream.remove();
			} catch ( RPCException e ) {
				logger.warn("Error removing stream", e);
			}
		}
	}
	
	private void _waitUntilUT_MUR(final double expected) throws InterruptedException {
		final double threshold = 0.9; // make enough time for precise jump
		final CountDownLatch done = new CountDownLatch(1);
		Stream<Double> stream = createStreamUpdateUT();
		
		stream.addCallback(new Consumer<Double>() {
			private int count = 0;
			@Override
			public void accept(Double actual) {
				if ( expected - actual < threshold ) {
					logger.debug("MUR: It's TIME: " + actual + " expected: " + expected);
					done.countDown();
				}
				count ++;
				if ( count % 200 == 0 ) {
					logger.debug("Total updates count: {}", count);
					logger.debug("Wait more: expected={} actual={}", expected, actual);
				}
			}
		});
		try {
			stream.start();
			while ( ! done.await((long)(expected - getUT() + 10), TimeUnit.SECONDS) ) {
				double actual = stream.get();
				if ( actual > expected ) {
					logger.debug("Timeout: expected={} actual={}", expected, actual);
					throw new IllegalStateException("Timeout");
				}
				logger.debug("Additional check: expected={} actual={}", expected, actual);
			}
			logger.debug("Counted down!!!: expected={} actual={}", expected, stream.get());

		} catch ( InterruptedException e ) {
			throw e;
		} catch ( RPCException|StreamException e ) {
			throw new IllegalStateException("Error waiting for time", e);
		} finally {
			close(stream);
		}
	}
	
	/**
	 * Precise jump to specified UT.
	 * <p>
	 * @param expected - expected UT
	 * @throws InterruptedException if the thread was interrupted
	 */
	private void _waitUntilUT_FUR(double expected) throws InterruptedException {
		double threshold = 0.005;
		// Don't try to do with KRPC streams. Possible deadlocks.
		SpaceCenter ksc = getKSC();
		try {
			double actual = 0, ksp_start = 0, ksp_end = 0;
			long rtn_start = 0, rtn_end = 0;
			final int maxCount = 3;
			int count = 0;
			double last = ksc.getUT();
			do {
				actual = ksc.getUT();
				if ( actual - last >= threshold ) {
					if ( actual >= expected ) {
						return; // no more time to play around
					}
					
					last = actual;
					count ++;
					if ( count == 1 ) {
						ksp_start = actual;
						rtn_start = System.nanoTime();
					} else if ( count == maxCount ) {
						ksp_end = actual;
						rtn_end = System.nanoTime();
						break;
					}
				}
			} while ( count < maxCount );
			double ksp_diff = ksp_end - ksp_start;
			double rtn_diff = ((double)(rtn_end - rtn_start))/1E+9;
			
			logger.debug("FUR: Stats: ksp diff={} sec.  real-time diff={} sec.", ksp_diff, rtn_diff);
			double ratio = rtn_diff / ksp_diff;
			logger.debug("FUR: Stats: ratio real-time/ksp={}", ratio);
			
			double ksp_rest = (expected - ksp_end);
			double rts_rest = ksp_rest * ratio;
			logger.debug("FUR: Rest seconds: ksp={} real-time={}", ksp_rest, rts_rest);
			long rest_mcs = (long)(rts_rest * 1E+6);
			logger.debug("FUR: Rest microseconds={}", rest_mcs);
			long n1 = System.nanoTime();
			CountDownLatch x = new CountDownLatch(1);
			x.await(rest_mcs, TimeUnit.MICROSECONDS);
			long real_mcs = (System.nanoTime() - n1) / 1000;
			double accuracy = 1 - Math.abs((double)(rest_mcs - real_mcs)) / rest_mcs;
			logger.debug("FUR: actual pause was: {} mcs. accuracy={}%", real_mcs, accuracy * 100);
			logger.debug("FUR: Done: actual={} expected={}", ksc.getUT(), expected);
			
			
		} catch ( Exception e ) {
			throw new IllegalStateException("Error waiting for time", e);
		}
	}

	@Override
	public void assertCurrentGameScene(GameScene expected) {
		try {
			GameScene actual = getKRPC().getCurrentGameScene();
			if ( actual != expected ) {
				throw new IllegalStateException("Unexpected game scene: " + actual);
			}
		} catch ( RPCException e ) {
			throw new IllegalStateException("Error obtaining current game scene", e);
		}
	}
	
	@Override
	public void assertCurrentGameSceneIsFlight() {
		assertCurrentGameScene(GameScene.FLIGHT);
	}
	
	@Override
	public Vessel getActiveVessel() {
		assertCurrentGameSceneIsFlight();
		try {
			return getKSC().getActiveVessel();
		} catch ( RPCException e ) {
			throw new IllegalStateException("Error obtaining active vessel", e);
		}
	}

	@Override
	public String getActiveVesselName() {
		try {
			return getActiveVessel().getName();
		} catch ( RPCException e ) {
			throw new IllegalStateException("Error obtaining vessel name", e);
		}
	}
	
	@Override
	public void assertVesselInFlight(Vessel vessel) {
		assertCurrentGameSceneIsFlight();
		if ( ! vessel.equals(getActiveVessel()) ) {
			throw new IllegalStateException("Unexpected active vessel");
		}
	}
	
	@Override
	public void assertActiveVesselName(String expected) {
		String actual = getActiveVesselName();
		if ( ! expected.equals(actual) ) {
			throw new IllegalStateException("Invalid vessel is currently loaded: " + actual);
		}
	}
	
	@Override
	public void assertActiveVesselNamePattern(String pattern) {
		String actual = getActiveVesselName();
		if ( ! actual.matches(pattern) ) {
			throw new IllegalStateException("Unexpected vessel name: " + actual);
		}
	}
	
	@Override
	public void assertActiveVesselSituation(VesselSituation expected) {
		assertCurrentGameSceneIsFlight();
		try {
			VesselSituation actual = getActiveVessel().getSituation();
			if ( actual != expected ) {
				throw new IllegalStateException("Unexpected situation: " + actual);
			}
		} catch ( RPCException e ) {
			throw new IllegalStateException("Error obtaining current situation", e);
		}
	}
	
	@Override
	public Node getActiveVesselManeuverNode() {
		Vessel vessel = getActiveVessel();
		try {
			List<Node> nodes = vessel.getControl().getNodes();
			if ( nodes.size() == 0 ) {
				throw new IllegalStateException("Active vessel doesn't have any nodes ahead");
			}
			return nodes.get(0);
		} catch ( RPCException e ) {
			throw new IllegalStateException("Error obtaining node list", e);
		}
	}

}
