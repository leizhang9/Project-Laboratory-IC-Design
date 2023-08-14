--------------------------------------------------------------------------------
-- Author       : Quang Phan
-- Author email : quang.phan@tum.de
-- Create Date  : 27/06/2022
-- Project Name : Project Lab IC Design
-- Module Name  : clock_module.vhd
-- Description  : Top level for the project - connecting all functionalities
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clock_module is
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
end entity clock_module;

architecture behavior of clock_module is

    -- ***********************************
    -- Component declarations
    -- ***********************************
    -- FSM
    component GlobalFSM
    generic (
        wait_3sec : integer := 30000
    );
    port (
        clk                  : in  std_logic;
        -- EN_1              : in  std_logic;
        reset                : in  std_logic;
        key_mode_imp         : in  std_logic;
        key_action_imp       : in  std_logic;
        key_plus_imp         : in  std_logic;
        key_minus_imp        : in  std_logic;
        fsm_time_start       : out std_logic;
        fsm_date_start       : out std_logic;
        fsm_alarm_start      : out std_logic;
        fsm_switch_on_start  : out std_logic;
        fsm_switch_off_start : out std_logic;
        fsm_count_down_start : out std_logic;
        fsm_stop_watch_start : out std_logic
    );
    end component GlobalFSM;

    -- Time and Date
    component Time_Date
    port (
        de_set   : in  std_logic;
        de_dow   : in  std_logic_vector(2 downto 0);
        de_day   : in  std_logic_vector(5 downto 0);
        de_month : in  std_logic_vector(4 downto 0);
        de_year  : in  std_logic_vector(7 downto 0);
        de_hour  : in  std_logic_vector(5 downto 0);
        de_min   : in  std_logic_vector(6 downto 0);
        clk      : in  std_logic;
        en_1     : in std_logic;
        rst      : in  std_logic;
        hour     : out std_logic_vector(6 downto 0);
        minute   : out std_logic_vector(6 downto 0);
        second   : out std_logic_vector(6 downto 0);
        dow      : out std_logic_vector(2 downto 0);
        year     : out std_logic_vector(6 downto 0);
        month    : out std_logic_vector(6 downto 0);
        day      : out std_logic_vector(6 downto 0);
        lcd_dcf  : out std_logic
    );
    end component Time_Date;

    -- Alarm
    component alarm
    port (
        clk              : in  std_logic;
        reset            : in  std_logic;
        key_action_imp   : in  std_logic;
        key_action_long  : in  std_logic;
        key_plus_minus   : in  std_logic;
        key_enable       : in  std_logic;
        fsm_alarm_start  : in  std_logic;
        second           : in  std_logic_vector (6 downto 0);
        minute           : in  std_logic_vector (6 downto 0);
        hour             : in  std_logic_vector (6 downto 0);
        led_alarm_act    : out std_logic;
        led_alarm_ring   : out std_logic;
        lcd_alarm_act    : out std_logic;
        lcd_alarm_snooze : out std_logic;
        lcd_alarm_mm     : out std_logic_vector (6 downto 0);
        lcd_alarm_hh     : out std_logic_vector (6 downto 0)
    );
    end component alarm;

    -- Switch
    component switch
    port (
        clk              : in  std_logic;
        reset            : in  std_logic;
        key_action_imp   : in  std_logic;
        key_plus_minus   : in  std_logic;
        key_enable       : in  std_logic;
        fsm_switch_on    : in  std_logic;
        fsm_switch_off   : in  std_logic;
        second           : in  std_logic_vector (6 downto 0);
        minute           : in  std_logic_vector (6 downto 0);
        hour             : in  std_logic_vector (6 downto 0);
        led_switch_act   : out std_logic;
        lcd_switch_act   : out std_logic;
        led_switch_on    : out std_logic;
        lcd_switchon_ss  : out std_logic_vector (6 downto 0);
        lcd_switchon_mm  : out std_logic_vector (6 downto 0);
        lcd_switchon_hh  : out std_logic_vector (6 downto 0);
        lcd_switchoff_ss : out std_logic_vector (6 downto 0);
        lcd_switchoff_mm : out std_logic_vector (6 downto 0);
        lcd_switchoff_hh : out std_logic_vector (6 downto 0)
    );
    end component switch;

    -- Countdown
    component countdown
    port (
		clk                 : in  std_logic;
        reset               : in  std_logic;
		fsm_countdown_start : in  std_logic;
		led_countdown_act   : out std_logic;
        led_countdown_ring  : out std_logic;
	    lcd_countdown_act   : out std_logic;
		ss                  : out std_logic_vector(6 downto 0);
		mm                  : out std_logic_vector(6 downto 0);
		hh                  : out std_logic_vector(6 downto 0)
	);
    end component countdown;

    -- Stopwatch
    component stopwatch
    port (
        clk                 : in  std_logic;
        reset               : in  std_logic;
        en_100              : in  std_logic;
        fsm_stopwatch_start : in  std_logic;
        key_minus_imp       : in  std_logic;
        key_plus_imp        : in  std_logic;
        key_action_imp      : in  std_logic;
        lcd_stopwatch_act   : out std_logic;
        cs                  : out std_logic_vector(6 downto 0);
        ss                  : out std_logic_vector(6 downto 0);
        mm                  : out std_logic_vector(6 downto 0);
        hh                  : out std_logic_vector(6 downto 0)
    );
    end component stopwatch;

    -- Display
    component display
    port (
        -- Clock and reset
        clk                 : in  std_logic;
        reset               : in  std_logic;
        en_100              : in  std_logic;
        en_10               : in  std_logic;
        -- Time
        fsm_time_start      : in  std_logic;
        lcd_time_act        : in  std_logic;  -- DCF
        lcd_time_data       : in  std_logic_vector(20 downto 0);  -- hh/mm/ss
        -- Date
        fsm_date_start      : in  std_logic;
        lcd_date_dow        : in  std_logic_vector(2  downto 0);
        lcd_date_data       : in  std_logic_vector(20 downto 0);  -- DD/MM/YY
        -- Alarm
        fsm_alarm_start     : in  std_logic;
        lcd_alarm_act       : in  std_logic;  -- Letter * under A
        lcd_alarm_snooze    : in  std_logic;  -- Letter Z under A
        lcd_alarm_data      : in  std_logic_vector(13 downto 0);  -- hh/mm
        -- Switch ON
        fsm_switchon_start  : in  std_logic;
        lcd_switchon_act    : in  std_logic;  -- Letter * under S
        lcd_switchon_data   : in  std_logic_vector(20 downto 0);  -- hh/mm/ss
        -- Switch OFF
        fsm_switchoff_start : in  std_logic;
        lcd_switchoff_act   : in  std_logic;  -- Letter * under S
        lcd_switchoff_data  : in  std_logic_vector(20 downto 0);  -- hh/mm/ss
        -- Countdown
        fsm_countdown_start : in  std_logic;
        lcd_countdown_act   : in  std_logic;
        lcd_countdown_data  : in  std_logic_vector(20 downto 0);  -- hh/mm/ss
        -- Stopwatch
        fsm_stopwatch_start : in  std_logic;
        lcd_stopwatch_act   : in  std_logic;
        lcd_stopwatch_data  : in  std_logic_vector(27 downto 0);  -- hh/mm/ss/cc
        -- Output to LCD
        lcd_en              : out std_logic;
        lcd_rw              : out std_logic;
        lcd_rs              : out std_logic;
        lcd_data            : out std_logic_vector(7 downto 0)
    );
    end component display;


    -- ***********************************
    -- Constances
    -- ***********************************
    constant DELAY_3SEC_c : integer := 30000;


    -- ***********************************
    -- Internal wires
    -- ***********************************
    -- FSM control signals
    signal fsm_time_start      : std_logic;
    signal fsm_date_start      : std_logic;
    signal fsm_alarm_start     : std_logic;
    signal fsm_switchon_start  : std_logic;
    signal fsm_switchoff_start : std_logic;
    signal fsm_countdown_start : std_logic;
    signal fsm_stopwatch_start : std_logic;

    -- Interrupt signals
    signal lcd_time_act      : std_logic;
    signal lcd_alarm_act     : std_logic;
    signal lcd_alarm_snooze  : std_logic;
    signal lcd_switch_act    : std_logic;
    signal lcd_countdown_act : std_logic;
    signal lcd_stopwatch_act : std_logic;

    -- Data signals
    signal lcd_time_data      : std_logic_vector(20 downto 0);
    signal lcd_date_data      : std_logic_vector(20 downto 0);
    signal lcd_date_dow       : std_logic_vector(2  downto 0);
    signal lcd_alarm_data     : std_logic_vector(13 downto 0);
    signal lcd_switchon_data  : std_logic_vector(20 downto 0);
    signal lcd_switchoff_data : std_logic_vector(20 downto 0);
    signal lcd_countdown_data : std_logic_vector(20 downto 0);
    signal lcd_stopwatch_data : std_logic_vector(27 downto 0);

    -- Time signals
    signal top_time_hh : std_logic_vector(6 downto 0);
    signal top_time_mm : std_logic_vector(6 downto 0);
    signal top_time_ss : std_logic_vector(6 downto 0);

    -- Date signals
    signal top_date_dow   : std_logic_vector(2 downto 0);
    signal top_date_day   : std_logic_vector(6 downto 0);
    signal top_date_month : std_logic_vector(6 downto 0);
    signal top_date_year  : std_logic_vector(6 downto 0);

    -- Alarm signals
    signal top_alarm_hh : std_logic_vector(6 downto 0);
    signal top_alarm_mm : std_logic_vector(6 downto 0);

    -- Switch-on signals
    signal top_switchon_hh : std_logic_vector(6 downto 0);
    signal top_switchon_mm : std_logic_vector(6 downto 0);
    signal top_switchon_ss : std_logic_vector(6 downto 0);

    -- Switch-off signals
    signal top_switchoff_hh : std_logic_vector(6 downto 0);
    signal top_switchoff_mm : std_logic_vector(6 downto 0);
    signal top_switchoff_ss : std_logic_vector(6 downto 0);

    -- Countdown signals
    signal top_countdown_hh : std_logic_vector(6 downto 0);
    signal top_countdown_mm : std_logic_vector(6 downto 0);
    signal top_countdown_ss : std_logic_vector(6 downto 0);

    -- Stopwatch signals
    signal top_stopwatch_hh : std_logic_vector(6 downto 0);
    signal top_stopwatch_mm : std_logic_vector(6 downto 0);
    signal top_stopwatch_ss : std_logic_vector(6 downto 0);
    signal top_stopwatch_cs : std_logic_vector(6 downto 0);

