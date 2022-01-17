library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;

entity cpu is 
port( 
  	clk: in std_logic;
	reset: in std_logic;
	rs_out, rt_out : out std_logic_vector(3 downto 0);
	pc_out : out std_logic_vector(3 downto 0);
	overflow, zero : out std_logic);
end cpu;
	  
  
architecture cpu_arch of cpu is

-- components --

component i_cache_comp is
	port
	(
		address : in std_logic_vector(4 downto 0);
		instruction : out std_logic_vector(31 downto 0));
end component;

component d_cache_comp is
	port
	(
		clock_d : in std_logic;
		reset_d : in std_logic;
		input : in std_logic_vector(31 downto 0);
		data_write_d : in std_logic;
		add : in std_logic_vector(4 downto 0);
		output: out std_logic_vector(31 downto 0));
end component;
	  
component sign_extend_comp is
	port
	( 	func_se : in std_logic_vector(1 downto 0);
		immediate : in std_logic_vector(15 downto 0);
		extended : out std_logic_vector(31 downto 0)); 
end component;

component regfile_comp is 
	port
	( 	din   : in std_logic_vector(31 downto 0);      
		reset_r : in std_logic;
		clk_r   : in std_logic;
		write : in std_logic;
		read_a : in std_logic_vector(4 downto 0);
		read_b : in std_logic_vector(4 downto 0);
		write_address : in std_logic_vector(4 downto 0);
		out_a  : out std_logic_vector(31 downto 0);
		out_b  : out std_logic_vector(31 downto 0));
end component;
	
component alu_comp is 
port
	( 	x : in std_logic_vector(31 downto 0);
		y : in std_logic_vector(31 downto 0); 
		add_sub_alu : in std_logic; -- 0 = add , 1 = sub
		logic_func_alu : in std_logic_vector(1 downto 0 );-- 00 = AND, 01 = OR , 10 = XOR , 11 = NOR
		func_alu : in std_logic_vector(1 downto 0 ) ; -- 00 = lui, 01 = setless , 10 = arith , 11 = logic
		output : out std_logic_vector(31 downto 0) ;
		overflow_alu : out std_logic ;
		zero_alu : out std_logic);
end component;

component next_address_comp is 
	port
	(
		rt : in std_logic_vector(31 downto 0);
		rs : in std_logic_vector(31 downto 0); 
		pc     : in std_logic_vector(31 downto 0);
    		target_address : in std_logic_vector(25 downto 0);
		branch_type_na    : in std_logic_vector(1 downto 0);
		pc_sel_na	: in std_logic_vector(1 downto 0);
     		next_pc	: out std_logic_vector(31 downto 0));
end component;

component pc_reg_comp is 
	port( 
	  	clock_pc : in  std_logic;
		reset_pc : in std_logic;
		in_next : in std_logic_vector(31 downto 0);
		out_pc : out std_logic_vector(31 downto 0));
end component;

-- entities --

for INST : i_cache_comp use entity work.i_cache(i_cache_arch);
for DTA : d_cache_comp use entity work.d_cache(d_cache_arch);
for XTND : sign_extend_comp use entity work.sign_extend(sign_arch);
for RG : regfile_comp use entity work.regfile(reg_arch);
for AL : alu_comp use entity work.alu(alu_arch);
for NA : next_address_comp use entity work.next_address(next_arch);
for PCRG : pc_reg_comp use entity work.pc_reg(pc_reg_arch);
	  
-- signals --
	
signal pc_s, next_pc_s, i_c_s, d_c_s, a_s, b_s, alu_s, se_s, alu_input, reg_input : std_logic_vector(31 downto 0) := X"00000000";
signal write_reg_mux : std_logic_vector(4 downto 0) := (others => '0');
	
--control unit
signal logic_func, func, branch_type, pc_sel : std_logic_vector(1 downto 0) := "00";
signal reg_write, reg_dst, reg_in_src, alu_src, add_sub, data_write, alu_overflow, alu_zero : std_logic := '0';
signal opcode : std_logic_vector(5 downto 0) := (others => '0');
signal funcc : std_logic_vector(5 downto 0) := (others => '0');


