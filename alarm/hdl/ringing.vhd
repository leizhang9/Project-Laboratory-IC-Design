----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Bo Zhou
-- 
-- 
-- Create Date: 25.06.2022 10:21:44
-- Design Name: 
-- Module Name: ringing - Behavioral
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

entity ringing is
    Port ( ss_alarm : in STD_LOGIC_VECTOR (5 downto 0);
           mm_alarm : in STD_LOGIC_VECTOR (5 downto 0);
           hh_alarm : in STD_LOGIC_VECTOR (4 downto 0);
           ss_current : in STD_LOGIC_VECTOR (5 downto 0);
           mm_current : in STD_LOGIC_VECTOR (5 downto 0);
           hh_current : in STD_LOGIC_VECTOR (4 downto 0);
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           I_act : in STD_LOGIC;
           snooze_state : in STD_LOGIC;
           snooze_1min : in STD_LOGIC;
           action_stop : in STD_LOGIC;
           action_long : in STD_LOGIC;
           action_imp : in STD_LOGIC;
           O_ring : out STD_LOGIC;
           O_snooze : out STD_LOGIC);
end ringing;

architecture Behavioral of ringing is
    signal reg_1, enable: std_logic := '0';
    
begin
process (clk, rst, ss_alarm, ss_current, mm_alarm, mm_current, hh_alarm, hh_current, snooze_1min, action_stop, reg_1, I_act, snooze_state)
    variable cnt: integer range 0 to 20100;
begin
    if (clk = '1' and clk'EVENT) then
        if (enable='1') then
                --cnt := 0;
            if (cnt=20100) then
                reg_1 <= '0';
                O_snooze <= '1';
                enable <= '0';
                cnt := 0;
            elsif (action_long='1') then
                enable <= '0';
                cnt := 0;
            else
                cnt := cnt +1;
            end if;
        end if;
        if (rst='1')then
            reg_1 <= '0';
        else
        if (ss_alarm=ss_current) and (mm_alarm=mm_current) and (hh_alarm=hh_current) then
            reg_1 <= I_act;
        --1 min snooze is reached
        elsif (snooze_1min='1') then
            reg_1 <= I_act;
        --press action short and get into snooze, ringing stop
        elsif (action_imp='1') and (reg_1='1') then
            enable <= '1';
            
        --press action long or 1 min no action, ringing stop
        elsif (snooze_state='0') then
            if (action_stop='1') or (action_long='1') then
                reg_1 <= '0';
            end if;
        end if;        
        end if;
        if (reg_1='0') then
            O_snooze <= '0';
        end if;
    end if;
end process;
O_ring <= reg_1;

end Behavioral;
