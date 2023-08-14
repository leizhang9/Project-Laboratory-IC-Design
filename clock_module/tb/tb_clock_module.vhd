--------------------------------------------------------------------------------
-- Author       : Quang Phan, Bo Zhou, Yinjia Wang
-- Author email : quang.phan@tum.de
-- Create Date  : 18/07/2022
-- Project Name : Project Lab IC Design
-- Module Name  : tb_clock_module.vhd
-- Description  : Testbench for clock module
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_clock_module is
end entity tb_clock_module;

architecture behavior of tb_clock_module is

    -- Component Declaration for the Unit Under Test (UUT)
    component clock_module
    port (
        clk                : in  std_logic;
        reset              : in  std_logic;
        en_1K              : in  std_logic;
        en_100             : in  std_logic;
        en_10              : in  std_logic;
        en_1               : in  std_logic;
        key_action_imp     : in  std_logic;
        key_action_long    : in  std_logic;
        key_mode_imp       : in  std_logic;
        key_minus_imp      : in  std_logic;
        key_plus_imp       : in  std_logic;
        key_plus_minus     : in  std_logic;
        key_enable         : in  std_logic;
        de_set             : in  std_logic;
        de_dow             : in  std_logic_vector (2 downto 0);
        de_day             : in  std_logic_vector (5 downto 0);
        de_month           : in  std_logic_vector (4 downto 0);
        de_year            : in  std_logic_vector (7 downto 0);
        de_hour            : in  std_logic_vector (5 downto 0);
        de_min             : in  std_logic_vector (6 downto 0);
        led_alarm_act      : out std_logic;
        led_alarm_ring     : out std_logic;
        led_countdown_act  : out std_logic;
        led_countdown_ring : out std_logic;
        led_switch_act     : out std_logic;
        led_switch_on      : out std_logic;
        lcd_en             : out std_logic;
        lcd_rw             : out std_logic;
        lcd_rs             : out std_logic;
        lcd_data           : out std_logic_vector (7 downto 0)
    );
    end component clock_module;

    -- Internal wires
    -- Inputs
    signal clk                : std_logic := '0';
    signal reset              : std_logic := '0';
    signal en_1K              : std_logic := '0';
    signal en_100             : std_logic := '0';
    signal en_10              : std_logic := '0';
    signal en_1               : std_logic := '0';
    signal key_action_imp     : std_logic := '0';
    signal key_action_long    : std_logic := '0';
    signal key_mode_imp       : std_logic := '0';
    signal key_minus_imp      : std_logic := '0';
    signal key_plus_imp       : std_logic := '0';
    signal key_plus_minus     : std_logic := '0';
    signal key_enable         : std_logic := '0';
    signal de_set             : std_logic := '0';
    signal de_dow             : std_logic_vector (2 downto 0) := (others => '0');
    signal de_day             : std_logic_vector (5 downto 0) := (others => '0');
    signal de_month           : std_logic_vector (4 downto 0) := (others => '0');
    signal de_year            : std_logic_vector (7 downto 0) := (others => '0');
    signal de_hour            : std_logic_vector (5 downto 0) := (others => '0');
    signal de_min             : std_logic_vector (6 downto 0) := (others => '0');
    -- Outputs
    signal led_alarm_act      : std_logic := '0';
    signal led_alarm_ring     : std_logic := '0';
    signal led_countdown_act  : std_logic := '0';
    signal led_countdown_ring : std_logic := '0';
    signal led_switch_act     : std_logic := '0';
    signal led_switch_on      : std_logic := '0';
    signal lcd_en             : std_logic := '0';
    signal lcd_rw             : std_logic := '0';
    signal lcd_rs             : std_logic := '0';
    signal lcd_data           : std_logic_vector (7 downto 0)  := (others => '0');

    -- Output wrappers
    signal lcd_output : std_logic_vector(10 downto 0);

    -- Input data count
    -- constant MAX_DATA_c : integer := 20;

    -- Clock period
    constant CLK_10K_PERIOD_c : time :=  100 us;
    constant CLK_1K_PERIOD_c  : time :=    1 ms;
    constant CLK_100_PERIOD_c : time :=   10 ms;
    constant CLK_10_PERIOD_c  : time :=  100 ms;
    constant CLK_1_PERIOD_c   : time := 1000 ms;

    -- Error counter
    signal error_cnt : integer := 0;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut : clock_module
    port map (
        clk                => clk,
        reset              => reset,
        en_1K              => en_1K,
        en_100             => en_100,
        en_10              => en_10,
        en_1               => en_1,
        key_action_imp     => key_action_imp,
        key_action_long    => key_action_long,
        key_mode_imp       => key_mode_imp,
        key_minus_imp      => key_minus_imp,
        key_plus_imp       => key_plus_imp,
        key_plus_minus     => key_plus_minus,
        key_enable         => key_enable,
        de_set             => de_set,
        de_dow             => de_dow,
        de_day             => de_day,
        de_month           => de_month,
        de_year            => de_year,
        de_hour            => de_hour,
        de_min             => de_min,
        led_alarm_act      => led_alarm_act,
        led_alarm_ring     => led_alarm_ring,
        led_countdown_act  => led_countdown_act,
        led_countdown_ring => led_countdown_ring,
        led_switch_act     => led_switch_act,
        led_switch_on      => led_switch_on,
        lcd_en             => lcd_en,
        lcd_rw             => lcd_rw,
        lcd_rs             => lcd_rs,
        lcd_data           => lcd_data
    );

    -- Clock 10 kHz generator
    CLK_10K_GEN : process
    begin
        wait for CLK_10K_PERIOD_c/2; -- 50/50 duty cycle
        clk <= not clk;
    end process CLK_10K_GEN;

    -- Enable 1 kHz generator
    EN_1K_GEN : process
    begin
        wait for CLK_10K_PERIOD_c*9/2;
        en_1K <= '1';
        wait for CLK_10K_PERIOD_c;    -- 1/99 duty cycle, actually "en_100"
        en_1K <= '0';
        wait for CLK_10K_PERIOD_c/2;
        wait for CLK_10K_PERIOD_c*5;
    end process EN_1K_GEN;

    -- Enable 100 Hz generator
    EN_100_GEN : process
    begin
        wait for CLK_10K_PERIOD_c*9/2;
        en_100 <= '1';
        wait for CLK_10K_PERIOD_c;    -- 1/99 duty cycle, actually "en_100"
        en_100 <= '0';
        wait for CLK_10K_PERIOD_c/2;
        wait for CLK_10K_PERIOD_c*95;
    end process EN_100_GEN;

    -- Enable 10 Hz generator
    EN_10_GEN : process
    begin
        wait for CLK_10K_PERIOD_c*9/2;
        en_10 <= '1';
        wait for CLK_10K_PERIOD_c;    -- 1/99 duty cycle, actually "en_100"
        en_10 <= '0';
        wait for CLK_10K_PERIOD_c/2;
        wait for CLK_10K_PERIOD_c*995;
    end process EN_10_GEN;

    -- Enable 1 Hz generator
    EN_1_GEN : process
    begin
        wait for CLK_10K_PERIOD_c*9/2;
        en_1 <= '1';
        wait for CLK_10K_PERIOD_c;    -- 1/99 duty cycle, actually "en_100"
        en_1 <= '0';
        wait for CLK_10K_PERIOD_c/2;
        wait for CLK_10K_PERIOD_c*9995;
    end process EN_1_GEN;

    -- Stimulus process
    STIM : process
    begin
    
        -- Generate reset
        wait for CLK_10K_PERIOD_c*2;
        reset <= '1';
        wait for CLK_10K_PERIOD_c*2;
        reset <= '0';
        wait for CLK_10K_PERIOD_c/2;
        
        -- Global FSM test ------------------------------------------------
        -- global FSM : date display state test
        wait for CLK_10K_PERIOD_c*2;
        key_mode_imp <= '1';
        wait for CLK_10K_PERIOD_c*2;
        key_mode_imp <= '0';
        wait for 4sec;
        
          -- Generate reset
        wait for CLK_10K_PERIOD_c*2;
        reset <= '1';
        wait for CLK_10K_PERIOD_c*2;
        reset <= '0';
        wait for CLK_10K_PERIOD_c/2;

        
        -- Global FSM :Alarm state test
        -- Time display -> alarm and activat it -> time display
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '1';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '0';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '1';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '0';
        
        wait for 2sec;
        key_action_imp <= '1'; 
        wait for CLK_10K_PERIOD_c; 
        key_action_imp <= '0';
        wait for CLK_10K_PERIOD_c; 
        key_mode_imp <= '1';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '0';
        
        -- Generate reset
        wait for CLK_10K_PERIOD_c*2;
        reset <= '1';
        wait for CLK_10K_PERIOD_c*2;
        reset <= '0';
        wait for CLK_10K_PERIOD_c/2;
        
        -- Global FSM :switch on state test
        -- time display -> switch on -> activate it -> switch off2 -> time isplay
        -- Access to swith on
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '1';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '0';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '1';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '0';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '1';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '0';
        wait for 1sec;
        -- Activiation
        wait for CLK_10K_PERIOD_c;
        key_action_imp <= '1'; 
        wait for CLK_10K_PERIOD_c; 
        key_action_imp <= '0';
        wait for 1sec;
        -- Go through switch off
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '1';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '0';
        wait for 1sec;
        -- return time display
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '1';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '0';
        
        -- Generate reset
        wait for CLK_10K_PERIOD_c*2;
        reset <= '1';
        wait for CLK_10K_PERIOD_c*2;
        reset <= '0';
        wait for CLK_10K_PERIOD_c/2;
        
        
        -- Generate reset
        wait for CLK_10K_PERIOD_c*2;
        reset <= '1';
        wait for CLK_10K_PERIOD_c*2;
        reset <= '0';
        wait for CLK_10K_PERIOD_c/2;
        
