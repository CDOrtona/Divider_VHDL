library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity comparison_datapaths is
end comparison_datapaths;

-- Testbench non sintetizabile usato solamente per calcolare l'errore assoluto dei risultati ottenuti neldatapath 1 e nel datapath2

architecture arch of comparison_datapaths is

	component datapath_1
			port( CLK   : IN std_logic;
					RESET : IN std_logic;
					A 		: IN std_logic_vector(15 downto 0);  --W(16,8,8)
					B 		: IN std_logic_vector(10 downto 0);	--w(11,3,8)
					C 		: IN std_logic_vector(15 downto 0);	--W(16,8,8)
					Y 		: OUT std_logic_vector(16 downto 0)	--W(17,7,10)
					);
	end component;

	component datapath_2
			port( CLK   : IN std_logic;
					RESET : IN std_logic;
					A 		: IN std_logic_vector(15 downto 0);  --W(16,8,8)
					B 		: IN std_logic_vector(10 downto 0);	--w(11,3,8)
					C 		: IN std_logic_vector(15 downto 0);	--W(16,8,8)
					Y 		: OUT std_logic_vector(16 downto 0)	--W(17,7,10)     
					);
	end component;
	
	signal CLK, RESET : std_logic;
	signal A : std_logic_vector(15 downto 0);
	signal B : std_logic_vector(10 downto 0);
	signal C : std_logic_vector(15 downto 0);
	signal Y_1 : std_logic_vector(16 downto 0);
	signal Y_2 : std_logic_vector(16 downto 0);
	
	signal error_abs : real;

		
	begin
		
		DP2 : datapath_2 port map (CLK, RESET, A, B, C, Y_2);  
		
		DP1 : datapath_1 port map (CLK, RESET, A, B, C, Y_1);
		
		
		xsclock_engine : process
			 begin
				CLK <= '0';
				wait for 10 ns;
				CLK <= '1';
				wait for 10 ns;
			 end process;

		RESET_engine : process
			begin
			  wait for 5 ns;
			  RESET <='1';
			  wait for 20 ns;
			  RESET <= '0';
			  wait;
		   end process;
		
		division : process
			begin
				wait for 30 ns;
				A <= "0111100110100000"; --121.625
				B <= "01111000000";		 --3.75   ris -> 32.43333
				C <= x"0000";
				wait for 20 ns;
				A <= "1100110100000000"; --205
				B <= "01111000000";		 --3.75   ris -> 54.66666 + 63 = 117.666666
				C <= "0011111100000000";    --63
				wait for 20 ns;
				A <= "1100100010000000"; --200.5
				B <= "10101000000";		 --5.25   ris -> 38.19048
				c <= x"0000";
				wait for 20 ns;
				A <= "1001101111010100"; --155.83
				B <= "10010111000";		 --4.72   ris -> 33.0148
				c <= x"0000";
				wait for 20 ns;
				A <= "1010001101001010"; --163.29
				B <= "10000111000";		 --4.22   ris -> 38.6943
				c <= x"0000";
				wait for 20 ns;
				A <= "1000001000100110"; --130.15
				B <= "10111000111";		 --5.75   ris -> 22.5173
				c <= x"0000";
				wait for 20 ns;
				A <= "1000001000100110"; --130.15
				B <= "10111000111";		 --5.75   ris -> 36.1248
				c <= "0011010111110101"; --13.49	
				wait for 20 ns;
				A <= "1001101111010100"; --155.83
				B <= "10010111000";		 --4.72   ris -> 33.0148 + 51.11 = 84.12
				c <= "1100110001110000"; --51.11
				wait;
			end process;
			
		error_abs <= (real(to_integer(unsigned(Y_1)))/real(1024) - real(to_integer(unsigned(Y_2)))/real(1024));
			
end arch;
