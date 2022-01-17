library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;

entity sign_extend is
port( 	immediate : in std_logic_vector(15 downto 0);
	func_se	: in std_logic_vector(1 downto 0);
      	extended: out std_logic_vector(31 downto 0));
end sign_extend;

architecture sign_arch of sign_extend is

begin
	process(immediate, func_se)
	begin
		case func_se is
			when "00" => extended <= immediate(15 downto 0) & "0000000000000000"; 
			when "01" => extended <= (31 downto 16 => immediate(15)) & immediate(15 downto 0); 
			when "10" => extended <= (31 downto 16 => immediate(15)) & immediate(15 downto 0);
			when "11" => extended <= "0000000000000000" & immediate(15 downto 0); 
			when others =>
		end case;
	end process;
end sign_arch;