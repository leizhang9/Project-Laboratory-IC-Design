--------------------------------------------------------------------------------
-- Author       : Quang Phan
-- Author email : quang.phan@tum.de
-- Create Date  : 27/06/2022
-- Project Name : Project Lab IC Design
-- Module Name  : tb_fifo.vhd
-- Description  : VHDL testbench for module: fifo
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_fifo is
end entity tb_fifo;

architecture behavior of tb_fifo is

    -- Component Declaration for the Unit Under Test (UUT)
    component fifo
    generic (
        WIDTH_g : integer := 11;
        DEPTH_g : integer := 50
    );
    port (
        -- Clock and reset
        clk           : in  std_logic;
        reset         : in  std_logic;
        -- FIFO write interface
        wr_en         : in  std_logic;
        wr_data       : in  std_logic_vector(WIDTH_g-1 downto 0);
        full          : out std_logic;
        -- FIFO read interface
        rd_en         : in  std_logic;
        rd_data       : out std_logic_vector(WIDTH_g-1 downto 0);
        rd_data_ready : out std_logic;
        empty         : out std_logic
    );
    end component fifo;

    -- Inputs
    signal clk     : std_logic := '0';
    signal reset   : std_logic := '0';
    signal wr_en   : std_logic := '0';
    signal rd_en   : std_logic := '0';
    signal wr_data : std_logic_vector(10 downto 0) := (others => '0');

    -- Outputs
    signal full          : std_logic := '0';
    signal empty         : std_logic := '0';
    signal rd_data       : std_logic_vector(10 downto 0) := (others => '0');
    signal rd_data_ready : std_logic := '0';

    -- Clock period
    constant CLK_PERIOD_c : time := 10 ns;

    -- Input data
    constant NUM_DATA_c : integer := 20;
    type data_array_t is array (0 to NUM_DATA_c-1) of std_logic_vector(10 downto 0);
    signal input_array  : data_array_t := (others => (others => '0'));
    signal output_array : data_array_t := (others => (others => '0'));

    -- Error counter
    signal error_cnt : integer range 0 to 50 := 0;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut : fifo
    generic map (
        WIDTH_g => 11,
        DEPTH_g => 10
    )
    port map (
        -- Clock and reset
        clk           => clk,
        reset         => reset,
        -- FIFO write interface
        wr_en         => wr_en,
        wr_data       => wr_data,
        full          => full,
        -- FIFO read interface
        rd_en         => rd_en,
        rd_data       => rd_data,
        rd_data_ready => rd_data_ready,
        empty         => empty
    );

    -- Clock generator
    -- clk <= '1' after CLK_PERIOD_c/2 when clk = '0' else
    --        '0' after CLK_PERIOD_c/2 when clk = '1';
    CLK_GEN : process
    begin
        wait for CLK_PERIOD_c/2;
        clk <= not clk;
    end process CLK_GEN;

    -- Stimulus
    STIM : process
    begin
        -- Generate input array
        INPUT_GEN : for i in 0 to NUM_DATA_c-1 loop
            input_array(i) <= std_logic_vector(to_unsigned(i+1, 11)); -- Input data: 1 -> 20
        end loop INPUT_GEN;

        -- Generate reset
        wait for CLK_PERIOD_c*2;
        reset <= '1';
        wait for CLK_PERIOD_c*2;
        reset <= '0';
        wait for CLK_PERIOD_c/2;

        -- Check if empty initially
        if ( empty /= '1' ) then
            error_cnt <= error_cnt + 1;
            report ("FIFO not empty at the beginning!");
        end if;

        -- Read when empty
        rd_en <= '1';
        wait for CLK_PERIOD_c/2;
        if ( rd_data_ready = '1' ) then
            error_cnt <= error_cnt + 1;
            report ("Read data not expected to be ready when FIFO is empty!");
        end if;
        rd_en <= '0';
        wait for CLK_PERIOD_c/2;

        -- Write to full
        SEND_TIL_FULL : for i in 0 to 9 loop
            wr_en   <= '1';
            wr_data <= input_array(i);
            wait for CLK_PERIOD_c;
        end loop SEND_TIL_FULL;

        -- Check if full after writing 10 data pieces
        if ( full /= '1' ) then
            error_cnt <= error_cnt + 1;
            report ("FIFO not full after writing 10 data pieces!");
        end if;

        -- Write when full
        SEND_WHEN_FULL : for i in 0 to 2 loop
            wr_en    <= '1';
            wr_data  <= input_array(10+i);
            wait for CLK_PERIOD_c;
        end loop SEND_WHEN_FULL;
        wr_en <= '0';
        wait for CLK_PERIOD_c;

        -- Read to empty
        READ_TIL_EMPTY : for i in 0 to 9 loop
            rd_en <= '1';
            wait for CLK_PERIOD_c/2;
            if ( rd_data_ready /= '1' ) then
                error_cnt <= error_cnt + 1;
                report ("Read data not ready when reading after writing to full!");
            end if;
            output_array(i) <= rd_data;
            wait for CLK_PERIOD_c/2;
        end loop READ_TIL_EMPTY;

        -- Check if FIFO is empty after reading 10 times
        if ( empty /= '1' ) then
            error_cnt <= error_cnt + 1;
            report ("FIFO not empty after reading 10 data pieces!");
        end if;

        -- Read when empty
        rd_en <= '1';
        wait for CLK_PERIOD_c/2;
        if ( rd_data_ready = '1' ) then
            error_cnt <= error_cnt + 1;
            report ("Read data not expected to be ready when FIFO is empty!");
        end if;

        -- Compare data
        CMP_DATA : for i in 0 to 9 loop
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