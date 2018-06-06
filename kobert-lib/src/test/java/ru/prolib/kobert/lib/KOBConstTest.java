package ru.prolib.kobert.lib;

import static org.junit.Assert.*;

import org.junit.Before;
import org.junit.Test;

public class KOBConstTest {

	@Before
	public void setUp() throws Exception {
	}

	@Test
	public void testConstants() {
		double epsilon = 1E-14;
		
		assertEquals(Math.E, KOBConst.E, epsilon);
		assertEquals(Math.PI, KOBConst.PI, epsilon);
		assertEquals(6.67384E-11, KOBConst.G, epsilon);
		assertEquals(9.81d, KOBConst.KERBIN_G, epsilon);
	}

}
