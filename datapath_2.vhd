library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath_2 is
	port( clk:  IN std_logic;
			reset: IN std_logic;
			A : 	 IN std_logic_vector(15 downto 0);   --W(16,8,8)
			B : 	 IN std_logic_vector(10 downto 0);   --W(11,3,8)
			C : 	 IN std_logic_vector(15 downto 0);   --W(16,6,10)
			Y : 	 OUT std_logic_vector(16 downto 0)); --W(17,7,10)     
	end datapath_2;
	
architecture behavioral of datapath_2 is

	constant N   : natural := 5;
	signal index : natural;
	type array_basex is array (0 to N-1) of unsigned(10 downto 0);
	type array_basey is array (0 to N-1) of unsigned(13 downto 0);
	type array_coeff is array (0 to N-1) of unsigned(11 downto 0);


	
	constant base_y : array_basey := (   "10001000100000",		--w(14,6,8)
												    "01111111110111",
												    "01110001101011",
												    "01100110010100",
												    "01011100111111");	  
												  
	constant coeff : array_coeff := (  "100010111100",		--w(12,4,8)
											     "011101000101",
											     "010111001101",
											     "010010111101",
											     "001111100000");
													
	constant base_x : array_basex := (	   "01111000000",     --w(11,3,8)
														"10000000000",
														"10010000000",
														"10100000000",
														"10110000000");
														
	signal reg_A : std_logic_vector(15 downto 0);   
	signal reg_B : std_logic_vector(10 downto 0);
	signal reg_C : std_logic_vector(15 downto 0);
	
	-- inverso = base_y - disp_x_coeff = base_y - displacement*coeff
	-- inverso_x_divid = inverso*reg_A
	
	signal displacement    : unsigned(10 downto 0);   --w(11, 3, 8)
	signal disp_x_coeff    : unsigned(19 downto 0);   --w(20, 4, 16)
	signal inverso         : unsigned(13 downto 0);    --w(14, 6, 8)
	signal inverso_x_divid : unsigned(29 downto 0);   --w(30, 14, 16) 
												  
begin
	
	sample : process(clk) 
	begin
		if clk'event and clk = '1' then
			if reset = '1' then
				reg_A <= (others => '0');
				reg_B <= (others => '0');
				reg_C <= (others => '0');
				Y 		<= (others => '0');
			else
				reg_A <= A;
				reg_B <= B;
				reg_C <= C;
				Y 		<= std_logic_vector(inverso_x_divid(29 downto 13) + unsigned('0' & reg_C));
			end if;
		end if;
	end process;
	
	
	comparator : process(reg_B)
	begin
	index <= 0;
		for I in 0 to N-1 loop
			if (base_x(I) < unsigned(reg_B)) then
				index <= I;
			end if;
		end loop;
	end process;
	
	displacement    <= unsigned(reg_B) - base_x(index);                --w(11,3,8) -> w(8,0,8) max disp. is 0.5
	disp_x_coeff    <= displacement(7 downto 0) * coeff(index);			 --w(8,0,8) * W(12,4,8) = w(20,4,16) -> w(12,4,8)
	inverso 		    <= base_y(index) - disp_x_coeff(19 downto 8);		 --w(14,6,8) - w(12,4,8) = w(14,6,8)
	inverso_x_divid <= unsigned(reg_A)*inverso;								 --w(16,8,8) * w(14,6,8) = w(30,14,16)

	
end behavioral;