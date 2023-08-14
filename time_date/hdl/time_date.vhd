----------------------------------------------------------------------------------
-- 
-- Author: Lei Zhang 
-- 
-- Create Date: 2022/07/05
-- Design Name: time_date
-- Module Name: time_date
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
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Time_Date is
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
   
end Time_Date;

architecture Behavioral of Time_Date is
    signal second_int: unsigned(5 downto 0);
    signal minute_int: unsigned(5 downto 0);
    signal minute_int2:unsigned(5 downto 0);
    signal hour_int: unsigned(4 downto 0);
    signal hour_int2: unsigned(4 downto 0);
    signal day_int: unsigned(4 downto 0);
    signal day_int2: unsigned(4 downto 0);
    signal month_int: unsigned(3 downto 0);
    signal month_int2: unsigned(3 downto 0);
    signal year_int: unsigned(6 downto 0);
    signal year_int2:unsigned(6 downto 0);
    signal dow_int: unsigned(2 downto 0);
    signal dow_int2:unsigned(2 downto 0);
    
    signal day_max: unsigned(4 downto 0);
    signal leap_year: std_logic;
    
    
begin
    second_counter:process(clk)
    begin
        if clk'event and clk='1' then
            if rst='1' then
                second_int<="000000";
            elsif de_set='1' and de_min(5 downto 0)/=std_logic_vector(minute_int) then
                second_int<="000000";
            else
            
                if en_1='1' then --
   
                        if second_int>=59 then
                            second_int<="000000";
                        else 
                            second_int<=second_int+"000001";
                        end if;
                    
                end if; --
            
            end if;
        end if;
    end process;
    
    
    minute_counter: process(clk)
    begin
        if clk'event and clk='1' then
            if rst='1' then
                minute_int<="000000";
            elsif de_set='1' and de_min(5 downto 0)/=std_logic_vector(minute_int) then  
                        minute_int<=unsigned(de_min(5 downto 0));
       
            else
                if en_1='1' then ---
                        
                        if second_int=59 then
                            if minute_int=59 then
                                minute_int<="000000";
                            else 
                                minute_int<=minute_int+"000001";
                            end if;
                        else
                            minute_int<=minute_int2;--avoid latch
                        end if;
                end if;    --
            end if;
        end if;
    end process;
    
    process(minute_int, minute_int2)
    begin
        minute_int2<=minute_int;
    end process;
    
    hour_counter: process(clk)
    begin
        if clk'event and clk='1' then
            if rst='1' then
                hour_int<="00000";
            elsif de_set='1' and de_hour(4 downto 0)/=std_logic_vector(hour_int) then --
                    hour_int<=unsigned(de_hour(4 downto 0));
 
            else
                if en_1='1' then  ---
                    if second_int=59 and minute_int=59 then
                        if hour_int=23 then
                            hour_int<="00000";
                        else 
                            hour_int<=hour_int+"00001";
                        end if;
                    else
                        hour_int<=hour_int2;--avoid latch
                    end if;
                end if;    --
            end if;
        end if;
    end process;

    process(hour_int,hour_int2)
    begin
        hour_int2<=hour_int;
    end process;
    
   day_counter: process(clk)
    begin
        if clk'event and clk='1' then
            if rst='1' then
                day_int<="00001";
            elsif de_set='1' and de_day(4 downto 0)/=std_logic_vector(day_int) then --
                    day_int<=unsigned(de_day(4 downto 0));
            else
                if en_1='1' then ---
                
                    if second_int=59 and minute_int=59 and hour_int=23 then
                        if day_int>=day_max then
                            day_int<="00001";
                        else 
                            day_int<=day_int+"00001";
                        end if;
                    else
                        day_int<=day_int2;--avoid latch
                    end if;
                end if;    --    
            end if;
        end if;
    end process;
    
    process(day_int,day_int2)
    begin
        day_int2<=day_int;
    end process;
    
    
    month_counter: process(clk)
    begin
        if clk'event and clk='1' then
            if rst='1' then
                month_int<="0001";
            elsif de_set='1' and de_month(3 downto 0)/=std_logic_vector(month_int) then --
                    month_int<=unsigned(de_month(3 downto 0));
            else
                if en_1='1' then  ---
   
                    if second_int=59 and minute_int=59 and hour_int=23 and day_int=day_max then
                        if month_int>=12 then
                            month_int<="0001";
                        else 
                            month_int<=month_int+"0001";
                        end if;
                    else 
                        month_int<=month_int2; --avoid latch
                    end if;
                end if;     --
            end if;
        end if;
    end process;
    
    process(month_int, month_int2)
    begin
        month_int2<=month_int;
    end process;
    
    year_counter: process(clk)
    begin
        if clk'event and clk='1' then
            if rst='1' then
                year_int<="0000001";
            elsif de_set='1' and de_year(6 downto 0)/=std_logic_vector(year_int) then --
                    year_int<=unsigned(de_year(6 downto 0));
            else
                if en_1='1' then  ---

                    if second_int=59 and minute_int=59 and hour_int=23 and day_int=day_max and month_int=12 then
                        year_int<=year_int+"0000001";
                    else
                        year_int<=year_int2;
                    end if;
                end if;     --
            end if;
        end if;
    end process;
    
    process(year_int, year_int2)
    begin
        year_int2<=year_int;
    end process;
    
    dow_counter: process(clk)
    begin
        if clk'event and clk='1' then
            if rst='1' then
                dow_int<="001";
            elsif de_set='1' and de_dow/=std_logic_vector(dow_int) then --
                    dow_int<=unsigned(de_dow);
            else
                if en_1='1' then  ---
  
                    if second_int=59 and minute_int=59 and hour_int=23 then
                        if dow_int="111" then
                            dow_int<="001";
                        else 
                            dow_int<=dow_int+"001";
                        end if;
                    else
                        dow_int<=dow_int2;--avoid latch
                    end if;
                end if;    --
            end if;
        end if;
    end process;
    
    process(dow_int, dow_int2)
    begin
        dow_int2<=dow_int;
    end process;
    
    day_max_assignment: process(month_int,leap_year)
    begin
        case month_int is 
        when "0001"|"0011"|"0101"|"0111"|"1000"|"1010"|"1100"=>  --1,3,5,7,8,10,12
            day_max<="11111";  --31
        when "0100"|"0110"|"1001"|"1011"=>    --4,6,9,11
            day_max<="11110";  --30
        when "0010"=>
            if leap_year='1' then 
                day_max<="11101";  --29
            else 
                day_max<="11100";  --28
            end if;
        when others=>
        end case;
    end process;
          
    leap_year_assignment: process(year_int)
    begin
        if (year_int rem 4=0 and year_int rem 4 /=0)or(year_int rem 400=0) then
            leap_year<='1';
        else 
            leap_year<='0';
        end if;
    end process;  
                
    lcd_dcf_assignment: process(clk)
    begin
        if clk'event and clk='1' then
            if rst='1' then
                lcd_dcf<='0';
            elsif de_set='1' then
                lcd_dcf<='1';
            elsif de_set='0' and second_int=59 then
                lcd_dcf<='0';
                --
--            else
--                lcd_dcf<='0';
            end if;
        end if;
    end process;
                    
                   
                
                
    second<='0'&std_logic_vector(second_int);
    minute<='0'&std_logic_vector(minute_int);
    hour<='0'&'0'&std_logic_vector(hour_int);
    day<='0'&'0'&std_logic_vector(day_int);
    month<='0'&'0'&'0'&std_logic_vector(month_int);
    year<=std_logic_vector(year_int);
    dow<=std_logic_vector(dow_int);
    

end Behavioral;