library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath_1 is
	port( CLK	: IN std_logic;
			RESET : IN std_logic;
			A 		: IN std_logic_vector(15 downto 0);  --W(16,8,8)  						range: 100-205
			B 		: IN std_logic_vector(10 downto 0);	 --w(11,3,8)	  					range: 3.75-6
			C 		: IN std_logic_vector(15 downto 0);	 --W(16,6,10) 					   range: 0-63
			Y 		: OUT std_logic_vector(16 downto 0)	 --W(17,7,10)   					range: 16.66-117.66
			);
end datapath_1;

architecture behavioral of datapath_1 is

signal reg_A 	: std_logic_vector(25 downto 0);   --w(26,8,18)
signal reg_B 	: std_logic_vector(10 downto 0);
signal reg_C 	: std_logic_vector(15 downto 0);
signal reg_div : std_logic_vector(25 downto 0); --w(26,16,10) -> w(16, 6, 10)

begin

	sample : process(CLK) is
	begin
		if CLK'event and CLK = '1' then
			if RESET = '1' then
				reg_A <= (others => '0');
				reg_B <= (others => '0');
				reg_C <= (others => '0');
				Y 		<= (others => '0');
			else
				reg_A <= A & std_logic_vector(to_unsigned(0, 10));
				reg_B <= B;
				reg_C <= C;
				Y 		<= std_logic_vector(unsigned('0' & reg_div(15 downto 0)) + unsigned('0' & reg_c));
			end if;
		end if;
	end process;
		
	reg_div <= std_logic_vector(unsigned(reg_A) / unsigned(reg_B)); 
   

	
end behavioral;