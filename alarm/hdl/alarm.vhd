----------------------------------------------------------------------------------
-- Company: TUM
-- Engineer: Bo Zhou
-- 
-- Create Date: 25.06.2022 20:55:01
-- Module Name: alarm - Behavioral
-- Project Name: Project IC design

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

entity alarm is
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
           --lcd_time_data : in STD_LOGIC_VECTOR (20 downto 0);
           led_alarm_act : out STD_LOGIC;
           led_alarm_ring : out STD_LOGIC;
           lcd_alarm_act : out STD_LOGIC;
           lcd_alarm_snooze : out STD_LOGIC;
           --lcd_alarm_ss : out STD_LOGIC_VECTOR (6 downto 0);
           lcd_alarm_mm : out STD_LOGIC_VECTOR (6 downto 0);--(6 downto 0);
           lcd_alarm_hh : out STD_LOGIC_VECTOR (6 downto 0));--(13 downto 7));
           --lcd_alarm_data : out STD_LOGIC_VECTOR (13 downto 0));
end alarm;

architecture Behavioral of alarm is
    component active
        Port ( clk : in STD_LOGIC;
           I_ring : in STD_LOGIC;
           fsm_alarm : in STD_LOGIC;
           action_imp : in STD_LOGIC;
           rst : in STD_LOGIC;
           O_act : out STD_LOGIC;
           lcd_act : out STD_LOGIC);
    end component;   
    component ringing
        Port ( ss_alarm : in STD_LOGIC_VECTOR (5 downto 0);
           mm_alarm : in STD_LOGIC_VECTOR (5 downto 0);
           hh_alarm : in STD_LOGIC_VECTOR (4 downto 0);
           ss_current : in STD_LOGIC_VECTOR (5 downto 0);
           mm_current : in STD_LOGIC_VECTOR (5 downto 0);
           hh_current : in STD_LOGIC_VECTOR (4 downto 0);
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           I_act : in STD_LOGIC;
           snooze_state : in STD_LOGIC;
           snooze_1min : in STD_LOGIC;
           action_stop : in STD_LOGIC;
           action_long : in STD_LOGIC;
           action_imp : in STD_LOGIC;
           O_ring : out STD_LOGIC;
           O_snooze : out STD_LOGIC);
    end component;
    component stop_ringing
        Port ( I_ring : in STD_LOGIC;
           clk : in STD_LOGIC;
           O_stop : out STD_LOGIC);
    end component;
    component snooze
        Port ( clk : in STD_LOGIC;
           I_snooze : in STD_LOGIC;
           I_active : in STD_LOGIC;
           O_active : out STD_LOGIC;
           O_snooze : out STD_LOGIC;
           O_1min :  out STD_LOGIC);
    end component;
    component modify
        Port ( clk : in STD_LOGIC;
           fsm_alarm : in STD_LOGIC;
           key_enable : in STD_LOGIC;
           key_p_m : in STD_LOGIC;
           rst : in STD_LOGIC;
           ss : out STD_LOGIC_VECTOR (5 downto 0);
           mm : out STD_LOGIC_VECTOR (5 downto 0);
           hh : out STD_LOGIC_VECTOR (4 downto 0));
    end component;
    
    signal ring, led_act_2, led_act_1, snooze_1min, snooze_imp, snooze_state, action_stop: std_logic;
    signal ss, mm : std_logic_vector (5 downto 0);
    signal hh : std_logic_vector (4 downto 0);
    
begin
    u1: active port map (clk=>clk, I_ring=>ring, fsm_alarm=>fsm_alarm_start, action_imp=>key_action_imp,
                         rst=>reset, O_act=>led_act_1, lcd_act=>lcd_alarm_act);
    u2: ringing port map (clk=>clk, rst=>reset, ss_alarm=>ss, mm_alarm=>mm, hh_alarm=>hh, ss_current=>second(5 downto 0),
                          mm_current=>minute(5 downto 0), hh_current=>hour(4 downto 0), I_act=>led_act_1, snooze_1min=>snooze_1min,
                          snooze_state=>snooze_state, action_stop=>action_stop, action_long=>key_action_long, action_imp=>key_action_imp, 
                          O_ring=>ring, O_snooze=>snooze_imp);
    u3: stop_ringing port map (clk=>clk, I_ring=>ring, O_stop=>action_stop);
    u4: snooze port map (clk=>clk, I_snooze=>snooze_imp, I_active=>led_act_1, O_active=>led_act_2, O_snooze=>snooze_state, 
                         O_1min=>snooze_1min);
    u5: modify port map (clk=>clk, fsm_alarm=>fsm_alarm_start, key_enable=>key_enable, key_p_m=>key_plus_minus, 
                         rst=>reset, ss=>ss, mm=>mm, hh=>hh);
    led_alarm_ring <= ring;
    lcd_alarm_act <= led_act_1;
    process (clk, snooze_state)
    begin
    if (clk = '1' and clk'EVENT) then
        if (snooze_state='1') then
            led_alarm_act <= led_act_2;
        else
            led_alarm_act <= led_act_1;
        end if;
    end if;
    end process;
    lcd_alarm_snooze <= snooze_state;
    --lcd_alarm_ss <= ss;
    lcd_alarm_mm <= "0" & mm;
    lcd_alarm_hh <= "00" & hh;
    --lcd_alarm_data <= "00" & hh & "0" & mm;
    
end Behavioral;
