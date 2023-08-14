----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:03:03 04/30/2013 
-- Design Name: 
-- Module Name:    clockGen - Behavioral 
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

entity clock_gen is
    Port ( clk : in  STD_LOGIC;
           clk_10K : out  STD_LOGIC;
           en_1K : out  STD_LOGIC;
           en_100 : out  STD_LOGIC;
           en_10 : out  STD_LOGIC;
           en_1 : out  STD_LOGIC);
end clock_gen;

architecture Behavioral of clock_gen is
	signal counter_10K : integer range 0 to 4999 := 0;
	signal counter_1K : integer range 0 to 9 := 0;
	signal counter_100 : integer range 0 to 9 := 0;
	signal counter_10 : integer range 0 to 9 := 0;
	signal counter_1 : integer range 0 to 9 := 0;
	
	signal i_clk_10K : std_logic := '0';
	
begin

	gen_clk : process(clk) begin
		if rising_edge(clk) then
			if counter_10K=4999 then
				counter_10K <= 0;
				i_clk_10K <= not(i_clk_10K);
			else
				counter_10K <= counter_10K + 1;
			end if;
		end if;
	end process;
	
	clk_10K <= i_clk_10K;
	
	gen_en : process(i_clk_10K)
	begin
		if rising_edge(i_clk_10K) then
			en_1K <= '0';
			en_100 <= '0';
			en_10 <= '0';
			en_1 <= '0';
			
			if counter_1K=9 then
				counter_1K <= 0;
				en_1K <= '1';
				if counter_100=9 then
					counter_100 <= 0;
					en_100 <= '1';
					if counter_10=9 then
						counter_10 <= 0;
						en_10 <= '1';
						if counter_1=9 then
							counter_1 <= 0;
							en_1 <= '1';
						else
							counter_1 <= counter_1 + 1;
						end if;
					else
						counter_10 <= counter_10 + 1;
					end if;
				else
					counter_100 <= counter_100 + 1;
				end if;
			else
				counter_1K <= counter_1K + 1;
			end if;
		end if;
	end process;
	
end Behavioral;

