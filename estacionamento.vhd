library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity estacionamento is
	generic (clockFreq : integer := 50e6); -- clock DE10 Lite = 50 MHz
	port (
		clk          : in  std_logic;
		reset        : in  std_logic := '0';
		entrada1     : in  std_logic;
		display1     : out std_logic_vector(6 downto 0);
		entrada2     : in  std_logic;
		display2     : out std_logic_vector(6 downto 0);
		entrada3     : in  std_logic;
		pagar        : in  std_logic_vector(2 downto 0);
		display3     : out std_logic_vector(6 downto 0);
		displayvagas : out std_logic_vector(6 downto 0);
		--vagas_disp   : out std_logic_vector(2 downto 0); -- Foi alterado de buffer para out
		vagaAPagar	: in	std_logic_vector(1 downto 0) := "00";
		abrirCancela	: out std_logic
	);
end entity estacionamento;

architecture behavior of estacionamento is

	constant totalVagas : integer := 3;

	signal contador_vagas	: unsigned(2 downto 0);
	signal vaga1_ocup, vaga2_ocup, vaga3_ocup : std_logic;
    
	signal valorAPagar1, valorAPagar2, valorAPagar3, valorAPagarAtual : std_logic_vector(2 downto 0);
	signal pgtoAutorizado1, pgtoAutorizado2, pgtoAutorizado3, pgtoAutorizadoAtual : std_logic;
	 
	signal comandoCancela 	:	std_logic;  -- Sinal para abrir a cancela

	signal entrada1Invertida, entrada2Invertida, entrada3Invertida	:	std_logic;
	signal vagas_disp   :  std_logic_vector(2 downto 0); -- Foi alterado de buffer para out

-----------------------------------------
------- Declaracao dos componentes ------
-----------------------------------------
	
	component vaga is
		generic (clockFreq : integer := 50e6);
		port (
			clk            : in  std_logic;
			reset          : in  std_logic := '0';
			entrada        : in  std_logic;
			saida          : in  std_logic;
			display        : out std_logic_vector(6 downto 0);
			valorAPagar    : out std_logic_vector(2 downto 0);
			pgtoAutorizado : in std_logic;
			vaga_ocup      : out std_logic
		);
	end component;

	component cobranca is
		port (
			valorAPagar         : in  std_logic_vector(2 downto 0);
			pagamento           : in  std_logic_vector(2 downto 0);
			pagamentoAutorizado : out  std_logic := '0'
		);
	end component;

	component display_7_segmentos_vagas_disp is
		port (
			vagas      : in unsigned(2 downto 0);
			segmentos  : out std_logic_vector(6 downto 0)
		);
	end component;
	 
	component controle_cancela is
		port (
        clk   		: in  std_logic;
        reset  	: in  std_logic;
        comando	: in  std_logic;  -- Sinal para abrir a cancela
        cancela	: out std_logic   -- Sinal PWM para o cancela motor
		);
	end component;

begin

---------------------------------------------
------- Inversao dos sinais de entrada ------
---------------------------------------------

	entrada1Invertida <= not entrada1;
	entrada2Invertida <= not entrada2;
	entrada3Invertida <= not entrada3;
	
-------------------------------
------- Mapeia os sinais ------
-------------------------------

	U_vaga1 : entity work.vaga
		generic map (clockFreq => clockFreq)
		port map (
			clk            => clk,
			reset          => reset,
			entrada        => entrada1Invertida,
			valorAPagar    => valorAPagar1,
			pgtoAutorizado => pgtoAutorizado1,
			display        => display1,
			vaga_ocup      => vaga1_ocup
		);

	U_vaga2 : entity work.vaga
		generic map (clockFreq => clockFreq)
		port map (
			clk            => clk,
			reset          => reset,
			entrada        => entrada2Invertida,
			valorAPagar    => valorAPagar2,
			pgtoAutorizado => pgtoAutorizado2,
			display        => display2,
			vaga_ocup      => vaga2_ocup
		);

	U_vaga3 : entity work.vaga
		generic map (clockFreq => clockFreq)
		port map (
			clk            => clk,
			reset          => reset,
			entrada        => entrada3Invertida,
			valorAPagar    => valorAPagar3,
			pgtoAutorizado => pgtoAutorizado3,
			display        => display3,
			vaga_ocup      => vaga3_ocup
		);

	U_cobranca : entity work.cobranca
		port map (
			valorAPagar         => valorAPagarAtual,
			pagamento           => pagar,
			pagamentoAutorizado => pgtoAutorizadoAtual
		);

