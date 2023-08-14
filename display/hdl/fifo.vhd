--------------------------------------------------------------------------------
-- Author       : Quang Phan
-- Author email : quang.phan@tum.de
-- Create Date  : 27/06/2022
-- Project Name : Project Lab IC Design
-- Module Name  : fifo.vhd
-- Description  : FIFO to store data for serial data transmission
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo is
    generic (
        WIDTH_g : integer := 11;
        DEPTH_g : integer := 50
    );
    port (
        -- Clock and reset
        clk           : in  std_logic;
        reset         : in  std_logic;
        -- FIFO wrire interface
        wr_en         : in  std_logic;
        wr_data       : in  std_logic_vector(WIDTH_g-1 downto 0);
        full          : out std_logic;
        -- FIFO read interface
        rd_en         : in  std_logic;
        rd_data       : out std_logic_vector(WIDTH_g-1 downto 0);
        rd_data_ready : out std_logic;
        empty         : out std_logic
    );
end entity fifo;

architecture behavior of fifo is
    -- FIFO array to store data
    type fifo_array_t is array (0 to DEPTH_g-1) of std_logic_vector(WIDTH_g-1 downto 0);

    -- Internal registers
    signal fifo_array_r    : fifo_array_t := (others => (others => '0'));
    signal wr_ptr_r        : integer range 0 to DEPTH_g-1 := 0;
    signal rd_ptr_r        : integer range 0 to DEPTH_g-1 := 0;
    signal full_r          : std_logic := '0';
    signal empty_r         : std_logic := '1';
    signal rd_data_ready_r : std_logic := '0';

begin

    -- Process
    FIFO_ACT : process (clk) is
        variable fifo_cnt_v : integer range 0 to DEPTH_g+1; -- FIFO fill level
    begin
        if ( clk'EVENT and clk = '1' ) then
            if ( reset = '1' ) then
                fifo_array_r    <= (others => (others => '0'));
                wr_ptr_r        <= 0;
                rd_ptr_r        <= 0;
                full_r          <= '0';
                empty_r         <= '1';
                fifo_cnt_v      := 0;
                rd_data_ready_r <= '0';
            else
                -- Reset RD_DATA handshake, can be overwritten later on
                rd_data_ready_r <= '0';

                -- Write operation
                if ( wr_en = '1' and full_r = '0' ) then
                    -- Write to FIFO
                    fifo_array_r(wr_ptr_r) <= wr_data;

                    -- Fill level
                    fifo_cnt_v := fifo_cnt_v + 1;

                    -- Update write pointer
                    if ( wr_ptr_r = DEPTH_g-1 ) then
                        wr_ptr_r <= 0;
                    else
                        wr_ptr_r <= wr_ptr_r + 1;
                    end if;
                end if;

                -- Read operation
                if ( rd_en = '1' and empty_r = '0' ) then
                    -- Read from FIFO
                    rd_data         <= fifo_array_r(rd_ptr_r);
                    rd_data_ready_r <= '1';

                    -- Fill level
                    fifo_cnt_v := fifo_cnt_v - 1;

                    -- Update read pointer
                    if ( rd_ptr_r = DEPTH_g-1 ) then
                        rd_ptr_r <= 0;
                    else
                        rd_ptr_r <= rd_ptr_r + 1;
                    end if;
                end if;

                -- Setting flags
                -- EMPTY
                if ( fifo_cnt_v = 0) then
                    empty_r <= '1';
                else
                    empty_r <= '0';
                end if;
                -- FULL
                if ( fifo_cnt_v = DEPTH_g ) then
                    full_r <= '1';
                else
                    full_r <= '0';
                end if;
            end if;
        end if;
    end process FIFO_ACT;

    -- FIFO flags
    -- full_s  <= '1' when fifo_cnt_r = DEPTH_g else '0';
    -- empty_s <= '1' when fifo_cnt_r = 0       else '0';

    -- Output assignments
    full          <= full_r;
    empty         <= empty_r;
    rd_data_ready <= rd_data_ready_r;

end architecture behavior;