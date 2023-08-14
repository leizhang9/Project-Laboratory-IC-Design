--------------------------------------------------------------------------------
-- Author       : Quang Phan
-- Author email : quang.phan@tum.de
-- Create Date  : 27/06/2022
-- Project Name : Project Lab IC Design
-- Module Name  : BCD_decoder_28bit.vhd
-- Description  : BCD decoder from one input to 8-digit output
--                (4 outputs of 2-digit signal)
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BCD_decoder_28bit is
    port (
        bin28_in  : in  std_logic_vector(27 downto 0);
        bcd32_out : out std_logic_vector(31 downto 0)
    );
end entity BCD_decoder_28bit;

architecture behavior of BCD_decoder_28bit is

    -- Signal declaration
    signal bcd32_out_s : std_logic_vector(31 downto 0);

    -- Component declarations
    component BCD_decoder_7bit
    port (
        bin_in  : in  std_logic_vector(6 downto 0);
        bcd_out : out std_logic_vector(7 downto 0)
    );
    end component BCD_decoder_7bit;

begin

    -- Output assignment
    bcd32_out <= bcd32_out_s;

    -- Component instantiations
    BCD_7bit_0_i : BCD_decoder_7bit
    port map (
        bin_in  => bin28_in(6 downto 0),
        bcd_out => bcd32_out_s(7 downto 0)
    );

    BCD_7bit_1_i : BCD_decoder_7bit
    port map (
        bin_in  => bin28_in(13 downto 7),
        bcd_out => bcd32_out_s(15 downto 8)
    );

    BCD_7bit_2_i : BCD_decoder_7bit
    port map (
        bin_in  => bin28_in(20 downto 14),
        bcd_out => bcd32_out_s(23 downto 16)
    );

    BCD_7bit_3_i : BCD_decoder_7bit
    port map (
        bin_in  => bin28_in(27 downto 21),
        bcd_out => bcd32_out_s(31 downto 24)
    );

end architecture behavior;