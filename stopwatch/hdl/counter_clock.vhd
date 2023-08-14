----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 07/04/2022 02:26:58 PM
-- Design Name:
-- Module Name: counter_clock - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
-- reference: http://esd.cs.ucr.edu/labs/tutorial/counter.vhd
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

Entity counter_clock Is
	Port (
		clk : In STD_LOGIC;
		en_100 : In STD_LOGIC;
		fsm_stopwatch_start : In STD_LOGIC;
		sw_reset : In std_logic;
		key_plus_imp : In STD_LOGIC;
		count_ena : In std_logic;
		csec : Out std_logic_vector(6 Downto 0);
		sec : Out std_logic_vector(6 Downto 0);
		min : Out std_logic_vector(6 Downto 0);
		hr : Out std_logic_vector(6 Downto 0) 
	);
End counter_clock;

Architecture Behavioral Of counter_clock Is 
 
	Signal csec_signal : std_logic_vector(6 Downto 0) := "0000000";
	Signal sec_signal : std_logic_vector(6 Downto 0) := "0000000";
	Signal min_signal : std_logic_vector(6 Downto 0) := "0000000";
	Signal hr_signal : std_logic_vector(6 Downto 0) := "0000000";
Begin
	Process (clk)
	Begin
		If (clk = '1' And clk'event) Then
 
			If sw_reset = '1' or (key_plus_imp = '1' and fsm_stopwatch_start = '1') Then
				csec_signal <= "0000000";
				sec_signal <= "0000000";
				min_signal <= "0000000";
				hr_signal <= "0000000";
 
			Else
				If count_ena = '1' Then
					If key_plus_imp = '1' and fsm_stopwatch_start = '1' Then 
						csec_signal <= "0000000";
						sec_signal <= "0000000";
						min_signal <= "0000000";
						hr_signal <= "0000000";
					Else
					   if en_100 = '1' then
                            csec_signal <= csec_signal + 1;
                            If csec_signal = "1100011" Then
                                csec_signal <= "0000000";
                                sec_signal <= sec_signal + 1;
                                If sec_signal = "111011" Then
                                    sec_signal <= "0000000";
                                    min_signal <= min_signal + 1;
                                    If min_signal = "0111011" Then
                                        min_signal <= "0000000";
                                        hr_signal <= hr_signal + 1;
                                        If hr_signal = "0010111" Then
                                            csec_signal <= csec_signal - csec_signal;
                                            sec_signal <= sec_signal - sec_signal;
                                            min_signal <= min_signal - min_signal;
                                            hr_signal <= hr_signal - hr_signal;
                                        End If;
                                    End If;
                                End If;
                            End If;
                         End If;
					End If;
				End If;
			End If;
		End If;
	End Process; 
 
	csec <= csec_signal;
	sec <= sec_signal;
	min <= min_signal;
	hr <= hr_signal;

End Behavioral;
