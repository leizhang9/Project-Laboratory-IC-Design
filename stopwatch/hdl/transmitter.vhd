----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 06/22/2022 11:54:10 AM
-- Design Name:
-- Module Name: transmitter - Behavioral
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
Library IEEE;
Use IEEE.STD_LOGIC_1164.All;
Use ieee.std_logic_unsigned.All;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
Use IEEE.NUMERIC_STD.All;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

Entity transmitter Is
	Port (
		clk : In std_logic;
		fsm_stopwatch_start : In std_logic;
		sw_reset : In std_logic;
		key_plus_imp : In STD_LOGIC;
		transmitter_ena : In std_logic := '1';
		csec_in : In std_logic_vector(6 Downto 0) := "0000000";
		sec_in : In std_logic_vector(6 Downto 0) := "0000000";
		min_in : In std_logic_vector(6 Downto 0) := "0000000";
		hr_in : In std_logic_vector(6 Downto 0) := "0000000";
		csec : Out std_logic_vector(6 Downto 0) := "0000000";
		sec : Out std_logic_vector(6 Downto 0) := "0000000";
		min : Out std_logic_vector(6 Downto 0) := "0000000";
		hr : Out std_logic_vector(6 Downto 0) := "0000000"
	);
End transmitter;

Architecture Behavioral Of transmitter Is

	Signal csec_old : std_logic_vector(6 Downto 0) := "0000000";
	Signal sec_old : std_logic_vector(6 Downto 0) := "0000000";
	Signal min_old : std_logic_vector(6 Downto 0) := "0000000";
	Signal hr_old : std_logic_vector(6 Downto 0) := "0000000";

Begin
	Process (clk)
 
	Begin
		If (clk = '1' And clk'event) Then
			If sw_reset = '1' Then
				csec_old <= "0000000";
				sec_old <= "0000000";
				min_old <= "0000000";
				hr_old <= "0000000";
				csec <= "0000000";
				sec <= "0000000";
				min <= "0000000";
				hr <= "0000000";
			Else
				If fsm_stopwatch_start = '1' Then
					If key_plus_imp = '1' Then
						csec_old <= "0000000";
						sec_old <= "0000000";
						min_old <= "0000000";
						hr_old <= "0000000";
						csec <= "0000000";
						sec <= "0000000";
						min <= "0000000";
						hr <= "0000000";
					Else
 
						If transmitter_ena = '1' Then 
							csec <= csec_in;
							csec_old <= csec_in;
							sec <= sec_in;
							sec_old <= sec_in;
							min <= min_in;
							min_old <= min_in;
							hr <= hr_in;
							hr_old <= hr_in; 
						Else
							csec <= csec_old;
							sec <= sec_old;
							min <= min_old;
							hr <= hr_old; 
						End If;
					End If;
                
				End If;
				
			End If;
 
		End If;
	End Process;
End Behavioral;
