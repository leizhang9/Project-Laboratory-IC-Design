----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:18:35 05/02/2013 
-- Design Name: 
-- Module Name:    dcf_decode - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dcf_decode is
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
end dcf_decode;

architecture Behavioral of dcf_decode is


	signal stream : std_logic_vector(39 downto 0) := (others => '0'); -- Need only last 40 bits
	
	signal last_sample : std_logic := '0';
	signal value : std_logic := '0';
	signal edge_count : integer range 0 to 5;
	signal edge : std_logic := '0';
	signal sample_count : integer range 0 to 120;
	
	signal valid : std_logic := '0';
	signal minute : std_logic := '0';
	signal checkbit1 : std_logic := '0';
	signal checkbit2 : std_logic := '0';
	signal checkbit3 : std_logic := '0';
	
begin

	sampling : process(clk)
	begin
		if rising_edge(clk) then
			if reset='1' then
				last_sample <= '0';	
			elsif en_100='1' then
				last_sample <= dcf;
			end if;
		end if;
	end process;
	
	edge_detection : process(clk)
	begin
		if rising_edge(clk) then
			edge <= '0';
			if reset='1' then
				edge_count <= 0;
				value <= '0';
			elsif en_100='1' then
				if last_sample=dcf then
					-- No change => increment counter
					if edge_count=4 then
						edge <= '1';
						value <= last_sample;
					end if;
					if not(edge_count=5) then
						edge_count <= edge_count + 1;
					end if;
				else
					-- Signal changed => start counting
					edge_count <= 0;
				end if;
			end if;
		end if;
	end process;
	
	sample_counter : process(clk)
	begin
		if rising_edge(clk) then
			if reset='1' or edge='1' then
				sample_count <= 0;
			elsif en_100='1' then
				if not(sample_count = 120) then
					sample_count <= sample_count + 1;
				end if;
			end if;
		end if;
	end process;
	
	mark_detection : process(clk)
	begin
		if rising_edge(clk) then
			if reset='1' then
				stream <= (others => '0');
				checkbit1 <= '0';
				checkbit2 <= '0';
				checkbit3 <= '0';
			elsif edge='1' and value='1' then
				stream <= '0' & stream(39 downto 1); -- Shift
				checkbit1 <= stream(1) xor stream(8) xor checkbit1; -- Bit 1 leaving parity frame, Bit 8 entering parity frame
				checkbit2 <= stream(9) xor stream(15) xor checkbit2; -- Bit 9 leaving parity frame, Bit 15 entering parity frame
				checkbit3 <= stream(16) xor stream(38) xor checkbit3; -- Bit 16 leaving parity frame, Bit 38 entering parity frame
			elsif en_100='1' and sample_count=15 and value='0' then
				stream(39) <= '1'; -- Current mark is 1				
			end if;
		end if;
	end process;
	
	minute_detect : process(clk)
	begin
		if rising_edge(clk) then
			minute <= '0';
			-- When for more than 1.2 seconds high signal and falling edge => minute
			if sample_count=120 and edge='1' and value='0' then
				minute <= '1';
			end if;
		end if;				
	end process;
	
	de_year <= stream(37 downto 30);
	de_month <= stream(29 downto 25);
	de_dow <= stream(24 downto 22);
	de_day <= stream(21 downto 16);
	de_hour <= stream(14 downto 9);
	de_min <= stream(7 downto 1);
	
	validation : process(stream, checkbit1, checkbit2, checkbit3)
	begin
		if stream(0)='1' and stream(8)=checkbit1 and stream(15)=checkbit2 and stream(38)=checkbit3 then
			valid <= '1';
		else
			valid <= '0';
		end if;
	end process;
	
	de_set <= valid and minute;
end Behavioral;