begin
process(i_c_s, clk, reset, opcode, funcc)
begin
	opcode	 <= i_c_s(31 downto 26);
	funcc	 <= i_c_s(5 downto 0);
	case opcode is
		when "000000" =>
			 case funcc is
				when "100000" => -- add
						reg_write <= '1'; 
						reg_dst <=  '1'; 
						reg_in_src <=  '1'; 
						alu_src <=  '0'; 
						add_sub <=  '0'; 
						data_write <= '0'; 
						logic_func <= "00";
						func <= "10";
						branch_type <= "00";
						pc_sel <= "00"; 
				when "100010" => -- sub
						reg_write <= '1'; 
						reg_dst <=  '1'; 
						reg_in_src <=  '1'; 
						alu_src <=  '0'; 
						add_sub <=  '1'; 
						data_write <= '0'; 
						logic_func <= "00";
						func <= "10";
						branch_type <= "00";
						pc_sel <= "00"; 
				when "101010" => -- slt
						reg_write <= '1'; 
						reg_dst <=  '1'; 
						reg_in_src <=  '1'; 
						alu_src <=  '0'; 
						add_sub <=  '0'; 
						data_write <= '0'; 
						logic_func <= "00";
						func <= "01";
						branch_type <= "00";
						pc_sel <= "00"; 
				when "100100" => -- and
						reg_write <= '1'; 
						reg_dst <=  '1'; 
						reg_in_src <=  '1'; 
						alu_src <=  '0'; 
						add_sub <=  '1'; 
						data_write <= '0'; 
						logic_func <= "00";
						func <= "11";
						branch_type <= "00";
						pc_sel <= "00"; 
				when "100101" => -- or
						reg_write <= '1'; 
						reg_dst <=  '1'; 
						reg_in_src <=  '1'; 
						alu_src <=  '0'; 
						add_sub <=  '0'; 
						data_write <= '0'; 
						logic_func <= "01";
						func <= "11";
						branch_type <= "00";
						pc_sel <= "00";
				when "100110" => -- xor
						reg_write <= '1'; 
						reg_dst <=  '1'; 
						reg_in_src <=  '1'; 
						alu_src <=  '0'; 
						add_sub <=  '0'; 
						data_write <= '0'; 
						logic_func <= "10";
						func <= "11";
						branch_type <= "00";
						pc_sel <= "00";
				when "100111" => -- nor
						reg_write <= '1'; 
						reg_dst <=  '1'; 
						reg_in_src <=  '1'; 
						alu_src <=  '0'; 
						add_sub <=  '0'; 
						data_write <= '0'; 
						logic_func <= "11";
						func <= "11";
						branch_type <= "00";
						pc_sel <= "00";
				when "001000" => -- jr
						reg_write <= '0'; 
						reg_dst <=  '0'; 
						reg_in_src <=  '0'; 
						alu_src <=  '0'; 
						add_sub <=  '0'; 
						data_write <= '0'; 
						logic_func <= "00";
						func <= "00";
						branch_type <= "00";
						pc_sel <= "10";
				when others => 
			end case;
		when "001111" => -- lui
				reg_write <= '1'; 
				reg_dst <=  '0'; 
				reg_in_src <=  '1'; 
				alu_src <=  '1'; 
				add_sub <=  '0'; 
				data_write <= '0'; 
				logic_func <= "00";
				func <= "00";
				branch_type <= "00";
				pc_sel <= "00";
		when "001000" => -- addi
				reg_write <= '1'; 
				reg_dst <=  '0'; 
				reg_in_src <=  '1'; 
				alu_src <=  '1'; 
				add_sub <=  '0'; 
				data_write <= '0'; 
				logic_func <= "00";
				func <= "10";
				branch_type <= "00";
				pc_sel <= "00";
		when "001010" => -- slti
				reg_write <= '1'; 
				reg_dst <=  '0'; 
				reg_in_src <=  '1'; 
				alu_src <=  '1'; 
				add_sub <=  '0'; 
				data_write <= '0'; 
				logic_func <= "00";
				func <= "01";
				branch_type <= "00";
				pc_sel <= "00";
		when "001100" => -- andi
				reg_write <= '1'; 
				reg_dst <=  '0'; 
				reg_in_src <=  '1'; 
				alu_src <=  '1'; 
				add_sub <=  '0'; 
				data_write <= '0'; 
				logic_func <= "00";
				func <= "11";
				branch_type <= "00";
				pc_sel <= "00";
		when "001101" => -- ori
				reg_write <= '1'; 
				reg_dst <=  '0'; 
				reg_in_src <=  '1'; 
				alu_src <=  '1'; 
				add_sub <=  '0'; 
				data_write <= '0'; 
				logic_func <= "01";
				func <= "11";
				branch_type <= "00";
				pc_sel <= "00";
		when "001110" => -- xori
				reg_write <= '1'; 
				reg_dst <=  '0'; 
				reg_in_src <=  '1'; 
				alu_src <=  '1'; 
				add_sub <=  '0'; 
				data_write <= '0'; 
				logic_func <= "10";
				func <= "11";
				branch_type <= "00";
				pc_sel <= "00";
		when "100011" => -- lw
				reg_write <= '1'; 
				reg_dst <=  '0'; 
				reg_in_src <=  '0'; 
				alu_src <=  '1'; 
				add_sub <=  '0'; 
				data_write <= '0'; 
				logic_func <= "10";
				func <= "10";
				branch_type <= "00";
				pc_sel <= "00";
		when "101011" => -- sw
				reg_write <= '0'; 
				reg_dst <=  '0'; 
				reg_in_src <=  '0'; 
				alu_src <=  '1'; 
				add_sub <=  '0'; 
				data_write <= '1'; 
				logic_func <= "00";
				func <= "10";
				branch_type <= "00";
				pc_sel <= "00";
		when "000010" => -- j
				reg_write <= '0'; 
				reg_dst <=  '0'; 
				reg_in_src <=  '0'; 
				alu_src <=  '0'; 
				add_sub <=  '0'; 
				data_write <= '0'; 
				logic_func <= "00";
				func <= "00";
				branch_type <= "00";
				pc_sel <= "01";
		when "000001" => -- bltz
				reg_write <= '0'; 
				reg_dst <=  '0'; 
				reg_in_src <=  '0'; 
				alu_src <=  '0'; 
				add_sub <=  '0'; 
				data_write <= '0'; 
				logic_func <= "00";
				func <= "00";
				branch_type <= "11";
				pc_sel <= "00";
		when "000100" => -- beq
				reg_write <= '0'; 
				reg_dst <=  '0'; 
				reg_in_src <=  '0'; 
				alu_src <=  '0'; 
				add_sub <=  '0'; 
				data_write <= '0'; 
				logic_func <= "00";
				func <= "00";
				branch_type <= "01";
				pc_sel <= "00";
		when "000101" => -- bne
				reg_write <= '0'; 
				reg_dst <=  '0'; 
				reg_in_src <=  '0'; 
				alu_src <=  '0'; 
				add_sub <=  '0'; 
				data_write <= '0'; 
				logic_func <= "00";
				func <= "00";
				branch_type <= "10";
				pc_sel <= "00";
		when others =>
	end case;
