library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;

entity pc_reg is 
port( 
  	clock_pc : in  std_logic;
	reset_pc : in std_logic;
	in_next : in std_logic_vector(31 downto 0);
	out_pc : out std_logic_vector(31 downto 0));
end pc_reg;
	  
architecture pc_reg_arch of pc_reg is

begin
	process (clock_pc, reset_pc, in_next)
	begin
		if (reset_pc = '1') then 
			out_pc <= X"00000000";
		elsif (rising_edge(clock_pc)) then
			out_pc <= in_next;
		end if;
	end process;
end pc_reg_arch;
