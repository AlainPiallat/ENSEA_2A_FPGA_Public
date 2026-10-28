library ieee;
use IEEE.std_logic_1164.all;

entity counter_tb is
    generic (
        N: integer := 4
    );
end entity counter_tb;

architecture rtl of counter_tb is
    signal tb_i_rst: std_logic;
    
    signal tb_i_clk: std_logic;
    signal tb_i_en: std_logic;
    
    signal tb_o_count: std_logic_vector(N-1 downto 0);

    signal theoretical_output: std_logic_vector(N-1 downto 0);

    signal tb_fin: std_logic := '0';
begin
    clk: process
    begin
        tb_i_clk <= '0';
        wait for 10 ns;
        tb_i_clk <= '1';
        wait for 10 ns;
        
        if (tb_fin = '1') then
            wait;
        end if;
    end process clk;

    uut: entity work.counter
        generic map (
            N => N
        )
        port map (
            i_rst => tb_i_rst,

            i_clk => tb_i_clk,
            i_en => tb_i_en,
            
            o_count => tb_o_count
        );
        
    process
    begin
        -- Ce test initialise le compteur à 0, puis laisse la clock l'incrémenter 4 fois, puis le réinitialise à 0.
        tb_i_en <= '0';
        tb_i_rst <= '0';
        theoretical_output <= (others => '0');

        wait until falling_edge(tb_i_clk);

        tb_i_en <= '1';

        wait until rising_edge(tb_i_clk);
        theoretical_output <= "0001";

        wait until rising_edge(tb_i_clk);
        theoretical_output <= "0010";

        wait until rising_edge(tb_i_clk);
        theoretical_output <= "0011";

        wait until rising_edge(tb_i_clk);
        theoretical_output <= "0100";

        wait until falling_edge(tb_i_clk);
        tb_i_rst <= '1';
        theoretical_output <= (others => '0');

        wait until falling_edge(tb_i_clk);
        tb_i_rst <= '0';

        wait until rising_edge(tb_i_clk);
        theoretical_output <= "0001";

        tb_fin <= '1';
        wait;
    end process;
end architecture rtl;
