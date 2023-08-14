----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Bo Zhou
-- 
-- Create Date: 25.06.2022 08:15:13
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

entity active is
    Port ( clk : in STD_LOGIC;
           I_ring : in STD_LOGIC;
           fsm_alarm : in STD_LOGIC;
           action_imp : in STD_LOGIC;
           rst : in STD_LOGIC;
           O_act : out STD_LOGIC;
           lcd_act : out STD_LOGIC);
end active;

architecture Behavioral of active is
    signal reg_1: std_logic := '0';
begin
process (clk, fsm_alarm, reg_1, action_imp, I_ring, rst)
begin
    if (clk = '1' and clk'EVENT) then
        if (rst='0')then
            if (fsm_alarm='1') and (((not I_ring) and action_imp )='1')then
                reg_1 <= not reg_1;
            else
                reg_1 <= reg_1;
            end if;
        else
            reg_1 <= '0';
        end if;
    end if;
end process;
O_act <= reg_1;
lcd_act <= reg_1;
end Behavioral;
