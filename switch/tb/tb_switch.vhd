----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.07.2022 16:20:04
-- Design Name: 
-- Module Name: tb_switch - Behavioral
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

entity tb_switch is
--  Port ( );
end tb_switch;

architecture Behavioral of tb_switch is
    component switch
        Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           key_action_imp : in STD_LOGIC;
           key_action_long : in STD_LOGIC;
           key_plus_minus : in STD_LOGIC;
           key_enable : in STD_LOGIC;
           fsm_switch_on : in STD_LOGIC;
           fsm_switch_off : in STD_LOGIC;
           second : in STD_LOGIC_VECTOR (6 downto 0);
           minute : in STD_LOGIC_VECTOR (6 downto 0);
           hour : in STD_LOGIC_VECTOR (6 downto 0);
           led_switch_act : out STD_LOGIC;
           lcd_switch_act : out STD_LOGIC;
           led_switch_on : out STD_LOGIC;
           lcd_switchon_ss : out STD_LOGIC_VECTOR (6 downto 0);
           lcd_switchon_mm : out STD_LOGIC_VECTOR (6 downto 0);
           lcd_switchon_hh : out STD_LOGIC_VECTOR (6 downto 0);
           lcd_switchoff_ss : out STD_LOGIC_VECTOR (6 downto 0);
           lcd_switchoff_mm : out STD_LOGIC_VECTOR (6 downto 0);
           lcd_switchoff_hh : out STD_LOGIC_VECTOR (6 downto 0));
           --lcd_switchon_data : out STD_LOGIC_VECTOR (20 downto 0);
           --lcd_switchoff_data : out STD_LOGIC_VECTOR (20 downto 0));
    end component;
    
    signal clk, reset, key_action_imp, key_action_long, key_plus_minus, key_enable, fsm_switch_on, fsm_switch_off: std_logic := '0';
    signal second : STD_LOGIC_VECTOR (6 downto 0) := (others => '0');
    signal minute : STD_LOGIC_VECTOR (6 downto 0) := (others => '0');
    signal hour : STD_LOGIC_VECTOR (6 downto 0) := (others => '0');
    signal led_switch_act, led_switch_on, lcd_switch_act : std_logic;
    signal on_ss, off_ss, on_mm, off_mm, on_hh, off_hh : STD_LOGIC_VECTOR (6 downto 0);
    constant clk_period: time := 100 ns;
begin
    uut: switch port map (clk=>clk, reset=>reset, key_action_imp=>key_action_imp, key_action_long=>key_action_long, key_plus_minus=>key_plus_minus, 
                       key_enable=>key_enable, fsm_switch_on=>fsm_switch_on, fsm_switch_off=>fsm_switch_off, second=>second, minute=>minute, hour=>hour, led_switch_act=>led_switch_act,
                       led_switch_on=>led_switch_on, lcd_switch_act=>lcd_switch_act, lcd_switchon_ss=>on_ss, lcd_switchoff_ss=>off_ss
                       , lcd_switchon_mm=>on_mm, lcd_switchoff_mm=>off_mm, lcd_switchon_hh=>on_hh, lcd_switchoff_hh=>off_hh);
    clock: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process clock;
    process
    begin
        --case 1 and 3
        wait for 100 ns;
        fsm_switch_on <= '1';
        key_action_imp <= '1'; wait for 100 ns; key_action_imp <= '0'; fsm_switch_on <= '0';
        wait for 100 ns;
        fsm_switch_off <= '1';
        key_action_imp <= '1'; wait for 100 ns; key_action_imp <= '0'; fsm_switch_off <= '0';
        wait for 100 ns;
        fsm_switch_on <= '1';
        key_action_imp <= '1'; wait for 100 ns; key_action_imp <= '0'; fsm_switch_on <= '0';
        wait for 100 ns;
        reset <= '1';
        wait for 100 ns;
        reset <= '0'; 
        --case 2
        wait for 100 ns;
        key_action_imp <= '1'; wait for 100 ns; key_action_imp <= '0';
        wait for 100 ns;
        key_enable <= '1';
        key_plus_minus <= '0';
        --case 4 and 5       

        fsm_switch_on <= '1';
        wait for 100 ns;
        key_action_imp <= '1'; wait for 100 ns; key_action_imp <= '0';
        wait for 500 ns;
        --key_plus_minus <= '1';
        wait for 500 ns;
        key_plus_minus <= '1';
        wait for 500 ns;
        fsm_switch_on <= '0';
        fsm_switch_off <= '1';
        wait for 500 ns;
        reset <= '1';
        key_plus_minus <= '0';
        wait for 100 ns;
        reset <= '0';
        wait for 500 ns;
        key_enable <= '0';
        minute <= "0001001";
        --case 6
        
        wait;
    end process;
end Behavioral;