-------------------------------
------ Realiza pagamento ------
-------------------------------

process(clk, reset)
	begin
	 
	if reset = '1' then
		valorAPagarAtual <= (others => '0');
			pgtoAutorizado1 <= '0';
			pgtoAutorizado2 <= '0';
			pgtoAutorizado3 <= '0';
	elsif rising_edge(clk) then
		  
		if vagaAPagar = "00" then -- Nao faz nada, estado padrao
			pgtoAutorizado1 <= '0';
			pgtoAutorizado2 <= '0';
			pgtoAutorizado3 <= '0';
		  
		elsif vagaAPagar = "01" then
			valorAPagarAtual <= valorAPagar1;
			pgtoAutorizado1 <= pgtoAutorizadoAtual;
			
			pgtoAutorizado2 <= '0'; -- Nao libera 2 e 3 caso esteja pagando 1
			pgtoAutorizado3 <= '0';

		elsif vagaAPagar = "10"  then
			valorAPagarAtual <= valorAPagar2;
			pgtoAutorizado2 <= pgtoAutorizadoAtual;
			
			pgtoAutorizado1 <= '0'; -- Nao libera 1 e 3 caso esteja pagando 2
			pgtoAutorizado3 <= '0';
			
		elsif vagaAPagar = "11"  then
			valorAPagarAtual <= valorAPagar3;
			pgtoAutorizado3 <= pgtoAutorizadoAtual;
			
			pgtoAutorizado1 <= '0'; -- Nao libera 1 e 2 caso esteja pagando 3
			pgtoAutorizado2 <= '0';
			
		end if;
	end if;
end process;

-----------------------------------------------------------
------ Testar se o codigo abaixo resolve o pagamento ------
-----------------------------------------------------------

--process(clk, reset)
--begin
--    if reset = '1' then
--        valorAPagarAtual <= (others => '0');
--        pgtoAutorizado1 <= '0';
--        pgtoAutorizado2 <= '0';
--        pgtoAutorizado3 <= '0';
--    elsif rising_edge(clk) then
--        case vagaAPagar is
--            when "00" => -- Nao faz nada, estado padrao
--                valorAPagarAtual <= (others => '0');
--            when "01" =>
--                valorAPagarAtual <= valorAPagar1;
--                if pgtoAutorizadoAtual = '1' then
--                    pgtoAutorizado1 <= '1';
--                end if;
--            when "10" =>
--                valorAPagarAtual <= valorAPagar2;
--                if pgtoAutorizadoAtual = '1' then
--                    pgtoAutorizado2 <= '1';
--                end if;
--            when "11" =>
--                valorAPagarAtual <= valorAPagar3;
--                if pgtoAutorizadoAtual = '1' then
--                    pgtoAutorizado3 <= '1';
--                end if;
--            when others =>
--                valorAPagarAtual <= (others => '0');
--        end case;
--    end if;
--end process;

	 

--------------------------------------------------------
------ conta vagas disponiveis e controla cancela ------
--------------------------------------------------------

	U_controle_cancela : entity work.controle_cancela
		port map (
			clk		=> clk,
			reset		=> reset,
			comando	=> comandoCancela,
			cancela	=> abrirCancela
		);

