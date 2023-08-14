--------------------------------------------------------------------------------
-- Author       : Quang Phan
-- Author email : quang.phan@tum.de
-- Create Date  : 18/07/2022
-- Project Name : Project Lab IC Design
-- Module Name  : display_standalone.vhd
-- Description  : Standalone display module of the CLOCK for testing purpose
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
--use IEEE.std_logic_ARITH.ALL;
use IEEE.std_logic_UNSIGNED.ALL;
use IEEE.numeric_std.all;

entity display_standalone is
    port (
	    GCLK : in std_logic; -- Clock source running at 100.00 MHz

		BTNC : in std_logic; -- Button Center
		BTNU : in std_logic; -- Button Up
		BTND : in std_logic; -- Button Down
		BTNL : in std_logic; -- Button Left
		BTNR : in std_logic; -- Button Right
		SW : in std_logic_vector(7 downto 0); -- Switches
		LED : out std_logic_vector(7 downto 0); -- LEDs

		-- OLED_DC : out std_logic;
		-- OLED_RES : out std_logic;
		-- OLED_SCLK : out std_logic;
		-- OLED_SDIN : out std_logic;
		-- OLED_VBAT : out std_logic;
		-- OLED_VDD : out std_logic;

		LCD_E : out std_logic;
		LCD_RW : out std_logic;
		LCD_RS : out std_logic;
		LCD_DATA : out std_logic_vector(7 downto 0) -- LCD Data
	);
end entity display_standalone;

architecture behavior of display_standalone is

    -- Constant
    constant HH_MM_c       : std_logic_vector(13 downto 0) := "00100010010010"; -- 17:18
    constant HH_MM_SS_c    : std_logic_vector(20 downto 0) := "001000100100100010011"; -- 17:18:19
    constant HH_MM_SS_CS_c : std_logic_vector(27 downto 0) := "0010001001001000100110010100"; -- 17:18:19.20
    constant DD_MM_YY_c    : std_logic_vector(20 downto 0) := "001000100010100010110"; -- 17.10.22
    constant DOW_c         : std_logic_vector( 2 downto 0) := "011"; -- Do

    -- FSM control signals
    signal fsm_time_start      : std_logic := '0';
    signal fsm_date_start      : std_logic := '0';
    signal fsm_alarm_start     : std_logic := '0';
    signal fsm_switchon_start  : std_logic := '0';
    signal fsm_switchoff_start : std_logic := '0';
    signal fsm_countdown_start : std_logic := '0';
    signal fsm_stopwatch_start : std_logic := '1';

    -- Trigger signals for starting of states
    signal cnt_r : integer := 0;
    signal data_cnt_r : integer := 0;
    signal stw_data : std_logic_vector(27 downto 0);
    signal time_data : std_logic_vector(20 downto 0);

    -- Clock
    signal clk : std_logic := '0'; -- Internal clock running at 10.00 kHz
	signal en_1K : std_logic := '0';
	signal en_100 : std_logic := '0';
	signal en_10 : std_logic := '0';
	signal en_1 : std_logic := '0';

    -- DCF data
	signal dcf_generated : std_logic := '0'; -- Generated DCF signal
	signal dcf : std_logic := '0'; -- Selected DCF signal

    -- LED outputs
	signal led_alarm_act : std_logic := '0';
	signal led_alarm_ring : std_logic := '0';
	signal led_countdown_act : std_logic := '0';
	signal led_countdown_ring : std_logic := '0';
	signal led_switch_act : std_logic := '0';
	signal led_switch_on : std_logic := '0';

	-- Act signals
    signal lcd_time_act      : std_logic;
    signal lcd_alarm_act     : std_logic;
    signal lcd_alarm_snooze  : std_logic;
    signal lcd_switchon_act  : std_logic;
    signal lcd_switchoff_act : std_logic;
    signal lcd_countdown_act : std_logic;
    signal lcd_stopwatch_act : std_logic;

	-- STW signals
	signal cs : std_logic_vector(6 downto 0);
	signal ss : std_logic_vector(6 downto 0);
	signal mm : std_logic_vector(6 downto 0);
	signal hh : std_logic_vector(6 downto 0);
	signal key_plus_imp : std_logic;
	signal key_minus_imp : std_logic;
	signal key_action_imp : std_logic;
	signal key_action_long : std_logic;
	signal key_mode_imp : std_logic;
	signal key_plus_minus : std_logic;
	signal key_enable : std_logic;

    -- Reset signals
	signal reset : std_logic := '1';		-- Internal reset signal, high for at least 16 cycles
	signal reset_counter : std_logic_vector(3 downto 0) := (others => '0');
	signal heartbeat: std_logic := '0'; --Heartbeat signal

