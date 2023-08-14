--------------------------------------------------------------------------------
-- Author       : Quang Phan
-- Author email : quang.phan@tum.de
-- Create Date  : 18/07/2022
-- Project Name : Project Lab IC Design
-- Module Name  : tb_display_standalone.vhd
-- Description  : Testbench for module : display_standalone.vhd
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_ARITH.ALL;
use IEEE.std_logic_UNSIGNED.ALL;

entity tb_display_standalone is
end entity tb_display_standalone;

architecture behavior of tb_display_standalone is

    -- Component Declaration for the Unit Under Test (UUT)
    component display_standalone
    port (
        -- Clock
        GCLK : in std_logic; -- Clock source running at 100.00 MHz
        -- Inputs
		BTNC : in std_logic; -- Button Center
		BTNU : in std_logic; -- Button Up
		BTND : in std_logic; -- Button Down
		BTNL : in std_logic; -- Button Left
		BTNR : in std_logic; -- Button Right
		SW : in std_logic_vector(7 downto 0); -- Switches
		LED : out std_logic_vector(7 downto 0); -- LEDs
        -- Oled output (unused)
		-- OLED_DC : out std_logic;
		-- OLED_RES : out std_logic;
		-- OLED_SCLK : out std_logic;
		-- OLED_SDIN : out std_logic;
		-- OLED_VBAT : out std_logic;
		-- OLED_VDD : out std_logic;
        -- Outputs to LCD
		LCD_E : out std_logic;
		LCD_RW : out std_logic;
		LCD_RS : out std_logic;
		LCD_DATA : out std_logic_vector(7 downto 0) -- LCD Data
    );
    end component display_standalone;

    -- Internal wires
    -- Inputs
    signal GCLK : std_logic := '0';
    signal BTNC : std_logic := '0';
    signal BTNU : std_logic := '0';
    signal BTND : std_logic := '0';
    signal BTNL : std_logic := '0';
    signal BTNR : std_logic := '0';
    signal SW   : std_logic_vector(7 downto 0) := "11111111";
    -- Outputs
    signal LED      : std_logic_vector(7 downto 0) := "00000000";
    signal LCD_E    : std_logic := '0';
    signal LCD_RW   : std_logic := '0';
    signal LCD_RS   : std_logic := '0';
    signal LCD_DATA : std_logic_vector(7 downto 0) := "00000000";

    -- Output wrapper
    signal LCD_OUTPUT : std_logic_vector(10 downto 0) := (others => '0');

    -- Address wrapper
    signal LCD_ADDR : std_logic_vector(6 downto 0) := (others => '0');

    -- Clock period
    constant CLK_100M_period_c : time :=  10 ns;
    constant CLK_10K_period_c  : time := 100 us;

begin

    -- Output wrapper
    LCD_OUTPUT <= LCD_E & LCD_RS & LCD_RW & LCD_DATA;

    -- Address wrapper
    LCD_ADDR   <= LCD_DATA(6 downto 0);

    -- Instantiate the Unit Under Test (UUT)
    uut : display_standalone
    port map (
        GCLK     => GCLK,
        BTNC     => BTNC,
        BTNU     => BTNU,
        BTND     => BTND,
        BTNL     => BTNL,
        BTNR     => BTNR,
        SW       => SW,
        LED      => LED,
        LCD_E    => LCD_E,
        LCD_RW   => LCD_RW,
        LCD_RS   => LCD_RS,
        LCD_DATA => LCD_DATA
    );

    -- Clock 100 MHz generator
    CLK_100M_GEN : process
    begin
        wait for CLK_100M_PERIOD_c/2; -- 50/50 duty cycle
        GCLK <= not GCLK;
    end process CLK_100M_GEN;

    -- Stimulus
    STIM : process
    begin
        -- Generate reset by BTND
        wait for CLK_10K_PERIOD_c*2;
        BTND <= '1';
        wait for CLK_10K_PERIOD_c*2;
        BTND <= '0';
        wait for CLK_10K_PERIOD_c/2;

        -- Wait for a long time
        wait for 100 sec;

        -- Generate reset by BTND again
        wait for CLK_10K_PERIOD_c*2;
        BTND <= '1';
        wait for CLK_10K_PERIOD_c*2;
        BTND <= '0';
        wait for CLK_10K_PERIOD_c/2;

        wait;
    end process STIM;

end architecture behavior;