library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controle_cancela is
    port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        comando  : in  std_logic;  -- Sinal para abrir a cancela
        cancela    : out std_logic   -- Sinal PWM para o servo motor
    );
end entity controle_cancela;

architecture behavior of controle_cancela is
    constant clockFreq : integer := 50_000_000; -- Frequência do clock, 50 MHz
    constant periodo   : integer := clockFreq * 20 / 1000; -- Período de 20ms
    constant pulso_90  : integer := clockFreq * 15 / 10_000; -- Pulso de 1,5ms para 90 graus
    constant pulso_0   : integer := clockFreq * 10 / 10_000; -- Pulso de 1ms para 0 graus

    signal contador    : integer range 0 to periodo-1 := 0;
    signal pwm_signal  : std_logic := '0';

begin
    process(clk, reset)
    begin
        if reset = '1' then
            contador <= 0;
            pwm_signal <= '0';
        elsif rising_edge(clk) then
            if contador < periodo - 1 then
                contador <= contador + 1;
            else
                contador <= 0;
            end if;

            if comando = '1' then
                if contador < pulso_90 then
                    pwm_signal <= '1';
                else
                    pwm_signal <= '0';
                end if;
            elsif comando = '0' then
                if contador < pulso_0 then
                    pwm_signal <= '1';
                else
                    pwm_signal <= '0';
                end if;
            end if;
        end if;
    end process;

    cancela <= pwm_signal;

end architecture;