begin

    -- Clock generator
    clock_gen: entity work.clock_gen
    port map(
        clk => GCLK,
        clk_10K => clk,
        en_1K => en_1K,
        en_100 => en_100,
        en_10 => en_10,
        en_1 => en_1
    );

    -- DCF generator
    dcf_gen : entity work.dcf_gen
    port map(
        clk => clk,
        reset => reset,
        en_10 => en_10,
        en_1 => en_1,
        dcf => dcf_generated
    );

    -- Generate Reset signal
	reset_gen: process(clk)
	begin
		if rising_edge(clk) then
			if BTND='1' then
				reset <= '1';
				reset_counter <= (others => '0');
			elsif reset_counter=x"F" then
				reset <= '0';
			else
				reset <= '1';
				reset_counter <= reset_counter + x"1";
			end if;
		end if;
	end process;

    -- DCF MUX
	dcf_mux : process(SW, dcf_generated)
	begin
		if SW(1)='1' then
			dcf <= '0';
		else
			dcf <= dcf_generated;
		end if;
	end process;

    -- LED MUX
	led_mux : process(SW, heartbeat, dcf, led_alarm_act, led_alarm_ring, led_countdown_act, led_countdown_ring, led_switch_act, led_switch_on)
	begin
		if SW(0)='1' then
			LED <= "000000" & dcf & heartbeat;
		else
			LED <= led_alarm_act & led_alarm_ring & "0" &  led_countdown_act & led_countdown_ring & "0" & led_switch_act & led_switch_on;
		end if;
	end process;

    -- Display
    display_i : entity work.display
    port map (
        -- Clock and reset
        clk                 => clk,
        reset               => reset,
        en_100              => en_100,
        en_10               => en_10,
        -- Time
        fsm_time_start      => fsm_time_start,
        lcd_time_act        => lcd_time_act,
        lcd_time_data       => time_data,
        -- Date
        fsm_date_start      => fsm_date_start,
        lcd_date_dow        => DOW_c,
        lcd_date_data       => DD_MM_YY_c,
        -- Alarm
        fsm_alarm_start     => fsm_alarm_start,
        lcd_alarm_act       => lcd_alarm_act,
        lcd_alarm_snooze    => lcd_alarm_snooze,
        lcd_alarm_data      => HH_MM_c,
        -- Switch ON
        fsm_switchon_start  => fsm_switchon_start,
        lcd_switchon_act    => lcd_switchon_act,
        lcd_switchon_data   => time_data,
        -- Switch ON
        fsm_switchoff_start => fsm_switchoff_start,
        lcd_switchoff_act   => lcd_switchoff_act,
        lcd_switchoff_data  => time_data,
        -- Countdown
        fsm_countdown_start => fsm_countdown_start,
        lcd_countdown_act   => lcd_countdown_act,
        lcd_countdown_data  => time_data,
        -- Stopwatch
        fsm_stopwatch_start => fsm_stopwatch_start,
        lcd_stopwatch_act   => lcd_stopwatch_act,
        lcd_stopwatch_data  => stw_data,
        -- Output to LCD
        lcd_en              => LCD_E,
        lcd_rw              => LCD_RW,
        lcd_rs              => LCD_RS,
        lcd_data            => LCD_DATA
    );

    stw_i : entity work.stopwatch
    port map (
        clk                 => clk,
        en_100              => en_100,
        reset               => reset,
        fsm_stopwatch_start => fsm_stopwatch_start,
        key_plus_imp        => key_plus_imp,
        key_minus_imp       => key_minus_imp,
        key_action_imp      => key_action_imp,
        lcd_stopwatch_act   => lcd_stopwatch_act,
        cs                  => cs,
        ss                  => ss,
        mm                  => mm,
        hh                  => hh
    );

    key_ctrl_i : entity work.key_control
    port map (
        clk         => clk,
        reset       => reset,
        en_100      => en_100,
        en_10       => en_10,
        btn_action  => BTNC,
        btn_minus   => BTNL,
        btn_plus    => BTNR,
        btn_mode    => BTNU,
        action_imp  => key_action_imp,
        action_long => key_action_long,
        plus_imp    => key_plus_imp,
        minus_imp   => key_minus_imp,
        mode_imp    => key_mode_imp,
        plus_minus  => key_plus_minus,
        enable      => key_enable
    );

    -- Generate start & act
    GEN_START_ACT : process(clk)
    begin
        if (clk'EVENT and clk = '1') then
            if (reset = '1') then
                cnt_r               <= 0;
                fsm_time_start      <= '0';
                fsm_date_start      <= '0';
                fsm_alarm_start     <= '0';
                fsm_switchon_start  <= '0';
                fsm_switchoff_start <= '0';
                fsm_countdown_start <= '0';
                fsm_stopwatch_start <= '0';
            else
                if ( cnt_r = 20000 ) then
                    fsm_time_start      <= '1';
                    fsm_date_start      <= '0';
                    fsm_alarm_start     <= '0';
                    fsm_switchon_start  <= '0';
                    fsm_switchoff_start <= '0';
                    fsm_countdown_start <= '0';
                    fsm_stopwatch_start <= '0';
                elsif ( cnt_r = 70000 ) then
                    lcd_time_act        <= '1';
                elsif ( cnt_r = 120000 ) then
                    fsm_time_start      <= '0';
                    fsm_date_start      <= '1';
                    fsm_alarm_start     <= '0';
                    fsm_switchon_start  <= '0';
                    fsm_switchoff_start <= '0';
                    fsm_countdown_start <= '0';
                    fsm_stopwatch_start <= '0';
                elsif ( cnt_r = 220000 ) then
                    lcd_countdown_act   <= '1';
                    fsm_time_start      <= '0';
                    fsm_date_start      <= '0';
                    fsm_alarm_start     <= '1';
                    fsm_switchon_start  <= '0';
                    fsm_switchoff_start <= '0';
                    fsm_countdown_start <= '0';
                    fsm_stopwatch_start <= '0';
                elsif ( cnt_r = 260000 ) then
                    lcd_alarm_act       <= '1';
                elsif ( cnt_r = 295000 ) then
                    lcd_alarm_act       <= '0';
                    lcd_alarm_snooze    <= '1';
                elsif ( cnt_r = 320000 ) then
                    lcd_alarm_snooze    <= '0';
                    lcd_switchon_act    <= '0';
                    fsm_time_start      <= '0';
                    fsm_date_start      <= '0';
                    fsm_alarm_start     <= '0';
                    fsm_switchon_start  <= '1';
                    fsm_switchoff_start <= '0';
                    fsm_countdown_start <= '0';
                    fsm_stopwatch_start <= '0';
                elsif ( cnt_r = 370000 ) then
                    lcd_switchon_act    <= '1';
                elsif ( cnt_r = 420000 ) then
                    lcd_switchon_act    <= '0';
                    fsm_time_start      <= '0';
                    fsm_date_start      <= '0';
                    fsm_alarm_start     <= '0';
                    fsm_switchon_start  <= '0';
                    fsm_switchoff_start <= '1';
                    fsm_countdown_start <= '0';
                    fsm_stopwatch_start <= '0';
                elsif ( cnt_r = 470000 ) then
                    lcd_switchoff_act   <= '1';
                elsif ( cnt_r = 520000 ) then
                    lcd_time_act        <= '0';
                    lcd_alarm_snooze    <= '1';
                    lcd_switchoff_act   <= '0';
                    fsm_time_start      <= '0';
                    fsm_date_start      <= '0';
                    fsm_alarm_start     <= '0';
                    fsm_switchon_start  <= '0';
                    fsm_switchoff_start <= '0';
                    fsm_countdown_start <= '1';
                    fsm_stopwatch_start <= '0';
                elsif ( cnt_r = 570000 ) then
                    lcd_countdown_act   <= '0';
                elsif ( cnt_r = 620000 ) then
                    fsm_time_start      <= '0';
                    fsm_date_start      <= '0';
                    fsm_alarm_start     <= '0';
                    fsm_switchon_start  <= '0';
                    fsm_switchoff_start <= '0';
                    fsm_countdown_start <= '0';
                    fsm_stopwatch_start <= '1';
                elsif ( cnt_r = 670000 ) then
                    --lcd_stopwatch_act   <= '1';
                elsif ( cnt_r = 720000 ) then
                    --lcd_stopwatch_act   <= '0';
                end if;

                cnt_r <= cnt_r + 1;

            end if;
        end if;
    end process GEN_START_ACT;

    -- Generate the stopwatch data
    GEN_STW_DATA : process(clk)
    begin
        if (clk'EVENT and clk = '1') then
            if (reset = '1') then
                data_cnt_r <= 0;
            else
                if ( en_1 = '1' ) then
                    data_cnt_r <= data_cnt_r + 1;
                end if;
            end if;
        end if;
    end process GEN_STW_DATA;

    -- Data assignment
    -- stw_data <= std_logic_vector(to_unsigned(stw_cnt_r, 28));
    stw_data <= hh & mm & ss & cs;
    time_data <= std_logic_vector(to_unsigned(data_cnt_r, 21));

end architecture behavior;
