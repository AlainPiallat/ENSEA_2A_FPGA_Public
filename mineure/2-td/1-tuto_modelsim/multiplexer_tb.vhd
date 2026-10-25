library ieee;
use ieee.std_logic_1164.all;

entity multiplexer_tb is
end entity multiplexer_tb;

architecture tb of multiplexer_tb is
    constant BUS_WIDTH : positive := 2;

    signal tb_data_in0 : std_logic_vector(BUS_WIDTH-1 downto 0);
    signal tb_data_in1 : std_logic_vector(BUS_WIDTH-1 downto 0);

    signal tb_sel : std_logic;

    signal tb_data_out : std_logic_vector(BUS_WIDTH-1 downto 0);
    signal theoretical_out : std_logic_vector(BUS_WIDTH-1 downto 0);
begin
    uut : entity work.multiplexer
        generic map (
            BUS_WIDTH => BUS_WIDTH
        )
        port map (
            in0 => tb_data_in0,
            in1 => tb_data_in1,

            sel => tb_sel,

            data_out => tb_data_out
        );

    process
    begin
        tb_data_in0 <= "00";
        theoretical_out <= "UU";
        wait for 10 ns;
        tb_data_in1 <= "01";
        wait for 10 ns;
        tb_sel <= '0';
        theoretical_out <= "00";    
        wait for 10 ns;
        tb_sel <= '1';
        theoretical_out <= "01";
        wait for 10 ns;
        tb_data_in1 <= "11";
        theoretical_out <= "11";
        wait for 10 ns;
        tb_sel <= '0';
        theoretical_out <= "01";
        wait for 10 ns;
        tb_data_in0 <= "10";
        theoretical_out <= "10";
        wait for 10 ns;
        tb_data_in0 <= "UU";
        theoretical_out <= "UU";
        wait for 10 ns;
        tb_sel <= '1';
        theoretical_out <= "11";
        wait for 10 ns;
        tb_sel <= 'U';
        theoretical_out <= "UU";
        wait for 10 ns;
        wait;
    end process;
end architecture tb;