----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 06/22/2022 11:54:10 AM
-- Design Name:
-- Module Name: counter_controller - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY countdown IS
	PORT (
		clk : IN STD_LOGIC;
		fsm_countdown_start : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		led_countdown_act : OUT STD_LOGIC;
	    lcd_countdown_act : OUT STD_LOGIC;
	    led_countdown_ring : OUT std_logic ;
		ss : OUT STD_LOGIC_vector(6 DOWNTO 0);
		mm : OUT STD_LOGIC_vector(6 DOWNTO 0);
		hh : OUT STD_LOGIC_vector(6 DOWNTO 0) 
	);
END countdown;

ARCHITECTURE Behavioral OF countdown IS

BEGIN
	PROCESS (clk)
	BEGIN
		IF (clk = '1' AND clk'event) THEN
			IF reset = '1' THEN
				ss <= "0011110";
				mm <= "0000111";
				hh <= "0000000";
				led_countdown_act <= '0';
				lcd_countdown_act <= '0';
				led_countdown_ring <= '0';

			ELSE
				IF fsm_countdown_start = '1' THEN
					ss <= "0011110";
					mm <= "0000111";
					hh <= "0000000";
					
 
				END IF;
			END IF;
		END IF;
	END PROCESS;

END Behavioral;
