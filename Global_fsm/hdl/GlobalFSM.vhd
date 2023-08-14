----------------------------------------------------------------------------------
 
-- 
-- Create Date: 06.07.2022 17:25:55
-- Design Name:  Global FSM
-- Module Name: GlobalFSM - Behavioral
-- Project Name: Lab IC design
-- Name : Yinjia Wang

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

entity GlobalFSM is
    generic ( wait_3sec : integer := 30000);
    Port ( clk : in STD_LOGIC;
--           EN_1: in STD_LOGIC;
           reset : in STD_LOGIC;
           key_mode_imp : in STD_LOGIC;
           key_action_imp : in STD_LOGIC;
           key_plus_imp : in STD_LOGIC;
           key_minus_imp : in STD_LOGIC;
           fsm_time_start : out STD_LOGIC;
           fsm_date_start : out STD_LOGIC;
           fsm_alarm_start : out STD_LOGIC;
           fsm_switch_on_start : out STD_LOGIC;
           fsm_switch_off_start : out STD_LOGIC;
           fsm_count_down_start : out STD_LOGIC;
           fsm_stop_watch_start : out STD_LOGIC);
end GlobalFSM;

architecture Behavioral of GlobalFSM is
TYPE state IS (time_display, date_display, alarm, switch_on, switch_off,
               switch_off_2, countdown, stopwatch,
               wait_alarm,wait_switch_on,wait_switch_off);
signal reg_state, nx_state : state;

signal t : unsigned(15 downto 0) := (others => '0');
-- signals for removing the glitch 
signal n_fsm_time_start, 
       n_fsm_alarm_start, 
       n_fsm_date_start, 
       n_fsm_switch_on_start , 
       n_fsm_switch_off_start,
       n_fsm_stop_watch_start, 
       n_fsm_count_down_start, 
       n_fsm_alarm_wait ,
       n_fsm_switch_on_wait,
       n_fsm_switch_off_wait : std_logic;
begin

   -- Timer 
   timer : process(clk,reset)
   begin
     
     if clk'EVENT and clk= '1' then
         if reset ='0' then
           if reg_state /= nx_state then
               t <= (others => '0');
           elsif reg_state = date_display then
               t <= t + 1;
          end if;
         else
            t <= (others => '0');
         end if;      
     end if;
   end process timer;
   
