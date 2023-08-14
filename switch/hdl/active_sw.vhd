----------------------------------------------------------------------------------
-- Company: 
-- Engineer:
-- 
-- 
-- Create Date: 05.07.2022 09:04:15
-- Design Name: 
-- Module Name: active - Behavioral
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

entity active_sw is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           switch_on : in STD_LOGIC;
           switch_off : in STD_LOGIC;
           act_imp : in STD_LOGIC;
           switch_act : out STD_LOGIC);
end active_sw;

architecture Behavioral of active_sw is
    signal reg_1: std_logic := '0';
begin
process (clk, rst, switch_on, switch_off, reg_1)
begin
    if (clk = '1' and clk'EVENT) then
        if (rst='1') then
            reg_1 <= '0';
        else
            if (switch_on='1') or (switch_off='1') then
                if (act_imp='1') then
                    reg_1 <= not reg_1;
                else
                    reg_1 <= reg_1;
                end if;
            end if;
        end if;
    end if;
end process;
switch_act <= reg_1;
end Behavioral;
