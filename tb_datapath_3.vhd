library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_datapath_3 is
end tb_datapath_3;

architecture arch of tb_datapath_3 is

	component datapath_3 
		port( CLK	 : IN std_logic;
			RESET  : IN std_logic;
			A 		 : IN std_logic_vector(15 downto 0);  --W(16,8,8)
			B 		 : IN std_logic_vector(10 downto 0);  --W(11,3,8)
			C 		 : IN std_logic_vector(15 downto 0);  -- W(16,6,10)
			Y 		 : OUT std_logic_vector(16 downto 0);  --W(17,7,10)   
			START  : IN std_logic;
			VALID  : OUT std_logic;
			LOAD   : IN std_logic;
			base_x : IN std_logic_vector(10 downto 0);
			base_y : IN std_logic_vector(13 downto 0);
			coeff  :	IN std_logic_vector(11 downto 0));
	end component;
	
	signal CLK, RESET : std_logic;
	signal A, C			: std_logic_vector(15 downto 0);
	signal B 			: std_logic_vector(10 downto 0);
	signal Y				: std_logic_vector(16 downto 0);
	signal START, LOAD: std_logic;
	signal VALID		: std_logic;
	signal base_x		: std_logic_vector(10 downto 0);
	signal base_y 		: std_logic_vector(13 downto 0);
	signal coeff 		: std_logic_vector(11 downto 0);
	
	constant N_div : natural := 2;

	
	constant N : natural := 5; 
	type array_basex is array (0 to N-1) of std_logic_vector(10 downto 0);
	type array_basey is array (0 to N-1) of std_logic_vector(13 downto 0);
	type array_coeff is array (0 to N-1) of std_logic_vector(11 downto 0);


	
	constant vector_basey : array_basey := (   "10001000100000",		--w(14,16,8)
															 "01111111110111",
															 "01110001101011",
															 "01100110010100",
															 "01011100111111");	  
												  
	constant vector_coeff : array_coeff := (  "100010111100",		--w(12,4,8)
														   "011101000101",
														   "010111001101",
														   "010010111101",
														   "001111100000");
													
	constant vector_basex : array_basex := (	"01111000000",     --w(11,3,8)
															"10000000000",
															"10010000000",
															"10100000000",
															"10110000000");
	   
	
	begin
		
		UUT : datapath_3 port map( CLK, RESET, A, B, C, Y, START, VALID, LOAD, base_x, base_y, coeff);

		xsclock_engine : process
			begin
				CLK <= '0';
				wait for 3 ns;
				CLK <= '1';
				wait for 3 ns;
		end process;
		
		reset_engine : process
			begin
			  wait for 1.5 ns;
			  RESET <='1';
			  wait for 6 ns;
			  RESET <= '0';
			  wait;
		end process;
		
		array_loading : process
			begin
				wait for 6 ns;
				LOAD 	 <= '1';
				wait for 1.5 ns;
				for I in vector_coeff'range loop
					base_x <= vector_basex(I);
					base_y <= vector_basey(I);
					coeff  <= vector_coeff(I);
					wait for 6 ns;
				end loop;
				LOAD <= '0';
				wait;
		end process;
		
		start_eng : process
		begin
			start <= '0';
			wait for 38 ns;
			for I in 0 to 7 loop
				start <= '1';
				wait for 6 ns;
				start <= '0';
				wait for 6 ns;
			end loop;
			wait;
		end process;
				
		division : process
			begin
				--start <= '0';
				wait for 15 ns;
				A <= "0111100110100000"; --121.625
				B <= "01111100000";		 --3.87   ris -> 32.43333				this first sampling will be ignored as it occurs during
				C <= x"0000";															-- the LOAD phase
				wait for 23 ns;				
				--start <= '1';
				A <= "0111100110100000"; --121.625
				B <= "01111000000";		 --3.75   ris -> 32.43333
				C <= x"0000";
				wait for 12 ns;
				A <= "1100110100000000"; --205
				B <= "01111000000";		 --3.75   ris -> 54.66666 + 63 = 117.666666
				C <= "1111110000000000";    --63
				wait for 12 ns;
				A <= "1100100010000000"; --200.5
				B <= "10101000000";		 --5.25   ris -> 38.19048
				c <= x"0000";
				wait for 12 ns;
				A <= "1001101111010100"; --155.83
				B <= "10010111000";		 --4.72   ris -> 33.0148
				c <= x"0000";
				wait for 12 ns;
				A <= "1010001101001010"; --163.29
				B <= "10000111000";		 --4.22   ris -> 38.6943
				c <= x"0000";
				wait for 12 ns;
				A <= "1000001000100110"; --130.15
				B <= "10111000111";		 --5.75   ris -> 22.5173
				c <= x"0000";
				wait for 12 ns;
				A <= "1000001000100110"; --130.15
				B <= "10111000111";		 --5.75   ris -> 36.1248
				c <= "0011010111110101"; --13.49
				wait for 12 ns;
				A <= "1001101111010100"; --155.83
				B <= "10010111000";		 --4.72   ris -> 33.0148 + 51.11 = 84.12
				c <= "1100110001110000"; --51.11
				wait;
			end process;

end arch;	