--   -- Timer 1Hz
--   timer : process(EN_1,reset)
--   begin
--     if reset = '1' then 
--         t <= "000000";
--     elsif EN_1'EVENT and EN_1= '1' then
--         if reg_state /= nx_state then
--             t <= "000000";
--         elsif reg_state = date_display then
--             t <= t + "000001";
--         end if;      
--     end if;
--   end process timer;
-- This is combinational of the sequential design, 
-- which contains the logic for next-state
-- include all signals and input in sensitive-list except state_next
   state_logic : process (key_mode_imp, key_action_imp,key_plus_imp, key_minus_imp, reg_state,t)
   begin
      CASE reg_state IS 
         --- function 1 : time display 
         WHEN time_display => 
             if key_mode_imp = '1' then
                nx_state <= date_display;
             elsif key_minus_imp = '1' then 
                nx_state <= stopwatch;
             elsif key_plus_imp = '1' then 
                nx_state <= stopwatch;
             else
                nx_state <= time_display;
             end if;   
         ---- function 2 : date display
         WHEN date_display =>    
             -- "000011" stands for 3 seconds 
             if (key_mode_imp = '1') and (t < wait_3sec) then
                 nx_state <= alarm;
             elsif t = wait_3sec - 1 then
                 nx_state <= time_display;
             else 
                 nx_state <= date_display;
             end if;
         --- Function 3 : alarm clock
         -- Wait state is used for modifing the alarm's time
         when alarm => 
             if key_action_imp = '1'then
                 nx_state <= wait_alarm;
             elsif key_plus_imp = '1' then
                 nx_state <= wait_alarm;
             elsif key_minus_imp = '1' then
                 nx_state <= wait_alarm;
             elsif key_mode_imp = '1' then 
                 nx_state <= switch_on;
             else 
                 nx_state <= alarm;
             end if;
         when wait_alarm=> 
             if key_mode_imp = '1' then
                 nx_state <= time_display;
             else
                 nx_state <= wait_alarm;
             end if;
         --- Function 4 : time switch -- 'on' module
         when switch_on=> 
             if key_action_imp = '1' then
                 nx_state <= wait_switch_on;
             elsif key_mode_imp = '1' then
                 nx_state <= switch_off;
             else 
                 nx_state <= switch_on;
             end if;
         when wait_switch_on=> 
             if key_mode_imp = '1' then 
                 nx_state <= switch_off_2;
             else 
                 nx_state <= wait_switch_on;
             end if;
         ---Function 4: time switch -- 'off' module
         -- switch off: time disp -> 4 key mode imp -> switch_off
         -- switch_off_2: after modify the switch on -> key mode-> switch_off_2
         when switch_off=> 
             if key_action_imp = '1' then 
                 nx_state <= wait_switch_off;
             elsif key_mode_imp = '1' then
                 nx_state <= countdown; 
             else 
                 nx_state <= switch_off;
             end if;
         when switch_off_2 => 
             if key_action_imp = '1' then 
                 nx_state <= wait_switch_off;
             elsif key_mode_imp = '1' then
                 nx_state <= time_display; 
             else
                 nx_state <= switch_off_2;
             end if;
         when wait_switch_off=> 
             if key_mode_imp = '1' then
                 nx_state <= time_display;
             else 
                 nx_state <= wait_switch_off;
             end if;
         -- Function 5 : Countdown timer
         when countdown=> 
             if key_mode_imp = '1' then
                 nx_state <= time_display;
             else 
                 nx_state <= countdown;
             end if;
         --- Function 6: stop watch
         when stopwatch=> 
             if key_mode_imp = '1' then 
                 nx_state <= time_display;
             else 
                 nx_state <= stopwatch;
             end if;
         -- default state
         when others => 
             nx_state <= time_display;
      end CASE;
   end process state_logic;

   -- combination output logic
   -- This part contains the output of the design
   -- no if-else statement is used in this part
   -- include all signals and input in sensitive-list except state_next
   output_logic : process (reg_state)
   begin 
       case reg_state is 
       when time_display => 
            n_fsm_time_start <= '1';
            n_fsm_alarm_start <= '0';
            n_fsm_date_start <= '0';
            n_fsm_switch_on_start <= '0';
            n_fsm_switch_off_start <= '0';
            n_fsm_stop_watch_start <= '0';
            n_fsm_count_down_start <= '0';
            n_fsm_alarm_wait <= '0';
            n_fsm_switch_on_wait <= '0';
            n_fsm_switch_off_wait <= '0';
       when date_display =>
            n_fsm_time_start <= '0';
            n_fsm_alarm_start <= '0';
            n_fsm_date_start <= '1';
            n_fsm_switch_on_start <= '0';
            n_fsm_switch_off_start <= '0';
            n_fsm_stop_watch_start <= '0';
            n_fsm_count_down_start <= '0';
            n_fsm_alarm_wait <= '0';
            n_fsm_switch_on_wait <= '0';
            n_fsm_switch_off_wait <= '0';
       when alarm => 
            n_fsm_time_start <= '0';
            n_fsm_alarm_start <= '1';
            n_fsm_date_start <= '0';
            n_fsm_switch_on_start <= '0';
            n_fsm_switch_off_start <= '0';
            n_fsm_stop_watch_start <= '0';
            n_fsm_count_down_start <= '0';
            n_fsm_alarm_wait <= '0';
            n_fsm_switch_on_wait <= '0';
            n_fsm_switch_off_wait <= '0';

       when wait_alarm =>
            n_fsm_time_start <= '0';
            n_fsm_alarm_start <= '1';
            n_fsm_date_start <= '0';
            n_fsm_switch_on_start <= '0';
            n_fsm_switch_off_start <= '0';
            n_fsm_stop_watch_start <= '0';
            n_fsm_count_down_start <= '0';
            n_fsm_alarm_wait <= '1';
            n_fsm_switch_on_wait <= '0';
            n_fsm_switch_off_wait <= '0';
 
       when switch_on => 
            n_fsm_time_start <= '0';
            n_fsm_alarm_start <= '0';
            n_fsm_date_start <= '0';
            n_fsm_switch_on_start <= '1';
            n_fsm_switch_off_start <= '0';
            n_fsm_stop_watch_start <= '0';
            n_fsm_count_down_start <= '0';
            n_fsm_alarm_wait <= '0';
            n_fsm_switch_on_wait <= '0';
            n_fsm_switch_off_wait <= '0';
 
       when wait_switch_on => 
            n_fsm_time_start <= '0';
            n_fsm_alarm_start <= '0';
            n_fsm_date_start <= '0';
            n_fsm_switch_on_start <= '1';
            n_fsm_switch_off_start <= '0';
            n_fsm_stop_watch_start <= '0';
            n_fsm_count_down_start <= '0';
            n_fsm_alarm_wait <= '0';
            n_fsm_switch_on_wait <= '1';
            n_fsm_switch_off_wait <= '0';

       when switch_off => 
            n_fsm_time_start <= '0';
            n_fsm_alarm_start <= '0';
            n_fsm_date_start <= '0';
            n_fsm_switch_on_start <= '0';
            n_fsm_switch_off_start <= '1';
            n_fsm_stop_watch_start <= '0';
            n_fsm_count_down_start <= '0';
            n_fsm_alarm_wait <= '0';
            n_fsm_switch_on_wait <= '0';
            n_fsm_switch_off_wait <= '0';
  
       when switch_off_2 => 
            n_fsm_time_start <= '0';
            n_fsm_alarm_start <= '0';
            n_fsm_date_start <= '0';
            n_fsm_switch_on_start <= '0';
            n_fsm_switch_off_start <= '1';
            n_fsm_stop_watch_start <= '0';
            n_fsm_count_down_start <= '0';
            n_fsm_alarm_wait <= '0';
            n_fsm_switch_on_wait <= '0';
            n_fsm_switch_off_wait <= '0';

       when wait_switch_off => 
            n_fsm_time_start <= '0';
            n_fsm_alarm_start <= '0';
            n_fsm_date_start <= '0';
            n_fsm_switch_on_start <= '0';
            n_fsm_switch_off_start <= '1';
            n_fsm_stop_watch_start <= '0';
            n_fsm_count_down_start <= '0';
            n_fsm_alarm_wait <= '0';
            n_fsm_switch_on_wait <= '0';
            n_fsm_switch_off_wait <= '1';
   
       when countdown => 
            n_fsm_time_start <= '0';
            n_fsm_alarm_start <= '0';
            n_fsm_date_start <= '0';
            n_fsm_switch_on_start <= '0';
            n_fsm_switch_off_start <= '0';
            n_fsm_stop_watch_start <= '0';
            n_fsm_count_down_start <= '1';
            n_fsm_alarm_wait <= '0';
            n_fsm_switch_on_wait <= '0';
            n_fsm_switch_off_wait <= '0';
  
       when stopwatch => 
            n_fsm_time_start <= '0';
            n_fsm_alarm_start <= '0';
            n_fsm_date_start <= '0';
            n_fsm_switch_on_start <= '0';
            n_fsm_switch_off_start <= '0';
            n_fsm_stop_watch_start <= '1';
            n_fsm_count_down_start <= '0';
            n_fsm_alarm_wait <= '0';
            n_fsm_switch_on_wait <= '0';
            n_fsm_switch_off_wait <= '0';
        when others => 
            n_fsm_time_start <= '1';
            n_fsm_alarm_start <= '0';
            n_fsm_date_start <= '0';
            n_fsm_switch_on_start <= '0';
            n_fsm_switch_off_start <= '0';
            n_fsm_stop_watch_start <= '0';
            n_fsm_count_down_start <= '0';
            n_fsm_alarm_wait <= '0';
            n_fsm_switch_on_wait <= '0';
            n_fsm_switch_off_wait <= '0';
 
       end case;
   end process output_logic;

   -- Reset funtionality
   -- This process contains the squential part and D-FF s are included.
   state_reset : process (clk, reset)
   begin 
     if clk'EVENT and clk = '1' then
       if reset = '1' then 
         reg_state <= time_display;
       else 
          reg_state <= nx_state;
       end if;
     end if;
   end process State_reset;
   
   -- here reset all the outputs, using D-FF to delete the gliches
   glitch_free : process (clk, reset)
   begin 
     if clk'EVENT and clk = '1' then
       if reset = '1' then 
         fsm_time_start <= '1';
         fsm_alarm_start <= '0';
         fsm_date_start <= '0';
         fsm_switch_on_start <= '0';
         fsm_switch_off_start <= '0';
         fsm_stop_watch_start <= '0';
         fsm_count_down_start <= '0';
         
       else 
         fsm_time_start <= n_fsm_time_start;
         fsm_alarm_start <= n_fsm_alarm_start;
         fsm_date_start <= n_fsm_date_start;
         fsm_switch_on_start <= n_fsm_switch_on_start;
         fsm_switch_off_start <= n_fsm_switch_off_start;
         fsm_stop_watch_start <= n_fsm_stop_watch_start;
         fsm_count_down_start <= n_fsm_count_down_start;
         
       end if;
     end if;
   end process glitch_free; 
  
end Behavioral;
