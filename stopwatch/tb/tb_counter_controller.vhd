-- Testbench created online at:
-- https://www.doulos.com/knowhow/perl/vhdl-testbench-creation-using-perl/
-- Copyright Doulos Ltd

LIBRARY IEEE;
USE IEEE.Std_logic_1164.ALL;
USE IEEE.Numeric_Std.ALL;
use ieee.std_logic_unsigned.all;


ENTITY tb_counter_controller IS
END;

ARCHITECTURE bench OF tb_counter_controller IS

	COMPONENT counter_controller
		PORT (
			clk : IN STD_LOGIC;
			fsm_stopwatch_start : IN STD_LOGIC;
			sw_reset : IN STD_LOGIC;
			key_plus_imp : In STD_LOGIC;
			key_action_imp : IN STD_LOGIC;
			counter_ena : OUT STD_LOGIC
		);
	END COMPONENT;

	SIGNAL clk : STD_LOGIC;
	SIGNAL fsm_stopwatch_start : STD_LOGIC;
	SIGNAL sw_reset : STD_LOGIC;
	SIGNAL key_plus_imp : STD_LOGIC;
	SIGNAL key_action_imp : STD_LOGIC;
	SIGNAL counter_ena : STD_LOGIC;
BEGIN
	uut : counter_controller
	PORT MAP(
		clk => clk, 
		fsm_stopwatch_start => fsm_stopwatch_start, 
		sw_reset => sw_reset, 
		key_plus_imp => key_plus_imp,
		key_action_imp => key_action_imp, 
		counter_ena => counter_ena 
	);
 
	PROCESS 
	BEGIN
		clk <= '0'; -- clock cycle is 10 ns
		WAIT FOR 5 ns;
		clk <= '1';
		WAIT FOR 5 ns;
	END PROCESS;

	stimulus : PROCESS
	BEGIN
		-- Put initialisation code here
		fsm_stopwatch_start <= '1';
		sw_reset <= '0';
		key_action_imp <= '0';
		key_plus_imp <= '0';

		WAIT FOR 20 ns;
 
		--test case 1: start counting
		key_action_imp <= '1';
		WAIT FOR 10 ns;
		key_action_imp <= '0';
		WAIT FOR 40 ns;
 		assert (counter_ena = '1') report "Failed case 1" severity error;
 		
		--test case 2: stop counting
		key_action_imp <= '1';
		WAIT FOR 10 ns;
		key_action_imp <= '0';
		WAIT FOR 40 ns;
		assert (counter_ena = '0') report "Failed case 2" severity error;

 
		-- start counting
		key_action_imp <= '1';
		WAIT FOR 10 ns;
		key_action_imp <= '0';
		WAIT FOR 40 ns;
  		assert (counter_ena = '1') report "Failed case 3" severity error;

		-- test case 3:  reset 
		sw_reset <= '1';
		WAIT FOR 10 ns;
		sw_reset <= '0';
		WAIT FOR 40 ns;
		 assert (counter_ena = '0') report "Failed case 4" severity error;

		--test case 4: start counting
		key_action_imp <= '1';
		WAIT FOR 10 ns;
		key_action_imp <= '0';
		WAIT FOR 40 ns;
 		assert (counter_ena = '1') report "Failed case 5" severity error;
 
  		
  		-- test case 5: key_plus_imp stops counting
		key_plus_imp <= '1';
		WAIT FOR 10 ns;
		key_plus_imp <= '0';
		WAIT FOR 40 ns;
		 assert (counter_ena = '0') report "Failed case 6" severity error;

		-- test case 6: start counting
		key_action_imp <= '1';
		WAIT FOR 10 ns;
		key_action_imp <= '0';
		WAIT FOR 40 ns;
 		assert (counter_ena = '1') report "Failed case 7" severity error;
 		
 
		-- Put test bench stimulus code here

		WAIT;
	END PROCESS;
END;