-- Testbench created online at:
-- https://www.doulos.com/knowhow/perl/vhdl-testbench-creation-using-perl/
-- Copyright Doulos Ltd

LIBRARY IEEE;
USE IEEE.Std_logic_1164.ALL;
USE IEEE.Numeric_Std.ALL;
use ieee.std_logic_unsigned.all;


ENTITY tb_transmitter IS
END;

ARCHITECTURE bench OF tb_transmitter IS

	COMPONENT transmitter
		PORT (
			clk : IN std_logic;
			fsm_stopwatch_start : IN std_logic;
			sw_reset : IN std_logic;
			key_plus_imp : In STD_LOGIC;
			transmitter_ena : IN STD_LOGIC;
			csec_in : IN std_logic_vector(6 DOWNTO 0);
			sec_in : IN std_logic_vector(6 DOWNTO 0);
			min_in : IN std_logic_vector(6 DOWNTO 0);
			hr_in : IN std_logic_vector(6 DOWNTO 0);
			csec : OUT std_logic_vector(6 DOWNTO 0);
			sec : OUT std_logic_vector(6 DOWNTO 0);
			min : OUT std_logic_vector(6 DOWNTO 0);
			hr : OUT std_logic_vector(6 DOWNTO 0)
		);
	END COMPONENT;

 
	SIGNAL clk : STD_LOGIC;
	SIGNAL fsm_stopwatch_start : STD_LOGIC;
	SIGNAL sw_reset : STD_LOGIC;
	SIGNAL key_plus_imp : STD_LOGIC;
	SIGNAL transmitter_ena : STD_LOGIC;
	SIGNAL csec_in : std_logic_vector(6 DOWNTO 0);
	SIGNAL sec_in : std_logic_vector(6 DOWNTO 0);
	SIGNAL min_in : std_logic_vector(6 DOWNTO 0);
	SIGNAL hr_in : std_logic_vector(6 DOWNTO 0);
	SIGNAL csec : std_logic_vector(6 DOWNTO 0);
	SIGNAL sec : std_logic_vector(6 DOWNTO 0);
	SIGNAL min : std_logic_vector(6 DOWNTO 0);
	SIGNAL hr : std_logic_vector(6 DOWNTO 0);

BEGIN
	uut : transmitter
	PORT MAP(
		clk => clk, 
		fsm_stopwatch_start => fsm_stopwatch_start, 
		sw_reset => sw_reset, 
		key_plus_imp => key_plus_imp,
		transmitter_ena => transmitter_ena, 
		csec_in => csec_in, 
		sec_in => sec_in, 
		min_in => min_in, 
		hr_in => hr_in, 
		csec => csec, 
		sec => sec, 
		min => min, 
		hr => hr 
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
		-- Inintial values
		fsm_stopwatch_start <= '1';
		sw_reset <= '0';
		key_plus_imp <= '0';
		transmitter_ena <= '0';

		
		-- test case 1: In case transmitter is high, the output data equal to the input
		csec_in <= "0000001";
		sec_in <= "0000001";
		min_in <= "0000001";
		hr_in <= "0000001";
		WAIT FOR 20 ns;
		transmitter_ena <= '1';
		WAIT FOR 40 ns;
		assert (csec= 1 and sec=1 and min =1 and hr = 1) report "Failed case 1" severity error;

        -- test case 2: change the input value, causes changes in the output
		csec_in <= "0000010";
		sec_in <= "0000010";
		min_in <= "0000010";
		hr_in <= "0000010";
		WAIT FOR 40 ns;
		assert (csec= 2 and sec=2 and min =2 and hr = 2) report "Failed case 2" severity error;


         -- test case 3: In case transmitter is low, the output data keeps the same and is not effected with the input
		transmitter_ena <= '0';
		WAIT FOR 40 ns;
		csec_in <= "0000011";
		sec_in <= "0000011";
		min_in <= "0000011";
		hr_in <= "0000011";
		WAIT FOR 40 ns;
		assert (csec=2 and sec=2 and min=2 and hr=2) report "Failed case 3" severity error;

         -- test case 4: In case transmitter is high again, the output data becomes equal to the inputs
		transmitter_ena <= '1';
		WAIT FOR 40 ns;
 		assert (csec=3 and sec=3 and min=3 and hr=3) report "Failed case 4" severity error;

		-- test case 5: in case of pressing plus key the output data becommes zero 
		key_plus_imp <= '1';
		WAIT FOR 10 ns;
		key_plus_imp <= '0';
		assert (csec=0 and sec=0 and min=0 and hr=0) report "Failed case 5" severity error;
	
         -- test case 6: In case transmitter is high again, the output data becomes equal to the inputs
        csec_in <= "0000100";
		sec_in <= "0000100";
		min_in <= "0000100";
		hr_in <= "0000100";
		transmitter_ena <= '1';
		WAIT FOR 40 ns;
		assert (csec=4 and sec=4 and min=4 and hr=4) report "Failed case 6" severity error;

		-- Put test bench stimulus code here
		
	   -- test case 7: in case of pressing reset key the output data becommes zero 
		sw_reset <= '1';
		WAIT FOR 10 ns;
		sw_reset <= '0';
		assert (csec=0 and sec=0 and min=0 and hr=0) report "Failed case 7" severity error;

		

		WAIT;
	END PROCESS;
END;