process(clk, vaga1_ocup, vaga2_ocup, vaga3_ocup) -- Testar remocao de vaga1_ocup, vaga2_ocup, vaga3_ocup da lista de sensibilidade
	begin
		contador_vagas <= totalVagas - to_unsigned(
			to_integer(unsigned'("0" & vaga1_ocup)) +
			to_integer(unsigned'("0" & vaga2_ocup)) +
			to_integer(unsigned'("0" & vaga3_ocup)),
			3
		);
  
		if contador_vagas > 0 then
			comandoCancela <= '1';
		else
			comandoCancela <= '0';
		end if;
			
end process;

--------------------------------------
------ Mostra vagas disponiveis ------
--------------------------------------

	U_displayVagas : display_7_segmentos_vagas_disp
		port map (
			vagas      => contador_vagas,
			segmentos  => displayvagas
		);
		
	vagas_disp <= std_logic_vector(to_unsigned(3, 3) - contador_vagas);

end architecture;



---------------------------------------------------------------------------
-------- Codigo abaixo implementa a cobranca sem utilizar componente ------
---------------------------------------------------------------------------


--
--library ieee;
--use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
--
--entity estacionamento is
--	generic (clockFreq : integer := 50e6); -- clock DE10 Lite = 50 MHz
--	port (
--		clk          : in  std_logic;
--		reset        : in  std_logic := '0';
--		entrada1     : in  std_logic;
--		display1     : out std_logic_vector(6 downto 0);
--		entrada2     : in  std_logic;
--		display2     : out std_logic_vector(6 downto 0);
--		entrada3     : in  std_logic;
--		pagar        : in  std_logic_vector(2 downto 0);
--		display3     : out std_logic_vector(6 downto 0);
--		displayvagas : out std_logic_vector(6 downto 0);
--		vagas_disp   : out std_logic_vector(2 downto 0); -- Foi alterado de buffer para out
--		vagaAPagar	: in	std_logic_vector(1 downto 0) := "00";
--		abrirCancela	: out std_logic
--	);
--end entity estacionamento;
--
--architecture behavior of estacionamento is
--
--	constant totalVagas : integer := 3;
--
--	signal contador_vagas	: unsigned(2 downto 0);
--	signal vaga1_ocup, vaga2_ocup, vaga3_ocup : std_logic;
--    
--	signal valorAPagar1, valorAPagar2, valorAPagar3 : std_logic_vector(2 downto 0);
--	signal pgtoAutorizado1, pgtoAutorizado2, pgtoAutorizado3, pgtoAutorizadoAtual : std_logic;
--	 
--	signal comandoCancela 	:	std_logic;  -- Sinal para abrir a cancela
--
--	signal entrada1Invertida, entrada2Invertida, entrada3Invertida	:	std_logic;
--
-------------------------------------------
--------- Declaracao dos componentes ------
-------------------------------------------
--	
--	component vaga is
--		generic (clockFreq : integer := 50e6);
--		port (
--			clk            : in  std_logic;
--			reset          : in  std_logic := '0';
--			entrada        : in  std_logic;
--			saida          : in  std_logic;
--			display        : out std_logic_vector(6 downto 0);
--			valorAPagar    : out std_logic_vector(2 downto 0);
--			pgtoAutorizado : in std_logic;
--			vaga_ocup      : out std_logic
--		);
--	end component;
--
--	component display_7_segmentos_vagas_disp is
--		port (
--			vagas      : in unsigned(2 downto 0);
--			segmentos  : out std_logic_vector(6 downto 0)
--		);
--	end component;
--	 
--	component controle_cancela is
--		port (
--        clk   		: in  std_logic;
--        reset  	: in  std_logic;
--        comando	: in  std_logic;  -- Sinal para abrir a cancela
--        cancela	: out std_logic   -- Sinal PWM para o cancela motor
--		);
--	end component;
--
--begin
--
-----------------------------------------------
--------- Inversao dos sinais de entrada ------
-----------------------------------------------
--
--	entrada1Invertida <= not entrada1;
--	entrada2Invertida <= not entrada2;
--	entrada3Invertida <= not entrada3;
--
---------------------------------
--------- Mapeia os sinais ------
---------------------------------
--	U_vaga1 : entity work.vaga
--		generic map (clockFreq => clockFreq)
--		port map (
--			clk            => clk,
--			reset          => reset,
--			entrada        => entrada1Invertida,
--			valorAPagar    => valorAPagar1,
--			pgtoAutorizado => pgtoAutorizado1,
--			display        => display1,
--			vaga_ocup      => vaga1_ocup
--		);
--
--	U_vaga2 : entity work.vaga
--		generic map (clockFreq => clockFreq)
--		port map (
--			clk            => clk,
--			reset          => reset,
--			entrada        => entrada2Invertida,
--			valorAPagar    => valorAPagar2,
--			pgtoAutorizado => pgtoAutorizado2,
--			display        => display2,
--			vaga_ocup      => vaga2_ocup
--		);
--
--	U_vaga3 : entity work.vaga
--		generic map (clockFreq => clockFreq)
--		port map (
--			clk            => clk,
--			reset          => reset,
--			entrada        => entrada3Invertida,
--			valorAPagar    => valorAPagar3,
--			pgtoAutorizado => pgtoAutorizado3,
--			display        => display3,
--			vaga_ocup      => vaga3_ocup
--		);
--	  
---------------------------------
-------- Realiza pagamento ------
---------------------------------
--
--process(clk, reset)
--	begin
--	 
--	if reset = '1' then
--		pgtoAutorizado1 <= '0';
--		pgtoAutorizado2 <= '0';
--		pgtoAutorizado3 <= '0';
--	elsif rising_edge(clk) then
--		  
--		if vagaAPagar = "00" then -- Nao faz nada, estado padrao
--			pgtoAutorizado1 <= '0';
--			pgtoAutorizado2 <= '0';
--			pgtoAutorizado3 <= '0';
--		  
--		elsif vagaAPagar = "01" then
--			
--			if pagar = valorAPagar1 then
--				pgtoAutorizado1 <= '1';
--			else
--				pgtoAutorizado1 <= '0';
--			end if;
--			
--			pgtoAutorizado2 <= '0';
--			pgtoAutorizado3 <= '0';
--		
--		elsif vagaAPagar = "10"  then
--		
--			if pagar = valorAPagar2 then
--				pgtoAutorizado2 <= '1';
--			else
--				pgtoAutorizado2 <= '0';
--			end if;
--			
--			pgtoAutorizado1 <= '0';
--			pgtoAutorizado3 <= '0';
--		
--
--		elsif vagaAPagar = "11"  then
--		
--			if pagar = valorAPagar3 then
--				pgtoAutorizado3 <= '1';
--			else
--				pgtoAutorizado3 <= '0';
--			end if;
--			
--			pgtoAutorizado1 <= '0';
--			pgtoAutorizado2 <= '0';
--
--		end if;
--	end if;
--end process;
--
----------------------------------------------------------
-------- conta vagas disponiveis e controla cancela ------
----------------------------------------------------------
--
--	U_controle_cancela : entity work.controle_cancela
--		port map (
--			clk		=> clk,
--			reset		=> reset,
--			comando	=> comandoCancela,
--			cancela	=> abrirCancela
--		);
--
--process(clk, vaga1_ocup, vaga2_ocup, vaga3_ocup) -- Testar remocao de vaga1_ocup, vaga2_ocup, vaga3_ocup da lista de sensibilidade
--	begin
--		contador_vagas <= totalVagas - to_unsigned(
--			to_integer(unsigned'("0" & vaga1_ocup)) +
--			to_integer(unsigned'("0" & vaga2_ocup)) +
--			to_integer(unsigned'("0" & vaga3_ocup)),
--			3
--		);
--  
--		if contador_vagas > 0 then
--			comandoCancela <= '1';
--		else
--			comandoCancela <= '0';
--		end if;
--			
--end process;
--
----------------------------------------
-------- Mostra vagas disponiveis ------
----------------------------------------
--
--	U_displayVagas : display_7_segmentos_vagas_disp
--		port map (
--			vagas      => contador_vagas,
--			segmentos  => displayvagas
--		);
--		
--	vagas_disp <= std_logic_vector(to_unsigned(3, 3) - contador_vagas);
--
--end architecture;