----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Bo Zhou
-- 
-- 
-- Create Date: 25.06.2022 14:24:02
-- Design Name: 
-- Module Name: stop_ringing - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity stop_ringing is
    Port ( I_ring : in STD_LOGIC;
           clk : in STD_LOGIC;
           O_stop : out STD_LOGIC);
end stop_ringing;

architecture Behavioral of stop_ringing is
    signal reg_1: std_logic := '0';
begin
process (clk, I_ring)
    variable cnt: integer range 0 to 599998;
begin
    if (clk = '1' and clk'EVENT) then
        if (I_ring='0') then
            cnt := 0; 
            reg_1 <= '0';           
        elsif (I_ring='1') and (cnt=599998) then
            cnt := 0;
            reg_1 <= '1';
        else
            cnt := cnt + 1;
            reg_1 <= '0';
        end if;
    end if;
end process;
O_stop <= reg_1;

end Behavioral;
