library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fifo is
    generic (
        FIFO_DEPTH: integer := 4
    );
    port (
        fifo_i_clk: in std_logic;
        fifo_i_en: in std_logic;
        fifo_i_d: in std_logic;
        fifo_i_rst: in std_logic;
        fifo_o_q: out std_logic
    );
end entity fifo;

architecture rtl of fifo is
    signal fifo_r_q: std_logic_vector(FIFO_DEPTH downto 0);
begin
    fifo_r_q(0) <= fifo_i_d;

    gen_dff: for i in 0 to FIFO_DEPTH-1 generate
        dff_i: entity work.dff
            port map (
                i_clk => fifo_i_clk,
                i_en => fifo_i_en,
                i_d => fifo_r_q(i),
                i_rst => fifo_i_rst,
                o_q => fifo_r_q(i + 1)
            );
    end generate gen_dff;

    fifo_o_q <= fifo_r_q(FIFO_DEPTH);
end architecture rtl;