begin

    -- ***********************************
    -- Concurrent assignments
    -- ***********************************
    lcd_time_data      <= top_time_hh      & top_time_mm      & top_time_ss;
    lcd_date_data      <= top_date_day     & top_date_month   & top_date_year;
    lcd_date_dow       <= top_date_dow;
    lcd_alarm_data     <= top_alarm_hh     & top_alarm_mm;
    lcd_switchon_data  <= top_switchon_hh  & top_switchon_mm  & top_switchon_ss;
    lcd_switchoff_data <= top_switchoff_hh & top_switchoff_mm & top_switchoff_ss;
    lcd_countdown_data <= top_countdown_hh & top_countdown_mm & top_countdown_ss;
    lcd_stopwatch_data <= top_stopwatch_hh & top_stopwatch_mm & top_stopwatch_ss & top_stopwatch_cs;

    -- ***********************************
    -- Component instatiations
    -- ***********************************
    -- FSM
    FSM_i : GlobalFSM
    generic map (
        wait_3sec => DELAY_3SEC_c
    )
    port map (
        clk                  => clk,
        reset                => reset,
        key_mode_imp         => key_mode_imp,
        key_action_imp       => key_action_imp,
        key_plus_imp         => key_plus_imp,
        key_minus_imp        => key_minus_imp,
        fsm_time_start       => fsm_time_start,
        fsm_date_start       => fsm_date_start,
        fsm_alarm_start      => fsm_alarm_start,
        fsm_switch_on_start  => fsm_switchon_start,
        fsm_switch_off_start => fsm_switchoff_start,
        fsm_count_down_start => fsm_countdown_start,
        fsm_stop_watch_start => fsm_stopwatch_start
    );

    -- Time and Date
    Time_date_i : Time_Date
    port map (
        de_set   => de_set,
        de_dow   => de_dow,
        de_day   => de_day,
        de_month => de_month,
        de_year  => de_year,
        de_hour  => de_hour,
        de_min   => de_min,
        clk      => clk,
        en_1     => en_1,
        rst      => reset,
        hour     => top_time_hh,
        minute   => top_time_mm,
        second   => top_time_ss,
        dow      => top_date_dow,
        year     => top_date_year,
        month    => top_date_month,
        day      => top_date_day,
        lcd_dcf  => lcd_time_act
    );

    -- Alarm
    Alarm_i : alarm
    port map (
        clk              => clk,
        reset            => reset,
        key_action_imp   => key_action_imp,
        key_action_long  => key_action_long,
        key_plus_minus   => key_plus_minus,
        key_enable       => key_enable,
        fsm_alarm_start  => fsm_alarm_start,
        second           => top_time_ss,
        minute           => top_time_mm,
        hour             => top_time_hh,
        led_alarm_act    => led_alarm_act,
        led_alarm_ring   => led_alarm_ring,
        lcd_alarm_act    => lcd_alarm_act,
        lcd_alarm_snooze => lcd_alarm_snooze,
        lcd_alarm_hh     => top_alarm_hh,
        lcd_alarm_mm     => top_alarm_mm
    );

    -- Switch
    Switch_i : switch
    port map (
        clk                => clk,
        reset              => reset,
        key_action_imp     => key_action_imp,

        key_plus_minus     => key_plus_minus,
        key_enable         => key_enable,
        fsm_switch_on      => fsm_switchon_start,
        fsm_switch_off     => fsm_switchoff_start,
        second             => top_time_ss,
        minute             => top_time_mm,
        hour               => top_time_hh,
        led_switch_act     => led_switch_act,
        lcd_switch_act     => lcd_switch_act,
        led_switch_on      => led_switch_on,
        lcd_switchon_hh    => top_switchon_hh,
        lcd_switchon_mm    => top_switchon_mm,
        lcd_switchon_ss    => top_switchon_ss,
        lcd_switchoff_hh   => top_switchoff_hh,
        lcd_switchoff_mm   => top_switchoff_mm,
        lcd_switchoff_ss   => top_switchoff_ss
    );

    -- Countdown
    Countdown_i : countdown
    port map (
        clk => clk,
        reset => reset,
        fsm_countdown_start => fsm_countdown_start,
        led_countdown_act   => led_countdown_act,
        led_countdown_ring  => led_countdown_ring,
        lcd_countdown_act   => lcd_countdown_act,
        ss                  => top_countdown_ss,
        mm                  => top_countdown_mm,
        hh                  => top_countdown_hh
    );

    -- Stopwatch
    Stopwatch_i : stopwatch
    port map (
        clk                 => clk,
        reset               => reset,
        en_100              => en_100,
        fsm_stopwatch_start => fsm_stopwatch_start,
        key_minus_imp       => key_minus_imp,
        key_plus_imp        => key_plus_imp,
        key_action_imp      => key_action_imp,
        lcd_stopwatch_act   => lcd_stopwatch_act,
        cs                  => top_stopwatch_cs,
        ss                  => top_stopwatch_ss,
        mm                  => top_stopwatch_mm,
        hh                  => top_stopwatch_hh
    );

    -- Display
    Display_i : display
    port map (
        -- Clock and reset
        clk                 => clk,
        reset               => reset,
        en_100              => en_100,
        en_10               => en_10,
        -- Time
        fsm_time_start      => fsm_time_start,
        lcd_time_act        => lcd_time_act,
        lcd_time_data       => lcd_time_data,
        -- Date
        fsm_date_start      => fsm_date_start,
        lcd_date_dow        => lcd_date_dow,
        lcd_date_data       => lcd_date_data,
        -- Alarm
        fsm_alarm_start     => fsm_alarm_start,
        lcd_alarm_act       => lcd_alarm_act,
        lcd_alarm_snooze    => lcd_alarm_snooze,
        lcd_alarm_data      => lcd_alarm_data,
        -- Switch ON
        fsm_switchon_start  => fsm_switchon_start,
        lcd_switchon_act    => lcd_switch_act,
        lcd_switchon_data   => lcd_switchon_data,
        -- Switch ON
        fsm_switchoff_start => fsm_switchoff_start,
        lcd_switchoff_act   => lcd_switch_act,
        lcd_switchoff_data  => lcd_switchoff_data,
        -- Countdown
        fsm_countdown_start => fsm_countdown_start,
        lcd_countdown_act   => lcd_countdown_act,
        lcd_countdown_data  => lcd_countdown_data,
        -- Stopwatch
        fsm_stopwatch_start => fsm_stopwatch_start,
        lcd_stopwatch_act   => lcd_stopwatch_act,
        lcd_stopwatch_data  => lcd_stopwatch_data,
        -- Output to LCD
        lcd_en              => lcd_en,
        lcd_rw              => lcd_rw,
        lcd_rs              => lcd_rs,
        lcd_data            => lcd_data
    );

end architecture behavior;
