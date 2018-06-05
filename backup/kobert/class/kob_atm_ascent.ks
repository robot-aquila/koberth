// kob_atm_ascent - class to calculate parameters of atmospheric ascent

// Constructor
// Param2: dynamic pressure limit kPA
function kob_atm_ascent {
	declare local parameter myMaxQ.

	local obj is lexicon().

	// class attributes
	set obj["q_lim"] to myMaxQ.
	set obj["q_cur"] to 0.
	set obj["q_factor"] to 0.
	set obj["vel_cur"] to 0.
	set obj["vel_lim"] to 0. 
	set obj["ship_mass_kg"] to 0.
	set obj["ship_local_g"] to 0.
	set obj["ship_local_g_vec"] to v(0, 0, 0).
	set obj["ship_acc"] to 0.
	set obj["ship_acc_vec"] to v(0, 0, 0).

	// class methods
	set obj["update"] to kob_atm_ascent_update@:bind(obj).

	return obj.
}

// Update variables according to ship current state
// Param1: object
function kob_atm_ascent_update {
	declare local parameter obj.

	// ����� ���-�� ������� ������� �������� � Q.
	// Q ������� �� ��������, � �� �� ���������.
	// ����������� ����� ���������: LimQ / CurQ = LimVel / CurVel
	// �����: LimVel = LimQ / CurQ * CurVel
	// �� ����� ����, ��� ����� ���������. ����� ������� �����.
	// ��� ������ ���� ���������������� �����������.

	// �������� ������ ������ ��� ���������. ��������� �������:
	//
	//   ��������� - ���������� + ��������
	//
	// ����� ������ �������� � ��������� ������ �������. ����� �������
	// ������ ��������� ����� �����, ��� �� ������� ������ ��������
	// �� ����� �� �������� LimVel.


	set obj["q_cur"] to ship:dynamicpressure * constant:ATMtoKPA().
	set obj["q_factor"] to obj["q_lim"] / obj["q_cur"].
	set obj["vel_cur"] to ship:airspeed.
	set obj["vel_lim"] to obj["q_factor"] * obj["vel_cur"].
	local ship_mass_kg is mass * 1000.
	set obj["ship_mass_kg"] to ship_mass_kg.
	set obj["ship_local_g"] to (constant:g() * body:mass * ship_mass_kg / (body:radius + altitude) ^ 2) / ship_mass_kg.
	set obj["ship_local_g_vec"] to ship:up:vector * obj["ship_local_g"] * -1.
	set obj["ship_acc"] to maxthrust / mass * throttle.
	set obj["ship_acc_vec"] to ship:facing:vector * obj["ship_acc"].
}
