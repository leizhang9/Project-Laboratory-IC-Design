--------------------------------------------------------------------------------
-- Author       : Quang Phan
-- Author email : quang.phan@tum.de
-- Create Date  : 27/06/2022
-- Project Name : Project Lab IC Design
-- Module Name  : tb_BCD_decoder_28bit.vhd
-- Description  : VHDL testbench for module: BCD_decoder_28bit
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_BCD_decoder_28bit is
end entity tb_BCD_decoder_28bit;

architecture behavior of tb_BCD_decoder_28bit is

    -- Component Declaration for the Unit Under Test (UUT)
    component BCD_decoder_28bit
    port (
        bin28_in  : in  std_logic_vector(27 downto 0);
        bcd32_out : out std_logic_vector(31 downto 0)
    );
    end component BCD_decoder_28bit;

    -- Input
    signal bin_in  : std_logic_vector(27 downto 0);

    -- Output
    signal bcd_out : std_logic_vector(31 downto 0);

    -- Reference test arrays
    type sti_array_t is array (0 to 5) of std_logic_vector(27 downto 0);
    type exp_array_t is array (0 to 5) of std_logic_vector(31 downto 0);
    constant sti_array : sti_array_t := ( x"0000000", x"000003B", x"0001D80", x"00EC000", x"7600000", x"76EDDBB");
    constant exp_array : exp_array_t := ( b"00000000000000000000000000000000",
                                          b"00000000000000000000000001011001",
                                          b"00000000000000000101100100000000",
                                          b"00000000010110010000000000000000",
                                          b"01011001000000000000000000000000",
                                          b"01011001010110010101100101011001");

    -- Error counter
    signal error_cnt : integer range 0 to 6 :=0;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut : BCD_decoder_28bit
    port map (
        bin28_in  => bin_in,
        bcd32_out => bcd_out
    );

    -- Stimulus process
    STIM_PROC : process is
    begin
        -- Stimulus
        STIMULUS: for i in 0 to 5 loop
            -- Send input
            bin_in <= sti_array(i);

            wait for 20 ns;

            -- Check output
            if ( bcd_out /= exp_array(i) ) then
                error_cnt <= error_cnt + 1;
            else
                error_cnt <= error_cnt;
            end if;

            wait for 20 ns;
        end loop STIMULUS;

        if ( error_cnt /= 0 ) then
            report "TEST FAILED! Number of unmatched results is " & integer'image(error_cnt);
        else
            report "TEST PASSED!";
        end if;

        wait;
    end process STIM_PROC;

end architecture behavior;