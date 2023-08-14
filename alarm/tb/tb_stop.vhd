----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.06.2022 16:18:48
-- Design Name: 
-- Module Name: tb_stop - Behavioral
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

entity tb_stop is
--  Port ( );
end tb_stop;

architecture Behavioral of tb_stop is
    component stop_ringing
        Port ( I_ring : in STD_LOGIC;
           clk : in STD_LOGIC;
           O_stop : out STD_LOGIC);
    end component;
    
    signal clk, I_ring: std_logic := '0';
    signal O_stop: std_logic;
    constant clk_period: time := 100 ns;
begin
    uut: stop_ringing port map (clk=>clk, I_ring=>I_ring, O_stop=>O_stop);
    clock: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process clock;
    process
    begin 
    --wait for 100 ns;
    I_ring <= '1';
    wait for 1000 ns;
    I_ring <= '0';
    wait for 1000 ns;
    I_ring <= '1';
    wait;
    end process;

end Behavioral;
