library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cobranca is
    port (
		  valorAPagar    			: in  std_logic_vector(2 downto 0);
        pagamento    			: in  std_logic_vector(2 downto 0);
        pagamentoAutorizado	: out  std_logic := '0'
    );
end entity cobranca;

architecture behavior of cobranca is

begin

	pagamentoAutorizado <= '1' when valorAPagar = pagamento else '0';

end architecture;