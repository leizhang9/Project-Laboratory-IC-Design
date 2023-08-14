--------------------------------------------------------------------------------
-- Author       : Quang Phan
-- Author email : quang.phan@tum.de
-- Create Date  : 18/07/2022
-- Project Name : Project Lab IC Design
-- Module Name  : tb_top.vhd
-- Description  : Testbench for top level
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_top is
end entity tb_top;

architecture behavior of tb_top is

    -- Component Declaration for the Unit Under Test (UUT)
    component top
    port (
        clk                : in  std_logic;
        reset              : in  std_logic;
        en_1K              : in  std_logic;
        en_100             : in  std_logic;
        en_10              : in  std_logic;
        en_1               : in  std_logic;
        key_action         : in  std_logic;
        key_mode           : in  std_logic;
        key_minus          : in  std_logic;
        key_plus           : in  std_logic;
        dcf_data           : in  std_logic;
        led_alarm_act      : out std_logic;
        led_alarm_ring     : out std_logic;
        led_countdown_act  : out std_logic;
        led_countdown_ring : out std_logic;
        led_switch_act     : out std_logic;
        led_switch_on      : out std_logic;
        -- Output
        lcd_en             : out std_logic;
        lcd_rw             : out std_logic;
        lcd_rs             : out std_logic;
        lcd_data           : out std_logic_vector(7 downto 0)
    );
    end component top;

    -- Internal wires
    -- Inputs
    signal clk                : std_logic := '0';
    signal reset              : std_logic := '0';
    signal en_1K              : std_logic := '0';
    signal en_100             : std_logic := '0';
    signal en_10              : std_logic := '0';
    signal en_1               : std_logic := '0';
    signal key_action         : std_logic := '0';
    signal key_mode           : std_logic := '0';
    signal key_minus          : std_logic := '0';
    signal key_plus           : std_logic := '0';
    signal dcf_data           : std_logic := '0';
    signal led_alarm_act      : std_logic := '0';
    signal led_alarm_ring     : std_logic := '0';
    signal led_countdown_act  : std_logic := '0';
    signal led_countdown_ring : std_logic := '0';
    signal led_switch_act     : std_logic := '0';
    signal led_switch_on      : std_logic := '0';
    -- Output
    signal lcd_en             : std_logic := '0';
    signal lcd_rw             : std_logic := '0';
    signal lcd_rs             : std_logic := '0';
    signal lcd_data           : std_logic_vector(7 downto 0) := (others => '0');

    -- Output wrappers
    signal lcd_output : std_logic_vector(10 downto 0);

    -- Input data count
    constant MAX_DATA_c : integer := 20;

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
    uut : top
    port map (
        clk                => clk,
        reset              => reset,
        en_1K              => en_1K,
        en_100             => en_100,
        en_10              => en_10,
        en_1               => en_1,
        key_action         => key_action,
        key_mode           => key_mode,
        key_minus          => key_minus,
        key_plus           => key_plus,
        dcf_data           => dcf_data,
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
        clk_10k <= not clk_10k;
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

        -- Test time module

        -- Generate reset
        wait for CLK_10K_PERIOD_c*2;
        reset <= '1';
        wait for CLK_10K_PERIOD_c*2;
        reset <= '0';
        wait for CLK_10K_PERIOD_c/2;

        -- Test date module

        -- Generate reset
        wait for CLK_10K_PERIOD_c*2;
        reset <= '1';
        wait for CLK_10K_PERIOD_c*2;
        reset <= '0';
        wait for CLK_10K_PERIOD_c/2;

        -- Test alarm module

        -- Generate reset
        wait for CLK_10K_PERIOD_c*2;
        reset <= '1';
        wait for CLK_10K_PERIOD_c*2;
        reset <= '0';
        wait for CLK_10K_PERIOD_c/2;

        -- Test switch-on module

        -- Generate reset
        wait for CLK_10K_PERIOD_c*2;
        reset <= '1';
        wait for CLK_10K_PERIOD_c*2;
        reset <= '0';
        wait for CLK_10K_PERIOD_c/2;

        -- Test switch-off module

        -- Generate reset
        wait for CLK_10K_PERIOD_c*2;
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