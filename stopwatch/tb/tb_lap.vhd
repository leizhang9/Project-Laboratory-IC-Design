-- Testbench created online at:
-- https://www.doulos.com/knowhow/perl/vhdl-testbench-creation-using-perl/
-- Copyright Doulos Ltd

LIBRARY IEEE;
USE IEEE.Std_logic_1164.ALL;
USE IEEE.Numeric_Std.ALL;
use ieee.std_logic_unsigned.all;


ENTITY tb_lap IS
END;

ARCHITECTURE bench OF tb_lap IS

	COMPONENT lap
		PORT (
			clk : IN STD_LOGIC;
			fsm_stopwatch_start : IN STD_LOGIC;
			sw_reset : IN STD_LOGIC;
		    key_plus_imp : In STD_LOGIC;
			counter_ena : IN STD_LOGIC;
			key_minus_imp : IN STD_LOGIC;
			transmitter_ena : OUT STD_LOGIC
		);
	END COMPONENT;

	SIGNAL clk : STD_LOGIC;
	SIGNAL fsm_stopwatch_start : STD_LOGIC;
	SIGNAL sw_reset : STD_LOGIC;
	SIGNAL key_plus_imp : STD_LOGIC;
	SIGNAL counter_ena : STD_LOGIC;
	SIGNAL key_minus_imp : STD_LOGIC;
	SIGNAL transmitter_ena : STD_LOGIC;

	--constant clock_period: time := 10 ns;
BEGIN
	uut : lap
	PORT MAP(
		clk => clk, 
		fsm_stopwatch_start => fsm_stopwatch_start, 
		sw_reset => sw_reset, 
		key_plus_imp => key_plus_imp,
		counter_ena => counter_ena, 
		key_minus_imp => key_minus_imp, 
		transmitter_ena => transmitter_ena 
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
		key_plus_imp <= '0';
		counter_ena <= '0';
		key_minus_imp <= '0';
		WAIT FOR 20 ns;
 
        -- test case 1: when counter_ena is high, transmitter is also high
		fsm_stopwatch_start <= '1';
		counter_ena <= '1';
	    WAIT FOR 40 ns;
 		assert (transmitter_ena = '1') report "Failed case 1" severity error;

        -- test case 2: when pressing minus key one time, transmitter becomes low
		key_minus_imp <= '1';
		WAIT FOR 10 ns;
		key_minus_imp <= '0';
		WAIT FOR 40 ns;
 		assert (transmitter_ena = '0') report "Failed case 2" severity error;

         -- test case 3: when pressing minus key another time, transmitter becomes high
		key_minus_imp <= '1';
		WAIT FOR 10 ns;
		key_minus_imp <= '0';
		WAIT FOR 40 ns;
  		assert (transmitter_ena = '1') report "Failed case 3" severity error;

		WAIT FOR 80 ns;
 
        -- test case 4: when minus key once , transmitter becomes low
		key_minus_imp <= '1';
		WAIT FOR 10 ns;
		key_minus_imp <= '0';
		WAIT FOR 40 ns;
  		assert (transmitter_ena = '0') report "Failed case 4" severity error;
           
         -- test case 5: when  pressing key plus, transmitter becomes high
		key_plus_imp <= '1';
		WAIT FOR 10 ns;
		key_plus_imp <= '0';
		WAIT FOR 40 ns;
  		assert (transmitter_ena = '1') report "Failed case 5" severity error;
 
		-- Put test bench stimulus code here

		WAIT;
	END PROCESS;
END;