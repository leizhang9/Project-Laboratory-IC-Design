----------------------------------------------------------------------------------
-- 
-- Author: Lei Zhang 
-- 
-- Create Date: 2022/07/05
-- Design Name: tb_time_date
-- Module Name: tb_time_date
-- Project Name: Lab IC desgin
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

entity tb_time_date is
--  Port ( );
end tb_time_date;

architecture Behavioral of tb_time_date is
    component time_date
        port(
    de_set: in std_logic;
    de_dow : in std_logic_vector(2 downto 0);
    de_day : in std_logic_vector(5 downto 0);
    de_month : in std_logic_vector(4 downto 0);
    de_year : in std_logic_vector(7 downto 0);
    de_hour: in std_logic_vector(5 downto 0);
    de_min: in std_logic_vector(6 downto 0);
    clk: in std_logic;
    en_1: in std_logic;
    rst: in std_logic;
    hour: out std_logic_vector(6 downto 0);
    minute: out std_logic_vector(6 downto 0);
    second: out std_logic_vector(6 downto 0);
    dow: out std_logic_vector(2 downto 0);
    year: out std_logic_vector(6 downto 0);
    month: out std_logic_vector(6 downto 0);
    day: out std_logic_vector(6 downto 0);
    lcd_dcf: out std_logic);
    end component;
    
    component dcf_decode
        Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           en_100 : in  STD_LOGIC;
           dcf : in  STD_LOGIC;
           de_set : out  STD_LOGIC;
           de_dow : out  STD_LOGIC_VECTOR (2 downto 0);
           de_day : out  STD_LOGIC_VECTOR (5 downto 0);
           de_month : out  STD_LOGIC_VECTOR (4 downto 0);
           de_year : out  STD_LOGIC_VECTOR (7 downto 0);
           de_hour : out  STD_LOGIC_VECTOR (5 downto 0);
           de_min : out  STD_LOGIC_VECTOR (6 downto 0));

    end component;
    
    component dcf_gen
        Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           en_10 : in  STD_LOGIC;
           en_1 : in  STD_LOGIC;
           dcf : out  STD_LOGIC);
    end component;
    
           signal clk :  STD_LOGIC:='1';
           signal reset :   STD_LOGIC;
           signal en_100 :   STD_LOGIC:='1';
           signal en_10: std_logic:='1';
           signal en_1: std_logic:='1';
           signal dcf :   STD_LOGIC;
           signal de_set :   STD_LOGIC;
           signal de_dow :   STD_LOGIC_VECTOR (2 downto 0);
           signal de_day :   STD_LOGIC_VECTOR (5 downto 0);
           signal de_month :   STD_LOGIC_VECTOR (4 downto 0);
           signal de_year :   STD_LOGIC_VECTOR (7 downto 0);
           signal de_hour :   STD_LOGIC_VECTOR (5 downto 0);
           signal de_min :   STD_LOGIC_VECTOR (6 downto 0);
    

    signal hour: std_logic_vector(6 downto 0);
    signal minute: std_logic_vector(6 downto 0);
    signal second: std_logic_vector(6 downto 0);
    signal dow: std_logic_vector(2 downto 0);
    signal year: std_logic_vector(6 downto 0);
    signal month: std_logic_vector(6 downto 0);
    signal day: std_logic_vector(6 downto 0);
    signal lcd_dcf: std_logic;
    
begin
    uut:time_date port map ( de_set=>de_set,
    de_dow=>de_dow,
    de_day=>de_day,
    de_month=>de_month,
    de_year=>de_year,
    de_hour=>de_hour,
    de_min=>de_min,
    clk=>clk,
    en_1=>en_1,
    rst=>reset,
    hour=>hour,
    minute=>minute,
    second=>second,
    dow=>dow,
    year=>year,
    month=>month,
    day=>day,
    lcd_dcf=>lcd_dcf);
    
    uut_dcf_decoder: dcf_decode port map (clk =>clk,
           reset =>reset,
           en_100  =>en_100,
           dcf =>dcf,
           de_set =>de_set,
           de_dow =>de_dow,
           de_day =>de_day,
           de_month =>de_month,
           de_year =>de_year,
           de_hour =>de_hour,
           de_min =>de_min);
           
    uut_dcf_gen: dcf_gen port map 
            ( clk  =>clk,
           reset    =>reset,
           en_10    =>en_10,
           en_1     =>en_1,
           dcf      =>dcf);
           
    process
    begin
    wait for 0.05 ms;
    clk<=not clk;
    end process;
    
    process 
    begin
    wait for 0.05 ms;
    en_100<=not en_100;
    wait for 9.95 ms;
    en_100<=not en_100;
    end process;
    
    en_10_gen: process
    begin
    wait for 0.05 ms;
    en_10<=not en_10;
    wait for 99.95 ms;
    en_10<=not en_10;
    end process;
    
    en_1_gen: process
    begin
    wait for 0.05 ms;
    en_1<=not en_1;
    wait for 999.95 ms;
    en_1<=not en_1;
    end process;
    
    process
    begin
    wait for 50 ms;
    reset<='1';
    wait for 100 ms;
    reset <='0';
    wait;
    end process;

end Behavioral;