--        -- Global FSM : Switch off state test
--        -- Access to swith off
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '1';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '0';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '1';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '0';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '1';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '0';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '1';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '0';
        wait for 1sec;
        -- Activiation
        wait for CLK_10K_PERIOD_c;
        key_action_imp <= '1'; 
        wait for CLK_10K_PERIOD_c; 
        key_action_imp <= '0';
        wait for 1sec;
        -- back to time display
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '1';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '0';
        wait for 1sec;
        
        -- Generate reset
        wait for CLK_10K_PERIOD_c*2;
        reset <= '1';
        wait for CLK_10K_PERIOD_c*2;
        reset <= '0';
        wait for CLK_10K_PERIOD_c/2;
        
        -- Global FSM :count down state test
        --access to count down
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '1';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '0';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '1';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '0';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '1';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '0';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '1';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '0';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '1';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '0';
        wait for 1sec;
        
        -- Back to time display 
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '1';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '0';
        wait for 1sec;
        
        -- Generate reset
        wait for CLK_10K_PERIOD_c*2;
        reset <= '1';
        wait for CLK_10K_PERIOD_c*2;
        reset <= '0';
        wait for CLK_10K_PERIOD_c/2;
        
--        -- Global FSM: stop watch state test
--        -- Access tp stop watch function
        key_plus_imp <= '1';
        wait for CLK_10K_PERIOD_c;
        key_plus_imp <= '0';
        wait for 1sec;
        
        
        -- Back to time display
        key_mode_imp <= '1';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '0';
        wait for CLK_10K_PERIOD_c;
        
        -- Generate reset
        wait for CLK_10K_PERIOD_c*2;
        reset <= '1';
        wait for CLK_10K_PERIOD_c*2;
        reset <= '0';
        wait for CLK_10K_PERIOD_c/2;
        
        -------------------------------Global FSM State test end at 15s---------------------------
        
        -- Generate reset
        wait for CLK_10K_PERIOD_c*2;
        reset <= '1';
        wait for CLK_10K_PERIOD_c*2;
        reset <= '0';
        wait for CLK_10K_PERIOD_c/2;

        -- Test time module
          

        -- Generate reset
        wait for CLK_10K_PERIOD_c*2;
        reset <= '1';
        wait for CLK_10K_PERIOD_c*2;
        reset <= '0';
        wait for CLK_10K_PERIOD_c/2;

        -- Test date module
