----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Bo Zhou
-- 
-- Create Date: 25.06.2022 21:41:50
-- Design Name: 
-- Module Name: tb_top - Behavioral
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

entity tb_alarm is
--  Port ( );
end tb_alarm;

architecture Behavioral of tb_alarm is
    component alarm
        Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           key_action_imp : in STD_LOGIC;
           key_action_long : in STD_LOGIC;
           key_plus_minus : in STD_LOGIC;
           key_enable : in STD_LOGIC;
           fsm_alarm_start : in STD_LOGIC;
           second : in STD_LOGIC_VECTOR (6 downto 0);
           minute : in STD_LOGIC_VECTOR (6 downto 0);
           hour : in STD_LOGIC_VECTOR (6 downto 0);
           led_alarm_act : out STD_LOGIC;
           led_alarm_ring : out STD_LOGIC;
           lcd_alarm_act : out STD_LOGIC;
           lcd_alarm_snooze : out STD_LOGIC;
           --lcd_alarm_ss : out STD_LOGIC_VECTOR (5 downto 0);
           lcd_alarm_mm : out STD_LOGIC_VECTOR (6 downto 0);
           lcd_alarm_hh : out STD_LOGIC_VECTOR (6 downto 0));
           --lcd_alarm_data : out STD_LOGIC_VECTOR (13 downto 0));
    end component;
    
    signal clk, reset, key_action_imp, key_action_long, key_plus_minus, key_enable, fsm_alarm_start: std_logic := '0';
    signal second : STD_LOGIC_VECTOR (6 downto 0) := (others => '0');
    signal minute : STD_LOGIC_VECTOR (6 downto 0) := "0010000";
    signal hour : STD_LOGIC_VECTOR (6 downto 0) := (others => '0');
    signal led_alarm_act, led_alarm_ring, lcd_alarm_act, lcd_alarm_snooze: std_logic;
    --signal ss : STD_LOGIC_VECTOR (5 downto 0);
    signal mm : STD_LOGIC_VECTOR (6 downto 0);
    signal hh : STD_LOGIC_VECTOR (6 downto 0);
    --signal data : STD_LOGIC_VECTOR (13 downto 0);
    constant clk_period: time := 100 ns;

begin
    uut: alarm port map (clk=>clk, reset=>reset, key_action_imp=>key_action_imp, key_action_long=>key_action_long, key_plus_minus=>key_plus_minus, 
                       key_enable=>key_enable, fsm_alarm_start=>fsm_alarm_start, second=>second, minute=>minute, hour=>hour, led_alarm_act=>led_alarm_act,
                       led_alarm_ring=>led_alarm_ring, lcd_alarm_act=>lcd_alarm_act, lcd_alarm_snooze=>lcd_alarm_snooze, lcd_alarm_mm=>mm, lcd_alarm_hh=>hh);
    clock: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process clock;
    process
    begin 
    
      --case1: Press reset -> The alarm mode is deactivated and the alarm time is reset to 00:16
        wait for 100 ns;
        fsm_alarm_start <= '1';
        key_action_imp <= '1'; wait for 100 ns; key_action_imp <= '0';
        wait for 100 ns;
        key_enable <= '1'; wait for 100 ns; key_enable <= '0';
        wait for 100 ns; reset <= '1'; wait for 100 ns; reset <= '0'; 
        
      --case2: Not in the alarm mode -> Action key and +/- key do not work for alarm module
        wait for 1 ms;
        fsm_alarm_start <= '0';  
        wait for 100 ns;
        key_action_imp <= '1'; wait for 100 ns; key_action_imp <= '0';
        wait for 100 ns;
        key_enable <= '1';
        key_plus_minus <= '0';
        wait for 100 ns;
        key_enable <= '0';
        
      --case3: In the alarm mode, press Action key -> Toggle between in-/action state
        wait for 1 ms;
        fsm_alarm_start <= '1';
        wait for 100 ns;
        key_action_imp <= '1'; wait for 100 ns; key_action_imp <= '0';
        wait for 100 ns;
        key_action_imp <= '1'; wait for 100 ns; key_action_imp <= '0';

      --case4: Press +/- key -> Modify the alarm time (23:59->00:00; 00:00->23:59)
        wait for 1 ms;
        key_enable <= '1'; wait for 100 ns; key_enable <= '0';
        wait for 100 ns;
        key_enable <= '1'; wait for 100 ns; key_enable <= '0';
        wait for 100 ns;
        key_enable <= '1'; wait for 100 ns; key_enable <= '0';
        wait for 100 ns;
        key_plus_minus <= '1';
        key_enable <= '1'; wait for 100 ns; key_enable <= '0';
        wait for 100 ns;
        key_enable <= '1'; wait for 100 ns; key_enable <= '0';
        wait for 100 ns;
        key_enable <= '1'; wait for 100 ns; key_enable <= '0';
        wait for 100 ns;
        key_enable <= '1'; wait for 100 ns; key_enable <= '0';
        wait for 100 ns;
        key_enable <= '1'; wait for 100 ns; key_enable <= '0';
        
      --case5: In the active state, the alarm time is reached -> Ringing 
        wait for 1 ms;
        key_enable <= '1'; wait for 100 ns; key_enable <= '0';
        wait for 100 ns;
        fsm_alarm_start <= '0';
        wait for 400 ns;
        fsm_alarm_start <= '1';
        wait for 100 ns;
        key_enable <= '1'; wait for 100 ns; key_enable <= '0';
        
      --case6: Long press Action key -> Ringing stops
        wait for 1 ms; key_action_imp <= '1'; wait for 100 ns; key_action_imp <= '0';
        wait for 2 ms; key_action_long <= '1'; wait for 100 ns; key_action_long <= '0';
        
      --case7: Not press Action key for one minute -> Ringing stops
        wait for 1 ms;
        key_plus_minus <= '0';
        key_enable <= '1'; wait for 100 ns; key_enable <= '0';
        wait for 100 ns;
        key_enable <= '1'; wait for 100 ns; key_enable <= '0';
        wait for 100 ns;
        key_enable <= '1'; wait for 100 ns; key_enable <= '0';
        wait for 100 ns;
        key_enable <= '1'; wait for 100 ns; key_enable <= '0';
        wait for 100 ns;
        key_enable <= '1'; wait for 100 ns; key_enable <= '0';
        wait for 10 ms;
        fsm_alarm_start <= '0';
        wait for 10 ms;
        fsm_alarm_start <= '1';
        
      --case8: Press Action key for less than 2 second -> Snooze state 
        wait for 41 ms;
        key_plus_minus <= '1';
        key_enable <= '1'; wait for 100 ns; key_enable <= '0';
        wait for 100 ns;
        key_enable <= '1'; wait for 100 ns; key_enable <= '0';
        wait for 200 us;
        key_action_imp <= '1'; wait for 100 ns; key_action_imp <= '0';
        wait for 10 us;
        fsm_alarm_start <= '0';
        wait for 60 us;
        key_action_imp <= '1'; wait for 100 ns; key_action_imp <= '0';
        wait for 2 us;
        key_plus_minus <= '1';
        
        
        wait;
    end process;
    
end Behavioral;
