library ieee;
use IEEE.std_logic_1164.all;

entity multiplexer is
    generic (
        BUS_WIDTH : positive := 8
    );
    port (
        in0 : in std_logic_vector(BUS_WIDTH-1 downto 0);
        in1 : in std_logic_vector(BUS_WIDTH-1 downto 0);

        sel : in std_logic;
        
        data_out : out std_logic_vector(BUS_WIDTH-1 downto 0)
    );
end entity multiplexer;

architecture rtl of multiplexer is
    
begin
    data_out <= in0 when sel = '0' else
                in1 when sel = '1' else 
                (others => 'U');
end architecture rtl;
