package ru.prolib.kobert.lib;

public interface KOBVessel {

	/**
	 * Get combined specific impulse of all stage engines in vacuum.
	 * <p>
	 * @return vacuum specific impulse in seconds
	 */
	double getVacuumISP();

	/**
	 * Get max thrust the stage can produce in vacuum.
	 * <p>
	 * @return max thrust in vacuum in Newton
	 */
	double getVacuumMaxThrust();

	/**
	 * Get current mass of the stage.
	 * <p>
	 * @return mass of the stage in kilograms. This includes all: engines,
	 * fuel tanks, other stage parts and the load of stage. 
	 */
	double getMass();

	/**
	 * Get dry mass of the stage.
	 * <p>
	 * @return dry mass of the stage in kilograms. Similar as current mass but
	 * fuel tanks of the stage are counted with dry mass (as empty). 
	 */
	double getDryMass();
	
	/**
	 * Get current Delta-V available for the stage.
	 * <p>
	 * @return vacuum delta-V m/s
	 */
	double getVacuumDeltaV();

}