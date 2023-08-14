----------------------------------------------------------------------------------
-- Company:        TUM/LIS
-- Engineer:       Dirk Gabriel <dirk.gabriel@mytum.de>
-- 
-- Create Date:    12:53:32 04/17/2013 
-- Design Name: 
-- Module Name:    hardware - Behavioral 
-- Project Name:   Project Lab IC-Design
-- Target Devices: 
-- Tool versions: 
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
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_ARITH.ALL;
use IEEE.std_logic_UNSIGNED.ALL;


entity hardware is
	port (
		GCLK : in std_logic;	-- Clock source running at 100.00 MHz
		
		BTNC : in std_logic; -- Button Center
		BTNU : in std_logic; -- Button Up
		BTND : in std_logic; -- Button Down
		BTNL : in std_logic; -- Button Left
		BTNR : in std_logic; -- Button Right
		SW : in std_logic_vector(7 downto 0); -- Switches
		LED : out std_logic_vector(7 downto 0); -- LEDs
		
--		OLED_DC : out std_logic;
--		OLED_RES : out std_logic;
--		OLED_SCLK : out std_logic;
--		OLED_SDIN : out std_logic;
--		OLED_VBAT : out std_logic;
--		OLED_VDD : out std_logic;
		
		LCD_E : out std_logic;
		LCD_RW : out std_logic;
		LCD_RS : out std_logic;
		LCD_DATA : out std_logic_vector(7 downto 0) -- LCD Data
	);	
end hardware;

architecture Behavioral of hardware is
	
	signal clk : std_logic := '0'; -- Internal clock running at 10.00 kHz
	signal en_1K : std_logic := '0';
	signal en_100 : std_logic := '0';
	signal en_10 : std_logic := '0';
	signal en_1 : std_logic := '0';
	
	signal dcf_generated : std_logic := '0'; -- Generated DCF signal
	signal dcf : std_logic := '0'; -- Selected DCF signal
	
	signal led_alarm_act : std_logic := '0';
	signal led_alarm_ring : std_logic := '0';
	signal led_countdown_act : std_logic := '0';
	signal led_countdown_ring : std_logic := '0';
	signal led_switch_act : std_logic := '0';
	signal led_switch_on : std_logic := '0';

	signal reset : std_logic := '1';		-- Internal reset signal, high for at least 16 cycles
	signal reset_counter : std_logic_vector(3 downto 0) := (others => '0');
	signal heartbeat: std_logic := '0'; --Heartbeat signal
	
	--signal cpu_mio : std_logic_vector(53 downto 0) := (others => '0');
	
	
begin	
	-- Generate 10kHz Clock
	clock_gen: entity work.clock_gen
		port map(
			clk => GCLK,
			clk_10K => clk,
			en_1K => en_1K,
			en_100 => en_100,
			en_10 => en_10,
			en_1 => en_1
		);
		
	-- DCF Generator
	dcf_gen : entity work.dcf_gen
		port map(
			clk => clk,
			reset => reset,
			en_10 => en_10,
			en_1 => en_1,
			dcf => dcf_generated
		);
		
	--Generate Reset signal
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
	
	-- Generate Heartbeat
	heartbeat_gen: process(clk)
	begin
		if rising_edge(clk) then
			if en_1='1' then
				heartbeat <= not(heartbeat);
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

	-- Clock Main Module
	top : entity work.top
		port map(
			clk => clk,
			reset => reset,
			en_1K => en_1K,
			en_100 => en_100,
			en_10 => en_10,
			en_1 => en_1,
			key_action => BTNC,
			key_mode => BTNU,
			key_minus => BTNL,
			key_plus => BTNR,
			dcf_data => dcf,
			led_alarm_act => led_alarm_act,
			led_alarm_ring => led_alarm_ring,
			led_countdown_act => led_countdown_act,
			led_countdown_ring => led_countdown_ring,
			led_switch_act => led_switch_act,
			led_switch_on => led_switch_on,
			
			--oled_en => OLED_SCLK,
			--oled_dc => OLED_DC,
			--oled_data => OLED_SDIN,
			--oled_reset => OLED_RES,
			--oled_vdd => OLED_VDD,
			--oled_vbat => OLED_VBAT
			
			lcd_en => LCD_E,
			lcd_rw => LCD_RW,
			lcd_rs => LCD_RS,
			lcd_data => LCD_DATA
		);
	
end Behavioral;

