--------------------------------------------------------------------------------
-- Author       : Quang Phan
-- Author email : quang.phan@tum.de
-- Create Date  : 27/06/2022
-- Project Name : Project Lab IC Design
-- Module Name  : transmitter_lcd.vhd
-- Description  : Transmitter to control the output flow
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity transmitter_lcd is
    port (
        -- Clock and reset
        clk           : in  std_logic;
        reset         : in  std_logic;
        -- Data in
        data_in       : in  std_logic_vector(10 downto 0);
        data_in_ready : in  std_logic;
        -- Output to LCD
        lcd_en        : out std_logic;
        lcd_rw        : out std_logic;
        lcd_rs        : out std_logic;
        lcd_data      : out std_logic_vector(7 downto 0);
        -- Acknowledge for transmission
        lcd_ack       : out std_logic
    );
end entity transmitter_lcd;

architecture behavior of transmitter_lcd is

    -- Zero command
    constant CMD_ALL_ZEROS_c : std_logic_vector(10 downto 0) := "00000000000";
    -- Internal registers / signals
    signal data_out_r : std_logic_vector(10 downto 0) := CMD_ALL_ZEROS_c;

begin

    -- Output assignments
    lcd_en   <= data_out_r(10);
    lcd_rs   <= data_out_r(9);
    lcd_rw   <= data_out_r(8);
    lcd_data <= data_out_r(7 downto 0);
    lcd_ack  <= '1';

    -- Process
    SEND : process (clk) is
    begin
        if ( clk'EVENT and clk = '1') then
            if ( reset = '1' ) then
                data_out_r <= CMD_ALL_ZEROS_c;
            else
                if ( data_in_ready = '1' ) then
                    data_out_r <= data_in; -- Send every clock cycle
                else
                    data_out_r <= CMD_ALL_ZEROS_c;
                end if;
            end if;
        end if;
    end process SEND;

end architecture behavior;