----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Bo Zhou
-- 
-- 
-- Create Date: 25.06.2022 19:24:37
-- Design Name: 
-- Module Name: snooze - Behavioral
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

entity snooze is
    Port ( clk : in STD_LOGIC;
           I_snooze : in STD_LOGIC;
           I_active : in STD_LOGIC;
           O_active : out STD_LOGIC;
           O_snooze : out STD_LOGIC;
           O_1min :  out STD_LOGIC);
end snooze;

architecture Behavioral of snooze is
    signal enable, reg_2 : std_logic := '0';
begin
process (clk, enable, reg_2, I_snooze)
    variable cnt: integer range 0 to 579896;
    variable cnt_1: integer range 0 to 2499;
begin
    if (clk = '1' and clk'EVENT) then
        if (I_active='1') then
            if (I_snooze='1') then
                enable <= '1';
            --else
            --    enable <= '0';
            end if;
            if (enable <= '0') then
                cnt := 0;
                O_1min <= '0';
                --reg_1 <= '0';
            elsif (enable='1') and (cnt=579896) then
                cnt := 0;
                enable <= '0';
                O_1min <= '1';
                --reg_1 <= '0';
            else
                cnt := cnt + 1;
                O_1min <= '0';
                --reg_1 <= '1';
            end if;
            if (enable='0') then
                cnt_1 := 0;
            elsif (cnt_1=2499) then
                reg_2 <= not reg_2;
                cnt_1 := 0;
            else
                cnt_1 := cnt_1 +1;
            end if;
        else
            enable <= '0';
            cnt_1 := 0;
            reg_2 <= '0';
        end if;   
    end if;
end process;
O_snooze <= enable;
O_active <= reg_2;
end Behavioral;
