library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath_3 is
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
			
	end datapath_3;
	
architecture behavioral of datapath_3 is

	constant N : natural := 5;
	signal index : natural;
	type basex_array is array (0 to N-1) of unsigned(10 downto 0);
	type basey_array is array (0 to N-1) of unsigned(13 downto 0);
	type coeff_array is array (0 to N-1) of unsigned(11 downto 0);
														
	signal reg_A 	     : std_logic_vector(15 downto 0);   
	signal reg_B 	     : std_logic_vector(10 downto 0);
	signal reg_C 	  	  : std_logic_vector(15 downto 0);
	signal en_op_sample : std_logic;
	signal done   		  : std_logic; 
	
	signal reg_basex       : basex_array;
	signal reg_basey       : basey_array;
	signal reg_coeff       : coeff_array;
	
	signal current_count, next_count	   : natural;
	signal end_count, reset_counter	: std_logic;
	
	type state is (idle, op_sample, stop);
	signal cs, ns : state;
	
	signal displacement    : unsigned(10 downto 0);   --w(11, 3, 8)
	signal disp_x_coeff    : unsigned(19 downto 0);   --w(20, 4, 16)
	signal inverso         : unsigned(13 downto 0);    --w(14, 6, 8)
	signal inverso_x_divid : unsigned(29 downto 0);   --w(30, 14, 16)

begin

-------------------------- SAMPLING ---------------
	
	sample_operands : process(CLK) 
	begin
		if CLK'event and CLK = '1' then
			if RESET = '1' then
				reg_A <= (others => '0');
				reg_B <= (others => '0');
				reg_C <= (others => '0');
			elsif en_op_sample = '1' then
				reg_A <= A;
				reg_B <= B;
				reg_C <= C;
			end if;
		end if;
	end process;
	
	sample_const : process(CLK)
	begin
		if CLK'event and CLK = '1' then
			if RESET = '1' then
				reg_basex <= (others => (others => '0'));
				reg_basey <= (others => (others => '0'));
				reg_coeff <= (others => (others => '0'));
			elsif LOAD = '1' then
				reg_basex(current_count) <= unsigned(base_x);
				reg_basey(current_count) <= unsigned(base_y);
				reg_coeff(current_count) <= unsigned(coeff);
			end if;
		end if;
	end process;
	
------------------------- OPERATIONS ----------------------
	
	comparator : process(reg_B)
	begin
		index <= 0;
			for I in 0 to N-1 loop
				if (reg_basex(I) < unsigned(reg_B)) then
					index <= I;
				end if;
			end loop;
	end process;
	
	displacement    <= unsigned(reg_B) - reg_basex(index);
	disp_x_coeff    <= displacement(7 downto 0) * reg_coeff(index);
	inverso 		    <= reg_basey(index) - disp_x_coeff(19 downto 8);
	inverso_x_divid <= unsigned(reg_A)*inverso;
	Y 					 <= std_logic_vector(inverso_x_divid(29 downto 13) + unsigned('0' & reg_C)) when done = '1' else (others => '0');
	
 ------------------------------- FSM ----------------------------
 
	FSM_comb : process(cs, LOAD, START, reset_counter) 
	begin
		
		VALID 			 <= '0';
		en_op_sample    <= '0';
		done      		 <= '0';
	
		case cs is
			
			when idle =>
				if START = '1' and LOAD = '0' then
					ns <= op_sample;
				else
					ns <= cs;
				end if;
	
			
			when op_sample =>
				en_op_sample <= '1';
				ns <= stop;
				
			when stop =>
				done <= '1';
				VALID <= '1';
				if start = '1' then
					ns <= op_sample;
				else
					ns <= idle;
				end if;
			
			when others =>
				ns <= idle;			
			
		end case;
	end process;
	
		
	
	FSM_seq : process(CLK) 
	begin
		if CLK'event and CLK = '1' then
			if RESET = '1' then
				cs <= idle;
			else
				cs <= ns;
			end if;
		end if;	
	end process;
	
				
				
	counter_3b : process(CLK) 
	begin
		if CLK'event and CLK = '1' then
			if reset_counter = '1' then
				current_count <= 0;
			elsif LOAD = '1' then
				current_count <= next_count;
			end if;
		end if;
	end process;
	
	next_count 	  <= current_count + 1;
	end_count 	  <= '1' when next_count = N or RESET = '1' else '0';
	reset_counter <= end_count or reset;
	
end architecture;
