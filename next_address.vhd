library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;

entity next_address is
port(	
	rt,rs	    	: in std_logic_vector(31 downto 0);  -- two register input
	pc		: in std_logic_vector(31 downto 0);
	target_address	: in std_logic_vector(25 downto 0);
	branch_type_na	: in std_logic_vector(1 downto 0);
	pc_sel_na	    	: in std_logic_vector(1 downto 0);
	next_pc	    	: out std_logic_vector(31 downto 0));
end next_address;

architecture next_arch of next_address is

signal branch_result: std_logic_vector(31 downto 0);

begin
process(rt, rs, pc, pc_sel_na, branch_type_na, target_address, branch_result)
begin

case pc_sel_na is
	when "00" => next_pc <= branch_result;
	when "01" => next_pc <= "000000" & target_address(25 downto 0);
	when "10" => next_pc <= rs;
	when "11" =>
	when others =>
end case;

case branch_type_na is
	when "00" => 	branch_result <= pc + "00000000000000000000000000000001";
	when "01" => 
		if (rs = rt) then
			branch_result <= pc + "00000000000000000000000000000001" + ((31 downto 16 => target_address(15)) & target_address(15 downto 0));
		else
			branch_result <= pc + "00000000000000000000000000000001";
		end if;
	when "10" => 
		if (rs /= rt) then
			branch_result <= pc + "00000000000000000000000000000001" + ((31 downto 16 => target_address(15)) & target_address(15 downto 0));
		else
			branch_result <= pc + "00000000000000000000000000000001";
		end if;
	when "11" =>
		if (rs < 0) then
			branch_result <= pc + "00000000000000000000000000000001" + ((31 downto 16 => target_address(15)) & target_address(15 downto 0));
		 else
			branch_result <= pc + "00000000000000000000000000000001";
		end if;
	when others =>
end case;
end process;
end next_arch;