end process; 

-- portmaps
INST: i_cache_comp port map(address => pc_s(4 downto 0), instruction => i_c_s);

DTA: d_cache_comp port map(input => b_s, reset_d => reset, clock_d => clk,add => alu_s(4 downto 0), data_write_d => data_write, output => d_c_s);

XTND: sign_extend_comp port map(immediate => i_c_s(15 downto 0), func_se => func, extended => se_s);


RG: regfile_comp port map(din => reg_input, reset_r => reset, clk_r => clk, write => reg_write, read_a => i_c_s(25 downto 21), read_b => i_c_s(20 downto 16), write_address => write_reg_mux, out_a => a_s, out_b => b_s);

AL: alu_comp port map(x => a_s, y => alu_input, add_sub_alu => add_sub, logic_func_alu => logic_func, func_alu => func, output => alu_s, overflow_alu => alu_overflow, zero_alu => alu_zero);

NA: next_address_comp port map(rt => b_s, rs => a_s, pc => pc_s, target_address => i_c_s(25 downto 0), branch_type_na => branch_type, pc_sel_na => pc_sel, next_pc => next_pc_s);

PCRG: pc_reg_comp port map(in_next => next_pc_s, reset_pc => reset, clock_pc => clk, out_pc => pc_s);


-- muxes

write_reg_mux <= i_c_s(20 downto 16) WHEN (reg_dst = '0') ELSE
	         i_c_s(15 downto 11) WHEN (reg_dst = '1');

alu_input <= se_s WHEN (alu_src = '1') ELSE
	      b_s WHEN (alu_src = '0');

reg_input <= alu_s WHEN (reg_in_src = '1') ELSE
	     d_c_s WHEN (reg_in_src = '0');

--outputs

zero <= alu_zero;
overflow <= alu_overflow;
rs_out	<= (a_s(3 downto 0));
rt_out	<= (b_s(3 downto 0));
pc_out	<= (pc_s(3 downto 0));

end cpu_arch;
