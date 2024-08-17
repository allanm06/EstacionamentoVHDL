--library ieee;
--use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
--
--entity display_7_segmentos is
--    port (
--        numero    : in  integer;
--        segmentos : out std_logic_vector(6 downto 0)
--    );
--end display_7_segmentos;
--
--architecture behavior of display_7_segmentos is
--begin
--    process(numero)
--    begin
--        case numero is
--            when 0 => segmentos <= "1000000"; -- 0
--            when 1 => segmentos <= "1111001"; -- 1
--            when 2 => segmentos <= "0100100"; -- 2
--            when 3 => segmentos <= "0110000"; -- 3
--            when 4 => segmentos <= "0011001"; -- 4
--            when 5 => segmentos <= "0010010"; -- 5
--            when 6 => segmentos <= "0000010"; -- 6
--            when 7 => segmentos <= "1111000"; -- 7
--            when 8 => segmentos <= "0000000"; -- 8
--            when 9 => segmentos <= "0010000"; -- 9
--            when others => segmentos <= "1111111"; -- Blank
--        end case;
--    end process;
--end behavior;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity display_7_segmentos is
    port (
        valor     : in  unsigned(3 downto 0);
        segmentos : out std_logic_vector(6 downto 0)
    );
end entity display_7_segmentos;

architecture behavior of display_7_segmentos is
begin
    process(valor)
    begin
        case valor is
            when "0000" => segmentos <= "1000000"; -- 0
            when "0001" => segmentos <= "1111001"; -- 1
            when "0010" => segmentos <= "0100100"; -- 2
            when "0011" => segmentos <= "0110000"; -- 3
            when "0100" => segmentos <= "0011001"; -- 4
            when "0101" => segmentos <= "0010010"; -- 5
            when "0110" => segmentos <= "0000010"; -- 6
            when "0111" => segmentos <= "1011000"; -- 7
            when "1000" => segmentos <= "0000000"; -- 8
            when "1001" => segmentos <= "0010000"; -- 9
            when others => segmentos <= "0000000"; -- Apagar segmentos para valores fora do esperado
        end case;
    end process;
end architecture behavior;

