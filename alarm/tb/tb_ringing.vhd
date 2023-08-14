----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.06.2022 11:06:06
-- Design Name: 
-- Module Name: tb_ringing - Behavioral
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

entity tb_ringing is
--  Port ( );
end tb_ringing;

architecture Behavioral of tb_ringing is
    component ringing
        Port ( ss_alarm : in STD_LOGIC_VECTOR (5 downto 0);
           mm_alarm : in STD_LOGIC_VECTOR (5 downto 0);
           hh_alarm : in STD_LOGIC_VECTOR (4 downto 0);
           ss_current : in STD_LOGIC_VECTOR (5 downto 0);
           mm_current : in STD_LOGIC_VECTOR (5 downto 0);
           hh_current : in STD_LOGIC_VECTOR (4 downto 0);
           clk : in STD_LOGIC;
           I_act : in STD_LOGIC;
           snooze_1min : in STD_LOGIC;
           action_stop : in STD_LOGIC;
           action_long : in STD_LOGIC;
           action_imp : in STD_LOGIC;
           O_ring : out STD_LOGIC;
           O_snooze : out STD_LOGIC);
    end component;
    
    signal clk, I_act, snooze_1min, action_stop, action_long, action_imp: std_logic := '0';
    signal ss_alarm, ss_current : STD_LOGIC_VECTOR (5 downto 0) := (others => '0');
    signal mm_alarm, mm_current : STD_LOGIC_VECTOR (5 downto 0) := (others => '0');
    signal hh_alarm, hh_current : STD_LOGIC_VECTOR (4 downto 0) := (others => '0');
    signal O_ring, O_snooze : std_logic;
    constant clk_period: time := 10 ns;
begin
    uut: ringing port map ( ss_alarm=>ss_alarm, ss_current=>ss_current, mm_alarm=>mm_alarm, mm_current=>mm_current, 
                            hh_alarm=>hh_alarm, hh_current=>hh_current, clk=>clk, I_act=>I_act, snooze_1min=>snooze_1min, 
                            action_stop=>action_stop, action_long=>action_long, action_imp=>action_imp, O_ring=>O_ring, O_snooze=>O_snooze);
    clock: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process clock;
    process
    begin 
    wait for 100 ns;
    I_act <= '1';
    wait for 100ns;
    ss_alarm <= (others => '1');
    wait for 200 ns;
    action_imp <= '1';
    wait for 10 ns;
    action_imp <= '0';
    wait for 200 ns;
    action_imp <= '1';
    wait for 10 ns;
    action_imp <= '0';
    wait for 100 ns;
    action_stop <= '1';
    wait for 10 ns;
    action_stop <= '0';
    wait for 100 ns;
    snooze_1min <= '1';
    wait for 10 ns;
    snooze_1min <= '0';
    wait for 100 ns;
    action_stop <= '1';
    wait for 100 ns;
    action_stop <= '0';
    wait;
    end process;

end Behavioral;
