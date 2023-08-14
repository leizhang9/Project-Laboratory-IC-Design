----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.06.2022 20:24:37
-- Design Name: 
-- Module Name: tb_snooze - Behavioral
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

entity tb_snooze is
--  Port ( );
end tb_snooze;

architecture Behavioral of tb_snooze is
    component snooze
        Port ( clk : in STD_LOGIC;
           I_snooze : in STD_LOGIC;
           O_active : out STD_LOGIC;
           O_snooze : out STD_LOGIC;
           O_1min :  out STD_LOGIC);
    end component;
    
    signal clk, I_snooze: std_logic := '0';
    signal O_active, O_snooze, O_1min: std_logic;
    constant clk_period: time := 100 ns;
begin
    uut: snooze port map (clk=>clk, I_snooze=>I_snooze, O_active=>O_active, O_snooze=>O_snooze, O_1min=>O_1min);
    clock: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process clock;
    process
    begin 
        wait for 200 ns;
        I_snooze <= '1';
        wait for 100 ns;
        I_snooze <= '0';
        wait;
    end process;
end Behavioral;
