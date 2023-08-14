----------------------------------------------------------------------------------
-- Company: TUM
-- Engineer: Yinjia Wang
-- 
-- Create Date: 2022/07/11 17:28:07
-- Design Name: Global FSM test bench
-- Module Name: GlobalFSM_tb - Behavioral
-- Project Name: Project Labprojectory IC design
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.std_logic_signed.all;
use IEEE.std_logic_unsigned.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_GlobalFSM is
--  Port ( );
end tb_GlobalFSM;

architecture Behavioral of tb_GlobalFSM is
component GlobalFSM is 
port(    -- Inputs  
           clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           key_mode_imp : in STD_LOGIC;
           key_action_imp : in STD_LOGIC;
           key_plus_imp : in STD_LOGIC;
           key_minus_imp : in STD_LOGIC;
           fsm_time_start : out STD_LOGIC;
         -- Outputs
           fsm_date_start : out STD_LOGIC;
           fsm_alarm_start : out STD_LOGIC;
           fsm_switch_on_start : out STD_LOGIC;
           fsm_switch_off_start : out STD_LOGIC;
           fsm_count_down_start : out STD_LOGIC;
           fsm_stop_watch_start : out STD_LOGIC);
end component;

signal clk_period : time := 100us;
signal clk_1Hz_period :time := 1sec;
--Inputs and Outputs
signal  clk, EN_1, reset, key_mode_imp, key_action_imp, key_plus_imp, key_minus_imp : std_logic := '0';
signal time_display, date_display, alarm_clock, switch_on, switch_off, count_down,stop_watch : std_logic := '0';

 
begin

uut : GlobalFSM port map( clk => clk,
                         reset => reset,
                         key_mode_imp => key_mode_imp,
                         key_action_imp => key_action_imp,
                         key_plus_imp => key_plus_imp,
                         key_minus_imp => key_minus_imp,
                         
                         fsm_time_start => time_display,
                         fsm_date_start => date_display,
                         fsm_alarm_start => alarm_clock,
                         fsm_switch_on_start => switch_on,
                         fsm_switch_off_start => switch_off,
                         fsm_count_down_start => count_down,
                         fsm_stop_watch_start => stop_watch);
                         
clk_gen : process 
begin
    wait for clk_period/2;
    clk <= not clk;
end process;

stim_proc : process
begin


    
    wait for clk_period;
    
    -- case 1 time display -> date_display -> time alarm_clock (Pass)
    wait for clk_period;
    key_mode_imp <= '1';
    wait for clk_period;
    key_mode_imp <= '0';
    wait for 4 sec;


    -- Case 2 : alarm_clock (Pass)
    
    key_mode_imp <= '1';
    wait for clk_period;
    key_mode_imp <= '0';
    wait for clk_period;
    key_mode_imp <= '1';
    wait for clk_period;
    key_mode_imp <= '0';
    wait for 5*clk_period;
    key_action_imp <= '1';
    wait for clk_period;
    key_action_imp <= '0';
    wait for 5*clk_period;
    key_mode_imp <= '1';
    wait for clk_period;
    key_mode_imp <= '0';
    wait for 10*clk_period;


    --Case 3: time switch on : Errors 
    key_mode_imp <= '1';
    wait for clk_period;
    key_mode_imp <= '0';
    wait for clk_period;
    key_mode_imp <= '1';
    wait for clk_period;
    key_mode_imp <= '0';
    wait for clk_period;
    key_mode_imp <= '1';
    wait for clk_period;
    key_mode_imp <= '0';
    wait for 3*clk_period; -- time switch on state 
    key_action_imp <= '1';
    wait for clk_period;
    key_action_imp <= '0';
    wait for 3*clk_period;-- wait_switch_on, allowed to modify the time of switch on
    key_mode_imp <= '1';
    wait for clk_period/2;
    key_mode_imp <= '0';
    wait for 3*clk_period; -- enter the time switch off S4.2
    key_action_imp <= '1';
    wait for clk_period;
    key_action_imp <= '0';
    wait for 3*clk_period; --wait_switch_off, allowed to modify the time of switch off
    key_mode_imp <= '1';
    wait for clk_period;
    key_mode_imp <= '0';
    wait for 10*clk_period; -- time display


    --Case 4 : time switch off; Pass
    key_mode_imp <= '1';
    wait for clk_period;
    key_mode_imp <= '0';
    wait for clk_period;
    key_mode_imp <= '1';
    wait for clk_period;
    key_mode_imp <= '0';
    wait for clk_period;
    key_mode_imp <= '1';
    wait for clk_period;
    key_mode_imp <= '0';
    wait for clk_period;
    key_mode_imp <= '1';
    wait for clk_period;
    key_mode_imp <= '0';
    wait for 3*clk_period;-- enter the time switch off state 
    key_action_imp <= '1';
    wait for clk_period;
    key_action_imp <= '0';
    wait for 3*clk_period;-- wait switch off
    key_mode_imp <= '1';
    wait for clk_period;
    key_mode_imp <= '0';
      wait for 10*clk_period;


    -- Case 5 : count down timer: PASS
    key_mode_imp <= '1';
    wait for clk_period;
    key_mode_imp <= '0';
    wait for clk_period;
    key_mode_imp <= '1';
    wait for clk_period;
    key_mode_imp <= '0';
    wait for clk_period;
    key_mode_imp <= '1';
    wait for clk_period;
    key_mode_imp <= '0';
    wait for clk_period;
    key_mode_imp <= '1';
    wait for clk_period;
    key_mode_imp <= '0';
    wait for clk_period;
    key_mode_imp <= '1';
    wait for clk_period;
    key_mode_imp <= '0';
    wait for 4*clk_period;
    key_mode_imp <= '1';
    wait for clk_period;
    key_mode_imp <= '0';
    wait for 10*clk_period;
    
    
    -- Case 6 : Stop watch PASS
    wait for clk_period;
    key_plus_imp <= '1';
    wait for clk_period;
    key_plus_imp <= '0';
    wait for 5*clk_period;
    key_mode_imp <= '1';
    wait for clk_period;
    key_mode_imp <= '0';
    wait for 10*clk_period;
    
    
    
    wait;
end process;

end Behavioral;
