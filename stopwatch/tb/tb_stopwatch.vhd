-- Testbench created online at:
-- https://www.doulos.com/knowhow/perl/vhdl-testbench-creation-using-perl/
-- Copyright Doulos Ltd

LIBRARY IEEE;
USE IEEE.Std_logic_1164.ALL;
USE IEEE.Numeric_Std.ALL;
Use ieee.std_logic_unsigned.All;


ENTITY tb_stopwatch IS
END;

ARCHITECTURE bench OF tb_stopwatch IS

	COMPONENT stopwatch
		PORT (
			clk : IN STD_LOGIC;
		    en_100 : In STD_LOGIC;
			fsm_stopwatch_start : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			key_plus_imp : IN STD_LOGIC;
			key_action_imp : IN STD_LOGIC;
			key_minus_imp : IN STD_LOGIC;
			lcd_stopwatch_act : OUT STD_LOGIC;
			cs : OUT STD_LOGIC_vector(6 DOWNTO 0);
			ss : OUT STD_LOGIC_vector(6 DOWNTO 0);
			mm : OUT STD_LOGIC_vector(6 DOWNTO 0);
			hh : OUT STD_LOGIC_vector(6 DOWNTO 0)
		);
	END COMPONENT;

	SIGNAL clk : STD_LOGIC;
	SIGNAL en_100 : STD_LOGIC;
	SIGNAL fsm_stopwatch_start : STD_LOGIC;
    SIGNAL reset : STD_LOGIC;
	SIGNAL key_plus_imp : STD_LOGIC;
    SIGNAL key_action_imp : STD_LOGIC;
	SIGNAL key_minus_imp : STD_LOGIC;
	SIGNAL lcd_stopwatch_act : STD_LOGIC;
	SIGNAL cs : STD_LOGIC_vector(6 DOWNTO 0);
	SIGNAL ss : STD_LOGIC_vector(6 DOWNTO 0);
	SIGNAL mm : STD_LOGIC_vector(6 DOWNTO 0);
	SIGNAL hh : STD_LOGIC_vector(6 DOWNTO 0);
	

BEGIN
	uut : stopwatch
	PORT MAP(

		clk => clk, 
		en_100 => en_100, 
	    fsm_stopwatch_start => fsm_stopwatch_start, 
		reset => reset, 
		key_plus_imp => key_plus_imp, 
		key_action_imp => key_action_imp,
		key_minus_imp => key_minus_imp, 
		lcd_stopwatch_act => lcd_stopwatch_act,
		cs => cs, 
		ss => ss, 
		mm => mm, 
		hh => hh 
	);
 
    -- in the simulation ==> on the board 
    -- 10 nano            ==> clk == 0,1 micro second == 0,0001second == 10khz 
    -- 100 nano           ==> en_100 == 1 cemti second ==   0,01 second  (in the real board this is 100 times slower that the clk)
    -- 10 micro           ==> 1 second
	stimulus : 
	
    PROCESS 
	BEGIN -- simulating clock: 10 kHz
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
 
		--initialization values
		fsm_stopwatch_start <= '1';
		key_minus_imp <= '0';
		key_plus_imp <= '0';
		key_action_imp <= '0';
		reset <= '0';
		
		WAIT FOR 10 us;-- after a second 
 
		--test case 1 : start counting
		key_action_imp <= '1';
		WAIT FOR 10 ns; 
		key_action_imp <= '0';
		WAIT FOR  20 us; -- two second 
		WAIT FOR 20 ns; -- probagatoin delay
		assert (ss=2 and mm = 0 and hh = 0) report "Failed case 1" severity error;
		assert (lcd_stopwatch_act = '0') report "Failed case 2" severity error;

 
		--test case 2 : start lapping
		key_minus_imp <= '1';
		WAIT FOR 10 ns;
		key_minus_imp <= '0'; 
		WAIT FOR  20 us; -- two second + two second old
	    WAIT FOR 20 ns; -- probagatoin delay
		assert (ss=2 and mm = 0 and hh = 0) report "Failed case 3" severity error;
		assert (lcd_stopwatch_act = '1') report "Failed case 4" severity error;
		
		--test case 3 : stop lapping
		key_minus_imp <= '1';
		WAIT FOR 10 ns;
		key_minus_imp <= '0';
		WAIT FOR 20 ns; -- probagatoin delay
		assert (ss=4 and mm = 0 and hh = 0) report "Failed case 5" severity error;
		assert (lcd_stopwatch_act = '0') report "Failed case 6" severity error;
 
		--test case 4 : start pause
		WAIT FOR  20 us; -- two second + four second old
		key_action_imp <= '1';
		WAIT FOR 10 ns;
		key_action_imp <= '0';
		WAIT FOR 20 ns; -- probagatoin delay
		assert (ss=6 and mm = 0 and hh = 0) report "Failed case 7" severity error;
		assert (lcd_stopwatch_act = '0') report "Failed case 8" severity error;
 
		--test case 5 : resume
		WAIT FOR  20 us; -- two second pause
		key_action_imp <= '1';
		WAIT FOR 10 ns;
		key_action_imp <= '0';
		WAIT FOR  20 us; -- two second + six second old
		WAIT FOR 20 ns; -- probagatoin delay
		assert (ss=8 and mm = 0 and hh = 0) report "Failed case 9" severity error;
		assert (lcd_stopwatch_act = '0') report "Failed case 10" severity error; 
		
		--test case 5 : pressing plus key resets 
		key_plus_imp <= '1';
		WAIT FOR 10 ns;
		key_plus_imp <= '0';
		WAIT FOR  20 us; -- two second stops

		WAIT FOR  10 ns; -- probagation delay
		assert (ss=0 and mm = 0 and hh = 0) report "Failed case 11" severity error;
		assert (lcd_stopwatch_act = '0') report "Failed case 12" severity error;
 
		--run
		key_action_imp <= '1';
		WAIT FOR 10 ns;
		key_action_imp <= '0';
		WAIT FOR 400 ns;

 
 
		-- Put test bench stimulus code here

		WAIT;
	END PROCESS;
END;