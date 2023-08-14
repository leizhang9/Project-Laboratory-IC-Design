----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.06.2022 09:14:27
-- Design Name: 
-- Module Name: tb_active - Behavioral
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

entity tb_active is
--  Port ( );
end tb_active;

architecture Behavioral of tb_active is
    component active
        Port ( clk : in STD_LOGIC;
           I_ring : in STD_LOGIC;
           fsm_alarm : in STD_LOGIC;
           action_imp : in STD_LOGIC;
           rst : in STD_LOGIC;
           O_act : out STD_LOGIC);
    end component;
    
    signal rst, clk, fsm_alarm, action_imp, I_ring: std_logic := '0';
    signal O_act: std_logic;
    constant clk_period: time := 10 ns;
begin
    uut: active port map (rst=>rst, clk=>clk, fsm_alarm =>fsm_alarm, action_imp=>action_imp, I_ring=>I_ring, O_act=>O_act);
    clock: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process clock;
    process
    begin
        wait for 100ns;
        fsm_alarm <= '1';
        action_imp <= '1';
        wait for 10 ns;
        action_imp <= '0';
        wait for 100ns;
        action_imp <= '1';
        wait for 10 ns;
        action_imp <= '0';
        wait for 100ns;
        action_imp <= '1';
        wait for 10 ns;
        action_imp <= '0';
        wait for 100ns;
        rst <= '1';
        wait for 10 ns;
        rst <= '0';
        wait for 100ns;
        action_imp <= '1';
        wait for 10 ns;
        action_imp <= '0';
        wait for 200 ns;
        I_ring <= '1';
        action_imp <= '1';
        wait for 10 ns;
        action_imp <= '0';
        wait for 200 ns;
        I_ring <= '0';
        action_imp <= '1';
        wait for 10 ns;
        action_imp <= '0';
        wait for 200 ns;
        I_ring <= '0';
        rst <= '1';
        wait for 10 ns;
        rst <= '0';
        wait;
    end process;
end Behavioral;
