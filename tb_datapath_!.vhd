library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_datapath_1 is
end tb_datapath_1;

architecture arch of tb_datapath_1 is

	component datapath_1
			port( CLK   : IN std_logic;
					RESET : IN std_logic;
					A 		: IN std_logic_vector(15 downto 0);  --W(16,8,8)
					B 		: IN std_logic_vector(10 downto 0);	--w(11,3,8)
					C 		: IN std_logic_vector(15 downto 0);	--W(16,8,8)
					Y 		: OUT std_logic_vector(16 downto 0)	--W(17,7,8)
					);
	end component;
	
	signal CLK, RESET : std_logic;
	signal A : std_logic_vector(15 downto 0);
	signal B : std_logic_vector(10 downto 0);
	signal C : std_logic_vector(15 downto 0);
	signal Y : std_logic_vector(16 downto 0);
		
	begin
		
		UUT : datapath_1 port map (CLK, reset, A, B, C, Y);
		
		
		xsclock_engine : process
			 begin
				CLK <= '0';
				wait for 64.5 ns;
				CLK <= '1';
				wait for 64.5 ns;
			 end process;

		reset_engine : process
			begin
			  wait for 5 ns;
			  RESET <='1';
			  wait for 64.5 ns;
			  RESET <= '0';
			  wait;
		   end process;
		
		division : process 
			begin
				wait for 139.5 ns;
				A <= "0111100110100000"; --121.625
				B <= "01111000000";		 --3.75   ris -> 32.43333
				C <= x"0000";
				wait for 129 ns;
				A <= "1100110100000000"; --205
				B <= "01111000000";		 --3.75   ris -> 54.66666 + 63 = 117.666666
				C <= "1111110000000000"; --63
				wait for 129 ns;
				A <= "1100100010000000"; --200.5
				B <= "10101000000";		 --5.25   ris -> 38.19048
				c <= x"0000";
				wait for 129 ns;
				A <= "1000001000100110"; --130.15
				B <= "10111000111";		 --5.75   ris -> 36.1248
				c <= "0011010111110101"; --13.49	
				wait;
			end process;
end arch;
