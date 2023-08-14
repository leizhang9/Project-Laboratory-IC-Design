----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:31:29 08/26/2014 
-- Design Name: 
-- Module Name:    top - Behavioral 
-- Project Name: 
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
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           en_1K : in  STD_LOGIC;
           en_100 : in  STD_LOGIC;
           en_10 : in  STD_LOGIC;
           en_1 : in  STD_LOGIC;
           key_action : in  STD_LOGIC;
           key_mode : in  STD_LOGIC;
           key_minus : in  STD_LOGIC;
           key_plus : in  STD_LOGIC;
           dcf_data : in  STD_LOGIC;
           led_alarm_act : out  STD_LOGIC;
           led_alarm_ring : out  STD_LOGIC;
           led_countdown_act : out  STD_LOGIC;
           led_countdown_ring : out  STD_LOGIC;
           led_switch_act : out  STD_LOGIC;
           led_switch_on : out  STD_LOGIC;
			  
			  lcd_en : out std_logic;
			  lcd_rw : out std_logic;
			  lcd_rs : out std_logic;
			  lcd_data : out std_logic_vector(7 downto 0)
			  
			  -- OLED signal only for development
			  --oled_en : out std_logic;
			  --oled_dc : out std_logic;
			  --oled_data : out std_logic;
			  --oled_reset : out std_logic;
			  --oled_vdd : out std_logic;
			  --oled_vbat : out std_logic
		);
end top;

architecture Behavioral of top is
	signal key_action_imp : std_logic := '0';
	signal key_action_long : std_logic := '0';
	signal key_mode_imp : std_logic := '0';
	signal key_minus_imp : std_logic := '0';
	signal key_plus_imp : std_logic := '0';
	signal key_plus_minus : std_logic := '0';
	signal key_enable : std_logic := '0';

	signal de_set : std_logic := '0';
	signal de_dow : std_logic_vector (2 downto 0) := (others => '0');
	signal de_day : std_logic_vector (5 downto 0) := (others => '0');
	signal de_month : std_logic_vector (4 downto 0) := (others => '0');
	signal de_year : std_logic_vector (7 downto 0) := (others => '0');
	signal de_hour : std_logic_vector (5 downto 0) := (others => '0');
	signal de_min : std_logic_vector (6 downto 0) := (others => '0');

begin
	-- Key module
	key_control : entity work.key_control
		port map(
			clk => clk,
			reset => reset,
			en_10 => en_10,
			en_100 => en_100,
			btn_action => key_action,
			btn_mode => key_mode,
			btn_minus => key_minus,
			btn_plus => key_plus,
			action_imp => key_action_imp,
			action_long => key_action_long,
			mode_imp => key_mode_imp,
			minus_imp => key_minus_imp,
			plus_imp => key_plus_imp,
			plus_minus => key_plus_minus,
			enable => key_enable
		);

	-- DCF Decode
	dcf_decode : entity work.dcf_decode
		port map(
			clk => clk,
			reset => reset,
			en_100 => en_100,
			dcf => dcf_data,
			de_set => de_set,
			de_dow => de_dow,
			de_day => de_day,
			de_month => de_month,
			de_year => de_year,
			de_hour => de_hour,
			de_min => de_min
		);

	-- Clock Main Module
	clock_module : entity work.clock_module
		port map(
			clk => clk,
			reset => reset,
			en_1K => en_1K,
			en_100 => en_100,
			en_10 => en_10,
			en_1 => en_1,
			key_action_imp => key_action_imp,
			key_action_long => key_action_long,
			key_mode_imp => key_mode_imp,
			key_minus_imp => key_minus_imp,
			key_plus_imp => key_plus_imp,
			key_plus_minus => key_plus_minus,
			key_enable => key_enable,
			de_set => de_set,
			de_dow => de_dow,
			de_day => de_day,
			de_month => de_month,
			de_year => de_year,
			de_hour => de_hour,
			de_min => de_min,
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
			
			lcd_en => lcd_en,
			lcd_rw => lcd_rw,
			lcd_rs => lcd_rs,
			lcd_data => lcd_data
		);

end Behavioral;

