library ieee;
use IEEE.std_logic_1164.all;

entity fifo_tb is
end entity fifo_tb;

architecture rtl of fifo_tb is
    signal tb_i_clk: std_logic;
    signal tb_i_en: std_logic;
    signal tb_i_d: std_logic;
    signal tb_i_rst: std_logic;
    signal tb_o_q: std_logic;

    signal theoretical_output: std_logic;

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

    uut: entity work.fifo
        port map (
            fifo_i_clk => tb_i_clk,
            fifo_i_en => tb_i_en,
            fifo_i_d => tb_i_d,
            fifo_i_rst => tb_i_rst,
            fifo_o_q => tb_o_q
        );
        
    process
    begin  
        tb_i_en <= '0';
        tb_i_d <= '0';
        tb_i_rst <= '0';
        theoretical_output <= '0';

        wait until falling_edge(tb_i_clk);

        tb_i_d <= '1';

        wait until falling_edge(tb_i_clk);

        tb_i_en <= '1';

        wait until falling_edge(tb_i_clk);

        tb_i_d <= '0';

        wait until falling_edge(tb_i_clk);

        tb_i_d <= '1';

        wait until falling_edge(tb_i_clk);

        tb_i_d <= '0';

        -- Comme on la file est de profondeur 4, et que l'on a mis 4 cycles à mettre des bits dans la file, il n'y a pas besoin d'attendre un cycle de plus pour que le premier bit sorte de la file. 
        wait until rising_edge(tb_i_clk);
        theoretical_output <= '1';

        wait until rising_edge(tb_i_clk);
        theoretical_output <= '0';

        wait until rising_edge(tb_i_clk);
        theoretical_output <= '1';

        wait until rising_edge(tb_i_clk);
        theoretical_output <= '0';


        wait for 10 ns;
        tb_fin <= '1';
        wait;
    end process;
end architecture rtl;