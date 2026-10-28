library ieee;
use IEEE.std_logic_1164.all;

entity dff_tb is
end entity dff_tb;

architecture rtl of dff_tb is
    signal tb_i_clk: std_logic;
    signal tb_i_en: std_logic;
    signal tb_i_d: std_logic;
    signal tb_i_rst: std_logic;
    signal tb_o_q: std_logic;

    signal theoretical_q: std_logic;

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

    uut: entity work.dff
        port map (
            i_clk => tb_i_clk,
            i_en => tb_i_en,
            i_d => tb_i_d,
            i_rst => tb_i_rst,
            o_q => tb_o_q
        );
        
    process
    begin  
        tb_i_en <= '0';
        tb_i_d <= '0';
        tb_i_rst <= '0';
        theoretical_q <= '0';

        wait until falling_edge(tb_i_clk);

        tb_i_d <= '1';

        wait until falling_edge(tb_i_clk);

        tb_i_en <= '1';

        wait until rising_edge(tb_i_clk);
        theoretical_q <= tb_i_d;

        wait until falling_edge(tb_i_clk);

        tb_i_d <= '0';

        wait until rising_edge(tb_i_clk);
        theoretical_q <= tb_i_d;

        wait until falling_edge(tb_i_clk);

        tb_i_d <= '1';

        wait until rising_edge(tb_i_clk);
        theoretical_q <= tb_i_d;

        wait until falling_edge(tb_i_clk);

        tb_i_d <= '0';

        wait until rising_edge(tb_i_clk);
        theoretical_q <= tb_i_d;

        wait for 50 ns;
        tb_fin <= '1';
        wait;
    end process;
end architecture rtl;