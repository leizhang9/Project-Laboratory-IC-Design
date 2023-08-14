----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:37:51 04/30/2013 
-- Design Name: 
-- Module Name:    dcf_gen - Behavioral 
-- Project Name: 
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

entity dcf_gen is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           en_10 : in  STD_LOGIC;
           en_1 : in  STD_LOGIC;
           dcf : out  STD_LOGIC);
end dcf_gen;

architecture Behavioral of dcf_gen is
	-- Timestamp in the format YYMMDDHHMMWC
	-- YY 47-40 : Year
	-- MM 39-32 : Month
	-- DD 31-24 : Day
	-- HH 23-16 : Hour
	-- MM 15-8  : Minute
	-- W  7-4   : Day of week
	-- C  3-0   : Checkbit errors
	subtype t_timestamp is std_logic_vector(47 downto 0);
	type t_timestamp_list is array (0 to 14) of t_timestamp;
	constant sample_timestamp_list : t_timestamp_list :=
	( x"130430124320",	-- 30.04.13 12:43 Tuesday
	  x"130430154822",	-- 30.04.13 15:48 Tuesday (corrupted)
	  x"121231235910",	-- 31.12.12 23:59 Monday
	  x"130430154822",	-- 30.04.13 15:48 Tuesday (corrupted)
	  x"130228235940",	-- 28.02.13 23:59 Thursday
	  x"130430154822",	-- 30.04.13 15:48 Tuesday (corrupted)
	  x"120228235920",	-- 28.02.12 23:59 Tuesday
	  x"130430154822",	-- 30.04.13 15:48 Tuesday (corrupted)
	  x"130502090040",	-- 02.05.13 09:00 Thursday
	  x"130502090140",	-- 02.05.13 09:01 Thursday
	  x"130502090240",	-- 02.05.13 09:02 Thursday
	  x"130502090340",	-- 02.05.13 09:03 Thursday
	  x"130502090441",	-- 02.05.13 09:04 Thursday (corrupted)
	  x"130502090540",	-- 02.05.13 09:05 Thursday
	  x"130502090640");	-- 02.05.13 09:06 Thursday
	
	signal current_sample : integer range 0 to 14 := 0;
	signal current_pos : integer range 0 to 59 := 0;
	signal current_time : integer range 0 to 9 := 0;
	signal current_timestamp : t_timestamp;
	signal current_mark : std_logic := '0';
	
	signal reset_parity : std_logic := '0';
	signal parity : std_logic := '0';
begin

	current_timestamp <= sample_timestamp_list(current_sample);
	
	mark_calc : process(current_pos, current_timestamp, parity)
	begin
		current_mark <= '0';
		reset_parity <= '0';
		case current_pos is
			when 20 => current_mark <= '1';	-- Start of Timecode
							reset_parity <= '1';
			when 21 => current_mark <= current_timestamp(8);	-- Min1
			when 22 => current_mark <= current_timestamp(9);	-- Min2
			when 23 => current_mark <= current_timestamp(10);	-- Min4
			when 24 => current_mark <= current_timestamp(11);	-- Min8
			when 25 => current_mark <= current_timestamp(12);	-- Min10
			when 26 => current_mark <= current_timestamp(13);	-- Min20
			when 27 => current_mark <= current_timestamp(14);	-- Min40
			when 28 => current_mark <= parity xor current_timestamp(2);
							reset_parity <= '1';
			when 29 => current_mark <= current_timestamp(16);	-- Hour1
			when 30 => current_mark <= current_timestamp(17);	-- Hour2
			when 31 => current_mark <= current_timestamp(18);	-- Hour4
			when 32 => current_mark <= current_timestamp(19);	-- Hour8
			when 33 => current_mark <= current_timestamp(20);	-- Hour10
			when 34 => current_mark <= current_timestamp(21);	-- Hour20
			when 35 => current_mark <= parity xor current_timestamp(1);
							reset_parity <= '1';
			when 36 => current_mark <= current_timestamp(24);	-- Day1
			when 37 => current_mark <= current_timestamp(25);	-- Day2
			when 38 => current_mark <= current_timestamp(26);	-- Day4
			when 39 => current_mark <= current_timestamp(27);	-- Day8
			when 40 => current_mark <= current_timestamp(28);	-- Day10
			when 41 => current_mark <= current_timestamp(29);	-- Day20
			when 42 => current_mark <= current_timestamp(4);	-- DOW1
			when 43 => current_mark <= current_timestamp(5);	-- DOW2
			when 44 => current_mark <= current_timestamp(6);	-- DOW4
			when 45 => current_mark <= current_timestamp(32);	-- Month1
			when 46 => current_mark <= current_timestamp(33);	-- Month2
			when 47 => current_mark <= current_timestamp(34);	-- Month4
			when 48 => current_mark <= current_timestamp(35);	-- Month8
			when 49 => current_mark <= current_timestamp(36);	-- Month10
			when 50 => current_mark <= current_timestamp(40);	-- Year1
			when 51 => current_mark <= current_timestamp(41);	-- Year2
			when 52 => current_mark <= current_timestamp(42);	-- Year4
			when 53 => current_mark <= current_timestamp(43);	-- Year8
			when 54 => current_mark <= current_timestamp(44);	-- Year10
			when 55 => current_mark <= current_timestamp(45);	-- Year20
			when 56 => current_mark <= current_timestamp(46);	-- Year40
			when 57 => current_mark <= current_timestamp(47);	-- Year80
			when 58 => current_mark <= parity xor current_timestamp(0);
							reset_parity <= '1';
			when others => null;
		end case;
	end process;
	
	parity_calc : process(clk)
	begin
		if rising_edge(clk) then
			if en_10='1' and current_time=4 then
				if reset_parity='1' then
					parity <= '0';
				else
					parity <= parity xor current_mark;
				end if;
			end if;
		end if;
	end process;
	
	time_counter : process(clk)
	begin
		if rising_edge(clk) then
			if en_1='1' then
				current_time <= 0;
			elsif en_10='1' then
				current_time <= current_time + 1;
			end if;
		end if;
	end process;
	
	pos_counter : process(clk)
	begin
		if rising_edge(clk) then
			if reset='1' then
				current_pos <= 59;
				current_sample <= 14;
			elsif en_1='1' then
				if current_pos = 59 then
					current_pos <= 0;
					if current_sample=14 then
						current_sample <= 0;
					else
						current_sample <= current_sample+1;
					end if;
				else
					current_pos <= current_pos+1;
				end if;
			end if;
		end if;
	end process;
		
	mark_gen : process(clk)
	begin
		if rising_edge(clk) then
			if current_pos=59 then
				dcf <= '1';
			elsif current_time=0 then
				dcf <= '0';
			elsif current_time=1 then
				dcf <= not(current_mark);
			else
				dcf <= '1';
			end if;
		end if;
	end process;
end Behavioral;

