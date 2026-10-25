library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alu_tb is
end entity alu_tb;

architecture rtl of alu_tb is
    constant BUS_WIDTH : positive := 8;

    signal tb_data_in0 : signed(BUS_WIDTH - 1 downto 0);
    signal tb_data_in1 : signed(BUS_WIDTH - 1 downto 0);
    
    signal tb_sel : std_logic_vector(2 downto 0);
    
    signal tb_data_out : signed(BUS_WIDTH - 1 downto 0);
    signal theoretical_out : signed(BUS_WIDTH - 1 downto 0);
begin
    uut : entity work.alu
        generic map (
            BUS_WIDTH => BUS_WIDTH
        )
        port map (
            data_in0 => tb_data_in0,
            data_in1 => tb_data_in1,

            sel => tb_sel,

            data_out => tb_data_out
        );
    
    process
    begin
        tb_data_in0 <= to_signed(9, 8);
        tb_data_in1 <= to_signed(3, 8);
        tb_sel <= "UUU";
        theoretical_out <= (others => 'U');
        wait for 10 ns;

        tb_sel <= "000"; -- Addition
        theoretical_out <= to_signed(12, 8);
        wait for 10 ns;

        tb_sel <= "001"; -- Subtraction
        theoretical_out <= to_signed(6, 8);
        wait for 10 ns;

        tb_sel <= "010"; -- Multiplication
        theoretical_out <= to_signed(27, 8);
        wait for 10 ns;

        tb_sel <= "011"; -- Division
        theoretical_out <= to_signed(3, 8);
        wait for 10 ns;

        tb_sel <= "100"; -- OR
        theoretical_out <= to_signed(11, 8);
        wait for 10 ns;

        tb_sel <= "101"; -- AND
        theoretical_out <= to_signed(1, 8);
        wait for 10 ns;

        tb_sel <= "110"; -- XOR
        theoretical_out <= to_signed(10, 8);
        wait for 10 ns;

        tb_sel <= "111"; -- NOT
        theoretical_out <= to_signed(-10, 8);
        wait for 10 ns;
        wait;
    end process;
end architecture rtl;