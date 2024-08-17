library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity display_7_segmentos_vagas_disp is
    port (
        vagas     : in  unsigned(2 downto 0);
        segmentos : out std_logic_vector(6 downto 0)
    );
end entity display_7_segmentos_vagas_disp;

architecture behavior of display_7_segmentos_vagas_disp is
begin
    process(vagas)
    begin
        case vagas is
            when "000" => segmentos <= "1000000"; -- 0
            when "001" => segmentos <= "1111001"; -- 1
            when "010" => segmentos <= "0100100"; -- 2
            when "011" => segmentos <= "0110000"; -- 3
            when others => segmentos <= "0000000"; -- Apagar segmentos para valores fora do esperado
        end case;
    end process;
end architecture behavior;
