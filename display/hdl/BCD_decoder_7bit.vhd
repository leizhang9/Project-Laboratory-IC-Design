--------------------------------------------------------------------------------
-- Author       : Quang Phan
-- Author email : quang.phan@tum.de
-- Create Date  : 27/06/2022
-- Project Name : Project Lab IC Design
-- Module Name  : BCD_decoder_7bit.vhd
-- Description  : BCD decoder from one input to 2-digit output
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BCD_decoder_7bit is
    generic (N : integer := 7);
    port (
        bin_in  : in  std_logic_vector(6 downto 0);
        bcd_out : out std_logic_vector(7 downto 0)
    );
end entity BCD_decoder_7bit;

architecture behavior of BCD_decoder_7bit is
begin

    DECODER: process (bin_in) is
        variable dec_in : integer;
    begin
        -- Convert to decimal
        -- bcd_out(3 downto 0) <= bin_in mod 10;
        -- bcd_out(7 downto 4) <= bin_in / 10;
        dec_in := to_integer(unsigned(bin_in));
        bcd_out(3 downto 0) <= std_logic_vector(to_unsigned((dec_in mod 10), 4));
        bcd_out(7 downto 4) <= std_logic_vector(to_unsigned((dec_in / 10), 4));
    end process DECODER;

end architecture behavior;