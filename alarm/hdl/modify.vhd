----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Bo Zhou
-- 
-- 
-- Create Date: 23.06.2022 09:56:10
-- Design Name: 
-- Module Name: modify - Behavioral
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
--use ieee.numeric_std_unsigned.all;
--use ieee.std_logic_unsigned.all;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity modify is
    Port ( clk : in STD_LOGIC;
           fsm_alarm : in STD_LOGIC;
           key_enable : in STD_LOGIC;
           key_p_m : in STD_LOGIC;
           rst : in STD_LOGIC;
           ss : out STD_LOGIC_VECTOR (5 downto 0);
           mm : out STD_LOGIC_VECTOR (5 downto 0);
           hh : out STD_LOGIC_VECTOR (4 downto 0));
end modify;

architecture Behavioral of modify is
    signal mux_1: signed(11 downto 0) := "000000010000";
    signal mux_2: signed(11 downto 0) := (others => '0');
    signal sub_1, O_1: signed(11 downto 0);
    signal temp_1, temp_2: std_logic_vector (11 downto 0);
begin

process (clk, rst, key_enable, key_p_m, mux_1, mux_2, temp_2, O_1, fsm_alarm)
begin
if (clk = '1' and clk'EVENT) then
    if (rst = '1') then
        mux_1 <= "000000010000";
        mux_2 <= "000000000000";
    elsif (fsm_alarm='1') then
    if (O_1 = "010110011111") and (key_enable = '1') and (key_p_m = '1') then
        mux_1 <= (others => '0'); --if hh> 23:59, -> 00:00
        mux_2 <= (others => '0');
    elsif (O_1 = "000000000000") and (key_enable = '1') and (key_p_m = '0') then
        mux_1 <= "010110011111"; -- 23:59
        mux_2 <= (others => '0');
    elsif (key_enable = '1') and (key_p_m = '1') then
        mux_1 <= mux_1 + 1;
    elsif (key_enable = '1') and (key_p_m = '0') then
        mux_2 <= mux_2 + 1;
    end if;
    end if;
end if;

end process;

--subtrahend: 00:16 + (plus time)
O_1 <= mux_1 - mux_2;

ss <= "000000";
temp_1 <= std_logic_vector (O_1 mod 60);
mm <= temp_1 (5 downto 0);
temp_2 <= std_logic_vector ((O_1 - (O_1 mod 60))/60);
hh <= temp_2 (4 downto 0);

end Behavioral;
