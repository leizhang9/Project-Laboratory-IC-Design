--------------------------------------------------------------------------------
-- Author       : Quang Phan
-- Author email : quang.phan@tum.de
-- Create Date  : 27/06/2022
-- Project Name : Project Lab IC Design
-- Module Name  : tb_display.vhd
-- Description  : VHDL testbench for module: display
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_display is
end entity tb_display;

architecture behavior of tb_display is

    -- Component Declaration for the Unit Under Test (UUT)
    component display
    port (
        -- Clock and reset
        clk                 : in  std_logic;
        reset               : in  std_logic;
        en_100              : in  std_logic;
        en_10               : in  std_logic;
        -- Time
        fsm_time_start      : in  std_logic;
        lcd_time_act        : in  std_logic;                      -- DCF
        lcd_time_data       : in  std_logic_vector(20 downto 0);  -- hh/mm/ss
        -- Date
        fsm_date_start      : in  std_logic;
        lcd_date_dow        : in  std_logic_vector(2  downto 0);
        lcd_date_data       : in  std_logic_vector(20 downto 0);  -- DD/MM/YY
        -- Alarm
        fsm_alarm_start     : in  std_logic;
        lcd_alarm_act       : in  std_logic;                      -- Letter * under A
        lcd_alarm_snooze    : in  std_logic;                      -- Letter Z under A
        lcd_alarm_data      : in  std_logic_vector(13 downto 0);  -- hh/mm
        -- Switch ON
        fsm_switchon_start  : in  std_logic;
        lcd_switchon_act    : in  std_logic;                      -- Letter * under S
        lcd_switchon_data   : in  std_logic_vector(20 downto 0);  -- hh/mm/ss
        -- Switch OFF
        fsm_switchoff_start : in  std_logic;
        lcd_switchoff_act   : in  std_logic;                      -- Letter * under S
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

    -- *** Inputs ***
    -- Clock and reset
    signal clk_10k             : std_logic := '0';
    signal reset               : std_logic := '0';
    signal en_100              : std_logic := '0';
    signal en_10               : std_logic := '0';
    -- Time
    signal fsm_time_start      : std_logic := '0';
    signal lcd_time_act        : std_logic := '0';                                  -- DCF
    signal lcd_time_data       : std_logic_vector(20 downto 0) := (others => '0');  -- hh/mm/ss
    -- Date
    signal fsm_date_start      : std_logic := '0';
    signal lcd_date_dow        : std_logic_vector(2  downto 0) := (others => '0');
    signal lcd_date_data       : std_logic_vector(20 downto 0) := (others => '0');  -- DD/MM/YY
    -- Alarm
    signal fsm_alarm_start     : std_logic := '0';
    signal lcd_alarm_act       : std_logic := '0';                                  -- Letter * under A
    signal lcd_alarm_snooze    : std_logic := '0';                                  -- Letter Z under A
    signal lcd_alarm_data      : std_logic_vector(13 downto 0) := (others => '0');  -- hh/mm
    -- Switch ON
    signal fsm_switchon_start  : std_logic := '0';
    signal lcd_switchon_act    : std_logic := '0';                                  -- Letter * under S
    signal lcd_switchon_data   : std_logic_vector(20 downto 0) := (others => '0');  -- hh/mm/ss
    -- Switch OFF
    signal fsm_switchoff_start : std_logic := '0';
    signal lcd_switchoff_act   : std_logic := '0';                                  -- Letter * under S
    signal lcd_switchoff_data  : std_logic_vector(20 downto 0) := (others => '0');  -- hh/mm/ss
    -- Countdown
    signal fsm_countdown_start : std_logic := '0';
    signal lcd_countdown_act   : std_logic := '0';
    signal lcd_countdown_data  : std_logic_vector(20 downto 0) := (others => '0');  -- hh/mm/ss
    -- Stopwatch
    signal fsm_stopwatch_start : std_logic := '0';
    signal lcd_stopwatch_act   : std_logic := '0';
    signal lcd_stopwatch_data  : std_logic_vector(27 downto 0) := (others => '0');  -- hh/mm/ss/cc

    -- *** Outputs ***
    signal lcd_en   : std_logic;
    signal lcd_rw   : std_logic;
    signal lcd_rs   : std_logic;
    signal lcd_data : std_logic_vector(7 downto 0);

    -- *** Output wrapper ***
    signal lcd_output : std_logic_vector(10 downto 0);

    -- Input data
    constant MAX_DATA_c : integer := 20;

    -- Input type declaration
    type input_dow_array_t    is array(0 to MAX_DATA_c-1) of std_logic_vector(2  downto 0);
    type input_2parts_array_t is array(0 to MAX_DATA_c-1) of std_logic_vector(13 downto 0);
    type input_3parts_array_t is array(0 to MAX_DATA_c-1) of std_logic_vector(20 downto 0);
    type input_4parts_array_t is array(0 to MAX_DATA_c-1) of std_logic_vector(27 downto 0);

    -- Output type declaration
    type output_data_array_t  is array(0 to 100) of std_logic_vector(10 downto 0);  -- For one piece of data
    type output_func_array_t  is array(0 to MAX_DATA_c-1) of output_data_array_t;   -- For one functionality

    -- Input declaration
    signal lcd_time_input_array      : input_3parts_array_t := (others => (others => '0'));
    signal lcd_date_input_array      : input_3parts_array_t := (others => (others => '0'));
    signal lcd_alarm_input_array     : input_2parts_array_t := (others => (others => '0'));
    signal lcd_switchon_input_array  : input_3parts_array_t := (others => (others => '0'));
    signal lcd_switchoff_input_array : input_3parts_array_t := (others => (others => '0'));
    signal lcd_timer_input_array     : input_3parts_array_t := (others => (others => '0'));
    signal lcd_stopwatch_input_array : input_4parts_array_t := (others => (others => '0'));
    signal lcd_dow_input_array       : input_dow_array_t    := (others => (others => '0'));

    -- Output declaration
    signal lcd_time_output_array      : output_func_array_t := (others => (others => (others => '0')));
    signal lcd_date_output_array      : output_func_array_t := (others => (others => (others => '0')));
    signal lcd_alarm_output_array     : output_func_array_t := (others => (others => (others => '0')));
    signal lcd_switchon_output_array  : output_func_array_t := (others => (others => (others => '0')));
    signal lcd_switchoff_output_array : output_func_array_t := (others => (others => (others => '0')));
    signal lcd_timer_output_array     : output_func_array_t := (others => (others => (others => '0')));
    signal lcd_stopwatch_output_array : output_func_array_t := (others => (others => (others => '0')));
    signal lcd_dow_output_array       : output_func_array_t := (others => (others => (others => '0')));

    -- Clock period
    constant CLK_10K_PERIOD_c : time := 100 us;
    constant CLK_100_PERIOD_c : time :=  10 ms;

    -- Special commands for LCD
    constant CMD_TURN_ON_DISPLAY_c : std_logic_vector(10 downto 0) := "10000001100";
    constant CMD_FUNCTION_SET_c    : std_logic_vector(10 downto 0) := "10000111000";

    -- Error counter
    -- signal error_cnt : integer := 0;

    -- Process to decode commands to LCD

begin

    -- Instantiate the Unit Under Test (UUT)
    uut : display
    port map (
        -- Clock and reset
        clk                 => clk_10k,
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
        lcd_switchon_act    => lcd_switchon_act,
        lcd_switchon_data   => lcd_switchon_data,
        -- Switch ON
        fsm_switchoff_start => fsm_switchoff_start,
        lcd_switchoff_act   => lcd_switchoff_act,
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

    -- Wrap the LCD outputs from display module
    lcd_output <= lcd_en & lcd_rs & lcd_rw & lcd_data;

    -- Clock 10 kHz generator
    CLK_10K_GEN : process
    begin
        wait for CLK_10K_PERIOD_c/2; -- 50/50 duty cycle
        clk_10k <= not clk_10k;
    end process CLK_10K_GEN;

    -- Enable 100 Hz generator
    EN_100_GEN : process
    begin
        wait for CLK_10K_PERIOD_c*99/2;
        en_100 <= '1';
        wait for CLK_10K_PERIOD_c;    -- 1/99 duty cycle, actually "en_100"
        en_100 <= '0';
        wait for CLK_10K_PERIOD_c/2;
        wait for CLK_10K_PERIOD_c*49;
    end process EN_100_GEN;

    -- Enable 10 Hz generator
    EN_10_GEN : process
    begin
        wait for CLK_10K_PERIOD_c*99/2;
        en_10 <= '1';
        wait for CLK_10K_PERIOD_c;    -- 1/999 duty cycle, actually "en_10"
        en_10 <= '0';
        wait for CLK_10K_PERIOD_c/2;
        wait for CLK_10K_PERIOD_c*949;
    end process EN_10_GEN;

    -- Time Data generator
    DATA_GEN : process
    begin
        wait until reset = '1';

        wait on fsm_time_start;

        DATA_GEN_LOOP : for i in 0 to MAX_DATA_c-1 loop
            lcd_time_data      <= lcd_time_input_array(i);
            lcd_date_data      <= lcd_date_input_array(i);
            lcd_date_dow       <= lcd_dow_input_array(i);
            lcd_alarm_data     <= lcd_alarm_input_array(i);
            lcd_switchon_data  <= lcd_switchon_input_array(i);
            lcd_switchoff_data <= lcd_switchoff_input_array(i);
            lcd_countdown_data <= lcd_timer_input_array(i);
            lcd_stopwatch_data <= lcd_stopwatch_input_array(i);
            wait for CLK_100_PERIOD_c;
        end loop DATA_GEN_LOOP;
    end process DATA_GEN;

    -- Stimulus
    STIM : process
        variable index : std_logic_vector(6 downto 0);
    begin
        -- Generate input array
        INPUT_GEN : for i in 0 to MAX_DATA_c-1 loop

            index := std_logic_vector(to_unsigned(i+1, 7));
            lcd_time_input_array(i)      <= index & index & index; -- Input data: 1 -> MAX_DATA_c
            lcd_date_input_array(i)      <= index & index & index;
            lcd_alarm_input_array(i)     <= index & index;
            lcd_switchon_input_array(i)  <= index & index & index;
            lcd_switchoff_input_array(i) <= index & index & index;
            lcd_timer_input_array(i)     <= index & index & index;
            lcd_stopwatch_input_array(i) <= index & index & index & index;
            lcd_dow_input_array(i)       <= std_logic_vector(to_unsigned(i mod 7 + 1, 3));

        end loop INPUT_GEN;


        -- Generate reset
        wait for CLK_10K_PERIOD_c*2;
        reset <= '1';
        wait for CLK_10K_PERIOD_c*2;
        reset <= '0';
        wait for CLK_10K_PERIOD_c*9/2;

        -- Enable all features
        lcd_time_act      <= '1';
        lcd_alarm_act     <= '1';  -- Will go LOW later and lcd_alarm_snooze goes HIGH by then
        lcd_switchon_act  <= '1';
        lcd_switchoff_act <= '1';
        lcd_countdown_act <= '1';
        lcd_stopwatch_act <= '1';

        -- Wake up the display and activate TIME mode
        fsm_time_start <= '1';

        -- Activate DATE mode after 2 TIME data
        wait for CLK_100_PERIOD_c*19;
        wait on en_100;
        fsm_time_start <= '0';
        fsm_date_start <= '1';

        -- Test the snooze function
        wait for CLK_100_PERIOD_c*10;
        lcd_alarm_act    <= '0';
        lcd_alarm_snooze <= '1';
        wait for CLK_100_PERIOD_c*10;
        lcd_alarm_snooze <= '0';
        wait for CLK_100_PERIOD_c*10;

        -- Activate ALARM mode after 3 DATE data
        wait on en_100;
        fsm_date_start  <= '0';
        fsm_alarm_start <= '1';

        -- Activate SWITCH-ON mode after 2 ALARM data
        wait for CLK_100_PERIOD_c*20;
        wait on en_100;
        fsm_alarm_start    <= '0';
        fsm_switchon_start <= '1';

        -- Activate SWITCH-OFF mode after 2 SWITCH-ON data
        wait for CLK_100_PERIOD_c*20;
        wait on en_100;
        fsm_switchon_start  <= '0';
        fsm_switchoff_start <= '1';

        -- Activate COUNTDOWN mode after 2 SWITCH-OFF data
        wait for CLK_100_PERIOD_c*20;
        wait on en_100;
        fsm_switchoff_start <= '0';
        fsm_countdown_start <= '1';

        -- Activate STOPWATCH mode after 2 COUNTDOWN data
        wait for CLK_100_PERIOD_c*20;
        wait on en_100;
        fsm_countdown_start <= '0';
        fsm_stopwatch_start <= '1';

        -- Activate TIME mode after 2 STOPWATCH data
        wait for CLK_100_PERIOD_c*20;
        wait on en_100;
        fsm_stopwatch_start <= '0';
        fsm_time_start      <= '0';  -- Ends up at INIT state

        wait;
    end process STIM;

end architecture behavior;