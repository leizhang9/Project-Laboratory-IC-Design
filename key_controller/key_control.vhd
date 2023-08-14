----------------------------------------------------------------------------------
-- Company:        TUM/LIS
-- Engineer:       Dirk Gabriel <dirk.gabriel@mytum.de>
-- 
-- Create Date:    19:22:48 04/28/2013 
-- Design Name: 
-- Module Name:    key_control - Behavioral 
-- Project Name:   Project Lab IC-Design
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity key_control is
	Port (
		clk : in std_logic;
		reset : in std_logic;
		en_10 : in std_logic;
		en_100 : in std_logic;
		
		btn_action : in std_logic;
		btn_mode : in std_logic;
		btn_minus : in std_logic;
		btn_plus : in std_logic;
		
		action_imp : out std_logic;
		action_long : out std_logic;
		mode_imp : out std_logic;
		minus_imp : out std_logic;
		plus_imp : out std_logic;
		plus_minus : out std_logic;
		enable : out std_logic
	);
end key_control;

architecture Behavioral of key_control is
	signal key_action : std_logic := '0';
	signal key_minus : std_logic := '0';
	signal key_plus : std_logic := '0';
	signal key_plus_minus : std_logic := '0';
	
	signal current_sec : integer range 0 to 5 := 0;
	signal current_10ms : integer range 0 to 99 := 0;
	
	signal count : integer range 0 to 99 := 0;
	signal overflow : integer range 0 to 99 := 0;
	
	signal action_count : integer range 0 to 20 := 0;
begin

	action_debounce : entity work.debounce
		port map(
			clk => clk,
			reset => reset,
			d_in => btn_action,
			d_out => key_action,
			imp => action_imp
		);
	
	mode_debounce : entity work.debounce
		port map(
			clk => clk,
			reset => reset,
			d_in => btn_mode,
			d_out => open,
			imp => mode_imp
		);
	
	minus_debounce : entity work.debounce
		port map(
			clk => clk,
			reset => reset,
			d_in => btn_minus,
			d_out => key_minus,
			imp => minus_imp
		);

	plus_debounce : entity work.debounce
		port map(
			clk => clk,
			reset => reset,
			d_in => btn_plus,
			d_out => key_plus,
			imp => plus_imp
		);

	key_plus_minus <= key_plus or key_minus;
	plus_minus <= key_plus;
	
	state_detect : process(key_plus_minus, current_sec)
	begin
		if key_plus_minus='1' then
			case current_sec is
				when 0 => overflow <= 99;
				when 1 => overflow <= 7;
				when 2 => overflow <= 7;
				when 3 => overflow <= 7;
				when 4 => overflow <= 7;
				when 5 => overflow <= 1;
			end case;
		else
			overflow <= 0;
		end if;
	end process;
				
	
	sec_counter : process(clk)
	begin
		if rising_edge(clk) then
			if key_plus_minus = '0' then
				current_sec <= 0;
				current_10ms <= 0;
			elsif en_100='1' then
				if current_10ms=99 then
					current_10ms <= 0;
					if not(current_sec=5) then
						current_sec <= current_sec + 1;
					end if;
				else
					current_10ms <= current_10ms + 1;
				end if;
			end if;
		end if;
	end process;
	
	counter : process(clk)
	begin
		if rising_edge(clk) then
			if key_plus_minus = '0' then
				count <= 0;
			elsif en_100='1' then
				if (count=overflow) then
					count <= 0;
				else
					count <= count + 1;
				end if;
			end if;
		end if;
	end process;
	
	enable_gen : process(clk)
	begin
		if rising_edge(clk) then
			enable <= '0';
			if en_100='1' then
				if (count = 0) and (key_plus_minus='1') then
					enable <= '1';
				end if;
			end if;
		end if;
	end process;
	
	action_long_detect : process(clk)
	begin
		if rising_edge(clk) then
			action_long <= '0';
			
			if key_action='0' then
				action_count <= 0;
			elsif en_10='1' then
				if action_count = 19 then
					action_long <= '1';
				end if;
				
				if not(action_count = 20) then
					action_count <= action_count + 1;
				end if;
			end if;
		end if;
	end process;
	
end Behavioral;

