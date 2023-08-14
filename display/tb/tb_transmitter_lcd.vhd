--------------------------------------------------------------------------------
-- Author       : Quang Phan
-- Author email : quang.phan@tum.de
-- Create Date  : 27/06/2022
-- Project Name : Project Lab IC Design
-- Module Name  : tb_transmitter_lcd.vhd
-- Description  : VHDL testbench for module: transmitter_lcd
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_transmitter_lcd is
end entity tb_transmitter_lcd;

architecture behavior of tb_transmitter_lcd is
    -- Component Declaration for the Unit Under Test (UUT)
    component transmitter_lcd
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
        -- Acknowledge
        lcd_ack       : out std_logic
    );
    end component transmitter_lcd;

    -- Inputs
    signal clk           : std_logic := '0';
    signal reset         : std_logic := '0';
    signal data_in       : std_logic_vector(10 downto 0) := (others => '0');
    signal data_in_ready : std_logic := '0';

    -- Outputs
    signal lcd_en   : std_logic := '0';
    signal lcd_rw   : std_logic := '0';
    signal lcd_rs   : std_logic := '0';
    signal lcd_data : std_logic_vector(7 downto 0) := (others => '0');
    signal lcd_ack  : std_logic := '0';

    -- Clock period
    constant CLK_PERIOD_c : time := 10 ns;

    -- Input data
    type data_array_t is array (0 to 3) of std_logic_vector(10 downto 0);
    signal input_array  : data_array_t := ("11111111111", "10101010101", "01010101010", "00000000000");
    signal output_array : data_array_t := (others => (others => '0'));

    -- Minimum interval
    constant MIN_INTERVAL_g : integer := 1;

    -- Error counter
    signal error_cnt : integer range 0 to 10 := 0;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut : transmitter_lcd
    port map (
        -- Clock and reset
        clk           => clk,
        reset         => reset,
        -- Data in
        data_in       => data_in,
        data_in_ready => data_in_ready,
        -- Output to LCD
        lcd_en        => lcd_en,
        lcd_rw        => lcd_rw,
        lcd_rs        => lcd_rs,
        lcd_data      => lcd_data,
        -- Acknowledge for transmission
        lcd_ack       => lcd_ack  -- ACK for next data to be read from FIFO
    );

    -- Clock generator
    CLK_GEN : process
    begin
        wait for CLK_PERIOD_c/2;
        clk <= not clk;
    end process CLK_GEN;

    -- Stimulus
    STIM : process
        variable data_out : std_logic_vector(10 downto 0);
    begin
        -- Generate reset
        -- wait for CLK_PERIOD_c*2;
        reset <= '1';
        wait for CLK_PERIOD_c*2;
        reset <= '0';
        wait for CLK_PERIOD_c/2;

        -- Start giving data to transmitter
        SEND_DATA : for i in 0 to 3 loop
            -- Send data in
            data_in_ready <= '1';
            data_in       <= input_array(i);

            wait for (MIN_INTERVAL_g) * CLK_PERIOD_c;

            -- Get transmitter output and check ack signal
            output_array(i) <= lcd_en & lcd_rs & lcd_rw & lcd_data;
            if ( lcd_ack /= '1' ) then
                error_cnt <= error_cnt + 1;
                report ("Acknowledge not received after waiting for minimum interval!");
            end if;
            data_in_ready <= '0';
        end loop SEND_DATA;

        -- Compare data
        CMP_DATA : for i in 0 to 3 loop
            if ( input_array(i) /= output_array(i) ) then
                error_cnt <= error_cnt + 1;
                report ("Read and write data mismatched!");
            end if;
        end loop CMP_DATA;

        -- Print testbench output
        if ( error_cnt /= 0 ) then
            report "TEST FAILED! Number of unmatched results is " & integer'image(error_cnt);
        else
            report "TEST PASSED!";
        end if;

        wait;
    end process STIM;

end architecture behavior;
