----------------------------------------------------------------------------------
-- Company: 
-- Engineer:
-- 
-- 
-- Create Date: 05.07.2022 10:42:12
-- Design Name: 
-- Module Name: led - Behavioral
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

entity led is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           active : in STD_LOGIC;
           ss_on : in STD_LOGIC_VECTOR (5 downto 0);
           mm_on : in STD_LOGIC_VECTOR (5 downto 0);
           hh_on : in STD_LOGIC_VECTOR (4 downto 0);
           ss_off : in STD_LOGIC_VECTOR (5 downto 0);
           mm_off : in STD_LOGIC_VECTOR (5 downto 0);
           hh_off : in STD_LOGIC_VECTOR (4 downto 0);
           ss : in STD_LOGIC_VECTOR (5 downto 0);
           mm : in STD_LOGIC_VECTOR (5 downto 0);
           hh : in STD_LOGIC_VECTOR (4 downto 0);
           led : out STD_LOGIC);
end led;

architecture Behavioral of led is
    signal reg : STD_LOGIC := '0';
begin
process (clk, rst)
begin
    if (clk = '1' and clk'EVENT) then
        if (rst='1') then
            reg <= '0';
        else
            if (active='1') then
                if ((ss_on=ss) and (mm_on=mm) and (hh_on=hh)) then
                    reg <= '1';
                end if;
                if ((ss_off=ss) and (mm_off=mm) and (hh_off=hh)) then
                    reg <= '0';
                end if;
            end if;
        end if;
     end if;
     
end process;  
led <= reg;
end Behavioral;
