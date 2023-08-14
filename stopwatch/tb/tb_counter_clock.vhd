-- Testbench created online at:
-- https://www.doulos.com/knowhow/perl/vhdl-testbench-creation-using-perl/
-- Copyright Doulos Ltd

LIBRARY IEEE;
USE IEEE.Std_logic_1164.ALL;
USE IEEE.Numeric_Std.ALL;
use ieee.std_logic_unsigned.all;

ENTITY tb_counter_clock IS
END;

ARCHITECTURE bench OF tb_counter_clock IS

	COMPONENT counter_clock
		PORT (
			clk : IN STD_LOGIC;
		    en_100 : In STD_LOGIC;
			fsm_stopwatch_start : IN STD_LOGIC;
			sw_reset : IN std_logic;
		    key_plus_imp : IN STD_LOGIC;
		    count_ena : IN std_logic;
			csec : OUT std_logic_vector(6 DOWNTO 0);
			sec : OUT std_logic_vector(6 DOWNTO 0);
			min : OUT std_logic_vector(6 DOWNTO 0);
			hr : OUT std_logic_vector(6 DOWNTO 0)
		);
	END COMPONENT;

	SIGNAL clk : STD_LOGIC;
	SIGNAL en_100 :  STD_LOGIC;
	SIGNAL fsm_stopwatch_start : STD_LOGIC;
	SIGNAL sw_reset : std_logic;
	SIGNAL count_ena : std_logic;
	SIGNAL key_plus_imp : std_logic;
	SIGNAL csec : std_logic_vector(6 DOWNTO 0);
	SIGNAL sec : std_logic_vector(6 DOWNTO 0);
	SIGNAL min : std_logic_vector(6 DOWNTO 0);
	SIGNAL hr : std_logic_vector(6 DOWNTO 0);

BEGIN
	uut : counter_clock
	PORT MAP(
		clk => clk, 
		en_100 => en_100 ,
		fsm_stopwatch_start => fsm_stopwatch_start,
		sw_reset => sw_reset, 
		count_ena => count_ena, 
		key_plus_imp => key_plus_imp,
		csec => csec, 
		sec => sec, 
		min => min, 
		hr => hr 
	);

    -- in the simulation ==> on the board 
    -- 10 nano            ==> clk == 0,1 micro second == 0,0001second == 10khz 
    -- 100 nano           ==> en_100 == 1 cemti second ==   0,01 second  (in the real board this is 100 times slower that the clk)
    -- 10 micro           ==> 1 second

	stimulus : 
	
	PROCESS 
	BEGIN   -- simulating clock: 10 kHz
		clk <= '0'; 
		WAIT FOR 5 ns;
		clk <= '1';
		WAIT FOR 5 ns;
	END PROCESS;

	PROCESS 
	BEGIN  -- simulating ena_100: puls each 100 Herz on the board, to count cemti seconds
		en_100 <= '0'; 
		WAIT FOR 5 ns;
		en_100 <= '1';
		WAIT FOR 5 ns;
		en_100 <= '0';
	    WAIT FOR 5*9*2 ns;
	END PROCESS;
 
	PROCESS

		BEGIN
		   -- initial values
			sw_reset <= '0'; 
			count_ena <= '0';
			fsm_stopwatch_start <= '0';
			key_plus_imp <= '0';
			
			WAIT FOR 10 us; -- after a second
            
            -- start counting
			sw_reset <= '0'; 
			count_ena <= '1';
			fsm_stopwatch_start <= '1';
			key_plus_imp <= '0';
 
			-- test case 1 : the clock accumulate from csec to sec to min to hr correctly
			WAIT FOR 60 *60*24 *10 us; -- after one day
			assert (sec=59 and min = 59 and hr = 23) report "Failed case 1" severity error;
			
			-- test case 2 : After the clock is full of data it reset to initial zero value and continue running 
            WAIT FOR 1 us; --after 0.01 second
            assert (sec=0 and min = 0 and hr = 0) report "Failed case 2" severity error;

			-- test case 3 : If counter enable in down the clock does not count
			 count_ena <= '0';
			 WAIT FOR 60 * 10 us; --after one minutes 
             assert (sec=0 and min = 0 and hr = 0) report "Failed case 3" severity error;
             
             -- test case 4 : If counter enable is up the clock count again 
             count_ena <= '1';
    
             WAIT FOR 60 * 10 us; --after one minutes 
             assert (sec=0 and min = 1 and hr = 0) report "Failed case 4" severity error;
             
             --test case 5: pressing key plus does not reset the clock if the clock module is not is stopwatch mode
             fsm_stopwatch_start <= '0';
             key_plus_imp <= '1';
             wait for 10 ns;
             key_plus_imp <= '0';
            assert (csec/=0 ) report "Failed case 5" severity error;
            
           --test case 6: pressing key plus reset the clock if the clock module is in stopwatch mode
            fsm_stopwatch_start <= '1';
             key_plus_imp <= '1';
             wait for 10 ns;
             key_plus_imp <= '0';
            assert (csec = 0 and sec=0 and min = 0 and hr = 0) report "Failed case 6" severity error;
            
              

			WAIT;
		END PROCESS;

END;