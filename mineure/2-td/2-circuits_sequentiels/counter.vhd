library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity counter is
    generic (
        N: integer
    );
    port (
        i_rst: in std_logic;
        
        i_clk: in std_logic;
        i_en: in std_logic;
        
        o_count: out std_logic_vector(N-1 downto 0)
    );
end entity counter;

architecture rtl of counter is
    signal r_count: std_logic_vector(N-1 downto 0) := (others => '0');

    signal s_next: std_logic_vector(N-1 downto 0);
    signal s_carry: std_logic_vector(N-1 downto 0);
begin
    s_carry(0) <= i_en;
    s_carry(N-1 downto 1) <= r_count(N-2 downto 0) AND s_carry(N-2 downto 0);
    
    process(i_clk, i_rst)
    begin
        if i_rst = '1' then
            r_count <= (others => '0');
        else
            if rising_edge(i_clk) then
                -- On utilise le carry 0 pour incrémenter le compteur (selon la valeur de i_en)
                
                r_count(N-1 downto 0) <= r_count(N-1 downto 0) XOR s_carry(N-1 downto 0);
            end if;
        end if;
    end process;

    o_count <= r_count;
end architecture rtl;