--        wait for CLK_10K_PERIOD_c*2;
--        key_mode_imp <= '1';
--        wait for CLK_10K_PERIOD_c*2;
--        key_mode_imp <= '0';
--        wait for 4sec;

--        -- Generate reset
--        wait for CLK_10K_PERIOD_c*2;
--        reset <= '1';
--        wait for CLK_10K_PERIOD_c*2;
--        reset <= '0';
--        wait for CLK_10K_PERIOD_c/2;

-- Test alarm module

        -- Generate reset
        wait for CLK_10K_PERIOD_c*2;
        reset <= '1';
        wait for CLK_10K_PERIOD_c*2;
        reset <= '0';
        
        --case1: toggling between active/inactive
        wait for CLK_10K_PERIOD_c*2;
        key_mode_imp <= '1';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '0';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '1';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '0';
        wait for CLK_10K_PERIOD_c*2;
        key_action_imp <= '1'; wait for CLK_10K_PERIOD_c; key_action_imp <= '0';
        wait for CLK_10K_PERIOD_c;
        key_action_imp <= '1'; wait for CLK_10K_PERIOD_c; key_action_imp <= '0';
        wait for CLK_10K_PERIOD_c;
        key_action_imp <= '1'; wait for CLK_10K_PERIOD_c; key_action_imp <= '0';

        --case2: time modification & ringing & ringing stop after 1 min without pressing Action key
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        --pressing +/- key and mode key will not influence this process
        wait for 1000 ms;
        key_mode_imp <= '1'; wait for CLK_10K_PERIOD_c*5; key_mode_imp <= '0';
        wait for CLK_10K_PERIOD_c*5000;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c*5; key_enable <= '0';
        wait for CLK_10K_PERIOD_c*5000;
        key_plus_minus <= '1';
        key_enable <= '1'; wait for CLK_10K_PERIOD_c*5; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_plus_minus <= '0';
        --case3: ringing stop while long pressing Action key
        wait for 61000 ms;
        reset <= '1';
        wait for CLK_10K_PERIOD_c*2;
        reset <= '0';
        wait for CLK_10K_PERIOD_c*2;
        key_mode_imp <= '1';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '0';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '1';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '0';
        wait for CLK_10K_PERIOD_c*2;
        key_action_imp <= '1'; wait for CLK_10K_PERIOD_c; key_action_imp <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c*2;
        key_action_imp <= '1'; wait for CLK_10K_PERIOD_c; key_action_imp <= '0';
        wait for 2000 ms;
        key_action_long <= '1'; wait for CLK_10K_PERIOD_c; key_action_long <= '0';
        --case4: ringing stop and going into snooze state when pressing Action key no more than 2 s.
        --* LED must wait for 3 second to detect key_act_long signal.
        wait for 1000 ms;
        reset <= '1';
        wait for CLK_10K_PERIOD_c*2;
        reset <= '0';
        wait for CLK_10K_PERIOD_c*2;
        key_mode_imp <= '1';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '0';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '1';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '0';
        wait for CLK_10K_PERIOD_c*2;
        key_action_imp <= '1'; wait for CLK_10K_PERIOD_c; key_action_imp <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_plus_minus <= '0';
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c*2;
        key_action_imp <= '1'; wait for CLK_10K_PERIOD_c; key_action_imp <= '0';
        --pressing action key, +/- key and mode key will not influence this process
        wait for 3000 ms;
        key_mode_imp <= '1'; wait for CLK_10K_PERIOD_c*5; key_mode_imp <= '0';
        wait for CLK_10K_PERIOD_c*5000;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c*5; key_enable <= '0';
        wait for CLK_10K_PERIOD_c*5000;
        key_plus_minus <= '1';
        key_enable <= '1'; wait for CLK_10K_PERIOD_c*5; key_enable <= '0';
        wait for CLK_10K_PERIOD_c*5000;
        key_plus_minus <= '0';
        key_action_imp <= '1'; wait for CLK_10K_PERIOD_c*5; key_action_imp <= '0';
        wait for CLK_10K_PERIOD_c;
        key_action_imp <= '1'; wait for CLK_10K_PERIOD_c*5; key_action_imp <= '0';
        --test for alarm module ends
        wait for 70000 ms;
        reset <= '1';
        wait for CLK_10K_PERIOD_c*2;
        reset <= '0';

        

        -- Test switch-on module
        wait for CLK_10K_PERIOD_c*2;
        reset <= '1';
        wait for CLK_10K_PERIOD_c*2;
        reset <= '0';
        wait for CLK_10K_PERIOD_c/2;
        wait for CLK_10K_PERIOD_c*2;
        key_mode_imp <= '1';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '0';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '1';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '0';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '1';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '0';
        wait for CLK_10K_PERIOD_c*2;
        key_action_imp <= '1'; wait for CLK_10K_PERIOD_c; key_action_imp <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_plus_minus <= '0';
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';


        -- Test switch-off module
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '1';
        wait for CLK_10K_PERIOD_c;
        key_mode_imp <= '0';
        wait for 30 sec;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';
        wait for CLK_10K_PERIOD_c;
        key_enable <= '1'; wait for CLK_10K_PERIOD_c; key_enable <= '0';

        -- Generate reset
        wait for 3 sec;
        reset <= '1';
        wait for CLK_10K_PERIOD_c*2;
        reset <= '0';
        wait for CLK_10K_PERIOD_c/2;

        -- Test countdown module
        
       

        -- Generate reset
        wait for CLK_10K_PERIOD_c*2;
        reset <= '1';
        wait for CLK_10K_PERIOD_c*2;
        reset <= '0';
        wait for CLK_10K_PERIOD_c/2;

        -- Test stopwatch module
        
       
        

        -- Generate reset
        wait for CLK_10K_PERIOD_c*2;
        reset <= '1';
        wait for CLK_10K_PERIOD_c*2;
        reset <= '0';
        wait for CLK_10K_PERIOD_c/2;

        -- Test time module when lap


        wait;
    end process STIM;

end architecture behavior;
