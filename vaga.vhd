library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vaga is
	generic (
		clockFreq : integer := 50e6
	);
	port (
		clk        		: in  std_logic;
		reset      		: in  std_logic := '0';
		entrada    		: in  std_logic;
		display    		: out std_logic_vector(6 downto 0);
		valorAPagar		: out std_logic_vector(2 downto 0);
		pgtoAutorizado	: in std_logic;
		vaga_ocup  		: out std_logic
	);
end entity vaga;

architecture behavior of vaga is
	type estado is (VAGA_VAZIA, VAGA_PREENCHIDA, EXIBICAO);
	signal estado_atual, prox_estado : estado;
   signal tempo, prox_tempo : unsigned(31 downto 0);
   signal pagamento : std_logic_vector(2 downto 0);
   signal ticks : integer range 0 to clockFreq := 0;
	signal one_second_tick : std_logic := '0';

begin

----------------------------------------------------
--------------------- Contador ---------------------
----------------------------------------------------
process(clk, reset)
	begin
		if reset = '1' then
			estado_atual <= VAGA_VAZIA;
			tempo <= (others => '0');
			ticks <= 0;
			one_second_tick <= '0';
		elsif rising_edge(clk) then
			if ticks = clockFreq - 1 then
				ticks <= 0;
				one_second_tick <= '1';
			else
				ticks <= ticks + 1;
				one_second_tick <= '0';
			end if;
			estado_atual <= prox_estado;
			tempo <= prox_tempo;
        end if;
	  
end process;


------------------------------------------------------
----------------- Máquina de Estado ------------------
------------------------------------------------------

process(estado_atual, entrada, tempo, one_second_tick)
	begin
		prox_estado <= estado_atual;
		prox_tempo <= tempo;
		
		if one_second_tick = '1' then
			case estado_atual is
				when VAGA_VAZIA => -- Vaga vazia
					if entrada = '1' then
						prox_estado <= VAGA_PREENCHIDA;
					end if;
				when VAGA_PREENCHIDA => -- Vaga preenchida
					if entrada = '0' then
						prox_estado <= EXIBICAO;
					elsif tempo < 9 then
						prox_tempo <= tempo + 1;
					end if;
				when EXIBICAO => -- Exibição
					 
					if tempo < 7 then
						pagamento <= std_logic_vector(tempo(2 downto 0));
					else 
						pagamento <= "111";
					end if;
							
					valorAPagar <= pagamento;
						  
					if pgtoAutorizado = '1' then
						prox_estado <= VAGA_VAZIA;
						prox_tempo <= (others => '0');
					end if;
						  
				when others =>
					prox_estado <= VAGA_VAZIA;
					prox_tempo <= (others => '0');
            end case;
		end if;
end process;

	vaga_ocup <= '1' when estado_atual /= VAGA_VAZIA else '0';

	U_display : entity work.display_7_segmentos
		port map (
			valor     => unsigned(tempo(3 downto 0)),
			segmentos => display
		);
end architecture;