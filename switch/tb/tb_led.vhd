----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.07.2022 10:53:44
-- Design Name: 
-- Module Name: tb_led - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_led is
--  Port ( );
end tb_led;

architecture Behavioral of tb_led is
    component led
        Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           active : in STD_LOGIC;
           ss_on : in STD_LOGIC_VECTOR (5 downto 0);
           mm_on : in STD_LOGIC_VECTOR (5 downto 0);
           hh_on : in STD_LOGIC_VECTOR (4 downto 0);
           ss_off : in STD_LOGIC_VECTOR (5 downto 0);
           mm_off : in STD_LOGIC_VECTOR (5 downto 0);
           hh_off : in STD_LOGIC_VECTOR (4 downto 0);
           ss : in STD_LOGIC_VECTOR (5 downto 0);
           mm : in STD_LOGIC_VECTOR (5 downto 0);
           hh : in STD_LOGIC_VECTOR (4 downto 0);
           led : out STD_LOGIC);
    end component;
    signal rst, clk, active: std_logic := '0';
    signal ss_on : STD_LOGIC_VECTOR (5 downto 0):= "000010";
    signal ss_off : STD_LOGIC_VECTOR (5 downto 0):= "000110";
    signal mm_on, mm_off : STD_LOGIC_VECTOR (5 downto 0):= (others => '0');
    signal hh_on, hh_off : STD_LOGIC_VECTOR (4 downto 0):= (others => '0');
    signal ss : STD_LOGIC_VECTOR (5 downto 0):= (others => '0');
    signal mm : STD_LOGIC_VECTOR (5 downto 0):= (others => '0');
    signal hh : STD_LOGIC_VECTOR (4 downto 0):= (others => '0');
    signal LEDon : std_logic;
    constant clk_period: time := 10 ns;

begin
    uut: led port map ( ss_on=>ss_on, ss_off=>ss_off, ss=>ss, mm=>mm, mm_on=>mm_on, mm_off=>mm_off, 
                        hh=>hh, hh_on=>hh_on, hh_off=>hh_off, clk=>clk, active=>active, rst=>rst, led=>LEDon);
    clock: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process clock;
    process
    begin 
    wait for 10 ns;
    active <= '1';
    wait for 10 ns;
    ss <= "000010";
    wait for 10 ns;
    ss <= "000011";
    wait for 10 ns;
    rst <= '1';
    ss <= "000111";
    wait for 10 ns;
    rst <= '0';
    ss <= "000101";
    wait for 50 ns;
    ss <= "000110";
    wait;
    end process;
end Behavioral;
